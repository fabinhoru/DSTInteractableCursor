local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local CursorEffects = Class(function(self, cursor) 
	self.cursor = cursor
	
	self.CurrentEffect = nil
	self.CurrentClickEffect = nil
	self.Dirty = false
	
	self.GetCurrentActionBase = cursor.handler.GetCurrentAction
end)

-- HELPERS

local randomfloat = function(min, max) 
	return math.random() * (max - min) + min
end

local function IsPlayerValid()
	return ThePlayer and ThePlayer:IsValid()
end

local function UpdateFXCC(cursor, fx)
	if not CursorCanUpdate() then return end
	local pos = TheInput:GetWorldPosition() or Vector3(0, 0, 0)
	fx:GetAnimState():UseColourCube(cursor.cfg.cc_affected)
	fx:GetAnimState():SetDefaultEffectHandle(cursor.cfg.cc_affected and cursor.cfg.cc or cursor.cfg.cc_default)
	fx:GetAnimState():SetWorldSpaceAmbientLightPos(pos.x, pos.y, pos.z)
end

local function CreateFX(parent, fx_name, bank, build, move_to_front)
	local fx = parent:AddChild(UIAnim(fx_name))
	fx:SetClickable(false)
	if move_to_front then fx:MoveToFront() else fx:MoveToBack() end
	local anim = fx:GetAnimState()
	anim:SetBank(bank)
	anim:SetBuild(build)
	return fx
end

local function KillFX(cursor, fx_index)
	if cursor[fx_index] then
		cursor[fx_index]:Kill()
		cursor[fx_index] = nil
	end
end

local function ExpireFX(cursor, fx_index, time_to_expire)
	cursor[fx_index].expiretask = cursor[fx_index].inst:DoTaskInTime(time_to_expire, function()
		KillFX(cursor, fx_index)
	end)
end

local function PlayFX(cursor, fx_index, interval, fx_fn, ...)
	if not cursor[fx_index] then return end
	local time = GetTime()
	cursor[fx_index].timer = cursor[fx_index].timer or (time + interval)
	if time >= cursor[fx_index].timer then
		fx_fn(cursor, ...)
		cursor[fx_index].timer = time + interval
		cursor[fx_index].expiretask = ExpireFX(cursor, fx_index, interval * 2)
	end
end

local function PlayClickFX(cursor, fx_index, fx_fn, ...)
	fx_fn(cursor, ...)
	cursor.fx_click.expiretask = ExpireFX(cursor, fx_index, 0.3)
end

CursorEffects["clean"] = {
	fn_update = function(cursor)
		if not CursorEffects.Dirty then return end
		local anim = cursor:GetAnimState()
		
		anim:SetErosionParams(0, 0, 0)
		anim:SetBrightness(1)
		anim:SetSaturation(1)
		CursorEffects.CurrentEffect.RanInit = false
		cursor.handler.GetCurrentAction = CursorEffects.GetCurrentActionBase
		
		if cursor.fx then
			cursor.fx:Kill()
			cursor.fx = nil
		end
		
		CursorEffects.Dirty = false
	end
}

-- EFFECT "LOOP" FUNCTIONS

CursorEffects["projector"] = {
	fn_update = function(cursor) 
		if not IsPlayerValid() then return end
		local intensity
		local anim = cursor:GetAnimState()

		intensity = -.2 * randomfloat(0.9, 1.05)
		anim:SetErosionParams(.07, GetTime(), intensity)
		anim:SetBrightness(randomfloat(0.975, 1.05))
		
		local health = ThePlayer.replica.health
		
		local current = health:GetCurrent() or 100
		local max = health:Max() or 100
		local percent = current / max
		local saturation = math.max(0.25, percent)
		anim:SetSaturation(saturation)
		
		CursorEffects.Dirty = true
	end
}

CursorEffects["blooming"] = {
	fn_update = function(cursor)
		if not IsPlayerValid() then return end
		local build = ThePlayer.AnimState and ThePlayer.AnimState:GetBuild()
		
		cursor.fx = cursor.fx or CreateFX(cursor, "blooming_fx", "cursor_wormwood_fx", "cursor_wormwood_fx_leaves", false)
		PlayFX(cursor, "fx", randomfloat(2.5, 6.5), function(cursor, build)
			local bloominess = (build:find("stage2") or build:find("stage_2")) and ("fx_bloom" .. math.random(1, 2))
				or (build:find("stage3") or build:find("stage_3")) and ("fx_bloom" .. math.random(3, 4))
				or (build:find("stage4") or build:find("stage_4")) and ("fx_bloom" .. math.random(5, 6))
				or nil
			
			local scale_offset = {_32 = 0, _48 = -8, _64 = -16, _80 = -24, _96 = -32} -- NOT CURSOR OFFSETS, NOT AGAIN. NOOOO!!!!
			local offset = scale_offset[cursor.cfg.cursor_scl] or 0
			if bloominess then cursor.fx:GetAnimState():PlayAnimation(bloominess, false) end
			cursor.fx:SetPosition(-offset, offset, 0)
			cursor.fx:SetScale(1 + (math.abs(offset) / 100))
			cursor.fx:MoveTo(Vector3(-offset, offset, 0), Vector3(-offset, offset - 20, 0) , 2, nil)
			
			UpdateFXCC(cursor, cursor.fx)
		end, build)
		
		CursorEffects.Dirty = true
	end
}

