name = "Interactable Cursor"
author = "fabinhoru"

actual_version = "1.9b2a" -- changing things around for easier maintenance
version_description = " - Tidying Up!"
forumthread = "https://steamcommunity.com/sharedfiles/filedetails/?id=3399184840" -- does this work?

version = actual_version
description = "It interacts, I think. \nVersion " .. actual_version .. version_description .. " \n\nIf you want to make your own custom dynamic cursor, check this mod's folder!"
api_version = 10

icon_atlas = "modicon.xml"
icon = "modicon.tex"

dst_compatible = true

dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = false
client_only_mod = true

local Separator, SeparatorLabeled, Option
Separator = function() -- separators for organization. thank you Uncompromising Mode modinfo.lua for letting me know about this cool feature. EDIT: also made these a function too
    return {
		name = "",
		label = "",
		hover = "",
		options = { { description = "", data = false } },
		default = false
    }
end

SeparatorLabeled = function(label)
	return {
		name = "",
		label = label,
		hover = "",
		options = { { description = "", data = false } },
		default = false
    }
end

Option = function(description, hover, data)
	return {
		description = description,
		hover = hover,
		data = data
	}
end

configuration_options = {
	SeparatorLabeled("Cursor Settings"),
	{
		name = "cursortexture",
		label = "Cursor Style",
		hover = "Changes which style to use for your cursor. \nI recommend using Remi's \"Convenient Configs\" if i were you.",
		options = {
--			Option("Custom-made", "Your very own cursor!", "custom"), -- uncomment this one if you're doing custom cursors!
--			Option("WX Hand (Old)", "ARCHAIC SYSTEM DETECTED", "wx_old"), -- i'll leave this for later because for some fucking reason when compiling the animations now some symbols just randomly disappear
			Option("Curly", "A curly and pointy cursor!", "curly"),
			Option("Marbly", "I chiseled it.", "marble"),
			Option("Glassy", "The contents of this cursor may be fragile.", "alter"),
			Option("Mushy", "You can be a Fungi, a Fungal, a Funthem, but you cannot run from... Fun-IT...", "mushroom"),
			Option("Icy", "Ice ice, baby.", "icy"),

			Option("Metheus Puzzle", "A shadowy hand.", "metheus"),
			Option("Generic", "Anyone could be behind those hands... It could even be--", "generic"),
			Option("Shadow Hand", "\"I am the \"Who\" when you call \"Who's there?!\"...\"", "charlie"), -- I am the wind blowing through your hair...
			Option("The Queen's Hand", "To pull at your heart strings. In a more literal sense than metaphoric.", "queen"),
			Option("Charlie's Hand", "Weak and frail.", "assistant"),
			Option("Skeleton Hand", "Spooky and scary.", "skeleton"),
			Option("Cat Paw", "Meow!", "cat"),
			Option("Windows White", "Windows's Default Cursor.", "syswhite"),
			Option("Windows Black", "Windows's Black Cursor.", "sysblack"),

			Option("Wilson's Hand", "Hands fit for a fool. Or a pawn.", "wilson"),
			Option("Willow's Hand", "\"These ashes could be anyone's! --I mean, anything's!\"", "willow"),
			Option("Wolfgang's Hand", "Gently ginormous. And sweaty, eugch.", "wolfgang"),
			Option("Wendy's Hand", "Cold and Unfeeling.", "wendy"),
			Option("WX-78 Hand", "Mechanical!", "wx"),
			Option("Wickerbottom's Hand", "Is she malnourished, or just old?", "wickerbottom"),
			Option("Woodie's Glove", "\"Probably full of splinters, eh?\"", "woodie"),
			Option("Wes' Glove", "... Pathetic.", "wes"),
			Option("Maxwell's Hand", "Hands fit for a king... Well, a has-been king.", "maxwell"),
			Option("Wigfrid's Hand", "Ready for a glöriöus battle.", "wigfrid"),
			Option("Webber's Claw", "Sharp and pointy.", "webber"),
			Option("Winona's Glove", "Hard at work.", "winona"),
			Option("Warly's Hand", "He's an accomplished butcher, you know?", "warly"),
			Option("Wortox's Paw", "Why don't you give him a handshake?", "wortox"),
			Option("Wormwood's Leaf", "\"Hello, friend?\"", "wormwood"),
			Option("Wurt's Claw", "Greasy and grimy.", "wurt"),
			Option("Walter's Hand", "For slinging and petting.", "walter"),
			Option("Wanda's Glove", "\"At least they cover up the wrinkles!\"", "wanda"),
			
--			Option("Wonkey's Hand", "Hey!! How did this get here?!", "wonkey"),

			Option("Winky's Paw", "\"Oooh, nice stuff you got there. Can i have it?\"", "winky"), -- EVIL WINKY VIRUS -- Uncompromising Mode
			Option("Wathom's Claw", "\"Claws, sharpened. Stand before me, none will.\"", "wathom"), -- the desc came out generic as shit. i couldn't think of anything else, okay?

			Option("Walani's Hand", "Tubular. Wicked, even.", "walani"), -- Island Adventures - Shipwrecked
			Option("Woodlegs' Hand", "\"'Least i've still got both me eyes'n hands, yar-har-harr!\"", "woodlegs"),
			Option("Wilbur's Hand", "\"Ook.\"", "wilbur"),

			Option("Whimsy's Hand", "\"At least i think they are...\"", "whimsy"), -- Whimsy the Disoriented
			Option("Why's Exo-skeleton", "Fractured.", "why"), -- Ancient Dreams

			Option("Deerclops' Claw", "\"Rrheeeaagh!!\"", "weerclops"), -- old description: "That's what a Deerclops does best..." -- Reign of Runts
			Option("Dragonfly's Claw", "\"Zrt! Zrt! Zrrrrgh...\"", "wragonfly"), -- old decription: "Zrt! Oh, to find a pile of treasures..."
			Option("Bearger's Paw", "\"Rhuoourgh!\"", "wearger"), -- old description: "Full of honey."
			Option("Moose's Wing", "\"HOOOONK!\"", "woose"), -- old description: "HOONK! Don't mess with momma!."

			Option("Wirlywings' Hand", "Mphddah Mphdda Mhh! Wait, no, wrong character?", "wirly"), -- Cherry Forest

			Option("Wheeler's Hand", "\"To adventure!\"", "wheeler"), -- Hamlet / IA: Hamlet ;]
			Option("Wilba's Hoof", "\"I BITE MY HOOF AT THEE!\"", "wilba"),
			Option("Wagstaff's Glove", "I thought he lost his gloves, though...", "wagstaff"),
--			Option("Warbucks", "\"You cannot contain me forever, good chum.\"", "warbucks"),

			Option("Wade's Glove", "At least this suit freak cleans up his messes.", "wade"), -- The Black Death
			
			Option("System / Disabled", "Disables the custom cursor.", 0),
		},
		default = "curly"
	},
	{
		name = "cursorscale",
		label = "Cursor Scale",
		hover = "Changes the cursor's style scale. Default is 32x32. \nScales beyond 64x64 aren't recommended in resolutions lower than 1080p.",
		options = {
			{description = "32x32", data = "_32", hover = "Default Scale"},
			{description = "48x48", data = "_48", hover = "1.5x Default Scale"},
			{description = "64x64", data = "_64", hover = "2x Default Scale"},
			{description = "80x80", data = "_80", hover = "2.5x Default Scale"},
			{description = "96x96", data = "_96", hover = "3x Default Scale"},
		},
		default = "_32"
	},
	{
		name = "cursorscalemult", -- honestly, after the decision to export them to x96, i'm compelled to remove this option entirely
		label = "Cursor Size",
		hover = "Changes cursor size. This stretches out the texture to the desired size. \nDefault is recommended unless you have a very, very small/big monitor.",
		options = {
			{description = "0.5x", data = 0.5, hover = "TINY!"},
			{description = "0.6x", data = 0.6, hover = "Really small."},
			{description = "0.7x", data = 0.7, hover = "Small."},
			{description = "0.8x", data = 0.8},
			{description = "0.9x", data = 0.9},
			{description = "Default", data = 1, hover = "The default size."},
			{description = "1.1x", data = 1.1},
			{description = "1.2x", data = 1.2},
			{description = "1.3x", data = 1.3},
			{description = "1.4x", data = 1.4},
			{description = "1.5x", data = 1.5},
			{description = "1.6x", data = 1.6},
			{description = "1.7x", data = 1.7, hover = "Big."},
			{description = "1.8x", data = 1.8, hover = "Really big."},
			{description = "1.9x", data = 1.9, hover = "Really really big."},
			{description = "2x", data = 2, hover = "Huge."},
			{description = "3x", data = 3, hover = "MASSIVE!"},
		},
		default = 1
	},
	{
		name = "cursorleft",
		label = "Lefty Mode",
		hover = "Mirrors the cursor to face left instead.",
		options = {
			{description = "Left", hover = "Points Left.", data = true},
			{description = "Default", hover = "Points Right.", data = false},
		},
		default = false
	},
	Separator(),
	{
		name = "invstates",
		label = "Interactable Inventory",
		hover = "When hovering over an item in your inventory, your cursor changes to the \"Interactable\" state. (Like when you hover an entity or item.)",
		options = {
			{description = "Enabled", hover = "Inventory Items will be \"Interactable\".", data = true},
			{description = "Disabled", hover = "Normal behaviour.", data = false},
		},
		default = true -- dunno if this'll stay. if anyone's actually bothered by this to tell me in the comments, i'll make it false by default
	},
	{
		name = "rmbstates",
		label = "Right Click States",
		hover = "\"Right Click\" actions set the cursor to its \"Interact\" state. \nThis is most noticeable when Casting, Tilling, Rowing or Teleporting.",
		options = {
			{description = "Enabled", hover = "Certain \"Right Click\" actions will affect the cursor.", data = true},
			{description = "Disabled", hover = "Normal behaviour.", data = false},
		},
		default = false
	},
	Separator(),
	SeparatorLabeled("\"Fun\" Settings"),
	{
		name = "cursorshadow",
		label = "Cursor Shadow",
		hover = "Adds a drop-shadow to your cursor!",
		options = {
			{description = "Enabled", hover = "Dynamic!", data = true},
			{description = "Disabled", hover = "Normal.", data = false},
		},
		default = true
	},
	{
		name = "cursorcharacterdepend",
		label = "Character Cursors",
		hover = "What character you choose in-game affects your cursor! \nModded characters don't count. Well, most of them.",
		options = {
			{description = "Enabled", hover = "Unique!", data = true},
			{description = "Disabled", hover = "Immutable.", data = false},
		},
		default = false
	},
	{
		name = "cursorcharactereffects",
		label = "Cursor VFX",
		hover = "Some characters may have visual effects when using their cursor! \nPurely cosmetic.",
		options = {
			{description = "Enabled", hover = "Flashy!", data = true},
			{description = "Disabled", hover = "Clean.", data = false},
		},
		default = false
	},
	{
		name = "cursorccaffected",
		label = "Color Correction",
		hover = "When in-game, use the current palette as the in-game season/locale! \nBasically, y'know when winter comes and everything gets blue? That!",
		options = {
			{description = "Enabled", hover = "Colorful!", data = true},
			{description = "Disabled", hover = "Also colorful.", data = false},
		},
		default = false
	},
	Separator(),
	{
		name = "cursoranimated",
		label = "Click Feedback",
		hover = "When you click, it visibly clicks as well! \n(It shrinks down a bit when holding down click)",
		options = {
			{description = "Enabled", hover = "Have fun!", data = true},
			{description = "Disabled", hover = "Static.", data = false},
		},
		default = false
	},
	{
		name = "cursorclicky",
		label = "Clicky Cursor",
		hover = "Makes clicking sounds when you click! Only works when \"Click Feedback\" is Enabled.",
		options = {
			{description = "Enabled", hover = "Clicky!", data = true},
			{description = "Disabled", hover = "Silent.", data = false},
		},
		default = false
	},
	{
		name = "cursorclickvolume",
		label = "Clicking Volume",
		hover = "For when clicking is too loud/quiet.",
		options = {
			{description = "0%", hover = "At this point this's placebo.", data = 0},
			{description = "10%", hover = "Can you even hear anything?", data = 0.1},
			{description = "20%", hover = "Quieter.", data = 0.2},
			{description = "30%", hover = "Quiet.", data = 0.3},
			{description = "40%", data = 0.4},
			{description = "50%", data = 0.5},
			{description = "60%", data = 0.6},
			{description = "70%", hover = "A little loud.", data = 0.7},
			{description = "80%", hover = "Getting there.", data = 0.8},
			{description = "90%", hover = "Very Loud!", data = 0.9},
			{description = "100%", hover = "LOUD!!!", data = 1.0},
		},
		default = 0.3
	},
	{
		name = "cursorclicksoft",
		label = "Clicking Sound",
		hover = "Changes the sound between a clicker sound, or a softer one.",
		options = {
			{description = "Soft", hover = "Tock... Tock...", data = true},
			{description = "Clicky", hover = "Click Clack.", data = false},
		},
		default = false
	},
	Separator(),
	{
		name = "cursorwobbly",
		label = "Wobbly Cursor",
		hover = "The cursor will wobble left and right as you move it. Not recommended, unless you like that stuff.",
		options = {
			{description = "Enabled", hover = "Wobbly!", data = true},
			{description = "Disabled", hover = "Sobered up.", data = false},
		},
		default = false
	},
	Separator(),
	SeparatorLabeled("Experimental"),
	{
		name = "cursoroptionspanel",
		label = "[E] Options Panel",
		hover = "Experimental! \nInjects a custom configuration panel directly into the settings screen.",
		options = {
			{description = "Enabled", hover = "Dangerous!", data = true},
			{description = "Disabled", hover = "Normal.", data = false},
		},
		default = true -- oh boy
	},
	Separator(),
	SeparatorLabeled("Debug"),
	{
		name = "cursordebugmode",
		label = "Debug Functions",
		hover = "\"NUMPAD +\" = Change Cursor Style. \"NUMPAD *\" = Change Cursor Scale. \"NUMPAD /\" = Change Cursor Action. \"J\" = Run Command.",
		options = {
			{description = "Enabled", hover = "Complicated!", data = true},
			{description = "Disabled", hover = "Normal.", data = false},
		},
		default = false
	}
}

