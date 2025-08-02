local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local CursorEffects = Class(function(self, cursor) 
	self.cursor = cursor
	
	self.current_loop = nil
	self.current_init = nil
	self.current_click = nil
	
	self.last_init = nil
	
	self.dirty = false
	
	self.baseGetAction = cursor.handler.GetCurrentAction
	
	self.fx_maps =	{
		wagstaff = "projector",
		wormwood = "blooming",
		woodie = "werecurses",
		wx = "sparking",
		walter = "boyscout",
		wixie = "delinquent",
		willow = "pyrocaster",
		maxwell = "shadowcaster",
		winona = "engineer",

		wormwood_click = "blooming_click",
		woodie_click = "werecurses_click",
		willow_click = "cast_click",
		maxwell_click = "cast_click",
		winona_click = "cast_click",
		wendy_click = "cast_click",
		wigfrid_click = "cast_click"
	}
end)

-- HELPERS

local randomFloat = function(min, max) 
	return math.random() * (max - min) + min
end

local function IsPlayerValid()
	return ThePlayer and ThePlayer:IsValid()
end

function CursorEffects:updateFXCC(fx) 
	if not self.cursor:CanUpdate() then return end 
	local pos = _G.TheInput:GetWorldPosition() or Vector3(0,0,0) 
	local anim = fx:GetAnimState() 
	local cfg  = self.cursor.cfg 
	anim:UseColourCube(cfg.cc_affected) 
	anim:SetDefaultEffectHandle(cfg.cc_affected and cfg.cc or cfg.cc_default) 
	anim:SetWorldSpaceAmbientLightPos(pos.x, pos.y, pos.z) 
end

function CursorEffects:createFX(parent, name, bank, build, move_to_front)
    local fx = parent:AddChild(UIAnim(name))
    fx:SetClickable(false)
    if move_to_front then fx:MoveToFront() else fx:MoveToBack() end
    local anim = fx:GetAnimState()
    anim:SetBank(bank)
    anim:SetBuild(build)
    return fx
end

function CursorEffects:killFX(fx_index)
    local fx = self.cursor[fx_index]
    if fx then fx:Kill() ; fx = nil end
end

function CursorEffects:expireFX(fx_index, time_to_expire)
	local fx = self.cursor[fx_index]
	if fx.expiretask then fx.expiretask:Cancel() ; fx.expiretask = nil end
	fx.expiretask = fx.inst:DoTaskInTime(time_to_expire, function() self:killFX(fx_index) end)
end

function CursorEffects:playLoopFX(fx_index, interval, fn, ...)
    local fx = self.cursor[fx_index]
    local t  = _G.GetTime()
    fx.timer = fx.timer or (t + interval)
    if t >= fx.timer then
        fn(self, self.cursor, ...)
        fx.timer = t + interval
        self:expireFX(fx_index, interval * 4)
    end
end

function CursorEffects:playClickFX(fx_index, fn, ...)
    fn(self, self.cursor, ...)
    self:expireFX(fx_index, 0.3)
end

function CursorEffects:clean()
	if not self.dirty then return end
	local anim = self.cursor:GetAnimState()
	anim:SetErosionParams(0, 0, 0)
	anim:SetBrightness(1)
	anim:SetSaturation(1)

	self.cursor.handler.GetCurrentAction = self.baseGetAction

	self.current_init, self.last_init = self.current_init or {}, self.last_init or {}
	self.current_init.RanInit, self.current_init = false, nil
	self.last_init.RanInit, self.last_init = false, nil

	self:killFX("fx")
	self.dirty = false
end

-- EFFECT "LOOP" FUNCTIONS

CursorEffects.projector = {
	fn_update = function(self, cursor) 
		if not IsPlayerValid() then return end
		local intensity
		local anim = cursor:GetAnimState()

		intensity = -.2 * randomFloat(0.9, 1.05)
		anim:SetErosionParams(.07, _G.GetTime(), intensity)
		anim:SetBrightness(randomFloat(0.975, 1.05))
		
		local health = ThePlayer.replica.health
		
		local current = health:GetCurrent() or 100
		local max = health:Max() or 100
		local percent = current / max
		local saturation = math.max(0.25, percent)
		anim:SetSaturation(saturation)
		
		self.dirty = true
	end
}

CursorEffects.blooming = {
	fn_update = function(self, cursor)
		if not IsPlayerValid() then return end
		local build = ThePlayer.AnimState and ThePlayer.AnimState:GetBuild()
		
		cursor.fx = cursor.fx or self:createFX(cursor, "blooming_fx", "cursor_wormwood_fx", "cursor_wormwood_fx_leaves", false)
		self:playLoopFX("fx", randomFloat(2.5, 6.5), function(self, cursor, build)
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
			
			self:updateFXCC(cursor.fx)
		end, build)
		
		self.dirty = true
	end
}