CursorEffects["sparking"] = {
	fn_update = function(cursor)
		if not IsPlayerValid() then return end
		local moisture = ThePlayer:GetMoisture()
		local time = GetTime()
		
		cursor.fx = cursor.fx or CreateFX(cursor, "sparking_fx", "sparks", "sparks", true)
		PlayFX(cursor, "fx", 1, function(cursor, moisture)
			if moisture >= 15 and time >= cursor.fx.timer then
				local scale_offset = {_32 = -8, _48 = -16, _64 = -24, _80 = -32, _96 = -40}
				local offset = scale_offset[cursor.cfg.cursor_scl] or 0
				cursor.fx:SetPosition(-offset, offset, 0)
				cursor.fx:SetScale(0.15 * (math.abs(offset) / 10))
				cursor.fx:GetAnimState():PlayAnimation("sparks_" .. math.random(1, 3), false)
				
				local i
				local function flash()
					i = i or 3
					if i > 1 then
						cursor:GetAnimState():SetBrightness(i)
						i = i - 0.2
						cursor.inst:DoTaskInTime(0, flash)
					else
						i = 0
						cursor:GetAnimState():SetBrightness(1)
						return
					end
				end
				flash()
			end
		end, moisture)
		
		CursorEffects.Dirty = true
	end
}

-- EFFECT "INIT" FUNCTIONS

CursorEffects["werecurses"] = {
	InitOnce = true, -- only run once, then "dirty" the cursor
	fn_init = function(cursor) -- ABSOLUTE THINGAMABOB
		cursor.state._beaver = false -- adding in states for woodie's wereforms
		cursor.state._goose = false
		cursor.state._moose = false
		
		local OldGetCurrentAction = cursor.handler.GetCurrentAction
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS) -- wrapping the function to add extra checks
			local wereform = cfg.cursor_bank == "woodie" and ThePlayer and ThePlayer.prefab == "woodie" and (
				ThePlayer:HasTag("beaver") and "_beaver" or
				ThePlayer:HasTag("weregoose") and "_goose" or
				ThePlayer:HasTag("weremoose") and "_moose"
			) or nil
			if wereform then return wereform end
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		cursor.handler:ChangeCursorState(cursor.cfg.base_action, cursor.state) 
		
		CursorEffects.Dirty = true
	end
}

local uncompromising = nil -- (KnownModIndex:IsModEnabled("workshop-2039181790") 
		-- or KnownModIndex:IsModEnabled(KnownModIndex:GetModActualName("󰀕 Uncompromising Mode")) 
		-- or KnownModIndex:IsModEnabled(KnownModIndex:GetModActualName("[LOCAL] - 󰀕 Uncompromising Mode"))
		-- )
for _, mod in ipairs(ModManager.mods) do 
	local modinfo = KnownModIndex:GetModInfo(mod.modname) 
	if modinfo and (modinfo.name:find("Uncompromising Mode") or modinfo.name:find("󰀕 Uncompromising")) then 
		uncompromising = true 
		break 
	end 
end 
CursorEffects["boyscout"] = {
	InitOnce = true,
	fn_init = function(cursor) -- runs once
		if not uncompromising then return end
		
		cursor.characters.walter = "walter_alt" -- he got his slingshot stolen. haha, idiot!
		
		CursorEffects.Dirty = true
	end
}

CursorEffects["delinquent"] = {
	InitOnce = true,
	fn_init = function(cursor) -- runs once
		cursor.state._taunt = false
		
		local OldGetCurrentAction = cursor.handler.GetCurrentAction
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == "WIXIE_TAUNT" then return "_taunt" end -- this took me way too long to figure out
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		cursor.handler:ChangeCursorState(cursor.cfg.base_action, cursor.state) 
		
		CursorEffects.Dirty = true
	end
}

CursorEffects["pyrocaster"] = {
	InitOnce = true,
	fn_init = function(cursor)
		local OldGetCurrentAction = cursor.handler.GetCurrentAction
		local scale = {_32 = .333, _48 = .5, _64 = .667, _80 = .833, _96 = 1}
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == STRINGS.ACTIONS.CASTAOE then -- i believe having a unique widget behind the "clickable" hand is the best way to go about this here
				cursor.fx = cursor.fx or CreateFX(cursor, "willow_fire", "cursor_willow_fx", "cursor_willow_fx_fire", false)
				if not cursor.fx:GetAnimState():IsCurrentAnimation("fx_fire") then 
					cursor.fx:GetAnimState():PlayAnimation("fx_fire", true) 
					cursor.fx:SetScale(scale[cursor.cfg.cursor_scl] or 1)
					cursor.fx.inst:DoPeriodicTask(FRAMES, function()
						UpdateFXCC(cursor, cursor.fx)
					end)
				end
				return "_clickable" -- don't need a new state for this
			elseif cursor.fx then 
				cursor.fx:Kill() 
				cursor.fx = nil 
			end
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		
		CursorEffects.Dirty = true
	end
}

