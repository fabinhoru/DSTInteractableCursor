local UIAnim = require "widgets/uianim"

local CursorShadow = Class(UIAnim, function(self, cursor)
	UIAnim._ctor(self, "shadow")

	self.cursor = cursor
	local cfg = cursor and cursor.cfg
	if not cfg or not cfg.cursor_shadow then return end

	local anim = self:GetAnimState()
	local use_pointfilter = cfg.cursor_scl_mult % 1 == 0

	self:SetClickable(false)
	self:SetPosition(2, -2, 0)
	anim:SetMultColour(0, 0, 0, 0.4)
	anim:SetBank(cfg.cursor_bank)
	anim:SetBuild(cfg.cursor_build)
	anim:PlayAnimation(cfg.cursor_anim, true)
	anim:UsePointFiltering(use_pointfilter)
end)

return CursorShadow
