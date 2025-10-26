
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
-- Level Text
KP.dbp.levelText_hide = true
KP.dbp.levelText_font = "Arial Narrow"
KP.dbp.levelText_size = 12
KP.dbp.levelText_outline = ""
KP.dbp.levelText_anchor = "Right"
KP.dbp.levelText_offsetX = 0
KP.dbp.levelText_offsetY = 0
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
-- Totem Plates
KP.dbp.totemSize = 23 -- Size of the totem (or NPC) icon replacing the nameplate
KP.dbp.totemOffset = 0 -- Vertical offset for totem icon

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
		tab1 = {
			order = 1,
			name = "General",
			type = "group",
			args = {
				blank1 = {
					order = 1,
					type = "description",
					name = "",
				},
				general_header = {
					order = 2,
					type = "header",
					name = "General Settings",
				},
				blank2 = {
					order = 3,
					type = "description",
					name = "",
				},
				healthBar_border = {
					order = 4,
					type = "select",
					name = "Nameplate Style",
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
							KP.dbp.nameText_offsetX = 0
							KP.dbp.nameText_offsetY = 0
							KP.dbp.nameText_width = 85
							KP.dbp.levelText_hide = true
							KP.dbp.levelText_font = "Arial Narrow"
							KP.dbp.levelText_size = 12				
							KP.dbp.healthText_font = "Arial Narrow"
							KP.dbp.healthText_size = 8.8
							KP.dbp.healthText_anchor = "RIGHT"
							KP.dbp.healthText_offsetX = 0
							KP.dbp.healthText_offsetY = 0
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
							KP.dbp.nameText_offsetX = 11
							KP.dbp.nameText_offsetY = 17
							KP.dbp.nameText_width = 250
							KP.dbp.levelText_hide = false
							KP.dbp.levelText_font = "Friz Quadrata TT"
							KP.dbp.levelText_size = 14
							KP.dbp.healthText_font = "Friz Quadrata TT"
							KP.dbp.healthText_size = 9.5
							KP.dbp.healthText_anchor = "CENTER"
							KP.dbp.healthText_offsetX = 11
							KP.dbp.healthText_offsetY = -0.2
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
						KP.dbp.levelText_outline = ""
						KP.dbp.levelText_anchor = "Right"
						KP.dbp.levelText_offsetX = 0
						KP.dbp.levelText_offsetY = 0
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
						KP:MoveAllVisiblePlates(KP.dbp.globalOffsetX - KP.globalOffsetX, 0)
						KP:UpdateAllNameTexts()
						KP:UpdateAllLevelTexts()
						KP:UpdateAllHealthBars()
						KP:UpdateAllCastBarBorders()
						KP:UpdateAllCastBars()
						KP:UpdateAllGlows()
						KP:UpdateAllIcons()
						KP.globalOffsetX = KP.dbp.globalOffsetX
					end,
				},
				blank3 = {
					order = 5,
					type = "description",
					name = "",
				},
				blank4 = {
					order = 6,
					type = "description",
					name = "",
				},
				blank5 = {
					order = 7,
					type = "description",
					name = "",
				},
				globalScale = {
					order = 8,
					type = "range",
					name = "Global Scale",
					desc = "Affects mainly the visual nameplate.\nThe hitbox can only be scaled out of combat, and it will restore its original size when hidden; so if shown during combat, it will scale once combat ends.",
					min = 0.5,
					max = 2.5,
					step = 0.01,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllVirtualsScale()
					end,
				},
				blank6 = {
					order = 9,
					type = "description",
					name = "",
				},
				blank7 = {
					order = 10,
					type = "description",
					name = "",
				},
				blank8 = {
					order = 11,
					type = "description",
					name = "",
				},
				globalOffsetX = {
					order = 12,
					type = "range",
					name = "Global Offset X",
					desc = "Affects only the visual nameplate.\nThe real hitbox can't be moved.",
					min = -50,
					max = 50,
					step = 1,
					set = function(info, val)
						KP.dbp.globalOffsetX = val
						KP:MoveAllVisiblePlates(KP.dbp.globalOffsetX - KP.globalOffsetX, 0)
						KP.globalOffsetX = KP.dbp.globalOffsetX
					end,
				},
				globalOffsetY = {
					order = 13,
					type = "range",
					name = "Global Offset Y",
					desc = "Affects only the visual nameplate.\nThe real hitbox can't be moved.",
					min = -50,
					max = 50,
					step = 1,
					set = function(info, val)
						KP.dbp.globalOffsetY = val
						KP:MoveAllVisiblePlates(0, KP.dbp.globalOffsetY - KP.globalOffsetY)
						KP.globalOffsetY = KP.dbp.globalOffsetY
					end,
				},
				blank9 = {
					order = 14,
					type = "description",
					name = "",
				},
				blank10 = {
					order = 15,
					type = "description",
					name = "",
				},
				blank11 = {
					order = 165,
					type = "description",
					name = "",
				},
				levelFilter = {
					order = 17,
					type = "range",
					name = "Level Filter",
					desc = "Minimum unit level required for the nameplate to be shown.",
					min = 1,
					max = 80,
					step = 1,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateLevelFilter()
					end,
				},
			},
		},
		tab2 = {
			order = 2,
			name = "Health Bar",
			type = "group",
			set = function(info, val)
				KP.dbp[info[#info]] = val
				KP:UpdateAllHealthBars()
			end,
			args = {
				blank1 = {
					order = 1,
					type = "description",
					name = "",
				},
				healthBar_header = {
					order = 2,
					type = "header",
					name = "Appearance",
				},
				blank2 = {
					order = 3,
					type = "description",
					name = "",
				},
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
				blank3 = {
					order = 6,
					type = "description",
					name = "",
				},
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
				blank4 = {
					order = 8,
					type = "description",
					name = "",
				},
				blank5 = {
					order = 9,
					type = "description",
					name = "",
				},
				healthBarGlow_header = {
					order = 10,
					type = "header",
					name = "Glows",
				},
				blank6 = {
					order = 11,
					type = "description",
					name = "",
				},
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
				blank7 = {
					order = 14,
					type = "description",
					name = "",
				},
				blank8 = {
					order = 15,
					type = "description",
					name = "",
				},
				healthText_header = {
					order = 16,
					type = "header",
					name = "Health Text",
				},
				blank9 = {
					order = 17,
					type = "description",
					name = "",
				},
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
			},
		},
		tab3 = {
			order = 3,
			name = "Name/Level",
			type = "group",
			set = function(info, val)
				KP.dbp[info[#info]] = val
				KP:UpdateAllNameTexts()
				KP:UpdateAllLevelTexts()
			end,
			args = {
				blank1 = {
					order = 1,
					type = "description",
					name = "",
				},
				nameText_header = {
					order = 2,
					type = "header",
					name = "Name Text",
				},
				blank2 = {
					order = 3,
					type = "description",
					name = "",
				},
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
						["LEFT"] = "Left",
						["CENTER"] = "Center",
						["RIGHT"] = "Right"
					},
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP.dbp.nameText_offsetX = 0
						KP.dbp.nameText_offsetY = 0
						KP:UpdateAllNameTexts()
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
				nameText_width = {
					order = 10,
					type = "range",
					name = "Width",
					min = 50,
					max = 250,
					step = 1,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllNameTexts()
					end,
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_color = {
					order = 11,
					type = "color",
					name = "Text Color",
					get = function(info)
						local c = KP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						KP.dbp[info[#info]] = {r, g, b}
						KP:UpdateAllNameTexts()
					end,
					disabled = function() return KP.dbp.nameText_hide end
				},
				nameText_hide = {
					order = 12,
					type = "toggle",
					name = "Hide Name Text",
				},
				blank3 = {
					order = 13,
					type = "description",
					name = "",
				},
				blank4 = {
					order = 14,
					type = "description",
					name = "",
				},
				levelText_header = {
					order = 15,
					type = "header",
					name = "Level Text",
				},
				blank5 = {
					order = 16,
					type = "description",
					name = "",
				},
				levelText_font = {
					order = 17,
					type = "select",
					name = "Text Font",
					values = KP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function() return KP.dbp.levelText_hide end
				},
				levelText_size = {
					order = 18,
					type = "range",
					name = "Font Size",
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function() return KP.dbp.levelText_hide end
				},
				levelText_outline = {
					order = 19,
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
					order = 20,
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
						KP:UpdateAllLevelTexts()
					end,
					disabled = function() return KP.dbp.levelText_hide end
				},
				levelText_offsetX = {
					order = 21,
					type = "range",
					name = "Offset X",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.levelText_hide end
				},
				levelText_offsetY = {
					order = 22,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() return KP.dbp.levelText_hide end
				},
				levelText_hide = {
					order = 23,
					type = "toggle",
					name = "Hide Level Text",
				},
			},
		},
		tab4 = {
			order = 4,
			name = "Cast Bar",
			type = "group",
			set = function(info, val)
				KP.dbp[info[#info]] = val
				KP:UpdateAllCastBars()
			end,
			args = {
				blank1 = {
					order = 1,
					type = "description",
					name = "",
				},
				castBar_header = {
					order = 2,
					type = "header",
					name = "Appearance",
				},
				blank2 = {
					order = 3,
					type = "description",
					name = "",
				},
				castBar_Tex = {
					order = 4,
					type = "select",
					name = "Bar Texture",
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
				},
				blank3 = {
					order = 5,
					type = "description",
					name = "",
				},
				blank4 = {
					order = 6,
					type = "description",
					name = "",
				},
				castText_header = {
					order = 7,
					type = "header",
					name = "Cast Text",
				},
				blank5 = {
					order = 8,
					type = "description",
					name = "",
				},
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
				blank6 = {
					order = 18,
					type = "description",
					name = "",
				},
				blank7 = {
					order = 19,
					type = "description",
					name = "",
				},
				castTimerText_header = {
					order = 20,
					type = "header",
					name = "Cast Timer Text",
				},
				blank8 = {
					order = 21,
					type = "description",
					name = "",
				},
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
			},
		},
		tab5 = {
			order = 5,
			name = "Icons",
			type = "group",
			set = function(info, val)
				KP.dbp[info[#info]] = val
				KP:UpdateAllIcons()
			end,
			args = {
				blank1 = {
					order = 1,
					type = "description",
					name = "",
				},
				eliteIcon_header = {
					order = 2,
					type = "header",
					name = "Elite Icon",
				},
				blank2 = {
					order = 3,
					type = "description",
					name = "",
				},
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
					end,
				},
				blank3 = {
					order = 6,
					type = "description",
					name = "",
				},
				blank4 = {
					order = 7,
					type = "description",
					name = "",
				},
				bossIcon_header = {
					order = 8,
					type = "header",
					name = "Boss Icon",
				},
				blank5 = {
					order = 9,
					type = "description",
					name = "",
				},
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
				blank6 = {
					order = 14,
					type = "description",
					name = "",
				},
				blank7 = {
					order = 15,
					type = "description",
					name = "",
				},
				raidTargetIcon_header = {
					order = 16,
					type = "header",
					name = "Raid Target Icon",
				},
				blank8 = {
					order = 17,
					type = "description",
					name = "",
				},
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
				blank9 = {
					order = 22,
					type = "description",
					name = "",
				},
				blank10 = {
					order = 23,
					type = "description",
					name = "",
				},
				classIcon_header = {
					order = 24,
					type = "header",
					name = "Class Icon",
				},
				blank11 = {
					order = 25,
					type = "description",
					name = "",
				},
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
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateClassIconsShown()
					end,
				},
				showClassOnEnemies = {
					order = 31,
					type = "toggle",
					name = "Show on Enemies",
					desc = "Class icons are only shown in battlegrounds and arenas.",
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateClassIconsShown()
					end,
				},
				blank12 = {
					order = 32,
					type = "description",
					name = "",
				},
				blank13 = {
					order = 33,
					type = "description",
					name = "",
				},
				totemIcon_header = {
					order = 34,
					type = "header",
					name = "Totem Icon",
				},
				blank14 = {
					order = 35,
					type = "description",
					name = "",
				},
				totemSize = {
					order = 36,
					type = "range",
					name = "Icon Size",
					min = 15,
					max = 35,
					step = 0.1,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllTotemPlates()
					end,
				},
				totemOffset = {
					order = 37,
					type = "range",
					name = "Offset Y",
					min = -50,
					max = 50,
					step = 0.1,
					set = function(info, val)
						KP.dbp[info[#info]] = val
						KP:UpdateAllTotemPlates()
					end,
				},
			},
		},
		tab6 = {
			order = 6,
			name = "Totems",
			type = "group",
			args = {
				blank1 = {
					order = 1,
					type = "description",
					name = "",
				},
				Totems_header = {
					order = 2,
					type = "header",
					name = "In Development",
				},
				blank2 = {
					order = 3,
					type = "description",
					name = "",
				}
			}						
		}
	}
}

KP.AboutTable = {
	name = "About",
	type = "group",
	childGroups = "tab",
	get = function(info)
		return KP.dbp[info[#info]]
	end,
	set = function(info, v)
		KP.dbp[info[#info]] = v
	end,
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