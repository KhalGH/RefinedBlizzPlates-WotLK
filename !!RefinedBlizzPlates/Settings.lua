
local AddonFile, RBP = ... -- namespace

------------- Database -------------
RBP.default = {}
RBP.default.profile = {}
RBP.dbp = RBP.default.profile

-------------------- Default Settings --------------------
RBP.dbp.globalScale = 1    -- Global scale for nameplates
RBP.dbp.globalOffsetX = 0  -- Global offset X for nameplates
RBP.dbp.globalOffsetY = 21 -- Global offset Y for nameplates
RBP.dbp.targetScale = 1    -- Target scale factor
RBP.dbp.friendlyClickthrough = false -- Disables hitbox on friendly nameplates
RBP.dbp.levelFilter = 1    -- Minimum unit level to show its nameplate
RBP.dbp.clampTarget = false
RBP.dbp.clampBoss = false
RBP.dbp.upperborder = 35
RBP.dbp.LDWfix = false      -- Hide nameplates when controlled by LDW
-- Enhanced Stacking
RBP.dbp.stackingEnabled = false
RBP.dbp.xspace = 130
RBP.dbp.yspace = 15
RBP.dbp.originpos = 0
RBP.dbp.stackingInInstance = false
RBP.dbp.FreezeMouseover = false
-- Runtime references for previous values in profile changes
RBP.globalOffsetX = RBP.dbp.globalOffsetX
RBP.globalOffsetY = RBP.dbp.globalOffsetY
-- Name Text
RBP.dbp.nameText_hide = false
RBP.dbp.nameText_font = "Arial Narrow"
RBP.dbp.nameText_size = 9
RBP.dbp.nameText_outline = ""
RBP.dbp.nameText_anchor = "CENTER"
RBP.dbp.nameText_offsetX = 0
RBP.dbp.nameText_offsetY = 0
RBP.dbp.nameText_width = 85 -- max text width before truncation (...)
RBP.dbp.nameText_color = {1, 1, 1} -- white
RBP.dbp.nameText_classColorFriends = true
RBP.dbp.nameText_classColorEnemies = false
-- Level Text
RBP.dbp.levelText_hide = true
RBP.dbp.levelText_font = "Arial Narrow"
RBP.dbp.levelText_size = 12
RBP.dbp.levelText_outline = ""
RBP.dbp.levelText_anchor = "Right"
RBP.dbp.levelText_offsetX = 0
RBP.dbp.levelText_offsetY = 0
-- ArenaID Text
RBP.dbp.ArenaIDText_show = true
RBP.dbp.ArenaIDText_font = "Arial Narrow"
RBP.dbp.ArenaIDText_size = 12
RBP.dbp.ArenaIDText_outline = "OUTLINE"
RBP.dbp.ArenaIDText_anchor = "Right"
RBP.dbp.ArenaIDText_offsetX = 0
RBP.dbp.ArenaIDText_offsetY = 0
RBP.dbp.ArenaIDText_color = {1, 1, 1} -- white
RBP.dbp.ArenaIDText_HideLevel = true
RBP.dbp.ArenaIDText_HideName = false
-- PartyID Text
RBP.dbp.PartyIDText_show = true
RBP.dbp.PartyIDText_color = {1, 1, 1} -- white
RBP.dbp.PartyIDText_HideLevel = true
RBP.dbp.PartyIDText_HideName = false
-- HealthBar
RBP.dbp.healthBar_border = "Refined"
RBP.dbp.healthBar_borderTint = {1, 1, 1} -- This a tint overlay, not a regular color
RBP.dbp.healthBar_playerTex = "KhalBar"
RBP.dbp.healthBar_npcTex = "KhalBar"
RBP.dbp.targetGlow_Tint = {1, 1, 1} -- This a tint overlay, not a regular color
RBP.dbp.mouseoverGlow_Tint = {1, 1, 1} -- This a tint overlay, not a regular color
-- Health Text
RBP.dbp.healthText_hide = false
RBP.dbp.healthText_font = "Arial Narrow"
RBP.dbp.healthText_size = 8.8
RBP.dbp.healthText_outline = ""
RBP.dbp.healthText_anchor = "RIGHT"
RBP.dbp.healthText_offsetX = 0
RBP.dbp.healthText_offsetY = 0
RBP.dbp.healthText_color = {1, 1, 1} -- white
-- CastBar
RBP.dbp.castBar_Tex = "KhalBar"
-- Cast Text
RBP.dbp.castText_hide = false
RBP.dbp.castText_font = "Arial Narrow"
RBP.dbp.castText_size = 9
RBP.dbp.castText_outline = ""
RBP.dbp.castText_anchor = "CENTER"
RBP.dbp.castText_offsetX = 0
RBP.dbp.castText_offsetY = 0
RBP.dbp.castText_width = 90 -- max text width before truncation (...)
RBP.dbp.castText_color = {1, 1, 1} -- white
-- Cast Timer Text
RBP.dbp.castTimerText_hide = false
RBP.dbp.castTimerText_font = "Arial Narrow"
RBP.dbp.castTimerText_size = 8.8
RBP.dbp.castTimerText_outline = ""
RBP.dbp.castTimerText_anchor = "RIGHT"
RBP.dbp.castTimerText_offsetX = 0
RBP.dbp.castTimerText_offsetY = 0
RBP.dbp.castTimerText_color = {1, 1, 1} -- white
-- Cast Glow (Shows when nameplate unit is targetting you, requires nontarget castbar patch)
RBP.dbp.enableCastGlow = true
-- Elite Icon
RBP.dbp.eliteIcon_anchor = "Left"
RBP.dbp.eliteIcon_Tint = {1, 1, 1}
-- Boss Icon
RBP.dbp.bossIcon_size = 18
RBP.dbp.bossIcon_anchor = "Right"
RBP.dbp.bossIcon_offsetX = 0
RBP.dbp.bossIcon_offsetY = 0
-- Raid Target Icon
RBP.dbp.raidTargetIcon_size = 27
RBP.dbp.raidTargetIcon_anchor = "Right"
RBP.dbp.raidTargetIcon_offsetX = 0
RBP.dbp.raidTargetIcon_offsetY = 0
-- Class Icon
RBP.dbp.showClassOnFriends = true
RBP.dbp.showClassOnEnemies = true
RBP.dbp.classIcon_size = 26
RBP.dbp.classIcon_anchor = "Left"
RBP.dbp.classIcon_offsetX = 0
RBP.dbp.classIcon_offsetY = 0
-- Barless Plate
RBP.dbp.barlessPlate_showInBG = true
RBP.dbp.barlessPlate_showInArena = false
RBP.dbp.barlessPlate_showInPvE = true
RBP.dbp.barlessPlate_textFont = "Friz Quadrata TT"
RBP.dbp.barlessPlate_textSize = 14
RBP.dbp.barlessPlate_textOutline = "OUTLINE"
RBP.dbp.barlessPlate_textColor = {0.2, 0.2, 0.9}
RBP.dbp.barlessPlate_classColors = true
RBP.dbp.barlessPlate_offset = 0
RBP.dbp.barlessPlate_NPCtextFont = "Arial Narrow"
RBP.dbp.barlessPlate_NPCtextSize = 13
RBP.dbp.barlessPlate_NPCtextOutline = "OUTLINE"
RBP.dbp.barlessPlate_NPCtextColor = {0, 1, 0.1}
RBP.dbp.barlessPlate_NPCoffset = 0
RBP.dbp.barlessPlate_showHealthText = true
RBP.dbp.barlessPlate_showNPCHealthText = false
RBP.dbp.barlessPlate_healthTextSize = 11
RBP.dbp.barlessPlate_healthTextAnchor = "Bottom"
RBP.dbp.barlessPlate_healthTextOffsetX = 0
RBP.dbp.barlessPlate_healthTextOffsetY = 0
RBP.dbp.barlessPlate_showRaidTarget = false
RBP.dbp.barlessPlate_raidTargetIconSize = 30
RBP.dbp.barlessPlate_raidTargetIconAnchor = "Top"
RBP.dbp.barlessPlate_raidTargetIconOffsetX = 0
RBP.dbp.barlessPlate_raidTargetIconOffsetY = 0
RBP.dbp.barlessPlate_showClassIcon = false
RBP.dbp.barlessPlate_classIconSize = 32
RBP.dbp.barlessPlate_classIconAnchor = "Top"
RBP.dbp.barlessPlate_classIconOffsetX = 0
RBP.dbp.barlessPlate_classIconOffsetY = 0
RBP.dbp.barlessPlate_BGHiconSize = 36
RBP.dbp.barlessPlate_BGHiconAnchor = "Top"
RBP.dbp.barlessPlate_BGHiconOffsetX = 0
RBP.dbp.barlessPlate_BGHiconOffsetY = 0
-- Totem Plate
RBP.dbp.totemSize = 24 -- Size of the totem (or NPC) icon replacing the nameplate
RBP.dbp.totemOffset = 0 -- Vertical offset for totem icon
RBP.dbp.showTotemBorder = true -- Colors the totem border green (friendly) or red (enemy)
RBP.dbp.TotemsCheck = { -- 1 = Icon, 0 = Hiden, false = nameplate
	["Cleansing Totem"] = 1,
	["Earth Elemental Totem"] = 1,
	["Earthbind Totem"] = 1,
	["Fire Elemental Totem"] = 1,
	["Grounding Totem"] = 1,
	["Mana Tide Totem"] = 1,
	["Tremor Totem"] = 1,
	["Windfury Totem"] = 1,
	["Wrath of Air Totem"] = 1,
	["Sentry Totem"] = 1,
	["Fire Resistance Totem"] = 1,
	["Flametongue Totem"] = 1,
	["Frost Resistance Totem"] = 1,
	["Healing Stream Totem"] = 1,
	["Mana Spring Totem"] = 1,
	["Magma Totem"] = 1,
	["Nature Resistance Totem"] = 1,
	["Searing Totem"] = 1,
	["Stoneclaw Totem"] = 1,
	["Stoneskin Totem"] = 1,
	["Strength of Earth Totem"] = 1,
	["Totem of Wrath"] = 1,
}
-- Blacklist
RBP.dbp.Blacklist = CopyTable(RBP.Blacklist)
local tmpNewName = ""

