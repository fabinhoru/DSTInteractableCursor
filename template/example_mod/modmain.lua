Assets = {
	Asset("ANIM", "anim/cursor_blood_ice.zip")
}

local custombank = "blood_ice" 	-- your custom cursor texture name! this will let the mod know which cursor to use

local custombuild = "cursor_blood_ice" 	-- your custom cursor build! self explanatory. adds the build to the game
										-- so it knows how to display the textures!
										
local customscale = "_64"  	-- your custom scale! can be in the range of "_96", "_80", "_64", "_48" or "_32". 
							-- it has to be named as such so the mod doesn't break

local cursor 	-- the cursor! we are forward declaring this variable so the
				-- init function can successfully fetch the cursor after startup
				
local function init() 	-- this will "rev" up the mod so to get a readable "cursor" variable
	local c = GLOBAL.GetCursor()
	if c then 
		cursor = c
		
		-- GLOBAL.SetCursorCharacterOverride("character", custombank) 	-- an example of setting a custom modded character cursor bank!
																		-- as long as this matches the name of your character prefab, you're good
																		
		GLOBAL.SetCursorCustomOverride(custombuild, custombank, false, customscale)	-- the function that overrides the cursor's animations with our custom one!
																					-- it gets these arguments, respetively:
																					-- > the cursor build, so it can override it with our custom one
																					-- > the cursor bank, so it knows which texture/animation to display
																					-- > a boolean, to decide if are overriding the scale with a custom one as well
																					-- > the cursor scale, so we can override the scale of the cursor
		
		-- GLOBAL.SetCursorBuild(custombuild)
		-- GLOBAL.SetCursorStyle(custombank, customscale, false) 	-- a more complicated example of overriding the cursor
																	-- this method allows you to set a cursor shadow as well
																	-- it gets these arguments, respectively:
																	-- > the cursor bank
																	-- > the cursor scale
																	-- > and a boolean to decide if the cursor should display a
																	--   drop shadow as well
	else 
		GLOBAL.scheduler:ExecuteInTime(0.1, init) 
	end 	-- loops itself until we have cursor
end

if not GLOBAL.TheNet:IsDedicated() or not GLOBAL.TheNet:GetServerIsDedicated() then 	-- so the our mod starts roughly the same time the cursor does
    GLOBAL.scheduler:ExecuteInTime(0, init) -- so the our mod starts roughly the same time the cursor does
end
