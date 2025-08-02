local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Grid = require "widgets/grid"

-------------------- v v below is just a carbon copy of stuff in optionsscreen.lua

local label_width = 200
local spinner_width = 220
local spinner_height = 36
local spinner_scale_x = .76
local spinner_scale_y = .68
local narrow_field_nudge = -50
local space_between = 5

local function AddListItemBackground(w)
	local total_width = label_width + spinner_width + space_between
	w.bg = w:AddChild(TEMPLATES.ListItemBackground(total_width + 15, spinner_height + 5))
	w.bg:SetPosition(-40,0)
	w.bg:MoveToBack()
end
local function CreateTextSpinner(labeltext, spinnerdata, tooltip_text)
	local w = TEMPLATES.LabelSpinner(labeltext, spinnerdata, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge, nil, nil, tooltip_text)
	AddListItemBackground(w)
	return w.spinner
end
local function CreateNumericSpinner(labeltext, min, max, tooltip_text)
	local w = TEMPLATES.LabelNumericSpinner(labeltext, min, max, label_width, spinner_width, spinner_height, space_between, nil, nil, narrow_field_nudge, tooltip_text)
	AddListItemBackground(w)
	return w.spinner
end
local function MakeSpinnerTooltip(root)
	local spinner_tooltip = root:AddChild(Text(CHATFONT, 25, ""))
	spinner_tooltip:SetPosition(90, -275)
	spinner_tooltip:SetHAlign(ANCHOR_LEFT)
	spinner_tooltip:SetVAlign(ANCHOR_TOP)
	spinner_tooltip:SetRegionSize(800, 80)
	spinner_tooltip:EnableWordWrap(true)
	return spinner_tooltip
end
local function AddSpinnerTooltip(widget, tooltip, tooltipdivider)
	tooltipdivider:Hide()
	local function ongainfocus(is_enabled)
		if tooltip ~= nil and widget.tooltip_text ~= nil then
			tooltip:SetString(widget.tooltip_text)
			tooltipdivider:Show()
		end
	end
	
	local function onlosefocus(is_enabled)
		if widget.parent and not widget.parent.focus then
			tooltip:SetString("")
			tooltipdivider:Hide()
		end
	end

	widget.bg.ongainfocus = ongainfocus

	if widget.spinner then
		widget.spinner.ongainfocusfn = ongainfocus
	elseif widget.button then
		widget.button.ongainfocus = ongainfocus
	end

	widget.bg.onlosefocus = onlosefocus

	if widget.spinner then
		widget.spinner.onlosefocusfn = onlosefocus
	elseif widget.button then
		widget.button.onlosefocus = onlosefocus
	end

end
-------------------- ^ ^