--[[ cursor options backup before the hostile Option() takeover
--			{description = "Custom-made", hover = "Your very own cursor!", data = "custom"}, -- uncomment this one if you're doing custom cursors!
--			{description = "WX Hand (Old)", hover = "ARCHAIC SYSTEM DETECTED", data = "wx_old"}, -- i'll leave this for later because for some fucking reason when compiling the animations now some symbols just randomly disappear
			{description = "Curly", hover = "A curly and pointy cursor!", data = "curly"},
			{description = "Marbly", hover = "I chiseled it.", data = "marble"},
			{description = "Glassy", hover = "The contents of this cursor may be fragile.", data = "alter"},
			{description = "Mushy", hover = "You can be a Fungi, a Fungal, a Funthem, but you cannot run from... Fun-IT...", data = "mushroom"},

			{description = "WX-78 Hand", hover = "Mechanical!", data = "wx"},
			{description = "Metheus Puzzle", hover = "Wilson's black, shadowy hands.", data = "metheus"},
			{description = "Shadow Hand", hover = "I am the \"Who\" when you call \"Who's there?!\"...", data = "charlie"}, -- I am the wind blowing through your hair...
			{description = "The Queen's Hand", hover = "To pull at your heart strings. In a more literal sense than metaphoric.", data = "queen"},
			{description = "Charlie's Hand", hover = "Weak and frail.", data = "assistant"},
			{description = "Skeleton Hand", hover = "Spooky and scary.", data = "skeleton"},
			{description = "Cat Paw", hover = "Meow!", data = "cat"},
			{description = "Windows White", hover = "Windows's Default Cursor.", data = "syswhite"},
			{description = "Windows Black", hover = "Windows's Black Cursor.", data = "sysblack"},

			{description = "Maxwell's Hand", hover = "Hands fit for a king... Well, a has-been king.", data = "maxwell"},
			{description = "Woodie's Glove", hover = "Probably full of splinters, eh?", data = "woodie"},
			{description = "Winona's Glove", hover = "Hard at work.", data = "winona"},
			{description = "Wendy's Hand", hover = "Cold and Unfeeling.", data = "wendy"},
			{description = "Walter's Hand", hover = "For slinging and petting.", data = "walter"},
			{description = "Wortox's Paw", hover = "Why don't you give him a handshake?", data = "wortox"},
			{description = "Wormwood's Leaf", hover = "Hello friend?", data = "wormwood"},
			{description = "Webber's Claw", hover = "Sharp and pointy.", data = "webber"},
			{description = "Wurt's Claw", hover = "Greasy and grimy.", data = "wurt"},
			{description = "Wigfrid's Hand", hover = "Ready for a glöriöus battle.", data = "wigfrid"},
			{description = "Wolfgang's Hand", hover = "Gently ginormous. And sweaty, eugch.", data = "wolfgang"},
			{description = "Warly's Hand", hover = "He's an accomplished butcher, you know?", data = "warly"},
			{description = "Wes's Glove", hover = "... Pathetic.", data = "wes"},
			{description = "Wanda's Glove", hover = "At least they cover up the wrinkles!", data = "wanda"},
			{description = "Wickerbottom's Hand", hover = "Is she malnourished, or just old?", data = "wickerbottom"},
			{description = "Willow's Hand", hover = "These ashes could be anyone's! --I mean, anything's!", data = "willow"},
--			{description = "Wonkey's Hand", hover = "Hey!! How did this get here?!", data = "wonkey"},

			{description = "Winky's Paw", hover = "Oooh, nice stuff you got there. Can i have it?", data = "winky"}, -- EVIL WINKY VIRUS
			{description = "Wathom's Claw", hover = "Claws, sharpened. Stand before me, none will.", data = "wathom"}, -- the desc came out generic as shit. i couldn't think of anything else, okay?

			{description = "Walani's Hand", hover = "Tubular. Wicked, even.", data = "walani"}, -- Island Adventures - Shipwrecked
			{description = "Woodlegs' Hand", hover = "'Least i've still got both me eyes'n hands, yar-har-harr!", data = "woodlegs"},
			{description = "Wilbur's Hand", hover = "Ook.", data = "wilbur"},

			{description = "Whimsy's Hand", hover = "At least i think they are....", data = "whimsy"}, -- Whimsy the Disoriented
			{description = "Why's Exo-skeleton", hover = "Fractured.", data = "why"}, -- Ancient Dreams

			{description = "Generic", hover = "Anyone could be behind those hands... It could even be--", data = "generic"},
			{description = "System / Disabled", hover = "Disables the custom cursor.", data = 0},

			{description = "The Grue's Hand", hover = "One day, the light of day will no longer hurt me. You best be ready for that day.", data = "grue"}
]]