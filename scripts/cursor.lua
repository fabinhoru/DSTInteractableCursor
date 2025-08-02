local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ACTIONS = _G.STRINGS.ACTIONS	

local CursorCharacters = require "cursorcharacters" -- stores character values now. mostly useless, now that cursor offsets are gone for good
local CursorHandler = require "cursorhandler" -- serves as the handler for main functions, such as following, and cosmetic changes
local CursorEffects = require "cursoreffects" -- self explanatory. stores most effect functions inside itself
local CursorShadow = require "cursorshadow"
local CursorInput = require "cursorinput"

local Cursor = Class(UIAnim, function(self)
	UIAnim._ctor(self, "cursor")
	
	self.cfg = self:LoadDefaultConfigs()
	self.state = {
		_normal = true,
		_clickable = false,
		_drop = false,
		_examine = false,
		_attack = false,
	}
	self.current_action = nil -- current action's in here now, because it makes more sense to me
	
	self:SetClickable(false)
	
	self.characters = CursorCharacters
	self.input = CursorInput(self) -- cursor gets passed onto the class, so every function inherits it, which means i can access it without passing it everywhere!
	self.handler = CursorHandler(self)
	self.effects = CursorEffects(self)
	self.shadow = self:AddChild(CursorShadow(self))
	if self.shadow then self.shadow:MoveToBack() end
	
	self.fx = nil
	self.fx_click = nil
	
	self.handler:Init()
	self.inst:StartWallUpdatingComponent(self)
end)

function Cursor:CanUpdate()
	return (ThePlayer and ThePlayer:IsValid() and InGamePlay() and ThePlayer.components and ThePlayer.components.playercontroller)
end

function Cursor:LoadDefaultConfigs()
	local getcfg = function(cfg)
		return GetModConfigData(cfg, KnownModIndex:GetModActualName("Interactable Cursor"))
	end
		
	local cfg = { -- moved these in here now. now they're part of cursor itself. good? bad? i'm the guy with THE BRAIN DAMAGE ARGHHH!!!
		-- LOGIC
		character_cursor = getcfg("cursorcharacterdepend"),
		character_effects = getcfg("cursorcharactereffects"),
		inv_states = getcfg("invstates"), -- for clickable inv items
		rmb_states = getcfg("rmbstates"), -- for actions like "telepoof", "teleport", "row", etc.

		-- TEXTURE HANDLING
		cursor_build = "cursor",
		cursor_bank = getcfg("cursortexture"),  -- e.g., "curly", "wx", "syswhite", etc. i'm not listing them all after this update, fuck you. EDIT: counts as the bank index!!!
		cursor_scl = getcfg("cursorscale"),   -- "_32", "_48", "_64"
		cursor_lefty = getcfg("cursorleft"),
		default_action = "_normal", -- changed to "default_action". "current_action" is now a local in DoPeriodicTask. just here so cursor gets properly assigned at startup

		-- PURELY COSMETIC
		cursor_scl_mult = getcfg("cursorscalemult"),

		animated_cursor = getcfg("cursoranimated"),
		clicky_cursor = getcfg("cursorclicky"),
		clicky_cursor_volume = getcfg("cursorclickvolume"),
		clicky_cursor_soft = getcfg("cursorclicksoft"),

		cc_affected = getcfg("cursorccaffected"), -- on/off for cursor colo(u)r cubes
		cc_default = "shaders/none.ksh", -- default color cube/fallback. doesn't actually exist but doesn't make the game crash, so i assuuuume it's okay?
		cc = resolvefilepath"shaders/ui_anim_cc_noamb.ksh", -- modified ui_anim_cc.ksh to clamp ambientlight values to at least 50% brightness. otherwise, becomes pitch black

		cursor_wobbly = getcfg("cursorwobbly"),
		cursor_shadow = getcfg("cursorshadow"),
		
		debug = getcfg("cursordebugmode"),
		options_panel = getcfg("cursoroptionspanel")
	}
	
	cfg.last_action = cfg.default_action
	cfg.last_bank = cfg.cursor_bank
	cfg.last_cc = cfg.cc_default
	
	cfg.base_bank = cfg.cursor_bank -- here for when checking wether the player's in characer selection screen with characer cursors
	cfg.base_action = cfg.default_action
	
	cfg.cursor_anim = (cfg.cursor_bank and cfg.cursor_scl) and (cfg.cursor_bank .. cfg.cursor_scl) or "curly_32" -- if cursor texture and scale is real, then set it to the combination of those two, otherwise, "curly_32"
	
	return cfg
end

function Cursor:OnWallUpdate()
	local cfg = self.cfg
	local ch = self.handler
	local effects = self.effects
	if not self:CanUpdate() then 
		if cfg.cursor_bank ~= cfg.base_bank then
			cfg.last_bank, cfg.cursor_bank = cfg.base_bank, cfg.base_bank
			ch:SetCursorStyle(cfg.cursor_bank, cfg.cursor_scl)
			ch:ChangeCursorState(cfg.base_action, self.state)
			if effects.fx_maps[cfg.cursor_bank] then effects:InitEffect() end
		end
		return 	
	end
	
	self.current_action = ch:GetCurrentAction(cfg, ACTIONS) -- this now handles states

	if cfg.cc_affected then
		if not cfg.cc_set then
			ch:SetShader(cfg.cc_current, cfg.cc_affected, cfg)
			cfg.cc_set = true
		end
		local pos = TheInput:GetWorldPosition()
		self:GetAnimState():SetWorldSpaceAmbientLightPos(pos.x, pos.y, pos.z) -- hey, this wasn't as hard as i was thinkin!
	end

	if cfg.character_cursor then
		local new_cursor_bank, new_cursor_anim, new_current_cursor = ch:GetPlayerStyle()
		if new_cursor_bank ~= cfg.last_bank then
			print("[INTERACTABLE CURSOR] changing cursor bank to:", new_cursor_bank, new_cursor_anim)
			cfg.last_bank = new_cursor_bank
			cfg.cursor_bank = new_cursor_bank
			cfg.cursor_anim = new_cursor_anim
			cfg.current_cursor = new_current_cursor
			if effects.fx_maps[new_cursor_bank] then effects:InitEffect() end -- registers new states if the cursor has one
			ch:SetCursorStyle(new_cursor_bank, cfg.cursor_scl)
		end

		if not cfg.cc_affected then -- might as well make them tied to actual characters. when you die, your cursor also does!
			ch:SetDeadTint(cfg.cc_current, cfg)
		end
		
		if cfg.character_effects then
			effects:PlayEffect()
		end
	end

	if self.current_action ~= cfg.default_action then
		ch:ChangeCursorState(self.current_action, self.state)
		cfg.default_action = self.current_action
	end
end

return Cursor