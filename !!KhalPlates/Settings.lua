
local AddonFile, KP = ... -- namespace

------------- Database -------------
KP.default = {}
KP.default.profile = {}
KP.dbp = KP.default.profile

-------------------- Default Settings --------------------
KP.dbp.globalOffsetX = 0  -- Global offset X for nameplates
KP.dbp.globalOffsetY = 21 -- Global offset Y for nameplates
KP.dbp.globalScale = 1    -- Global scale for nameplates
KP.dbp.levelFilter = 1    -- Minimum unit level to show its nameplate
KP.dbp.friendlyClickthrough = false -- Disables hitbox on friendly nameplates
KP.dbp.LDWfix = false      -- Hide nameplates when controlled by LDW
-- Runtime references for previous values in profile changes
KP.globalOffsetX = KP.dbp.globalOffsetX
KP.globalOffsetY = KP.dbp.globalOffsetY
-- Name Text
KP.dbp.nameText_hide = false
KP.dbp.nameText_font = "Arial Narrow"
KP.dbp.nameText_size = 9
KP.dbp.nameText_outline = ""
KP.dbp.nameText_anchor = "CENTER"
KP.dbp.nameText_offsetX = 0
KP.dbp.nameText_offsetY = 0
KP.dbp.nameText_width = 85 -- max text width before truncation (...)
KP.dbp.nameText_color = {1, 1, 1} -- white
KP.dbp.nameText_classColorFriends = true
KP.dbp.nameText_classColorEnemies = false
-- Level Text
KP.dbp.levelText_hide = true
KP.dbp.levelText_font = "Arial Narrow"
KP.dbp.levelText_size = 12
KP.dbp.levelText_outline = ""
KP.dbp.levelText_anchor = "Right"
KP.dbp.levelText_offsetX = 0
KP.dbp.levelText_offsetY = 0
-- ArenaID Text
KP.dbp.ArenaIDText_show = true
KP.dbp.ArenaIDText_font = "Arial Narrow"
KP.dbp.ArenaIDText_size = 12
KP.dbp.ArenaIDText_outline = "OUTLINE"
KP.dbp.ArenaIDText_anchor = "Right"
KP.dbp.ArenaIDText_offsetX = 0
KP.dbp.ArenaIDText_offsetY = 0
KP.dbp.ArenaIDText_color = {1, 1, 1} -- white
KP.dbp.ArenaIDText_HideLevel = true
KP.dbp.ArenaIDText_HideName = false
-- PartyID Text
KP.dbp.PartyIDText_show = true
KP.dbp.PartyIDText_color = {1, 1, 1} -- white
KP.dbp.PartyIDText_HideLevel = true
KP.dbp.PartyIDText_HideName = false
-- HealthBar
KP.dbp.healthBar_border = "KhalPlates"
KP.dbp.healthBar_borderTint = {1, 1, 1} -- This a tint overlay, not a regular color
KP.dbp.healthBar_playerTex = "KhalBar"
KP.dbp.healthBar_npcTex = "KhalBar"
KP.dbp.targetGlow_Tint = {1, 1, 1} -- This a tint overlay, not a regular color
KP.dbp.mouseoverGlow_Tint = {1, 1, 1} -- This a tint overlay, not a regular color
-- Health Text
KP.dbp.healthText_hide = false
KP.dbp.healthText_font = "Arial Narrow"
KP.dbp.healthText_size = 8.8
KP.dbp.healthText_outline = ""
KP.dbp.healthText_anchor = "RIGHT"
KP.dbp.healthText_offsetX = 0
KP.dbp.healthText_offsetY = 0
KP.dbp.healthText_color = {1, 1, 1} -- white
-- CastBar
KP.dbp.castBar_Tex = "KhalBar"
-- Cast Text
KP.dbp.castText_hide = false
KP.dbp.castText_font = "Arial Narrow"
KP.dbp.castText_size = 9
KP.dbp.castText_outline = ""
KP.dbp.castText_anchor = "CENTER"
KP.dbp.castText_offsetX = 0
KP.dbp.castText_offsetY = 0
KP.dbp.castText_width = 90 -- max text width before truncation (...)
KP.dbp.castText_color = {1, 1, 1} -- white
-- Cast Timer Text
KP.dbp.castTimerText_hide = false
KP.dbp.castTimerText_font = "Arial Narrow"
KP.dbp.castTimerText_size = 8.8
KP.dbp.castTimerText_outline = ""
KP.dbp.castTimerText_anchor = "RIGHT"
KP.dbp.castTimerText_offsetX = 0
KP.dbp.castTimerText_offsetY = 0
KP.dbp.castTimerText_color = {1, 1, 1} -- white
-- Elite Icon
KP.dbp.eliteIcon_anchor = "Left"
KP.dbp.eliteIcon_Tint = {1, 1, 1}
-- Boss Icon
KP.dbp.bossIcon_size = 18
KP.dbp.bossIcon_anchor = "Right"
KP.dbp.bossIcon_offsetX = 0
KP.dbp.bossIcon_offsetY = 0
-- Raid Target Icon
KP.dbp.raidTargetIcon_size = 27
KP.dbp.raidTargetIcon_anchor = "Right"
KP.dbp.raidTargetIcon_offsetX = 0
KP.dbp.raidTargetIcon_offsetY = 0
-- Class Icon (in Arenas and BGs)
KP.dbp.showClassOnFriends = true
KP.dbp.showClassOnEnemies = true
KP.dbp.classIcon_size = 26
KP.dbp.classIcon_anchor = "Left"
KP.dbp.classIcon_offsetX = 0
KP.dbp.classIcon_offsetY = 0
-- Class Plates
KP.dbp.classPlate_textFont = "Friz Quadrata TT"
KP.dbp.classPlate_textSize = 14
KP.dbp.classPlate_textOutline = "OUTLINE"
KP.dbp.classPlate_textColor = {1, 1, 1} -- white
KP.dbp.classPlate_classColors = true
KP.dbp.classPlate_showNameInBG = false
KP.dbp.classPlate_showNameInArena = false
KP.dbp.classPlate_showNameInPvE = true
KP.dbp.classPlate_iconSize = 36
KP.dbp.classPlate_offset = 0
KP.dbp.classPlate_showIconInBG = false
KP.dbp.classPlate_showIconInArena = false
KP.dbp.classPlate_showIconInPvE = false
-- Totem Plates
KP.dbp.totemSize = 24 -- Size of the totem (or NPC) icon replacing the nameplate
KP.dbp.totemOffset = 0 -- Vertical offset for totem icon
KP.dbp.TotemsCheck = { -- 1 = Icon, 0 = Hiden, false = nameplate
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
KP.dbp.Blacklist = CopyTable(KP.Blacklist)
local tmpNewName = ""
-- Enhanced Stacking
KP.dbp.stackingEnabled = false
KP.dbp.xspace = 130
KP.dbp.yspace = 15
KP.dbp.originpos = 0
KP.dbp.upperborder = 35
KP.dbp.tallEntitiesFix = true
KP.dbp.allBossFix = false
KP.dbp.stackingInInstance = false
KP.dbp.FreezeMouseover = false

-------------------- Options Table --------------------
KP.MainOptionTable = {
	name = "KhalPlates",
	type = "group",
	childGroups = "tab",
	get = function(info)
        return KP.dbp[info[#info]]
    end,
	set = function(info, val)
        KP.dbp[info[#info]] = val
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
					values = {
						["KhalPlates"] = "KhalPlates",
						["Blizzard"] = "Blizzard",
					},
					set = function(info, val)
						KP.dbp[info[#info]] = val
						if val == "KhalPlates" then
							KP.dbp.globalOffsetX = 0
							KP.dbp.nameText_font = "Arial Narrow"
							KP.dbp.nameText_size = 9
							KP.dbp.nameText_width = 85
							KP.dbp.levelText_hide = true
							KP.dbp.levelText_font = "Arial Narrow"
							KP.dbp.levelText_size = 12				
							KP.dbp.healthText_font = "Arial Narrow"
							KP.dbp.ArenaIDText_font = "Arial Narrow"
							KP.dbp.ArenaIDText_size = 12
							KP.dbp.healthText_size = 8.8
							KP.dbp.healthText_anchor = "RIGHT"
							KP.dbp.healthText_offsetX = 0
							KP.dbp.castText_font = "Arial Narrow"
							KP.dbp.castText_size = 9
							KP.dbp.castText_offsetY = 0
							KP.dbp.castTimerText_font = "Arial Narrow"
							KP.dbp.castTimerText_size = 8.8
							KP.dbp.healthBar_playerTex = "KhalBar"
							KP.dbp.healthBar_npcTex = "KhalBar"
							KP.dbp.castBar_Tex = "KhalBar"
							KP.dbp.eliteIcon_anchor = "Left"
							KP.dbp.raidTargetIcon_size = 27
							KP.dbp.raidTargetIcon_anchor = "Right"
							KP.dbp.classIcon_size = 26
							KP.dbp.classIcon_anchor = "Left"
						else
							KP.dbp.globalOffsetX = -11
							KP.dbp.nameText_font = "Friz Quadrata TT"
							KP.dbp.nameText_size = 16
							KP.dbp.nameText_width = 250
							KP.dbp.levelText_hide = false
							KP.dbp.levelText_font = "Friz Quadrata TT"
							KP.dbp.levelText_size = 14
							KP.dbp.ArenaIDText_font = "Friz Quadrata TT"
							KP.dbp.ArenaIDText_size = 13
							KP.dbp.healthText_font = "Friz Quadrata TT"
							KP.dbp.healthText_size = 9.5
							KP.dbp.healthText_anchor = "CENTER"
							KP.dbp.healthText_offsetX = 11
							KP.dbp.castText_font = "Friz Quadrata TT"
							KP.dbp.castText_size = 10
							KP.dbp.castText_offsetY = -0.4
							KP.dbp.castTimerText_font = "Friz Quadrata TT"
							KP.dbp.castTimerText_size = 9.5
							KP.dbp.healthBar_playerTex = "Blizzard Nameplates"
							KP.dbp.healthBar_npcTex = "Blizzard Nameplates"
							KP.dbp.castBar_Tex = "Blizzard Nameplates"
							KP.dbp.eliteIcon_anchor = "Right"
							KP.dbp.raidTargetIcon_size = 35
							KP.dbp.raidTargetIcon_anchor = "Top"
							KP.dbp.classIcon_size = 35
							KP.dbp.classIcon_anchor = "Top"
						end
						KP.dbp.nameText_anchor = "CENTER"
						KP.dbp.nameText_offsetX = 0
						KP.dbp.nameText_offsetY = 0
						KP.dbp.levelText_outline = ""
						KP.dbp.levelText_anchor = "Right"
						KP.dbp.levelText_offsetX = 0
						KP.dbp.levelText_offsetY = 0
						KP.dbp.ArenaIDText_anchor = "Right"
						KP.dbp.ArenaIDText_offsetX = 0
						KP.dbp.ArenaIDText_offsetY = 0
						KP.dbp.healthText_offsetY = 0
						KP.dbp.ArenaIDText_HideLevel = true
						KP.dbp.castText_anchor = "CENTER"
						KP.dbp.castText_outline = ""
						KP.dbp.castText_width = 90
						KP.dbp.castText_offsetX = 0
						KP.dbp.castTimerText_outline = ""
						KP.dbp.castTimerText_anchor = "RIGHT"
						KP.dbp.castTimerText_offsetX = 0
						KP.dbp.castTimerText_offsetY = 0
						KP.dbp.bossIcon_anchor = "Right"
						KP.dbp.bossIcon_size = 18
						KP.dbp.bossIcon_offsetX = 0
						KP.dbp.bossIcon_offsetY = 0
						KP.dbp.raidTargetIcon_offsetX = 0
						KP.dbp.raidTargetIcon_offsetY = 0
						KP.dbp.classIcon_offsetX = 0
						KP.dbp.classIcon_offsetY = 0
						KP:MoveAllShownPlates(KP.dbp.globalOffsetX - KP.globalOffsetX, 0)
						KP:UpdateAllTexts()
						KP:UpdateAllHealthBars()
						KP:UpdateAllCastBars()
						KP:UpdateAllIcons()
						KP:UpdateAllGlows()
						KP:UpdateAllCastBarBorders()
						KP:UpdateAllShownPlates()
						KP:UpdateHitboxAttributes()
						KP.globalOffsetX = KP.dbp.globalOffsetX
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
						KP.dbp[info[#info]] = val
						KP:UpdateAllVirtualsScale()
						KP:UpdateHitboxAttributes()
					end,
				},
				globalOffsetX = {
					order = 9,
					type = "range",
					name = "Visual Offset X",
					desc = "Affects only the nameplate's visual regions. The real hitbox can't be moved using this feature.",
					min = -50,
					max = 50,
					step = 1,
					set = function(info, val)
						KP.dbp.globalOffsetX = val
						KP:MoveAllShownPlates(KP.dbp.globalOffsetX - KP.globalOffsetX, 0)
						KP.globalOffsetX = KP.dbp.globalOffsetX
					end,
				},
				globalOffsetY = {
					order = 10,
					type = "range",
					name = "Visual Offset Y",
					desc = "Affects only the nameplate's visual regions. The real hitbox can't be moved using this feature.",
					min = -50,
					max = 50,
					step = 1,
					set = function(info, val)
						KP.dbp.globalOffsetY = val
						KP:MoveAllShownPlates(0, KP.dbp.globalOffsetY - KP.globalOffsetY)
						KP.globalOffsetY = KP.dbp.globalOffsetY
					end,
				},
				lineBreak6 = {order = 11, type = "description", name = ""},
				lineBreak7 = {order = 12, type = "description", name = ""},
				lineBreak8 = {order = 13, type = "description", name = ""},
				levelFilter = {
					order = 14,
					type = "range",
					name = "Level Filter",
					desc = "Minimum unit level required for the nameplate to be shown.",
					min = 1,
					max = 80,
					step = 1,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllShownPlates()
					end,
				},
				friendlyClickthrough = {
					order = 15,
					type = "toggle",
					name = "Click-through Friendly Nameplates",
					desc = "Disable friendly nameplates hitboxes inside PvE and PvP instances.",
				},
				LDWfix = {
					order = 15,
					type = "toggle",
					name = "Hide on LDW MC",
					desc = "Hide nameplates when mind-controlled by Lady Deathwhisper.",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						if val then
							KP.EventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")
							KP.EventHandler:RegisterEvent("UNIT_AURA")
							KP.isICC = false
							KP.isLDWZone = false
							SetMapToCurrentZone()
							if GetCurrentMapAreaID() == 605 then
								KP.isICC = true
								if GetSubZoneText() == KP.LDWZoneText then
									KP.isLDWZone = true
								end
							end
						else
							KP.EventHandler:UnregisterEvent("ZONE_CHANGED_INDOORS")
							KP.EventHandler:UnregisterEvent("UNIT_AURA")
							KP.isICC = false
							KP.isLDWZone = false
							if KP.DominateMind then
								KP.DominateMind = nil
								SetUIVisibility(true)
							end							
						end
					end,
				},
				lineBreak9 = {order = 17, type = "description", name = ""},
				lineBreak10 = {order = 18, type = "description", name = ""},
				stacking_header = {
					order = 19,
					type = "header",
					name = "Retail-like Stacking",
				},
				lineBreak11 = {order = 20, type = "description", name = ""},
				stackingEnabled = {
					order = 21,
					type = "toggle",
					name = "Enable",
					desc = "Simulates Retail's nameplate stacking for enemies. This feature has a high CPU cost, use it with discretion.",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateWorldFrameHeight()
						KP:ResetStackingClamp()
						KP:UpdateAllShownPlates()
					end,
				},
				lineBreak12 = {order = 22, type = "description", name = ""},
				lineBreak13 = {order = 23, type = "description", name = ""},
				xspace = {
					order = 24,
					type = "range",
					name = "Collider Width",
					desc = "Sets the width of the virtual collider centered on each nameplate used to detect overlaps.",
					min = 20,
					max = 200,
					step = 1,
					disabled = function() return not KP.dbp.stackingEnabled end
				},
				yspace = {
					order = 25,
					type = "range",
					name = "Collider Height",
					desc = "Sets the height of the virtual collider centered on each nameplate used to detect overlaps.",
					min = 5,
					max = 50,
					step = 1,
					disabled = function() return not KP.dbp.stackingEnabled end
				},
				originpos = {
					order = 26,
					type = "range",
					name = "Vertical Offset",
					desc = "Vertically offsets the entire nameplate, including its hitbox.",
					min = 0,
					max = 50,
					step = 1,
					disabled = function() return not KP.dbp.stackingEnabled end
				},
				lineBreak14 = {order = 27, type = "description", name = ""},
				lineBreak15 = {order = 28, type = "description", name = ""},
				upperborder = {
					order = 29,
					type = "range",
					name = "Top Screen Boundary",
					desc = "Defines how far from the top of the screen targeted nameplate can move upward.",
					min = 0,
					max = 100,
					step = 1,
					disabled = function() return not KP.dbp.stackingEnabled end
				},
				tallEntitiesFix = {
					order = 30,
					type = "toggle",
					name = "Clamp Tall Entities",
					desc = "Prevents tall entities' nameplates from going above the top of the screen while targeted.",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateWorldFrameHeight()
					end,					
					disabled = function() return not KP.dbp.stackingEnabled end
				},
				allBossFix = {
					order = 31,
					type = "toggle",
					name = "Clamp all Bosses",
					desc = "Prevents bosses' nameplates from going above the top of the screen without needing to target.",					
					disabled = function() return not KP.dbp.stackingEnabled or not KP.dbp.tallEntitiesFix end
				},
				lineBreak16 = {order = 32, type = "description", name = ""},
				lineBreak17 = {order = 33, type = "description", name = ""},
				FreezeMouseover = {
					order = 35,
					type = "toggle",
					name = "Freeze Mouseover",
					desc = "Stops the nameplate you're mousing over from moving for better selection.",
					disabled = function() return not KP.dbp.stackingEnabled end
				},
				stackingInInstance = {
					order = 36,
					type = "toggle",
					name = "Disable in Open World",
					desc = "Only process stacking inside PvE and PvP instances. This will reduce CPU usage in the open world.",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:ResetStackingClamp()
						KP:UpdateAllShownPlates()
					end,
					disabled = function() return not KP.dbp.stackingEnabled end
				},
			},
		},
		Text = {
			order = 2,
			name = "Text",
			type = "group",
			set = function(info, val)
				KP.dbp[info[#info]] = val
				KP:UpdateAllTexts()
				KP:UpdateAllShownPlates()
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
					values = KP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_size = {
					order = 5,
					type = "range",
					name = "Font Size",
					min = 6,
					max = 18,
					step = 0.1,
					disabled = function() return KP.dbp.nameText_hide end
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
					disabled = function() return KP.dbp.nameText_hide end
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
						KP.dbp[info[#info]] = val
						KP.dbp.nameText_offsetX = 0
						KP.dbp.nameText_offsetY = 0
						KP:UpdateAllTexts()
						KP:UpdateAllShownPlates()
					end,
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_offsetX = {
					order = 8,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_offsetY = {
					order = 9,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_color = {
					order = 10,
					type = "color",
					name = "Base Text Color",
					get = function(info)
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllTexts()
						KP:UpdateAllShownPlates()
					end,
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_classColorFriends = {
					order = 11,
					type = "toggle",
					name = "Class Colors on Friends",
					desc = "Use class colors for friendly player names (only works for party or raid members).",
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_classColorEnemies = {
					order = 12,
					type = "toggle",
					name = "Class Colors on Enemies",
					desc = "Use class colors for enemy player names. 'Class Colors in Nameplates' must be enabled.",
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_width = {
					order = 13,
					type = "range",
					name = "Width",
					min = 50,
					max = 250,
					step = 1,
					disabled = function() return KP.dbp.nameText_hide end
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
					values = KP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function() return KP.dbp.levelText_hide end
				},
				levelText_size = {
					order = 20,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function() return KP.dbp.levelText_hide end
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
					disabled = function() return KP.dbp.levelText_hide end
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
						KP.dbp[info[#info]] = val
						KP.dbp.levelText_offsetX = 0
						KP.dbp.levelText_offsetY = 0
						KP:UpdateAllTexts()
						KP:UpdateAllShownPlates()
					end,
					disabled = function() return KP.dbp.levelText_hide end
				},
				levelText_offsetX = {
					order = 23,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.levelText_hide end
				},
				levelText_offsetY = {
					order = 24,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.levelText_hide end
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
					values = KP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function() return not KP.dbp.ArenaIDText_show and not KP.dbp.PartyIDText_show end
				},
				ArenaIDText_size = {
					order = 33,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function() return not KP.dbp.ArenaIDText_show and not KP.dbp.PartyIDText_show end
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
					disabled = function() return not KP.dbp.ArenaIDText_show and not KP.dbp.PartyIDText_show end
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
						KP.dbp[info[#info]] = val
						KP.dbp.ArenaIDText_offsetX = 0
						KP.dbp.ArenaIDText_offsetY = 0
						KP:UpdateAllTexts()
						KP:UpdateAllShownPlates()
					end,
					disabled = function() return not KP.dbp.ArenaIDText_show and not KP.dbp.PartyIDText_show end
				},
				ArenaIDText_offsetX = {
					order = 36,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return not KP.dbp.ArenaIDText_show and not KP.dbp.PartyIDText_show end
				},
				ArenaIDText_offsetY = {
					order = 37,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return not KP.dbp.ArenaIDText_show and not KP.dbp.PartyIDText_show end
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
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllTexts()
						KP:UpdateAllShownPlates()
					end,
					disabled = function() return not KP.dbp.ArenaIDText_show end
				},
				ArenaIDText_HideName = {
					order = 42,
					type = "toggle",
					name = "Hide Enemy Name",
					desc = "Hide name text on arena enemies",
					disabled = function() return not KP.dbp.ArenaIDText_show or KP.dbp.nameText_hide end
				},
				ArenaIDText_HideLevel = {
					order = 43,
					type = "toggle",
					name = "Hide Enemy Level",
					desc = "Hide level text on arena enemies",
					disabled = function() return not KP.dbp.ArenaIDText_show or KP.dbp.levelText_hide end
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
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllTexts()
						KP:UpdateAllShownPlates()
					end,
					disabled = function() return not KP.dbp.PartyIDText_show end
				},
				PartyIDText_HideName = {
					order = 49,
					type = "toggle",
					name = "Hide Friend Name",
					desc = "Hide name text on party",
					disabled = function() return not KP.dbp.PartyIDText_show or KP.dbp.nameText_hide end
				},
				PartyIDText_HideLevel = {
					order = 50,
					type = "toggle",
					name = "Hide Friend Level",
					desc = "Hide level text on party",
					disabled = function() return not KP.dbp.PartyIDText_show or KP.dbp.levelText_hide end
				},
				lineBreak15 = {order = 51, type = "description", name = ""},
				lineBreak16 = {order = 52, type = "description", name = ""},
				lineBreak17 = {order = 53, type = "description", name = ""},
				classPlate_nameHeader = {
					order = 54,
					type = "header",
					name = "Special Name Text",
				},
				lineBreak18 = {order = 55, type = "description", name = ""},
				classPlate_nameDesc = {
					order = 56, 
					type = "description", 
					name = "Unlike the regular name text, this completely replaces friendly player nameplates."
				},
				lineBreak19 = {order = 57, type = "description", name = ""},
				classPlate_textFont = {
					order = 58,
					type = "select",
					name = "Text Font",
					values = KP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				classPlate_textSize = {
					order = 59,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				classPlate_textOutline = {
					order = 60,
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
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				classPlate_textColor = {
					order = 61,
					type = "color",
					name = "Base name color",
					get = function(info)
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				classPlate_classColors = {
					order = 62,
					type = "toggle",
					name = "Name with class color",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				classPlate_offset = {
					order = 63,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				lineBreak20 = {order = 64, type = "description", name = ""},
				classPlate_showNameInBG = {
					order = 65,
					type = "toggle",
					name = "Show in BGs",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				classPlate_showNameInArena = {
					order = 66,
					type = "toggle",
					name = "Show in Arenas",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				classPlate_showNameInPvE = {
					order = 67,
					type = "toggle",
					name = "Show in PvE",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				lineBreak21 = {order = 68, type = "description", name = ""},
				lineBreak22 = {order = 69, type = "description", name = ""},
			},
		},
		HealthBar = {
			order = 3,
			name = "Health Bar",
			type = "group",
			set = function(info, val)
				KP.dbp[info[#info]] = val
				KP:UpdateAllHealthBars()
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
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllHealthBars()
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
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllGlows()
					end,
				},
				mouseoverGlow_Tint = {
					order = 13,
					type = "color",
					name = "Mouseover Glow Tint",
					desc = "This is a tint overlay, not a regular color. 'White' keeps the original look.",
					get = function(info)
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllGlows()
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
					values = KP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function() return KP.dbp.healthText_hide end
				},
				healthText_size = {
					order = 19,
					type = "range",
					name = "Font Size",
					min = 6,
					max = 18,
					step = 0.1,
					disabled = function() return KP.dbp.healthText_hide end
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
					disabled = function() return KP.dbp.healthText_hide end
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
						KP.dbp[info[#info]] = val
						KP.dbp.healthText_offsetX = 0
						KP.dbp.healthText_offsetY = 0
						KP:UpdateAllHealthBars()
					end,
					disabled = function() return KP.dbp.healthText_hide end
				},
				healthText_offsetX = {
					order = 22,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.healthText_hide end
				},
				healthText_offsetY = {
					order = 23,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.healthText_hide end
				},
				healthText_color = {
					order = 24,
					type = "color",
					name = "Text Color",
					get = function(info)
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllHealthBars()
					end,
					disabled = function() return KP.dbp.healthText_hide end
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
				KP.dbp[info[#info]] = val
				KP:UpdateAllCastBars()
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
					values = KP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function() return KP.dbp.castText_hide end
				},
				castText_size = {
					order = 10,
					type = "range",
					name = "Font Size",
					min = 6,
					max = 18,
					step = 0.1,
					disabled = function() return KP.dbp.castText_hide end
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
					disabled = function() return KP.dbp.castText_hide end
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
						KP.dbp[info[#info]] = val
						KP.dbp.castText_offsetX = 0
						KP.dbp.castText_offsetY = 0
						KP:UpdateAllCastBars()
					end,
					disabled = function() return KP.dbp.castText_hide end
				},
				castText_offsetX = {
					order = 13,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.castText_hide end
				},
				castText_offsetY = {
					order = 14,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.castText_hide end
				},
				castText_width = {
					order = 15,
					type = "range",
					name = "Width",
					min = 50,
					max = 250,
					step = 1,
					disabled = function() return KP.dbp.castText_hide end
				},
				castText_color = {
					order = 16,
					type = "color",
					name = "Text Color",
					get = function(info)
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllCastBars()
					end,
					disabled = function() return KP.dbp.castText_hide end
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
					values = KP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function() return KP.dbp.castTimerText_hide end
				},
				castTimerText_size = {
					order = 23,
					type = "range",
					name = "Font Size",
					min = 6,
					max = 18,
					step = 0.1,
					disabled = function() return KP.dbp.castTimerText_hide end
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
					disabled = function() return KP.dbp.castTimerText_hide end
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
						KP.dbp[info[#info]] = val
						KP.dbp.castTimerText_offsetX = 0
						KP.dbp.castTimerText_offsetY = 0
						KP:UpdateAllCastBars()
					end,
					disabled = function() return KP.dbp.castTimerText_hide end
				},
				castTimerText_offsetX = {
					order = 26,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.castTimerText_hide end
				},
				castTimerText_offsetY = {
					order = 27,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.castTimerText_hide end
				},
				castTimerText_color = {
					order = 28,
					type = "color",
					name = "Text Color",
					get = function(info)
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllCastBars()
					end,
					disabled = function() return KP.dbp.castTimerText_hide end
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
				KP.dbp[info[#info]] = val
				KP:UpdateAllIcons()
				KP:UpdateAllShownPlates()
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
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
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
						KP.dbp[info[#info]] = val
						KP.dbp.bossIcon_offsetX = 0
						KP.dbp.bossIcon_offsetY = 0
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
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
						KP.dbp[info[#info]] = val
						KP.dbp.raidTargetIcon_offsetX = 0
						KP.dbp.raidTargetIcon_offsetY = 0
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
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
						KP.dbp[info[#info]] = val
						KP.dbp.classIcon_offsetX = 0
						KP.dbp.classIcon_offsetY = 0
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
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
					desc = "Class icons are only shown in battlegrounds and arenas.",
				},
				showClassOnEnemies = {
					order = 31,
					type = "toggle",
					name = "Show on Enemies",
					desc = "Class icons are only shown in battlegrounds and arenas.",
				},
				lineBreak12 = {order = 32, type = "description", name = ""},
				lineBreak13 = {order = 33, type = "description", name = ""},
				classPlate_iconHeader = {
					order = 34,
					type = "header",
					name = "Special Class Icon",
				},
				lineBreak14 = {order = 35, type = "description", name = ""},
				classPlate_iconDesc = {
					order = 36, 
					type = "description", 
					name = "Unlike the regular class icon, this completely replaces friendly player nameplates."
				},
				lineBreak15 = {order = 37, type = "description", name = ""},
				lineBreak16 = {order = 38, type = "description", name = ""},
				classPlate_iconSize = {
					order = 39,
					type = "range",
					name = "Icon Size",
					min = 20,
					max = 50,
					step = 0.1,
				},
				classPlate_offset = {
					order = 40,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
				},
				lineBreak17 = {order = 41, type = "description", name = ""},
				classPlate_showIconInBG = {
					order = 42,
					type = "toggle",
					name = "Show in BGs",
				},
				classPlate_showIconInArena = {
					order = 43,
					type = "toggle",
					name = "Show in Arenas",
				},
				classPlate_showIconInPvE = {
					order = 44,
					type = "toggle",
					name = "Show in PvE",
				},
				lineBreak18 = {order = 45, type = "description", name = ""},
				lineBreak19 = {order = 46, type = "description", name = ""},
			},
		},
		Totems = {
			order = 6,
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
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				totemOffset = {
					order = 6,
					type = "range",
					name = "Offset Y",
					desc = "Adjusts the vertical position of all Totem and Blacklisted icons.",
					min = -50,
					max = 50,
					step = 0.1,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllIcons()
						KP:UpdateAllShownPlates()
					end,
				},
				lineBreak4 = {order = 7, type = "description", name = ""},
				lineBreak5 = {order = 8, type = "description", name = ""},
				lineBreak6 = {order = 9, type = "description", name = ""},	
			}
		},
		BlackList = {
			order = 7,
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
						if not KP.dbp.Blacklist[tmpNewName] then
							KP.dbp.Blacklist[tmpNewName] = ""
							KP:BuildBlacklistUI()
							KP:UpdateAllShownPlates()
							LibStub("AceConfigDialog-3.0"):SelectGroup("KhalPlates", "BlackList", tmpNewName)
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
						KP.dbp.Blacklist = CopyTable(KP.Blacklist)
						KP:BuildBlacklistUI()
						KP:UpdateAllShownPlates()
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

local tooltip = CreateFrame("GameTooltip", "KhalPlatesTooltip", UIParent, "GameTooltipTemplate")
tooltip:Show()
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

function KP:UpdateTotemDesc()
	for name, group in pairs(KP.MainOptionTable.args.Totems.args) do
		local spellID = TotemIDs[name]
		if spellID then
			tooltip:SetHyperlink("spell:" .. spellID)
			local lines = tooltip:NumLines()
			if lines > 0 then
				group.args.desc.name = _G["KhalPlatesTooltipTextLeft" .. lines]:GetText() or ""
			end
		end
	end
end

for i, element in ipairs(TotemOrder) do 
 	for j, name in ipairs(TotemGroups[element]) do
        local spellID = TotemIDs[name]
		local totemName, _, icon = GetSpellInfo(spellID)
        local iconString = "\124T" .. icon .. ":26\124t"
		KP.MainOptionTable.args.Totems.args[name] = {
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
						return KP.dbp.TotemsCheck[name] ~= false
					end,
					set = function(_, val)
						KP.dbp.TotemsCheck[name] = val and (KP.dbp.TotemsCheck[name] or 1) or false
						KP:UpdateAllShownPlates()
					end,
				},
				hide = {
					type = "toggle",
					name = "Hide Totem",
					desc = "Completely hides the nameplate and the totemplate for this totem.",
					order = 9,
					disabled = function()
						return KP.dbp.TotemsCheck[name] == false
					end,
					get = function()
						return KP.dbp.TotemsCheck[name] == 0
					end,
					set = function(_, val)
						KP.dbp.TotemsCheck[name] = val and 0 or 1
						KP:UpdateAllShownPlates()
					end,
				},
			},
		}
	end
end

function KP:BuildBlacklistUI()
    local args = KP.MainOptionTable.args.BlackList.args
	for k, v in pairs(args) do
		if v.order > 5 then
			args[k] = nil
		end
	end
    local namesList = {}
    for name, value in pairs(KP.dbp.Blacklist) do
		if value then
			table.insert(namesList, name)
		end
	end
    table.sort(namesList, function(a, b) return a < b end)
    for i, name in ipairs(namesList) do
        local iconPath = KP.dbp.Blacklist[name]
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
                    get = function() return KP.dbp.Blacklist[name] end,
                    set = function(_, val)
                        KP.dbp.Blacklist[name] = val
                        KP:BuildBlacklistUI()
						KP:UpdateAllShownPlates()
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
                		KP.dbp.Blacklist[name] = false
						KP:BuildBlacklistUI()
						KP:UpdateAllShownPlates()
                    end,
                },
            },
        }
    end
end

KP.AboutTable = {
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
						width = "double",
						order = i,
					}
				end
			end
		end
		return args
	end)()
}