-------------------- Options Table --------------------
RBP.MainOptionTable = {
	name = "RefinedBlizzPlates",
	type = "group",
	childGroups = "tab",
	get = function(info)
        return RBP.dbp[info[#info]]
    end,
	set = function(info, val)
        RBP.dbp[info[#info]] = val
    end,
	args = {
		General = {
			order = 1,
			name = "General",
			type = "group",
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				general_header = {
					order = 2,
					type = "header",
					name = "General Settings",
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				healthBar_border = {
					order = 4,
					type = "select",
					name = "Nameplate Style Preset",
					desc = "This will override some of your current settings to match the preset.",
					confirm = true,
					confirmText = "This will override some of your current settings to match the preset.",
					values = {
						["Refined"] = "Refined",
						["Blizzard"] = "Blizzard",
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						if val == "Blizzard" then
							RBP.dbp.globalOffsetX = -11
							RBP.dbp.nameText_font = "Friz Quadrata TT"
							RBP.dbp.nameText_size = 16
							RBP.dbp.nameText_width = 250
							RBP.dbp.levelText_hide = false
							RBP.dbp.levelText_font = "Friz Quadrata TT"
							RBP.dbp.levelText_size = 14
							RBP.dbp.ArenaIDText_font = "Friz Quadrata TT"
							RBP.dbp.ArenaIDText_size = 13
							RBP.dbp.healthText_font = "Friz Quadrata TT"
							RBP.dbp.healthText_size = 9.5
							RBP.dbp.healthText_anchor = "CENTER"
							RBP.dbp.healthText_offsetX = 11
							RBP.dbp.castText_font = "Friz Quadrata TT"
							RBP.dbp.castText_size = 10
							RBP.dbp.castText_offsetY = -0.4
							RBP.dbp.castTimerText_font = "Friz Quadrata TT"
							RBP.dbp.castTimerText_size = 9.5
							RBP.dbp.healthBar_playerTex = "Blizzard Nameplates"
							RBP.dbp.healthBar_npcTex = "Blizzard Nameplates"
							RBP.dbp.castBar_Tex = "Blizzard Nameplates"
							RBP.dbp.eliteIcon_anchor = "Right"
							RBP.dbp.raidTargetIcon_size = 35
							RBP.dbp.raidTargetIcon_anchor = "Top"
							RBP.dbp.classIcon_size = 35
							RBP.dbp.classIcon_anchor = "Top"
						else
							RBP.dbp.globalOffsetX = 0
							RBP.dbp.nameText_font = "Arial Narrow"
							RBP.dbp.nameText_size = 9
							RBP.dbp.nameText_width = 85
							RBP.dbp.levelText_hide = true
							RBP.dbp.levelText_font = "Arial Narrow"
							RBP.dbp.levelText_size = 12				
							RBP.dbp.healthText_font = "Arial Narrow"
							RBP.dbp.ArenaIDText_font = "Arial Narrow"
							RBP.dbp.ArenaIDText_size = 12
							RBP.dbp.healthText_size = 8.8
							RBP.dbp.healthText_anchor = "RIGHT"
							RBP.dbp.healthText_offsetX = 0
							RBP.dbp.castText_font = "Arial Narrow"
							RBP.dbp.castText_size = 9
							RBP.dbp.castText_offsetY = 0
							RBP.dbp.castTimerText_font = "Arial Narrow"
							RBP.dbp.castTimerText_size = 8.8
							RBP.dbp.healthBar_playerTex = "KhalBar"
							RBP.dbp.healthBar_npcTex = "KhalBar"
							RBP.dbp.castBar_Tex = "KhalBar"
							RBP.dbp.eliteIcon_anchor = "Left"
							RBP.dbp.raidTargetIcon_size = 27
							RBP.dbp.raidTargetIcon_anchor = "Right"
							RBP.dbp.classIcon_size = 26
							RBP.dbp.classIcon_anchor = "Left"
						end
						RBP.dbp.nameText_anchor = "CENTER"
						RBP.dbp.nameText_offsetX = 0
						RBP.dbp.nameText_offsetY = 0
						RBP.dbp.levelText_outline = ""
						RBP.dbp.levelText_anchor = "Right"
						RBP.dbp.levelText_offsetX = 0
						RBP.dbp.levelText_offsetY = 0
						RBP.dbp.ArenaIDText_anchor = "Right"
						RBP.dbp.ArenaIDText_offsetX = 0
						RBP.dbp.ArenaIDText_offsetY = 0
						RBP.dbp.healthText_offsetY = 0
						RBP.dbp.ArenaIDText_HideLevel = true
						RBP.dbp.castText_anchor = "CENTER"
						RBP.dbp.castText_outline = ""
						RBP.dbp.castText_width = 90
						RBP.dbp.castText_offsetX = 0
						RBP.dbp.castTimerText_outline = ""
						RBP.dbp.castTimerText_anchor = "RIGHT"
						RBP.dbp.castTimerText_offsetX = 0
						RBP.dbp.castTimerText_offsetY = 0
						RBP.dbp.bossIcon_anchor = "Right"
						RBP.dbp.bossIcon_size = 18
						RBP.dbp.bossIcon_offsetX = 0
						RBP.dbp.bossIcon_offsetY = 0
						RBP.dbp.raidTargetIcon_offsetX = 0
						RBP.dbp.raidTargetIcon_offsetY = 0
						RBP.dbp.classIcon_offsetX = 0
						RBP.dbp.classIcon_offsetY = 0
						RBP:MoveAllShownPlates(RBP.dbp.globalOffsetX - RBP.globalOffsetX, 0)
						RBP:UpdateAllTexts()
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllCastBars()
						RBP:UpdateAllIcons()
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllGlows()
						RBP:UpdateAllCastBarBorders()
						RBP:UpdateAllShownPlates()
						RBP:UpdateHitboxAttributes()
						RBP.globalOffsetX = RBP.dbp.globalOffsetX
					end,
				},
				lineBreak3 = {order = 5, type = "description", name = ""},
				lineBreak4 = {order = 6, type = "description", name = ""},
				lineBreak5 = {order = 7, type = "description", name = ""},
				globalScale = {
					order = 8,
					type = "range",
					name = "Global Scale",
					desc = "Scales both the visual size and the clickable hitbox of nameplates.",
					min = 0.5,
					max = 2.5,
					step = 0.01,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllVirtualsScale()
						RBP:UpdateHitboxAttributes()
					end,
				},
				globalOffsetX = {
					order = 9,
					type = "range",
					name = "Global Offset X",
					desc = "Affects only the nameplate's visual regions. The real hitbox can't be moved using this feature.",
					min = -50,
					max = 50,
					step = 1,
					set = function(info, val)
						RBP.dbp.globalOffsetX = val
						RBP:MoveAllShownPlates(RBP.dbp.globalOffsetX - RBP.globalOffsetX, 0)
						RBP.globalOffsetX = RBP.dbp.globalOffsetX
					end,
				},
				globalOffsetY = {
					order = 10,
					type = "range",
					name = "Global Offset Y",
					desc = "Affects only the nameplate's visual regions. The real hitbox can't be moved using this feature.",
					min = -50,
					max = 50,
					step = 1,
					set = function(info, val)
						RBP.dbp.globalOffsetY = val
						RBP:MoveAllShownPlates(0, RBP.dbp.globalOffsetY - RBP.globalOffsetY)
						RBP.globalOffsetY = RBP.dbp.globalOffsetY
					end,
				},
				lineBreak6 = {order = 11, type = "description", name = ""},
				lineBreak7 = {order = 12, type = "description", name = ""},
				lineBreak8 = {order = 13, type = "description", name = ""},
				targetScale = {
					order = 14,
					type = "range",
					name = "Target Scale Factor",
					desc = "Adjusts the target nameplate’s scale, applied multiplicatively with the global scale.",
					min = 1,
					max = 1.5,
					step = 0.01,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllVirtualsScale()
					end,
				},
				friendlyClickthrough = {
					order = 15,
					type = "toggle",
					name = "Click-through Friendly Nameplates",
					desc = "Disable friendly nameplates hitboxes inside PvE and PvP instances.",
				},
				levelFilter = {
					order = 16,
					type = "range",
					name = "Level Filter",
					desc = "Minimum unit level required for the nameplate to be shown.",
					min = 1,
					max = 80,
					step = 1,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},
				clampTarget = {
					order = 17,
					type = "toggle",
					name = "Clamp Target",
					desc = "Prevents targeted enemy nameplate from going above the top of the screen.",
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateWorldFrameHeight()
						RBP:UpdateAllShownPlates()
					end,					
				},
				clampBoss = {
					order = 18,
					type = "toggle",
					name = "Clamp Bosses",
					desc = "Prevents boss nameplates inside instances from going above the top of the screen.",
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateWorldFrameHeight()
						RBP:UpdateAllShownPlates()
					end,		
				},
				upperborder = {
					order = 19,
					type = "range",
					name = "Clamping Top Inset",
					desc = "Adjusts the distance below the top of the screen where clamped nameplates will stop.",
					min = 0,
					max = 200,
					step = 1,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not RBP.dbp.clampTarget and not RBP.dbp.clampBoss
					end,
				},
				LDWfix = {
					order = 20,
					type = "toggle",
					name = "Hide on LDW MC",
					desc = "Hide nameplates when mind-controlled by Lady Deathwhisper.",
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						if val then
							RBP.EventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")
							RBP.EventHandler:RegisterEvent("UNIT_AURA")
							RBP.inICC = false
							RBP.inLDWZone = false
							SetMapToCurrentZone()
							if GetCurrentMapAreaID() == 605 then
								RBP.inICC = true
								if GetSubZoneText() == RBP.LDWZoneText then
									RBP.inLDWZone = true
								end
							end
						else
							RBP.EventHandler:UnregisterEvent("ZONE_CHANGED_INDOORS")
							RBP.EventHandler:UnregisterEvent("UNIT_AURA")
							RBP.inICC = false
							RBP.inLDWZone = false
							if RBP.DominateMind then
								RBP.DominateMind = nil
								SetUIVisibility(true)
							end							
						end
					end,
				},
				lineBreak9 = {order = 21, type = "description", name = ""},
				lineBreak10 = {order = 22, type = "description", name = ""},
				stacking_header = {
					order = 23,
					type = "header",
					name = "Retail-like Stacking",
				},
				lineBreak11 = {order = 24, type = "description", name = ""},
				stackingEnabled = {
					order = 25,
					type = "toggle",
					name = "Enable",
					desc = "Simulates Retail's nameplate stacking for enemies. This feature has a high CPU cost, use it with discretion.",
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						if val then SetCVar("nameplateAllowOverlap", 1) end
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak12 = {order = 26, type = "description", name = ""},
				lineBreak13 = {order = 27, type = "description", name = ""},
				xspace = {
					order = 28,
					type = "range",
					name = "Collider Width",
					desc = "Sets the width of the virtual collider centered on each nameplate used to detect overlaps.",
					min = 20,
					max = 200,
					step = 1,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				yspace = {
					order = 29,
					type = "range",
					name = "Collider Height",
					desc = "Sets the height of the virtual collider centered on each nameplate used to detect overlaps.",
					min = 5,
					max = 50,
					step = 1,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				originpos = {
					order = 30,
					type = "range",
					name = "Vertical Offset",
					desc = "Vertically offsets the entire nameplate, including its hitbox.",
					min = 0,
					max = 50,
					step = 1,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				lineBreak14 = {order = 31, type = "description", name = ""},
				lineBreak15 = {order = 32, type = "description", name = ""},
				FreezeMouseover = {
					order = 33,
					type = "toggle",
					name = "Freeze Mouseover",
					desc = "Stops the nameplate you're mousing over from moving for better selection.",
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				stackingInInstance = {
					order = 34,
					type = "toggle",
					name = "Disable in Open World",
					desc = "Only process stacking inside PvE and PvP instances. This will reduce CPU usage in the open world.",
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				lineBreak16 = {order = 35, type = "description", name = ""},
				lineBreak17 = {order = 36, type = "description", name = ""},
			},
		},
		Text = {
			order = 2,
			name = "Text",
			type = "group",
			set = function(info, val)
				RBP.dbp[info[#info]] = val
				RBP:UpdateAllTexts()
				RBP:UpdateAllShownPlates()
			end,
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				nameText_header = {
					order = 2,
					type = "header",
					name = "Name Text",
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				nameText_font = {
					order = 4,
					type = "select",
					name = "Text Font",
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_size = {
					order = 5,
					type = "range",
					name = "Font Size",
					min = 6,
					max = 18,
					step = 0.1,
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_outline = {
					order = 6,
					type = "select", 
					name = "Outline",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
						["MONOCHROME"] = "Monochrome",
						["OUTLINE,MONOCHROME"] = "Monochrome Outline",
						["THICKOUTLINE,MONOCHROME"] = "Monochrome Thick Outline",
					},
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_anchor = {
					order = 7,
					type = "select", 
					name = "Anchor",
					values = {
						["LEFT"] = "LEFT",
						["CENTER"] = "CENTER",
						["RIGHT"] = "RIGHT"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.nameText_offsetX = 0
						RBP.dbp.nameText_offsetY = 0
						RBP:UpdateAllTexts()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_offsetX = {
					order = 8,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_offsetY = {
					order = 9,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_color = {
					order = 10,
					type = "color",
					name = "Base Text Color",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllTexts()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_classColorFriends = {
					order = 11,
					type = "toggle",
					name = "Class Colors on Friends",
					desc = "Use class colors for friendly player names (only works for party or raid members).",
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_classColorEnemies = {
					order = 12,
					type = "toggle",
					name = "Class Colors on Enemies",
					desc = "Use class colors for enemy player names. 'Class Colors in Nameplates' must be enabled.",
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_width = {
					order = 13,
					type = "range",
					name = "Width",
					min = 50,
					max = 250,
					step = 1,
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_hide = {
					order = 14,
					type = "toggle",
					name = "Hide Name Text",
				},
				lineBreak3 = {order = 15, type = "description", name = ""},
				lineBreak4 = {order = 16, type = "description", name = ""},
				levelText_header = {
					order = 17,
					type = "header",
					name = "Level Text",
				},
				lineBreak5 = {order = 18, type = "description", name = ""},
				levelText_font = {
					order = 19,
					type = "select",
					name = "Text Font",
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.levelText_hide
					end,
				},
				levelText_size = {
					order = 20,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function()
						return RBP.dbp.levelText_hide
					end,
				},
				levelText_outline = {
					order = 21,
					type = "select", 
					name = "Outline",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
						["MONOCHROME"] = "Monochrome",
						["OUTLINE,MONOCHROME"] = "Monochrome Outline",
						["THICKOUTLINE,MONOCHROME"] = "Monochrome Thick Outline",
					},
					disabled = function()
						return RBP.dbp.levelText_hide
					end,
				},
				levelText_anchor = {
					order = 22,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Center"] = "Center",
						["Right"] = "Right"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.levelText_offsetX = 0
						RBP.dbp.levelText_offsetY = 0
						RBP:UpdateAllTexts()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return RBP.dbp.levelText_hide
					end,
				},
				levelText_offsetX = {
					order = 23,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.levelText_hide
					end,
				},
				levelText_offsetY = {
					order = 24,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.levelText_hide
					end,
				},
				levelText_hide = {
					order = 25,
					type = "toggle",
					name = "Hide Level Text",
				},
				lineBreak6 = {order = 26, type = "description", name = ""},
				ArenaIDText_header = {
					order = 27,
					type = "header",
					name = "Arena/Party ID Text",
				},
				lineBreak7 = {order = 28, type = "description", name = ""},
				lineBreak8 = {order = 29, type = "description", name = ""},
				ArenaIDText_SharedConfig = {
					order = 30, 
					type = "description", 
					name = "Shared Settings",
					fontSize = "medium",
				},
				lineBreak9 = {order = 31, type = "description", name = ""},
				ArenaIDText_font = {
					order = 32,
					type = "select",
					name = "Text Font",
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return not RBP.dbp.ArenaIDText_show and not RBP.dbp.PartyIDText_show
					end,
				},
				ArenaIDText_size = {
					order = 33,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.ArenaIDText_show and not RBP.dbp.PartyIDText_show
					end,
				},
				ArenaIDText_outline = {
					order = 34,
					type = "select", 
					name = "Outline",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
						["MONOCHROME"] = "Monochrome",
						["OUTLINE,MONOCHROME"] = "Monochrome Outline",
						["THICKOUTLINE,MONOCHROME"] = "Monochrome Thick Outline",
					},
					disabled = function()
						return not RBP.dbp.ArenaIDText_show and not RBP.dbp.PartyIDText_show
					end,
				},
				ArenaIDText_anchor = {
					order = 35,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Center"] = "Center",
						["Right"] = "Right"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.ArenaIDText_offsetX = 0
						RBP.dbp.ArenaIDText_offsetY = 0
						RBP:UpdateAllTexts()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not RBP.dbp.ArenaIDText_show and not RBP.dbp.PartyIDText_show
					end,
				},
				ArenaIDText_offsetX = {
					order = 36,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.ArenaIDText_show and not RBP.dbp.PartyIDText_show
					end,
				},
				ArenaIDText_offsetY = {
					order = 37,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.ArenaIDText_show and not RBP.dbp.PartyIDText_show
					end,
				},
				lineBreak10 = {order = 38, type = "description", name = ""},
				lineBreak11 = {order = 39, type = "description", name = ""},
				ArenaIDText_show = {
					order = 40,
					type = "toggle",
					name = "Show ArenaID",
					desc = "Shows Arena ID numbers on nameplates in arena",
					width = "full",
				},
				ArenaIDText_color = {
					order = 41,
					type = "color",
					name = "ArenaID Color",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllTexts()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not RBP.dbp.ArenaIDText_show
					end,
				},
				ArenaIDText_HideName = {
					order = 42,
					type = "toggle",
					name = "Hide Enemy Name",
					desc = "Hide name text on arena enemies",
					disabled = function()
						return not RBP.dbp.ArenaIDText_show or RBP.dbp.nameText_hide
					end,
				},
				ArenaIDText_HideLevel = {
					order = 43,
					type = "toggle",
					name = "Hide Enemy Level",
					desc = "Hide level text on arena enemies",
					disabled = function() return
						not RBP.dbp.ArenaIDText_show or RBP.dbp.levelText_hide
					end,
				},
				lineBreak12 = {order = 44, type = "description", name = ""},
				lineBreak13 = {order = 45, type = "description", name = ""},
				lineBreak14 = {order = 46, type = "description", name = ""},
				PartyIDText_show = {
					order = 47,
					type = "toggle",
					name = "Show PartyID",
					desc = "Shows Party ID numbers on nameplates in arena",
					width = "full",
				},
				PartyIDText_color = {
					order = 48,
					type = "color",
					name = "PartyID Color",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllTexts()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() return
						not RBP.dbp.PartyIDText_show
					end,
				},
				PartyIDText_HideName = {
					order = 49,
					type = "toggle",
					name = "Hide Friend Name",
					desc = "Hide name text on party",
					disabled = function()
						return not RBP.dbp.PartyIDText_show or RBP.dbp.nameText_hide
					end,
				},
				PartyIDText_HideLevel = {
					order = 50,
					type = "toggle",
					name = "Hide Friend Level",
					desc = "Hide level text on party",
					disabled = function()
						return not RBP.dbp.PartyIDText_show or RBP.dbp.levelText_hide
					end,
				},
				lineBreak15 = {order = 51, type = "description", name = ""},
				lineBreak16 = {order = 52, type = "description", name = ""},
			},
		},
		HealthBar = {
			order = 3,
			name = "Health Bar",
			type = "group",
			set = function(info, val)
				RBP.dbp[info[#info]] = val
				RBP:UpdateAllHealthBars()
			end,
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				healthBar_header = {
					order = 2,
					type = "header",
					name = "Appearance",
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				healthBar_playerTex = {
					order = 4,
					type = "select",
					name = "Player Bar Texture",
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
				},			
				healthBar_npcTex = {
					order = 5,
					type = "select",
					name = "NPC Bar Texture",
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
				},
				lineBreak3 = {order = 6, type = "description", name = ""},
				healthBar_borderTint = {
					order = 7,
					type = "color",
					name = "Border Tint",
					desc = "This is a tint overlay, not a regular color. 'White' keeps the original look.",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllHealthBars()
					end,
				},
				lineBreak4 = {order = 8, type = "description", name = ""},
				lineBreak5 = {order = 9, type = "description", name = ""},
				healthBarGlow_header = {
					order = 10,
					type = "header",
					name = "Glows",
				},
				lineBreak6 = {order = 11, type = "description", name = ""},
				targetGlow_Tint = {
					order = 12,
					type = "color",
					name = "Target Glow Tint",
					desc = "This is a tint overlay, not a regular color. 'White' keeps the original look.",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllGlows()
						RBP:UpdateAllShownPlates()
					end,
				},
				mouseoverGlow_Tint = {
					order = 13,
					type = "color",
					name = "Mouseover Glow Tint",
					desc = "This is a tint overlay, not a regular color. 'White' keeps the original look.",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllGlows()
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak7 = {order = 14, type = "description", name = ""},
				lineBreak8 = {order = 15, type = "description",	name = ""},
				healthText_header = {
					order = 16,
					type = "header",
					name = "Health Text",
				},
				lineBreak9 = {order = 17, type = "description", name = ""},
				healthText_font = {
					order = 18,
					type = "select",
					name = "Text Font",
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_size = {
					order = 19,
					type = "range",
					name = "Font Size",
					min = 6,
					max = 18,
					step = 0.1,
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_outline = {
					order = 20,
					type = "select", 
					name = "Outline",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
						["MONOCHROME"] = "Monochrome",
						["OUTLINE,MONOCHROME"] = "Monochrome Outline",
						["THICKOUTLINE,MONOCHROME"] = "Monochrome Thick Outline",
					},
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_anchor = {
					order = 21,
					type = "select", 
					name = "Anchor",
					values = {
						["LEFT"] = "Left",
						["CENTER"] = "Center",
						["RIGHT"] = "Right"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.healthText_offsetX = 0
						RBP.dbp.healthText_offsetY = 0
						RBP:UpdateAllHealthBars()
					end,
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_offsetX = {
					order = 22,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_offsetY = {
					order = 23,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_color = {
					order = 24,
					type = "color",
					name = "Text Color",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllHealthBars()
					end,
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_hide = {
					order = 25,
					type = "toggle",
					name = "Hide Health Text",
				},
				lineBreak10 = {order = 26, type = "description", name = ""},
				lineBreak11 = {order = 27, type = "description", name = ""},
			},
		},
		CastBar = {
			order = 4,
			name = "Cast Bar",
			type = "group",
			set = function(info, val)
				RBP.dbp[info[#info]] = val
				RBP:UpdateAllCastBars()
			end,
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				castBar_header = {
					order = 2,
					type = "header",
					name = "Appearance",
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				castBar_Tex = {
					order = 4,
					type = "select",
					name = "Bar Texture",
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
				},
				lineBreak3 = {order = 5, type = "description", name = ""},
				lineBreak4 = {order = 6, type = "description", name = ""},
				castText_header = {
					order = 7,
					type = "header",
					name = "Cast Text",
				},
				lineBreak5 = {order = 8, type = "description", name = ""},
				castText_font = {
					order = 9,
					type = "select",
					name = "Text Font",
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_size = {
					order = 10,
					type = "range",
					name = "Font Size",
					min = 6,
					max = 18,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_outline = {
					order = 11,
					type = "select", 
					name = "Outline",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
						["MONOCHROME"] = "Monochrome",
						["OUTLINE,MONOCHROME"] = "Monochrome Outline",
						["THICKOUTLINE,MONOCHROME"] = "Monochrome Thick Outline",
					},
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_anchor = {
					order = 12,
					type = "select", 
					name = "Anchor",
					values = {
						["LEFT"] = "Left",
						["CENTER"] = "Center",
						["RIGHT"] = "Right"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.castText_offsetX = 0
						RBP.dbp.castText_offsetY = 0
						RBP:UpdateAllCastBars()
					end,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_offsetX = {
					order = 13,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_offsetY = {
					order = 14,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_width = {
					order = 15,
					type = "range",
					name = "Width",
					min = 50,
					max = 250,
					step = 1,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_color = {
					order = 16,
					type = "color",
					name = "Text Color",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllCastBars()
					end,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_hide = {
					order = 17,
					type = "toggle",
					name = "Hide Cast Text",
				},
				lineBreak6 = {order = 18, type = "description", name = ""},
				lineBreak7 = {order = 19, type = "description",	name = ""},
				castTimerText_header = {
					order = 20,
					type = "header",
					name = "Cast Timer Text",
				},
				lineBreak8 = {order = 21, type = "description", name = ""},
				castTimerText_font = {
					order = 22,
					type = "select",
					name = "Text Font",
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_size = {
					order = 23,
					type = "range",
					name = "Font Size",
					min = 6,
					max = 18,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_outline = {
					order = 24,
					type = "select", 
					name = "Outline",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
						["MONOCHROME"] = "Monochrome",
						["OUTLINE,MONOCHROME"] = "Monochrome Outline",
						["THICKOUTLINE,MONOCHROME"] = "Monochrome Thick Outline",
					},
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_anchor = {
					order = 25,
					type = "select", 
					name = "Anchor",
					values = {
						["LEFT"] = "Left",
						["CENTER"] = "Center",
						["RIGHT"] = "Right"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.castTimerText_offsetX = 0
						RBP.dbp.castTimerText_offsetY = 0
						RBP:UpdateAllCastBars()
					end,
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_offsetX = {
					order = 26,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_offsetY = {
					order = 27,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_color = {
					order = 28,
					type = "color",
					name = "Text Color",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllCastBars()
					end,
					disabled = function() 
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_hide = {
					order = 29,
					type = "toggle",
					name = "Hide Cast Timer Text",
				},
				lineBreak9 = {order = 30, type = "description", name = ""},
				lineBreak10 = {order = 31, type = "description", name = ""},
			},
		},
		Icons = {
			order = 5,
			name = "Icons",
			type = "group",
			set = function(info, val)
				RBP.dbp[info[#info]] = val
				RBP:UpdateAllIcons()
				RBP:UpdateAllShownPlates()
			end,
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				eliteIcon_header = {
					order = 2,
					type = "header",
					name = "Elite Icon",
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				eliteIcon_anchor = {
					order = 4,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Right"] = "Right"
					},
				},
				eliteIcon_Tint = {
					order = 5,
					type = "color",
					name = "Tint",
					desc = "This is a tint overlay, not a regular color. 'White' keeps the original look.",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak3 = {order = 6, type = "description", name = ""},
				lineBreak4 = {order = 7, type = "description", name = ""},
				bossIcon_header = {
					order = 8,
					type = "header",
					name = "Boss Icon",
				},
				lineBreak5 = {order = 9, type = "description", name = ""},
				bossIcon_anchor = {
					order = 10,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Top"] = "Top",
						["Right"] = "Right"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.bossIcon_offsetX = 0
						RBP.dbp.bossIcon_offsetY = 0
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
				},
				bossIcon_offsetX = {
					order = 11,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
				},
				bossIcon_offsetY = {
					order = 12,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
				},
				bossIcon_size = {
					order = 13,
					type = "range",
					name = "Icon Size",
					min = 15,
					max = 35,
					step = 0.1,
				},
				lineBreak6 = {order = 14, type = "description",	name = ""},
				lineBreak7 = {order = 15, type = "description", name = ""},
				raidTargetIcon_header = {
					order = 16,
					type = "header",
					name = "Raid Target Icon",
				},
				lineBreak8 = {order = 17, type = "description",	name = ""},
				raidTargetIcon_anchor = {
					order = 18,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Top"] = "Top",
						["Right"] = "Right"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.raidTargetIcon_offsetX = 0
						RBP.dbp.raidTargetIcon_offsetY = 0
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
				},
				raidTargetIcon_offsetX = {
					order = 19,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
				},
				raidTargetIcon_offsetY = {
					order = 20,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
				},
				raidTargetIcon_size = {
					order = 21,
					type = "range",
					name = "Icon Size",
					min = 20,
					max = 50,
					step = 0.1,
				},
				lineBreak9 = {order = 22, type = "description", name = ""},
				lineBreak10 = {order = 23, type = "description", name = ""},
				classIcon_header = {
					order = 24,
					type = "header",
					name = "Class Icon",
				},
				lineBreak11 = {order = 25, type = "description", name = ""},
				classIcon_anchor = {
					order = 26,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Top"] = "Top",
						["Right"] = "Right"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.classIcon_offsetX = 0
						RBP.dbp.classIcon_offsetY = 0
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
				},
				classIcon_offsetX = {
					order = 27,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
				},
				classIcon_offsetY = {
					order = 28,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
				},
				classIcon_size = {
					order = 29,
					type = "range",
					name = "Icon Size",
					min = 20,
					max = 50,
					step = 0.1,
				},
				showClassOnFriends = {
					order = 30,
					type = "toggle",
					name = "Show on Friends",
					desc = "Class icons will only be shown inside PvE or PvP instances.",
				},
				showClassOnEnemies = {
					order = 31,
					type = "toggle",
					name = "Show on Enemies",
					desc = "Class icons will only be shown inside PvE or PvP instances.",
				},
				lineBreak12 = {order = 32, type = "description", name = ""},
				lineBreak13 = {order = 33, type = "description", name = ""},
			},
		},
		BarlessPlate = {
			order = 6,
			name = "Barless Plate",
			type = "group",
			set = function(info, val)
				RBP.dbp[info[#info]] = val
				RBP:UpdateAllBarlessPlates()
				RBP:UpdateAllShownPlates()
			end,
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				barlessPlate_Header = {
					order = 2,
					type = "header",
					name = "Barless Plate Enabling",
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				lineBreak3 = {order = 4, type = "description", name = ""},
				barlessPlate_showInPvE = {
					order = 5,
					type = "toggle",
					name = "Enable in PvE",
					desc = "Replace friendly nameplates with a barless layout: name text and anchored indicators.",
				},
				barlessPlate_showInBG = {
					order = 6,
					type = "toggle",
					name = "Enable in BGs",
					desc = "Replace friendly nameplates with a barless layout: name text and anchored indicators.",
				},
				barlessPlate_showInArena = {
					order = 7,
					type = "toggle",
					name = "Enable in Arenas",
					desc = "Replace friendly nameplates with a barless layout: name text and anchored indicators.",
				},
				lineBreak4 = {order = 8, type = "description", name = ""},
				lineBreak5 = {order = 9, type = "description", name = ""},
				barlessPlate_nameHeader = {
					order = 10,
					type = "header",
					name = "Player Name Text",
				},
				lineBreak6 = {order = 11, type = "description", name = ""},
				barlessPlate_textFont = {
					order = 12,
					type = "select",
					name = "Text Font",
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_textSize = {
					order = 13,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
						RBP:UpdateHitboxAttributes()
					end,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_textOutline = {
					order = 14,
					type = "select", 
					name = "Outline",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
						["MONOCHROME"] = "Monochrome",
						["OUTLINE,MONOCHROME"] = "Monochrome Outline",
						["THICKOUTLINE,MONOCHROME"] = "Monochrome Thick Outline",
					},
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_offset = {
					order = 15,
					type = "range",
					name = "Offset Y",
					desc = "Adjusts the visual vertical position (does not affect the hitbox).",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_textColor = {
					order = 16,
					type = "color",
					name = "Text color",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_classColors = {
					order = 17,
					type = "toggle",
					name = "Use class color",
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},

				lineBreak7 = {order = 18, type = "description", name = ""},
				lineBreak8 = {order = 19, type = "description", name = ""},
				barlessPlate_NPCnameHeader = {
					order = 20,
					type = "header",
					name = "NPC Name Text",
				},
				lineBreak9 = {order = 21, type = "description", name = ""},
				barlessPlate_NPCtextFont = {
					order = 22,
					type = "select",
					name = "Text Font",
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_NPCtextSize = {
					order = 23,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_NPCtextOutline = {
					order = 24,
					type = "select", 
					name = "Outline",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
						["MONOCHROME"] = "Monochrome",
						["OUTLINE,MONOCHROME"] = "Monochrome Outline",
						["THICKOUTLINE,MONOCHROME"] = "Monochrome Thick Outline",
					},
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_NPCoffset = {
					order = 25,
					type = "range",
					name = "Offset Y",
					desc = "Adjusts the visual vertical position (does not affect the hitbox).",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_NPCtextColor = {
					order = 26,
					type = "color",
					name = "Text color",
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				lineBreak10 = {order = 27, type = "description", name = ""},
				lineBreak11 = {order = 28, type = "description", name = ""},
				barlessPlate_healthHeader = {
					order = 29,
					type = "header",
					name = "Health Text",
				},				
				lineBreak12 = {order = 30, type = "description", name = ""},
				barlessPlate_showHealthText = {
					order = 31,
					type = "toggle",
					name = "Show in Players",
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_showNPCHealthText = {
					order = 32,
					type = "toggle",
					name = "Show in NPCs",
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				lineBreak13 = {order = 33, type = "description", name = ""},
				barlessPlate_healthTextAnchor = {
					order = 34,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Top"] = "Top",
						["Right"] = "Right",
						["Bottom"] = "Bottom",
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_healthTextOffsetX = 0
						RBP.dbp.barlessPlate_healthTextOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showHealthText or RBP.dbp.barlessPlate_showNPCHealthText) or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_healthTextOffsetX = {
					order = 35,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showHealthText or RBP.dbp.barlessPlate_showNPCHealthText) or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_healthTextOffsetY = {
					order = 36,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showHealthText or RBP.dbp.barlessPlate_showNPCHealthText) or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_healthTextSize = {
					order = 37,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function()
						return not (RBP.dbp.barlessPlate_showHealthText or RBP.dbp.barlessPlate_showNPCHealthText) or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				lineBreak14 = {order = 38, type = "description", name = ""},
				lineBreak15 = {order = 39, type = "description", name = ""},
				barlessPlate_raidIconHeader = {
					order = 40,
					type = "header",
					name = "Raid Target Icon",
				},				
				lineBreak16 = {order = 41, type = "description", name = ""},
				barlessPlate_showRaidTarget = {
					order = 42,
					type = "toggle",
					name = "Show Raid Target Icon",
					width = "full",
					disabled = function()
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				lineBreak17 = {order = 43, type = "description", name = ""},
				barlessPlate_raidTargetIconAnchor = {
					order = 44,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Top"] = "Top",
						["Right"] = "Right",
						["Bottom"] = "Bottom"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_raidTargetIconOffsetX = 0
						RBP.dbp.barlessPlate_raidTargetIconOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showRaidTarget or not (RBP.dbp.barlessPlate_showInPvE	or RBP.dbp.barlessPlate_showInBG	or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_raidTargetIconOffsetX = {
					order = 45,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showRaidTarget or not (RBP.dbp.barlessPlate_showInPvE	or RBP.dbp.barlessPlate_showInBG	or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_raidTargetIconOffsetY = {
					order = 46,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showRaidTarget or not (RBP.dbp.barlessPlate_showInPvE	or RBP.dbp.barlessPlate_showInBG	or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_raidTargetIconSize = {
					order = 47,
					type = "range",
					name = "Icon Size",
					min = 20,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showRaidTarget or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				lineBreak18 = {order = 48, type = "description", name = ""},
				lineBreak19 = {order = 49, type = "description", name = ""},
				barlessPlate_classIconHeader = {
					order = 50,
					type = "header",
					name = "Class Icon",
				},				
				lineBreak20 = {order = 51, type = "description", name = ""},
				barlessPlate_showClassIcon = {
					order = 52,
					type = "toggle",
					name = "Show Class Icon",
					disabled = function() 
						return not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				lineBreak21 = {order = 53, type = "description", name = ""},
				barlessPlate_classIconAnchor = {
					order = 54,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Top"] = "Top",
						["Right"] = "Right",
						["Bottom"] = "Bottom"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_classIconOffsetX = 0
						RBP.dbp.barlessPlate_classIconOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showClassIcon or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_classIconOffsetX = {
					order = 55,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showClassIcon or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_classIconOffsetY = {
					order = 56,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showClassIcon or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				barlessPlate_classIconSize = {
					order = 57,
					type = "range",
					name = "Icon Size",
					min = 20,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showClassIcon or not (RBP.dbp.barlessPlate_showInPvE or RBP.dbp.barlessPlate_showInBG or RBP.dbp.barlessPlate_showInArena)
					end,
				},
				lineBreak22 = {order = 58, type = "description", name = ""},
				lineBreak23 = {order = 59, type = "description", name = ""},
				barlessPlate_BGHiconHeader = {
					order = 60,
					type = "header",
					name = "BG Healer Icon",
				},				
				lineBreak24 = {order = 61, type = "description", name = ""},
				lineBreak25 = {order = 62, type = "description", name = ""},
				barlessPlate_BGHiconDesc = {
					order = 63,
					type = "description",
					fontSize = "medium",
					name = function()
						if not IsAddOnLoaded("BattleGroundHealers") then
							return "|cff808080This feature is available only when BattleGroundHealers is loaded.|r"
						elseif not RBP.dbp.barlessPlate_showInBG then
							return "|cff808080These settings will replace some of BattleGroundHealers’ icon configuration for Barless Plates.|r"
						else
							return "These settings will replace some of BattleGroundHealers’ icon configuration for Barless Plates."
						end
					end,
				},
				lineBreak26 = {order = 64, type = "description", name = ""},
				lineBreak27 = {order = 65, type = "description", name = ""},
				barlessPlate_BGHiconAnchor = {
					order = 66,
					type = "select", 
					name = "Anchor",
					values = {
						["Left"] = "Left",
						["Top"] = "Top",
						["Right"] = "Right",
						["Bottom"] = "Bottom"
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_BGHiconOffsetX = 0
						RBP.dbp.barlessPlate_BGHiconOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return not (RBP.dbp.barlessPlate_showInBG and IsAddOnLoaded("BattleGroundHealers"))
					end,
				},
				barlessPlate_BGHiconOffsetX = {
					order = 67,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not (RBP.dbp.barlessPlate_showInBG and IsAddOnLoaded("BattleGroundHealers"))
					end,
				},
				barlessPlate_BGHiconOffsetY = {
					order = 68,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not (RBP.dbp.barlessPlate_showInBG and IsAddOnLoaded("BattleGroundHealers"))
					end,
				},
				barlessPlate_BGHiconSize = {
					order = 69,
					type = "range",
					name = "Icon Size",
					min = 20,
					max = 60,
					step = 0.1,
					disabled = function() 
						return not (RBP.dbp.barlessPlate_showInBG and IsAddOnLoaded("BattleGroundHealers"))
					end,
				},
				lineBreak28 = {order = 70, type = "description", name = ""},
				lineBreak29 = {order = 71, type = "description", name = ""},
			},
		},
		Totems = {
			order = 7,
			name = "Totems",
			type = "group",
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				Totem_header = {
					order = 2,
					type = "header",
					name = "Totem Icon",
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				lineBreak3 = {order = 4, type = "description", name = ""},	
				totemSize = {
					order = 5,
					type = "range",
					name = "Icon Size",
					desc = "Controls the size of all Totem and Blacklisted icons.",
					min = 15,
					max = 35,
					step = 0.1,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
						RBP:UpdateHitboxAttributes()
					end,
				},
				totemOffset = {
					order = 6,
					type = "range",
					name = "Offset Y",
					desc = "Adjusts the vertical position of all Totem and Blacklisted icons (does not affect plate hitbox).",
					min = -50,
					max = 50,
					step = 0.1,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
				},
				showTotemBorder = {
					order = 7,
					type = "toggle",
					name = "Show Reaction Border",
					desc = "Displays a colored border based on reaction.",
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak4 = {order = 8, type = "description", name = ""},
				lineBreak5 = {order = 9, type = "description", name = ""},
				lineBreak6 = {order = 10, type = "description", name = ""},	
			}
		},
		BlackList = {
			order = 8,
			name = "Blacklist",
			type = "group",
			args = {
				inputName = {
					order = 1,
					type = "input",
					name = "Unit name",
					desc = "Add the exact name of a unit whose nameplate you want to hide or replace with an icon. Blacklisted nameplates will always be click-through.",
					get = function() return tmpNewName end,
					set = function(_, val) tmpNewName = val end,
				},
				targetName = {
					order = 2,
					type = "execute",
					name = "Set target name",
					func = function()
						local target = UnitName("target")
						if target then 
							tmpNewName = target
						else
							tmpNewName = ""
						end
					end,
				},
				addName = {
					order = 3,
					type = "execute",
					name = "Add to blacklist",
					func = function()
						if tmpNewName == "" then return end
						if not RBP.dbp.Blacklist[tmpNewName] then
							RBP.dbp.Blacklist[tmpNewName] = ""
							RBP:BuildBlacklistUI()
							RBP:UpdateAllShownPlates()
							LibStub("AceConfigDialog-3.0"):SelectGroup("RefinedBlizzPlates", "BlackList", tmpNewName)
							tmpNewName = ""
						else
							tmpNewName = ""
						end
					end,
				},
				lineBreak = {order = 4, type = "description", name = ""},
				resetList = {
					order = 5,
					type = "execute",
					name = "Reset",
					desc = "Restore the default blacklist",
					confirm = true,
					confirmText = "Are you sure you want to restore the default blacklist?",
					func = function()
						RBP.dbp.Blacklist = CopyTable(RBP.Blacklist)
						RBP:BuildBlacklistUI()
						RBP:UpdateAllShownPlates()
					end,
				},
			},
		},
	},
}

local TotemOrder = { "earth", "fire", "water", "air" }

local TotemTextColor = {
	["earth"] = "|cFFCCAA00",
	["fire"]  = "|cFFFF5555",
	["water"] = "|cFF3366FF",
	["air"]   = "|cFF77DDFF",
}

local TotemGroups = {
	["earth"] = {
		"Earth Elemental Totem",
		"Earthbind Totem",
		"Stoneclaw Totem",
		"Stoneskin Totem",
		"Strength of Earth Totem",
		"Tremor Totem",
	},
	["fire"] = {
		"Fire Elemental Totem",
		"Flametongue Totem",
		"Frost Resistance Totem",
		"Magma Totem",
		"Searing Totem",
		"Totem of Wrath",
	},
	["water"] = {
		"Cleansing Totem",
		"Fire Resistance Totem",
		"Healing Stream Totem",
		"Mana Spring Totem",
		"Mana Tide Totem",
	},
	["air"] = {
		"Grounding Totem",
		"Nature Resistance Totem",
		"Sentry Totem",
		"Windfury Totem",
		"Wrath of Air Totem",
	},
}

local TotemIDs = {
    ["Earth Elemental Totem"] = 2062,
    ["Earthbind Totem"] = 2484,
    ["Stoneclaw Totem"] = 58582,
    ["Stoneskin Totem"] = 58753,
    ["Strength of Earth Totem"] = 58643,
    ["Tremor Totem"] = 8143,
    ["Fire Elemental Totem"] = 2894,
    ["Flametongue Totem"] = 58656,
    ["Frost Resistance Totem"] = 58745,
    ["Magma Totem"] = 58734,
    ["Searing Totem"] = 58704,
    ["Totem of Wrath"] = 57722,
    ["Cleansing Totem"] = 8170,
    ["Fire Resistance Totem"] = 58739,
    ["Healing Stream Totem"] = 58757,
    ["Mana Spring Totem"] = 58774,
    ["Mana Tide Totem"] = 16190,
    ["Grounding Totem"] = 8177,
    ["Nature Resistance Totem"] = 58749,
    ["Sentry Totem"] = 6495,
    ["Windfury Totem"] = 8512,
    ["Wrath of Air Totem"] = 3738,
}

local tooltip = CreateFrame("GameTooltip", "RefinedBlizzPlatesTooltip", UIParent, "GameTooltipTemplate")
tooltip:Show()
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

function RBP:UpdateTotemDesc()
	for name, group in pairs(RBP.MainOptionTable.args.Totems.args) do
		local spellID = TotemIDs[name]
		if spellID then
			tooltip:SetHyperlink("spell:" .. spellID)
			local lines = tooltip:NumLines()
			if lines > 0 then
				group.args.desc.name = _G["RefinedBlizzPlatesTooltipTextLeft" .. lines]:GetText() or ""
			end
		end
	end
end

for i, element in ipairs(TotemOrder) do 
 	for j, name in ipairs(TotemGroups[element]) do
        local spellID = TotemIDs[name]
		local totemName, _, icon = GetSpellInfo(spellID)
        local iconString = "\124T" .. icon .. ":26\124t"
		RBP.MainOptionTable.args.Totems.args[name] = {
			type = "group",
			name = iconString .. TotemTextColor[element] .. totemName .. "|r",
			order = 10*i + j,
			args = {
				header = {
					type = "header",
					name = totemName,
					order = 1,
				},
				lineBreak1 = {order = 2, type = "description", name = ""},
				lineBreak2 = {order = 3, type = "description", name = ""},
				desc = {
					order = 4,
					type = "description",
					name = "",
					image = icon,
					imageWidth = 32,
					imageHeight = 32,
				},
				lineBreak3 = {order = 5, type = "description", name = ""},
				lineBreak4 = {order = 6, type = "description", name = ""},
				lineBreak5 = {order = 7, type = "description", name = ""},
				enable = {
					type = "toggle",
					name = "Enable TotemPlate",
					desc = "Replaces the nameplate with a totem icon.",
					order = 8,
					get = function()
						return RBP.dbp.TotemsCheck[name] ~= false
					end,
					set = function(_, val)
						RBP.dbp.TotemsCheck[name] = val and (RBP.dbp.TotemsCheck[name] or 1) or false
						RBP:UpdateAllShownPlates()
					end,
				},
				hide = {
					type = "toggle",
					name = "Hide Totem",
					desc = "Completely hides the nameplate and the totemplate for this totem.",
					order = 9,
					get = function()
						return RBP.dbp.TotemsCheck[name] == 0
					end,
					set = function(_, val)
						RBP.dbp.TotemsCheck[name] = val and 0 or 1
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return RBP.dbp.TotemsCheck[name] == false 
					end,
				},
			},
		}
	end
end

function RBP:BuildBlacklistUI()
    local args = RBP.MainOptionTable.args.BlackList.args
	for k, v in pairs(args) do
		if v.order > 5 then
			args[k] = nil
		end
	end
    local namesList = {}
    for name, value in pairs(RBP.dbp.Blacklist) do
		if value then
			table.insert(namesList, name)
		end
	end
    table.sort(namesList, function(a, b) return a < b end)
    for i, name in ipairs(namesList) do
        local iconPath = RBP.dbp.Blacklist[name]
        args[name] = {
            order = i + 5,
            type = "group",
            name = name,
            args = {
                header = {
					order = 1,
					type = "header", 
					name = name, 
				},
                iconPath = {
                    order = 2,
                    type = "input",
                    name = "Icon Path",
					desc = "Enter the path to an icon texture to replace the nameplate, or leave it empty to hide it completely.",
                    width = "full",
                    get = function() return RBP.dbp.Blacklist[name] end,
                    set = function(_, val)
                        RBP.dbp.Blacklist[name] = val
                        RBP:BuildBlacklistUI()
						RBP:UpdateAllShownPlates()
                    end,
                },
				lineBreak1 = {order = 3, type = "description", name = ""},
				lineBreak2 = {order = 4, type = "description", name = ""},
                iconPreview = {
                    order = 5,
                    type = "description",
                    name = "",
                    image = iconPath ~= "" and iconPath or nil,
                    imageWidth = 42,
                    imageHeight = 42,
                },
				lineBreak3 = {order = 6, type = "description", name = ""},
				lineBreak4 = {order = 7, type = "description", name = ""},
				lineBreak5 = {order = 8, type = "description", name = ""},
				lineBreak6 = {order = 9, type = "description", name = ""},
                remove = {
                    order = 10,
                    type = "execute",
                    name = "Remove",
					desc = "Remove this unit from the blacklist",
					confirm = true,
					confirmText = "Are you sure you want to remove this unit from the blacklist?",
                    func = function()
                		RBP.dbp.Blacklist[name] = false
						RBP:BuildBlacklistUI()
						RBP:UpdateAllShownPlates()
                    end,
                },
            },
        }
    end
end

RBP.AboutTable = {
	name = "About",
	type = "group",
	childGroups = "tab",
	args = (function()
		local args = {}
		local fields = {
			"Title",
			"Notes",
			"Version",
			"Author",
			"X-Date",
			"X-Repository",
		}
		for i, field in ipairs(fields) do
			local val = GetAddOnMetadata(AddonFile, field)
			if val then
				if field == "X-Repository" then
					args[field] = {
						type = "input",
						name = field:gsub("^X%-", ""),
						width = "double",
						order = i,
						get = function(info)
							return GetAddOnMetadata(AddonFile, info[#info])
						end,
					}
				else
					args[field] = {
						type = "description",
						name = "|cffffd100" .. field:gsub("^X%-", "") .. ": |r" .. val,
						width = "full",
						order = i,
					}
				end
			end
		end
		return args
	end)()
}