AddClassPostConstruct("screens/redux/optionsscreen", function(self)
	local cursor = _G.GetCursor()
	local cfg = cursor.cfg
	local strings = {
		mod_name = KnownModIndex:GetModActualName("Interactable Cursor"),
		--------------------
		tab_label = "Cursor",
		tab_name = "cursorsettings",
		tab_tooltip = "Configure your Cursor, dynamically!",
		--------------------
		bank_label = "Style",
		bank_tooltip = "Changes which style to use for your cursor. \nGet ready to scroll, there's a loooooot of options...",
		--------------------
		scale_label = "Scale",
		scale_tooltip = "Changes the cursor's style scale. \nDefault is 32x32. \nScales beyond 64x64 aren't recommended in resolutions lower than 1080p.",
		--------------------
		size_label = "Size",
		size_tooltip = "Changes cursor size. This stretches out the texture to the desired size. \nDefault is recommended unless you have a very, very small/big monitor.",
		--------------------
		shadow_label = "Shadow",
		shadow_tooltip = "Adds a drop-shadow to your cursor!",
		--------------------
		character_label = "Character Cursors",
		character_tooltip = "What character you choose in-game affects your cursor! \nModded characters don't count. Well, most of them.",
		vfx_label = "Character Cursor VFX",
		vfx_tooltip = "Some characters may have visual effects when using their cursor! \nPurely cosmetic.",
		--------------------
		click_volume_label = "Clicking Volume",
		click_volume_tooltip = "For when clicking is too loud/quiet.",
		--------------------
		click_type_label = "Clicking Sound",
		click_type_tooltip = "Changes the sound between a clicker sound, or a softer one."
	}
	--------------------
	local config = KnownModIndex:GetModConfigurationOptions_Internal(strings.mod_name, false)
	local options = {
		bank = {},
		scale = {},
		size = {},
		shadow = {},
		character = {},
		vfx = {},
		click_volume = {},
		click_type = {}
	}
	for k,v in pairs(config[2].options) do if v ~= 0 then table.insert(options.bank, { text = v.description, data = v.data} ) end end
	for k,v in pairs(config[3].options) do table.insert(options.scale, { text = v.description, data = v.data} ) end
	for k,v in pairs(config[4].options) do table.insert(options.size, { text = v.description, data = v.data} ) end
	for k,v in pairs(config[11].options) do table.insert(options.shadow, { text = v.description, data = v.data} ) end
	for k,v in pairs(config[12].options) do table.insert(options.character, { text = v.description, data = v.data} ) end
	for k,v in pairs(config[13].options) do table.insert(options.vfx, { text = v.description, data = v.data} ) end
	for k,v in pairs(config[18].options) do table.insert(options.click_volume, { text = v.description, data = v.data} ) end
	for k,v in pairs(config[19].options) do table.insert(options.click_type, { text = v.description, data = v.data} ) end
	--------------------
	local function FindCursorBankIndex(bank)
		for i = 1, #options.bank do
			if options.bank[i].data == config[2].saved then
				return i
			end
		end
		return 1
	end
	local function FindOptionIndex(options_index, config_index)
		for i = 1, #options[options_index] do
			if options[options_index][i].data == config[config_index].saved then
				return i
			end
		end
		return 1
	end
	local function FindCursorScaleIndex(scale)
		for i = 1, #options.scale do
			if options.scale[i].data == config[3].saved then
				return i
			end
		end
		return 1
	end
	--------------------
	local cursorsettings_button = self.subscreener:MenuButton(strings.tab_label, strings.tab_name, strings.tab_tooltip, self.tooltip)
	self.subscreener.menu:AddCustomItem(cursorsettings_button)
	function self:_BuildCursorSettings()
		local cursorsettingsroot = Widget("ROOT")
		--------------------
		self.left_spinners_cursor, self.right_spinners_cursor = {}, {}
		self.grid = cursorsettingsroot:AddChild(Grid())
		self.grid:SetPosition(-90, 184, 0)
		self.cursorsettings_tooltip = cursorsettingsroot:AddChild(TEMPLATES.ScreenTooltip())
		--------------------
		-- self.cursordummySpinner = CreateTextSpinner(strings.dummy_label, options.dummy, strings.dummy_tooltip)
		-- self.cursordummySpinner.OnChanged =
			-- function(_, data)
				-- return true 
			-- end
		--------------------
		self.cursorbankSpinner = CreateTextSpinner(strings.bank_label, options.bank, strings.bank_tooltip)
		self.cursorbankSpinner.OnChanged =
			function(_, data)
				self:MakeDirty()
				_G.SetCursorStyle(data, cfg.cursor_scl)
				KnownModIndex:SetConfigurationOption(strings.mod_name, "cursortexture", data)
			end
			
		self.cursorscaleSpinner = CreateTextSpinner(strings.scale_label, options.scale, strings.scale_tooltip)
		self.cursorscaleSpinner.OnChanged =
			function(_, data)
				self:MakeDirty()
				_G.SetCursorStyle(cfg.cursor_bank, data)
				KnownModIndex:SetConfigurationOption(strings.mod_name, "cursorscale", data)
			end
			
		self.cursorsizeSpinner = CreateTextSpinner(strings.size_label, options.size, strings.size_tooltip)
		self.cursorsizeSpinner.OnChanged =
			function(_, data)
				self:MakeDirty()
				cursor:SetScale(data, data, data)
				KnownModIndex:SetConfigurationOption(strings.mod_name, "cursorscalemult", data)
			end
			
		self.cursorshadowSpinner = CreateTextSpinner(strings.shadow_label, options.shadow, strings.shadow_tooltip)
		self.cursorshadowSpinner.OnChanged =
			function(_, data)
				self:MakeDirty()
				KnownModIndex:SetConfigurationOption(strings.mod_name, "cursorshadow", data)
			end
			
		self.cursorcharacterSpinner = CreateTextSpinner(strings.character_label, options.character, strings.character_tooltip)
		self.cursorcharacterSpinner.OnChanged =
			function(_, data)
				self:MakeDirty()
				cfg.character_cursor = data
				KnownModIndex:SetConfigurationOption(strings.mod_name, "cursorcharacterdepend", data)
			end
			
		self.cursorvfxSpinner = CreateTextSpinner(strings.vfx_label, options.vfx, strings.vfx_tooltip)
		self.cursorvfxSpinner.OnChanged =
			function(_, data)
				self:MakeDirty()
				cfg.character_effects = data
				KnownModIndex:SetConfigurationOption(strings.mod_name, "cursorcharactereffects", data)
			end
			
		self.cursorclick_volumeSpinner = CreateTextSpinner(strings.click_volume_label, options.click_volume, strings.click_volume_tooltip)
		self.cursorclick_volumeSpinner.OnChanged =
			function(_, data)
				self:MakeDirty()
				cfg.clicky_cursor_volume = data
				KnownModIndex:SetConfigurationOption(strings.mod_name, "cursorclickvolume", data)
			end
			
		self.cursorclick_typeSpinner = CreateTextSpinner(strings.click_type_label, options.click_type, strings.click_type_tooltip)
		self.cursorclick_typeSpinner.OnChanged =
			function(_, data)
				self:MakeDirty()
				cfg.clicky_cursor_soft = data
				KnownModIndex:SetConfigurationOption(strings.mod_name, "cursorclicksoft", data)
			end
			
		table.insert(self.left_spinners_cursor, self.cursorbankSpinner)
		table.insert(self.left_spinners_cursor, self.cursorshadowSpinner)
		table.insert(self.left_spinners_cursor, self.cursorcharacterSpinner)
		table.insert(self.left_spinners_cursor, self.cursorclick_volumeSpinner)
		
		table.insert(self.right_spinners_cursor, self.cursorscaleSpinner)
		table.insert(self.right_spinners_cursor, self.cursorsizeSpinner)
		table.insert(self.right_spinners_cursor, self.cursorvfxSpinner)
		table.insert(self.right_spinners_cursor, self.cursorclick_typeSpinner)
		--------------------
		self.grid:UseNaturalLayout()
		self.grid:InitSize(2, math.max(#self.left_spinners_cursor, #self.right_spinners_cursor), 440, 40)

		local spinner_tooltip = MakeSpinnerTooltip(cursorsettingsroot)

		local spinner_tooltip_divider = cursorsettingsroot:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
		spinner_tooltip_divider:SetPosition(90, -225)
		--------------------
		for k,v in ipairs(self.left_spinners_cursor) do
			self.grid:AddItem(v.parent, 1, k)
			AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
		end

		for k,v in ipairs(self.right_spinners_cursor) do
			self.grid:AddItem(v.parent, 2, k)
			AddSpinnerTooltip(v.parent, spinner_tooltip, spinner_tooltip_divider)
		end
		--------------------
		self.cursorbankSpinner:SetSelectedIndex(FindCursorBankIndex(cfg.cursor_bank))
		self.cursorshadowSpinner:SetSelectedIndex(FindOptionIndex("shadow", 11))
		self.cursorcharacterSpinner:SetSelectedIndex(FindOptionIndex("character", 12))
		self.cursorclick_volumeSpinner:SetSelectedIndex(FindOptionIndex("click_volume", 18))
		
		self.cursorscaleSpinner:SetSelectedIndex(FindOptionIndex("scale", 3))
		self.cursorsizeSpinner:SetSelectedIndex(FindOptionIndex("size", 4))
		self.cursorvfxSpinner:SetSelectedIndex(FindOptionIndex("vfx", 13))
		self.cursorclick_typeSpinner:SetSelectedIndex(FindOptionIndex("click_type", 19))
		--------------------
		self:UpdateMenu()
		cursorsettingsroot:Hide()
		cursorsettingsroot.focus_forward = self.grid
		return cursorsettingsroot
	end
	
	local widget = self.panel_root:AddChild(self:_BuildCursorSettings())
	self.cursorsettings = widget
	self.subscreener.sub_screens["cursorsettings"] = widget
	
	local OldApply = self.Apply
	self.Apply = function(self)
		print("[INTERACTABLE CURSOR] successfully applied settings!")
		local callback = function() return true end
		KnownModIndex:SaveConfigurationOptions(callback, strings.mod_name, config, true)
		if GetModConfigData("cursorshadow", strings.mod_name) == false and cursor.shadow then
			cursor.shadow:Kill()
			cursor.shadow = nil
		elseif not cursor.shadow then
			cursor.shadow = cursor:AddChild(_G.TheInteractableCursor.CursorShadow(cursor))
			cursor.handler:ChangeCursorState(cursor.cfg.default_action, cursor.state)
			cursor.shadow:MoveToBack()
		end
		return OldApply(self)
	end
end)

return true