CursorEffects.sparking = {
	fn_update = function(self, cursor)
		if not IsPlayerValid() then return end
		local moisture = ThePlayer:GetMoisture()
		local t = _G.GetTime()
		
		cursor.fx = cursor.fx or self:createFX(cursor, "sparking_fx", "sparks", "sparks", true)
		if moisture >= 15 then
			self:playLoopFX("fx", 1, function(self, cursor)
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
			end)
		end
		
		self.dirty = true
	end
}

-- EFFECT "INIT" FUNCTIONS

CursorEffects.werecurses = {
	InitOnce = true, -- only run once, then "dirty" the cursor
	fn_state = function(self, cursor)
		cursor.state._beaver = false -- adding in states for woodie's wereforms
		cursor.state._goose = false
		cursor.state._moose = false
		cursor.handler:ChangeCursorState(cursor.cfg.base_action, cursor.state) 
	end,
	fn_init = function(self, cursor) -- ABSOLUTE THINGAMABOB
		local OldGetCurrentAction = self.baseGetAction
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS) -- wrapping the function to add extra checks
			local wereform = cfg.cursor_bank == "woodie" and ThePlayer and ThePlayer.prefab == "woodie" and (
				ThePlayer:HasTag("beaver") and "_beaver" or
				ThePlayer:HasTag("weregoose") and "_goose" or
				ThePlayer:HasTag("weremoose") and "_moose"
			) or nil
			if wereform then return wereform end
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		
		self.dirty = true
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
CursorEffects.boyscout = {
	InitOnce = true,
	fn_state = function(self, cursor) -- runs once. technically not a "state"
		if not uncompromising then return end
		
		cursor.characters.walter = "walter_alt" -- he got his slingshot stolen. haha, idiot!
		
		self.dirty = true
	end
}

CursorEffects.delinquent = {
	InitOnce = true,
	fn_state = function(self, cursor)
		cursor.state._taunt = false
		cursor.handler:ChangeCursorState(cursor.cfg.base_action, cursor.state) 
	end,
	fn_init = function(self, cursor) -- runs once
		local OldGetCurrentAction = self.baseGetAction
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == "WIXIE_TAUNT" then return "_taunt" end -- this took me way too long to figure out
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		
		self.dirty = true
	end
}

CursorEffects.pyrocaster = {
	InitOnce = true,
	fn_init = function(self, cursor)
		local OldGetCurrentAction = self.baseGetAction
		local scale = {_32 = .333, _48 = .5, _64 = .667, _80 = .833, _96 = 1}
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == STRINGS.ACTIONS.CASTAOE then -- i believe having a unique widget behind the "clickable" hand is the best way to go about this here
				cursor.fx = cursor.fx or cursor.effects:createFX(cursor, "willow_fire", "cursor_willow_fx", "cursor_willow_fx_fire", false)
				if not cursor.fx:GetAnimState():IsCurrentAnimation("fx_fire") then 
					cursor.fx:GetAnimState():PlayAnimation("fx_fire", true) 
					cursor.fx:SetScale(scale[cursor.cfg.cursor_scl] or 1)
					cursor.fx.inst:DoPeriodicTask(FRAMES, function()
						cursor.effects:updateFXCC(cursor.fx)
					end)
				end
				return "_clickable" -- don't need a new state for this
			else
				cursor.effects:killFX("fx")
			end
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		
		self.dirty = true
	end
}

CursorEffects.shadowcaster = {
	InitOnce = true,
	fn_init = function(self, cursor)
		local OldGetCurrentAction = self.baseGetAction
		local scale = {_32 = .333, _48 = .5, _64 = .667, _80 = .833, _96 = 1}
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == STRINGS.ACTIONS.CASTAOE then
				cursor.fx = cursor.fx or cursor.effects:createFX(cursor, "maxwell_shadow_fire", "cursor_willow_fx", "cursor_willow_fx_fire", false)
				if not cursor.fx:GetAnimState():IsCurrentAnimation("fx_fire") then -- hurgh, i'm gonna throw up...
					cursor.fx:GetAnimState():PlayAnimation("fx_fire", true) 
					cursor.fx:GetAnimState():OverrideMultColour(0, 0, 0, 0.5)
					cursor.fx:GetAnimState():UsePointFiltering(false)
					cursor.fx:SetScale(scale[cursor.cfg.cursor_scl] or 1)
					cursor.effects:updateFXCC(cursor.fx)
				end
				return "_clickable"
			elseif cursor.fx then 
				cursor.effects:killFX("fx")
			end
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		
		self.dirty = true
	end
}

