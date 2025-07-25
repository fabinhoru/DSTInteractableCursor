local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local CursorHandler = Class(function(self, cursor)
	self.cursor = cursor
end)

-- [[ CORE FUNCTIONS 'N SHIT ]] --

function CursorHandler:CheckValidity() -- hope and pray to whatever god you worship that this thingamabob doesn't fucking explode because of a stack overflow
    return (LastUIRoot and LastUIRoot:IsValid()) and TheFrontEnd and TheFrontEnd.overlayroot and TheFrontEnd.overlayroot.inst and TheFrontEnd.overlayroot.inst:IsValid()
end

function CursorHandler:Init()
	local cursor, cfg, anim = self.cursor, self.cursor.cfg, self.cursor:GetAnimState()
    local use_pointfilter = cursor.cfg.cursor_scl_mult % 1 == 0
    local use_lefty_mode = cursor.cfg.cursor_lefty and cursor.cfg.cursor_scl_mult * -1 or cursor.cfg.cursor_scl_mult

    anim:AnimateWhilePaused(true)
	cursor:UpdateWhilePaused(true)

    anim:SetBank(cfg.cursor_bank)
    anim:SetBuild(cfg.cursor_build)
    anim:PlayAnimation(cfg.cursor_anim, true)
    cursor:SetScale(use_lefty_mode, cfg.cursor_scl_mult, cfg.cursor_scl_mult)
    cursor:SetClickable(false)

    anim:UseColourCube(true)
    anim:SetDefaultEffectHandle(cfg.cc_default) -- here so color cubes don't try and apply in the main menu, and also to reset it when coming from a game to main menu
    anim:UsePointFiltering(use_pointfilter) -- otherwise it looks blurry as shit when using anim banks. i spent hours looking for something like this, lol

	cursor.effects:ApplyEffect()
	cursor.input:FollowMouse2()
    cursor.input:MakeClicky()
    self:ChangeCursorState(cursor.cfg.default_action, cursor.state)
	TheInputProxy:SetCursorVisible(false) -- is this necessary?
	
	if cfg.debug then self:SetupDebug(cursor) end

    print("[INTERACTABLE CURSOR] INITIATING! \n\tcurrent cursor:\t" .. cursor.cfg.cursor_bank .. "\n\tanimation:\t" .. cursor.cfg.cursor_anim .. "\n\tshader:\t" .. cursor.cfg.cc_default)
end

function CursorHandler:GetCurrentAction(cfg, ACTIONS)
    if not ThePlayer or not ThePlayer:IsValid() then return "_normal" end

    local widget = TheFrontEnd:GetFocusWidget()
    local lmb = ThePlayer.components.playercontroller:GetLeftMouseAction()
    local rmb = ThePlayer.components.playercontroller:GetRightMouseAction()

    local active_item_r = TheWorld.ismastersim == false and ThePlayer and ThePlayer.replica and ThePlayer.replica.inventory and ThePlayer.replica.inventory.classified and ThePlayer.replica.inventory.classified:GetActiveItem() or nil -- for non-hosted worlds(?)
    local active_item = ThePlayer and ThePlayer.components and ThePlayer.components.inventory and ThePlayer.components.inventory:GetActiveItem() or nil -- for self-hosted worlds(?)
    local item_hover = cfg.inv_states and widget and widget.name == "Image" and widget.parent and widget.parent.name == "ItemTile" or nil

    if (active_item_r or active_item) then return "_drop" end
    if item_hover then return "_clickable" end
    if lmb then
        if lmb.action.str == ACTIONS.ATTACK then return "_attack"
        elseif lmb.action.str == ACTIONS.LOOKAT then return "_examine"
        elseif lmb.action.str ~= ACTIONS.DROP then return "_clickable"
        end
    end
    if cfg.rmb_states and rmb then
        return (rmb.action.str == ACTIONS.LOOKAT) and "_examine" or "_clickable"
    end
    return "_normal"
end

-- [[ PURELY COSMETIC FUNCTIONS ]] --

function CursorHandler:ChangeCursorState(current_action, state)
	local cursor, anim = self.cursor, self.cursor:GetAnimState()
	local shadow = cursor.shadow and cursor.shadow:GetAnimState()
    for _state, _ in pairs(state) do
        state[_state] = false
        anim:Hide(_state)
		if shadow then shadow:Hide(_state) end
    end

    state[current_action] = true
    anim:Show(current_action)
	if shadow then shadow:Show(current_action) end
end

function CursorHandler:GetPlayerStyle()
	local cursor, cfg = self.cursor, self.cursor.cfg
	
    local current_cursor = cfg.cursor_bank
    local prefab = ThePlayer and ThePlayer:IsValid() and ThePlayer.prefab
    
    if prefab then
        current_cursor = cursor.characters[prefab] or "curly"
        if not cursor.characters[prefab] then
            cursor.characters[prefab] = "curly"
            print("[INTERACTABLE CURSOR] ERROR!!! unknown prefab: " .. prefab .. ". using default cursor: 'curly'.")
        end
    else
        current_cursor = cfg.base_bank
    end

    local full_cursor = current_cursor .. cfg.cursor_scl
    return current_cursor, full_cursor, full_cursor .. cfg.default_action
end

function CursorHandler:SetCursorStyle(style, scale)
	local cursor, cfg = self.cursor, self.cursor.cfg
	
	cfg.cursor_bank = style
	cfg.cursor_scl = scale
	if cfg.cursor_shadow then
		cursor.shadow:GetAnimState():SetBankAndPlayAnimation(cfg.cursor_bank, cfg.cursor_bank..cfg.cursor_scl, true)
	end
	
	cursor:GetAnimState():SetBankAndPlayAnimation(cfg.cursor_bank, cfg.cursor_bank..cfg.cursor_scl, true)
end

local last_state = nil
function CursorHandler:SetDeadTint(cc_current, cfg)
	local cursor, anim = self.cursor, self.cursor:GetAnimState()
	local is_dead = ThePlayer and ThePlayer:IsValid() and (ThePlayer.components.health and ThePlayer.components.health:IsDead() or ThePlayer:HasTag("playerghost"))

    if is_dead ~= last_state then
        last_state = is_dead
        if is_dead then
            self:SetShader(cursor, cc_current, is_dead, cfg)
        end
    end
end

function CursorHandler:SetShader(cc_current, cc_affected, cfg)
	local cursor, anim = self.cursor, self.cursor:GetAnimState()
	local use_cc = (cc_current ~= cfg.cc and cfg.cc) or cfg.cc_default

    if cc_affected then
        print("[INTERACTABLE CURSOR] enabling cursor color cubes. changing to shader: " .. use_cc)
        anim:UseColourCube(true)
        anim:SetDefaultEffectHandle(use_cc)
    else
        print("[INTERACTABLE CURSOR] disabling color cubes. changing to shader: " .. use_cc)
        anim:UseColourCube(false)
        anim:SetDefaultEffectHandle(use_cc)
    end
end

-- [[ DEBUG ]] --
function CursorHandler:SetupDebug()
	local cursor = self.cursor
    local cursors = { -- +40 cursors holy fucking macaroni!!!!!!!!
--[[    "wx", "cat", "curly", "generic", "marble", "metheus", "skeleton", "syswhite", "sysblack",
		"webber", "wormwood", "wortox", "wurt", "woodie", "winona", "walter", "wendy", "wigfrid",
        "wolfgang", "warly", "wes", "wanda", "wickerbottom", "willow", "maxwell", "charlie",
		"queen", "assistant", "wathom", "alter", "mushroom", "winky", "woodlegs", "walani", "wilbur",
		"whimsy", "why", "weerclops", "wragonfly", "wearger", woose", "wirly", "wade", "wheeler",
		"wagstaff", "wilba",]]
    }
	local scales = { --[["_32", "_48", "_64", "_80", "_96"]] }
    local states = {}
	CursorHandler.DebugFunction = "print(TheFrontEnd:GetFocusWidget()) print(TheFrontEnd:GetFocusWidget().parent) print(TheFrontEnd:GetFocusWidget().parent.name)"

	local config, temp = KnownModIndex:GetModConfigurationOptions_Internal(KnownModIndex:GetModActualName("Interactable Cursor"), false) -- admitedly, i feel stupid for not looking at modutil.lua to learn that i could do this...
	if config and type(config) == "table" then 
		for k, v in pairs(config) do 
			if v.name == "cursortexture" then 
				for _, i in ipairs(v.options) do
					if i.data ~= 0 then table.insert(cursors, i.data) end
				end
			end 
			if v.name == "cursorscale" then 
				for _, i in ipairs(v.options) do
					if i.data then table.insert(scales, i.data) end
				end
			end 
		end 
	end 

    for k in pairs(cursor.state) do
        if k ~= "_beaver" and k ~= "_goose" and k ~= "_moose" then
            table.insert(states, k)
        end
    end

	local i, s, t  = 1, 1, 1
	TheInput:AddKeyHandler(function(key, down)
		if not down then return end -- only trigger on key press
		if key == KEY_KP_PLUS then
			-- iterates through cursor textures
			cursor.cfg.cursor_bank = cursors[i] or cursors[1]
			cursor.cfg.base_bank = cursors[i] or cursors[1]
			SetCursorStyle(cursor.cfg.cursor_bank, cursor.cfg.cursor_scl)
			if ThePlayer and ThePlayer.prefab then
				SetCursorCharacterOverride(ThePlayer.prefab, cursor.cfg.cursor_bank)
			end
			i = (i % #cursors) + 1 -- wrap around the cursor index
		elseif key == KEY_KP_MULTIPLY then
			-- iterates through cursor scales
			cursor.cfg.cursor_scl = scales[s] or scales[1]
			SetCursorStyle(cursor.cfg.cursor_bank, cursor.cfg.cursor_scl)
			s = (s % #scales) + 1 -- wrap around the scale index
		elseif key == KEY_KP_DIVIDE then
			-- iterates through cursor actions, a tad broken outside of the main menu
			local previous_action = cursor.cfg.current_action
			cursor.cfg.current_action = states[t] or previous_action
			cursor.cfg.base_action = states[t] or previous_action
			GetCursorHandlerFns().ChangeCursorState(GetCursor(), states[t], GetCursorState())
			if cursor.cfg.cursor_shadow then GetCursorHandlerFns().ChangeCursorState(GetCursor().shadow, states[t], GetCursorState()) end
			t = (t % #states) + 1 -- wrap around action index
		elseif key == KEY_J then
			-- change this to whatever you need
			TheNet:SendRemoteExecute(CursorHandler.DebugFunction)
			--TheNet:SendRemoteExecute("print(GetCursor())")
			--TheNet:SendRemoteExecute("print(ThePlayer)")
			--TheNet:SendRemoteExecute("print(TheFrontEnd:GetActiveScreen())")
        end
	end)	
	
	CursorHandler.SetDebugFunction = function(fn)
		print(tostring(fn))
		if type(fn) ~= "string" then print("This isn't a string, try again!") return end
		CursorHandler.DebugFunction = tostring(fn)
	end
end

return CursorHandler
