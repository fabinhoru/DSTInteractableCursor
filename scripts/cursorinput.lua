local CursorInput = Class(function(self, cursor)
	self.cursor = cursor
end)

function CursorInput:FollowMouse()
	local cursor = self.cursor
	local cfg = cursor.cfg
	
    if not cursor.follow_handler then
        if not cfg.cursor_wobbly then
            cursor.follow_handler = _G.TheInput:AddMoveHandler(function(x, y)
				local cursor_pos = Vector3(_G.TheInputProxy:GetOSCursorPos()) or Vector3(x, y, 0)
                cursor:SetPosition(cursor_pos:Get())
                _G.TheInputProxy:SetCursorVisible(false)
            end)
            return
        end

        -- happy april fools! (i'm keeping this by the way, if you couldn't tell)
		local config = {
			threshold = 1.1,       -- minimum distance for drag
			max_rotation = 90,     -- maximum rotation in degrees
			min_for_max = 30,      -- distance for max_rotation to be used (which probably never happens, probably gets capped at 66.666% of the way there)
			lerp = 0.3,            -- time to reach target rotation
			decay = 0.5,           -- rate for setting rotation back to 0
		}
	
		cursor.rot = {}
		cursor.rot.last_x, cursor.rot.last_y, cursor.rot.current, cursor.rot.target = nil, nil, 0, 0
		
		local function CalculateDirection(dx, dy)
			local angle = math.deg(math.atan2(dy, dx)) + 180			-- returns the direction of the difference between positions in radians
			local flip = (math.abs(dy) < config.threshold or math.abs(dx) > math.abs(dy))
			return flip and (dx > 0 and angle or -angle) or (dy > 0 and angle or -angle)
		end

		local function ClampRotation(rotation, distance) 				-- don't want crazy ass rotation
			local factor = math.min(distance / config.min_for_max, 1)	-- reduces the max rotation according to the speed of the cursor
			local dynamic_max = config.max_rotation * factor
			return math.clamp(rotation, -dynamic_max, dynamic_max)
		end

		local function SmoothRotation(current, target)
			local decayed_target = math.floor((target + (0 - target) * config.decay) * 100) / 100
			local new_current = current + (decayed_target - current) * config.lerp
			return math.abs(new_current) < 0.01 and 0 or math.floor(new_current * 100) / 100, decayed_target -- clamp it to 0 instead of a huge fucking number
		end

		cursor.follow_handler = _G.TheInput:AddMoveHandler(function(x, y)
			local cursor_pos = Vector3(_G.TheInputProxy:GetOSCursorPos()) or Vector3(x, y, 0)
			local r = cursor.rot
			if r.last_x and r.last_y then
				local dx, dy = x - r.last_x, y - r.last_y				-- gets the distance between positions	
				local distance = math.sqrt(dx * dx + dy * dy)			-- baby equation

				if distance > config.threshold then
					local dir = CalculateDirection(dx, dy)
					r.target = ClampRotation(dir, distance)
				end
			end

			r.last_x, r.last_y = x, y
			cursor:SetPosition(cursor_pos:Get())
			_G.TheInputProxy:SetCursorVisible(false)
		end)

        cursor.inst:DoPeriodicTask(FRAMES, function()
			local r = cursor.rot
			r.current, r.target = SmoothRotation(r.current, r.target)
			cursor:SetRotation(r.current)
		end)
    end
end

function CursorInput:MakeClicky()
	local cursor = self.cursor
	local cfg = cursor.cfg
    if cursor.mouse_handler or not cfg.animated_cursor then return end

    local is_button_down = false

    cursor.mouse_handler = _G.TheInput:AddMouseButtonHandler(function(button, down)
        if button ~= MOUSEBUTTON_LEFT and button ~= MOUSEBUTTON_RIGHT then return end
        local scale = cfg.cursor_scl_mult
        local lefty = cfg.cursor_lefty and -scale or scale
        local shrink = 0.9 * scale
        local use_pointfilter = scale % 1 == 0

        local MakeClickSound = function()
            if cfg.clicky_cursor then
                local click = "cursor_mod/cursor_mod/click_" .. (down and "down" or "up") .. (cfg.clicky_cursor_soft and "_soft" or "")
                _G.TheFrontEnd:GetSound():PlaySoundWithParams(click, { volume = cfg.clicky_cursor_volume })
            end
        end
		local PlayClickEffect = function()
			if cfg.character_effects then
				local effect = cursor.effects:PlayClickEffect()
			end
		end

        if down and not is_button_down then
            is_button_down = true
            cursor:GetAnimState():UsePointFiltering(false)
            cursor:SetScale(lefty * 0.9, shrink, shrink) -- shrink
            MakeClickSound()
			PlayClickEffect()
        elseif not down and is_button_down then
            is_button_down = false
            cursor:GetAnimState():UsePointFiltering(use_pointfilter)
            cursor:SetScale(lefty, scale, scale) -- pop!
            MakeClickSound()
        end
    end)
end

return CursorInput