CursorEffects.engineer = {
	InitOnce = true,
	fn_state = function(self, cursor)
		cursor.state._cast = false
		cursor.handler:ChangeCursorState(cursor.cfg.base_action, cursor.state) 
	end,
	fn_init = function(self, cursor)
		local OldGetCurrentAction = self.baseGetAction
		cursor.handler.GetCurrentAction = function(self, cfg, ACTIONS)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == STRINGS.ACTIONS.CASTAOE then return "_cast" end
			return OldGetCurrentAction(self, cfg, ACTIONS)
		end
		
		self.dirty = true
	end
}

-- ON CLICK EFFECTS

CursorEffects.blooming_click = {
	fn_click = function(self, cursor)
		self:playClickFX("fx_click", function(self, cursor)
			self:killFX("fx_click")
			cursor.fx_click = self:createFX(_G.TheFrontEnd.overlayroot, "blooming_fx_click", "cursor_wormwood_fx", "cursor_wormwood_fx_leaves", false)
			cursor.fx_click:SetPosition(cursor:GetPosition())
			cursor.fx_click:SetRotation(math.random(-180, 180))
			cursor.fx_click:GetAnimState():PlayAnimation("fx_click" .. math.random(1, 2), false)
			if math.random(0, 1) > 0 then cursor.fx_click:SetScale(math.random(0, 1) * 2 - 1, math.random(0, 1) * 2 - 1, 1) end
			
			self:updateFXCC(cursor.fx_click)
		end)
	end
}

CursorEffects.werecurses_click = {
	fn_click = function(self, cursor)
		local wereform = cursor.cfg.cursor_bank == "woodie" and ThePlayer and ThePlayer.prefab == "woodie" and (
			ThePlayer:HasTag("beaver") and "_beaver" or
			ThePlayer:HasTag("weregoose") and "_goose" or
			ThePlayer:HasTag("weremoose") and "_moose"
		) or nil
		
		self:playClickFX("fx_click", function(self, cursor)
			self:killFX("fx_click")
			cursor.fx_click = self:createFX(_G.TheFrontEnd.overlayroot, "werecurses_fx_click", "impact", "impact", false)
			if wereform then
				cursor.fx_click:SetPosition(cursor:GetPosition())
				cursor.fx_click:SetScale(0.1)
				cursor.fx_click:SetRotation(math.random(-85, -95))
				cursor.fx_click:GetAnimState():PlayAnimation("idle", false) -- you're clicking REALLY hard
			end
		end)
	end
}

CursorEffects.cast_click = {
	fn_click = function(self, cursor)
		self:playClickFX("fx_click", function(self, cursor)
			self:killFX("fx_click")
			cursor.fx_click = self:createFX(_G.TheFrontEnd.overlayroot, "cast_fx_click", "elec_immune_fx", "elec_immune_fx", false)
			local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()
			if rmb and rmb.action.str == STRINGS.ACTIONS.CASTAOE then 
				cursor.fx_click:SetPosition(cursor:GetPosition())
				cursor.fx_click:SetScale(0.35)
				cursor.fx_click:SetRotation(math.random(-180, 180))
				cursor.fx_click:GetAnimState():PlayAnimation("sparks_" .. math.random(1, 3) , false) -- you're clicking REALLY hard
			end
		end)
	end
}

function CursorEffects:InitEffect()
	self:clean()
	local key = self.fx_maps[self.cursor.cfg.cursor_bank]
	local effect = key and self[key] or { fn_state = function(self) self:clean() end }

	self.current_init = effect
	if effect.InitOnce and not effect.RanInit then
		self.last_init = self.current_init
		if effect.fn_state then effect.fn_state(self, self.cursor) end
		if self.cursor.cfg.character_effects and effect.fn_init then
			effect.fn_init(self, self.cursor)
		end
		effect.RanInit = true
	end
end

function CursorEffects:PlayEffect()
	local key = self.fx_maps[self.cursor.cfg.cursor_bank]
	local effect = key and self[key] or { fn_update = function() self:clean() end }
	self.current_loop = effect
	if effect.fn_update then effect.fn_update(self, self.cursor) end
end

function CursorEffects:PlayClickEffect()
	local key = self.fx_maps[self.cursor.cfg.cursor_bank.."_click"]
	local effect = key and self[key] or { fn_click = function(self) return true end }
	self.current_click = effect
	if effect and effect.fn_click then effect.fn_click(self, self.cursor) end
end

return CursorEffects