CursorEffects["shadowcaster"] = {
	InitOnce = true,
	fn_init = function(cursor)
		local OldGetCurrentAction = cursor.handler.GetCurrentAction
		local scale = {_32 = .333, _48 = .5, _64 = .667, _80 = .833, _96 = 1}
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == STRINGS.ACTIONS.CASTAOE then
				cursor.fx = cursor.fx or CreateFX(cursor, "maxwell_shadow_fire", "cursor_willow_fx", "cursor_willow_fx_fire", false)
				if not cursor.fx:GetAnimState():IsCurrentAnimation("fx_fire") then -- hurgh, i'm gonna throw up...
					cursor.fx:GetAnimState():PlayAnimation("fx_fire", true) 
					cursor.fx:GetAnimState():OverrideMultColour(0, 0, 0, 0.5)
					cursor.fx:GetAnimState():UsePointFiltering(false)
					cursor.fx:SetScale(scale[cursor.cfg.cursor_scl] or 1)
					UpdateFXCC(cursor, cursor.fx)
				end
				return "_clickable"
			elseif cursor.fx then 
				cursor.fx:Kill() 
				cursor.fx = nil 
			end
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		
		CursorEffects.Dirty = true
	end
}

CursorEffects["engineer"] = {
	InitOnce = true,
	fn_init = function(cursor)
		cursor.state._cast = false
	
		local OldGetCurrentAction = cursor.handler.GetCurrentAction
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == STRINGS.ACTIONS.CASTAOE then return "_cast" end
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		cursor.handler:ChangeCursorState(cursor.cfg.base_action, cursor.state) 
		
		CursorEffects.Dirty = true
	end
}

-- ON CLICK EFFECTS

CursorEffects["blooming_click"] = {
	fn_click = function(cursor)
		PlayClickFX(cursor, "fx_click", function(cursor)
			KillFX(cursor, "fx_click")
			cursor.fx_click = CreateFX(TheFrontEnd.overlayroot, "blooming_fx_click", "cursor_wormwood_fx", "cursor_wormwood_fx_leaves", false)
			cursor.fx_click:SetPosition(cursor:GetPosition())
			cursor.fx_click:GetAnimState():PlayAnimation("fx_click" .. math.random(1, 2), false)
			if math.random(0, 1) > 0 then cursor.fx_click:SetScale(math.random(0, 1) * 2 - 1, math.random(0, 1) * 2 - 1, 1) end
			
			UpdateFXCC(cursor, cursor.fx_click)
		end)
	end
}

CursorEffects["werecurses_click"] = {
	fn_click = function(cursor)
		local wereform = cursor.cfg.cursor_bank == "woodie" and ThePlayer and ThePlayer.prefab == "woodie" and (
			ThePlayer:HasTag("beaver") and "_beaver" or
			ThePlayer:HasTag("weregoose") and "_goose" or
			ThePlayer:HasTag("weremoose") and "_moose"
		) or nil
		
		PlayClickFX(cursor, "fx_click", function(cursor)
			KillFX(cursor, "fx_click")
			cursor.fx_click = CreateFX(TheFrontEnd.overlayroot, "werecurses_fx_click", "impact", "impact", false)
			if wereform then
				cursor.fx_click:SetPosition(cursor:GetPosition())
				cursor.fx_click:SetScale(0.1)
				cursor.fx_click:SetRotation(-90)
				cursor.fx_click:GetAnimState():PlayAnimation("idle", false) -- you're clicking REALLY hard
			end
		end)
	end
}

CursorEffects.EffectMaps =	{
	wagstaff = CursorEffects["projector"],
	wormwood = CursorEffects["blooming"],
	woodie = CursorEffects["werecurses"],
	wx = CursorEffects["sparking"],
	walter = CursorEffects["boyscout"],
	wixie = CursorEffects["delinquent"],
	willow = CursorEffects["pyrocaster"],
	maxwell = CursorEffects["shadowcaster"],
	winona = CursorEffects["engineer"],

	wormwood_click = CursorEffects["blooming_click"],
	woodie_click = CursorEffects["werecurses_click"]
}

function CursorEffects:ApplyEffect()
	local cursor = self.cursor
	local fx = CursorEffects
	fx.CurrentEffect = fx.EffectMaps[cursor.cfg.cursor_bank] or fx["clean"]
	if fx.CurrentEffect.InitOnce and not fx.CurrentEffect.RanInit then
		fx.CurrentEffect.fn_init(cursor)
		fx.CurrentEffect.RanInit = true
	end
	if fx.CurrentEffect.fn_update then
		fx.CurrentEffect.fn_update(cursor)
	end
end

function CursorEffects:PlayClickEffect()
	local cursor = self.cursor
	local fx = CursorEffects
	fx.CurrentClickEffect = fx.EffectMaps[cursor.cfg.cursor_bank .. "_click"]
	if fx.CurrentClickEffect then
		fx.CurrentClickEffect.fn_click(cursor)
	end
end

return CursorEffects