do
	local GLOBAL = GLOBAL
	local modEnv = GLOBAL.getfenv(1)
	local rawget, setmetatable = GLOBAL.rawget, GLOBAL.setmetatable
	setmetatable(modEnv, {
		__index = function(self, index)
			return rawget(GLOBAL, index)
		end
	})

	_G = GLOBAL
end

Assets = {
	Asset("SOUNDPACKAGE",	"sound/cursor_mod.fev"),
	Asset("SOUND",	"sound/cursor_mod.fsb"),

	Asset("ANIM",	"anim/cursor.zip"),
	
	Asset("ANIM",	"anim/cursor_wormwood_fx_leaves.zip"),
	Asset("ANIM",	"anim/cursor_willow_fx_fire.zip"),

	Asset("SHADER",	"shaders/ui_anim_cc_noamb.ksh"),
	--	look at that, clean assets! honestly thank god i don't have to do cursor offsets when using anims now. much, much better
}

local cursor_enabled = GetModConfigData("cursorbank") ~= 0
_G.cursor = nil
_G.TheInteractableCursor = { -- so i don't pollute GLOBAL
	Cursor = require "cursor",
	CursorCharacters = require "cursorcharacters", -- stores character values now. mostly useless, now that cursor offsets are gone for good
	CursorHandler = require "cursorhandler", -- serves as the handler for main functions, such as following, and cosmetic changes
	CursorEffects = require "cursoreffects", -- self explanatory. stores most effect functions inside itself
	CursorShadow = require "cursorshadow", -- recent addition, after i WENT MAD and decided to REWRITE the mod again!!! AHHAHAHA!!! literally just creates a shadow instance
	CursorInput = require "cursorinput" -- most recent one. just moved functions that mainly handle inputs here. cursorhandler is mostly just visual stuff now
}

local function TryCursorInit()
	_G.TheInputProxy:SetCursorVisible(true)
    local c = _G.TheInteractableCursor.CursorHandler:CheckValidity() and _G.TheFrontEnd.overlayroot:AddChild(TheInteractableCursor.Cursor())
    if c then 
		cursor = c 
		cursor:MoveToFront()
		if cursor.cfg.options_panel then modimport("scripts/cursoroptionspanel.lua") end
    else scheduler:ExecuteInTime(0.1, TryCursorInit) end
end

if cursor_enabled and not TheNet:IsDedicated() or not TheNet:GetServerIsDedicated() then
    scheduler:ExecuteInTime(0, TryCursorInit)
end

-- API(?) functions
_G.CursorCanUpdate = function()
	return (ThePlayer and ThePlayer:IsValid() and InGamePlay() and ThePlayer.components and ThePlayer.components.playercontroller)
end
_G.GetCursor = function() return cursor end
_G.GetCursorModConfig = function() return cursor.cfg end
_G.GetCursorCharacterConfig = function() return cursor.characters end
_G.GetCursorState = function() return cursor.state end
_G.GetCursorHandlerFns = function() return cursor.handler end
_G.GetCursorEffects = function() return cursor.effects end

_G.SetCursorStyle = function(style, scale)
	assert(type(style) == "string", "[INTERACTABLE CURSOR] style must be a string (e.g. \"wx\", 'curly\")")
    assert(type(scale) == "string" and scale:match("^_%d+$"), "[INTERACTABLE CURSOR] scale must be format \'_SCALE\'! (e.g. \"_32\"). \n\tcurrent scales are \"_32\", \"_48\", \"_64\", \"_80\", \"_96\".")
	local cursor = GetCursor()
	local cfg = cursor.cfg
	cfg.cursor_bank, cfg.last_bank, cfg.base_bank = style, style, style
	cfg.cursor_scl = scale
	if cfg.cursor_shadow then
		cursor.shadow:GetAnimState():SetBankAndPlayAnimation(cfg.cursor_bank, cfg.cursor_bank..cfg.cursor_scl)
	end
	
	cursor:GetAnimState():SetBankAndPlayAnimation(cfg.cursor_bank, cfg.cursor_bank..cfg.cursor_scl)
	
	local effects = cursor.effects.fx_maps
	if effects[cfg.cursor_bank] then cursor.effects:InitEffect() end
end

_G.SetCursorCharacterOverride = function(character, style)
	assert(type(character) == "string", "[INTERACTABLE CURSOR] character prefab must be a string. (e.g. \"wx78\", \"wathgrithr\")")
    assert(type(style) == "string", "[INTERACTABLE CURSOR] style must be a string (e.g. \"wx\", 'curly\")")

	_G.GetCursorCharacterConfig()[character] = style
end

_G.SetCursorBuild = function(build)
	_G.GetCursorModConfig().cursor_build = build
end

_G.SetCursorCustomOverride = function(build, bank, specific_scale, scale)
	cfg = GetCursorModConfig()
	cfg.cursor_bank = bank
	cfg.last_bank = bank
	cfg.base_bank = bank
	cfg.cursor_scl = specific_scale and scale or cfg.cursor_scl
	_G.SetCursorBuild(build)
	
	if cfg.cursor_shadow then
		GetCursor().shadow:GetAnimState():SetBuild(cfg.cursor_build)
		GetCursor().shadow:GetAnimState():SetBankAndPlayAnimation(cfg.cursor_bank, cfg.cursor_bank..cfg.cursor_scl)
	end
	
	GetCursor():GetAnimState():SetBuild(cfg.cursor_build)
	GetCursor():GetAnimState():SetBankAndPlayAnimation(cfg.cursor_bank, cfg.cursor_bank..cfg.cursor_scl)
end