
local AddonFile, RBP = ... -- namespace
local L = RBP.L

if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
	RBP.hasModernAPI = true
end

------------- Database -------------
RBP.default = {}
RBP.default.profile = {}
RBP.dbp = RBP.default.profile

-------------------- Default Settings --------------------
RBP.dbp.globalScale = 1    -- Global scale for nameplates
RBP.dbp.globalOffsetX = 10.5  -- Global offset X for nameplates
RBP.dbp.globalOffsetY = 21 -- Global offset Y for nameplates
RBP.dbp.targetScale = 1    -- Target scale factor
RBP.dbp.friendlyScale = 1  -- Friendly scale factor
RBP.dbp.modNonTargetAlpha = false
RBP.dbp.nonTargetAlpha = 0.5
-- Box Selection Space
RBP.dbp.clickboxWidthFactor = 1
RBP.dbp.clickboxHeightFactor = 1
RBP.dbp.friendlyClickthrough = false -- Disables clickbox on friendly nameplates
RBP.dbp.showClickbox = false
-- Misc Settings
RBP.dbp.clampTarget = false
RBP.dbp.clampBoss = false
RBP.dbp.upperborder = 35
RBP.dbp.levelFilter = 1    -- Minimum unit level to show its nameplate
RBP.dbp.LDWfix = false      -- Hide nameplates when controlled by LDW
-- Enhanced Stacking
RBP.dbp.stackingEnabled = false
RBP.dbp.xspace = 130
RBP.dbp.yspace = 15
RBP.dbp.originpos = 0
RBP.dbp.yspeed = 210
RBP.dbp.FreezeMouseover = false
RBP.dbp.stackingInInstance = false
-- Depth Perspective
RBP.dbp.depthScaling = false
RBP.dbp.depthPivot = 80
RBP.dbp.minScaleFactor = 0.25
RBP.dbp.depthFading = false
RBP.dbp.depthFadeStart = 90
RBP.dbp.depthFadeRange = 30
RBP.dbp.fadeNPCs = false
RBP.dbp.fadePlateBuffs = true
-- Name Text
RBP.dbp.nameText_hide = false
RBP.dbp.nameText_font = RBP.RefinedFontKey
RBP.dbp.nameText_size = 7.5
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
RBP.dbp.levelText_font = RBP.RefinedFontKey
RBP.dbp.levelText_size = 10.5
RBP.dbp.levelText_outline = ""
RBP.dbp.levelText_anchor = "Right"
RBP.dbp.levelText_offsetX = 0
RBP.dbp.levelText_offsetY = 0
-- ArenaID Text
RBP.dbp.ArenaIDText_show = true
RBP.dbp.ArenaIDText_font = RBP.RefinedFontKey
RBP.dbp.ArenaIDText_size = 10
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
RBP.dbp.healthBar_friendlyPlayerTex = "KhalBar"
RBP.dbp.healthBar_hostilePlayerTex = "KhalBar"
RBP.dbp.healthBar_npcTex = "KhalBar"
RBP.dbp.healthBar_borderTint = {1, 1, 1} -- This a tint overlay, not a regular color
RBP.dbp.healthBar_progressiveTexCrop = true
RBP.dbp.healthBar_friendColor = {0, 0, 1}
RBP.dbp.healthBar_friendClassColor = false
RBP.dbp.healthBar_bgTex = "KhalBar"
RBP.dbp.healthBar_bgColor = {0, 0, 0}
RBP.dbp.healthBar_bgAlpha = 0.5
RBP.dbp.showTargetGlowBorder = true
RBP.dbp.targetGlow_Alpha = 1
RBP.dbp.targetGlow_Color = {1, 1, 0}
RBP.dbp.targetGlow_Gradient = true
RBP.dbp.showMouseoverGlowBorder = true
RBP.dbp.mouseoverGlow_Alpha = 1
RBP.dbp.mouseoverGlow_Color = {1, 1, 1} -- This a tint overlay, not a regular color
-- Health Text
RBP.dbp.healthText_hide = false
RBP.dbp.healthText_font = RBP.RefinedFontKey
RBP.dbp.healthText_size = 7.5
RBP.dbp.healthText_outline = ""
RBP.dbp.healthText_anchor = "RIGHT"
RBP.dbp.healthText_offsetX = 0
RBP.dbp.healthText_offsetY = 0
RBP.dbp.healthText_color = {1, 1, 1} -- white
RBP.dbp.healthText_format = 1
RBP.dbp.healthText_hideMax = true
-- Low Health Coloring
RBP.dbp.lowHpColor_EnemyPlayers = false
RBP.dbp.lowHpColor_EnemyNPCs = false
RBP.dbp.lowHpColor_FriendlyPlayers = false
RBP.dbp.lowHpColor_FriendlyNPCs = false
RBP.dbp.lowHpColor_threshold = 0.25
RBP.dbp.lowHpColor_color = {1, 0, 1}
-- Threat Overlay
RBP.dbp.enableAggroColoring = false
RBP.dbp.disableAggroOpenworld = true
RBP.dbp.aggroColor = {0.24, 0.64, 0.50}
RBP.dbp.gainingAggroColor = {0.36, 1.00, 0.82}
RBP.dbp.losingAggroColor = {0.7, 0.2, 0.4}
-- CastBar
RBP.dbp.castBar_Tex = "KhalBar"
RBP.dbp.castBar_progressiveTexCrop = true
RBP.dbp.castBar_color = {1, 0.7, 0}
RBP.dbp.castBar_channelingColor = {1, 0.7, 0}
RBP.dbp.castBar_showSpark = true
RBP.dbp.castBar_borderTint = {1, 1, 1} -- This a tint overlay, not a regular color
RBP.dbp.castBar_protectedBorderTint = {1, 1, 1} -- This a tint overlay, not a regular color
RBP.dbp.castBar_bgTex = "KhalBar"
RBP.dbp.castBar_bgColor = {0, 0, 0}
RBP.dbp.castBar_bgAlpha = 0.5
RBP.dbp.castBar_nonTargetPatch = false
-- Cast Text
RBP.dbp.castText_hide = false
RBP.dbp.castText_font = RBP.RefinedFontKey
RBP.dbp.castText_size = 7.5
RBP.dbp.castText_outline = ""
RBP.dbp.castText_anchor = "CENTER"
RBP.dbp.castText_offsetX = 0
RBP.dbp.castText_offsetY = 0
RBP.dbp.castText_width = 90 -- max text width before truncation (...)
RBP.dbp.castText_color = {1, 1, 1} -- white
-- Cast Timer Text
RBP.dbp.castTimerText_hide = false
RBP.dbp.castTimerText_font = RBP.RefinedFontKey
RBP.dbp.castTimerText_size = 7.2
RBP.dbp.castTimerText_outline = ""
RBP.dbp.castTimerText_anchor = "RIGHT"
RBP.dbp.castTimerText_offsetX = 0
RBP.dbp.castTimerText_offsetY = 0
RBP.dbp.castTimerText_color = {1, 1, 1} -- white
-- Cast Glow (Shows when nameplate unit is targetting you, requires nontarget castbar patch)
RBP.dbp.enableCastGlow = true
-- Elite Icon
RBP.dbp.eliteIcon_style = "Default"
RBP.dbp.eliteIcon_widthScale = 1
RBP.dbp.eliteIcon_heightScale = 1
RBP.dbp.eliteIcon_anchor = "Left"
RBP.dbp.eliteIcon_offsetX = 0
RBP.dbp.eliteIcon_offsetY = 0
RBP.dbp.eliteIcon_Tint = {1, 1, 1}
-- Boss Icon
RBP.dbp.bossIcon_anchor = "Right"
RBP.dbp.bossIcon_offsetX = 0
RBP.dbp.bossIcon_offsetY = 0
RBP.dbp.bossIcon_size = 13
-- Raid Target Icon
RBP.dbp.raidTargetIcon_anchor = "Right"
RBP.dbp.raidTargetIcon_offsetX = 0
RBP.dbp.raidTargetIcon_offsetY = 0
RBP.dbp.raidTargetIcon_size = 22
RBP.dbp.raidTargetIcon_hide = false
-- Class Icon
RBP.dbp.classIcon_anchor = "Left"
RBP.dbp.classIcon_offsetX = 0
RBP.dbp.classIcon_offsetY = 0
RBP.dbp.classIcon_size = 21
RBP.dbp.showClassOnFriends = true
RBP.dbp.showClassOnEnemies = true
-- Barless Plate: Enable Filters
RBP.dbp.barlessPlate_filterBG = 3
RBP.dbp.barlessPlate_filterArena = 0
RBP.dbp.barlessPlate_filterPvE = 3
RBP.dbp.barlessPlate_filterOpenWorld = 3
local BarlessPlateFilterValues = {
	[0] = L["Disabled"],
	[1] = L["NPCs"],
	[2] = L["Players"],
	[3] = L["Players and NPCs"],
}
local function IsBarlessPlateDisabled()
	return RBP.dbp.barlessPlate_filterPvE == 0 and RBP.dbp.barlessPlate_filterBG == 0 and RBP.dbp.barlessPlate_filterArena == 0 and RBP.dbp.barlessPlate_filterOpenWorld == 0
end
-- Barless Plate: Target Settings
RBP.dbp.barlessPlate_excludeTarget = false
RBP.dbp.barlessPlate_targetGlowAlpha = 1
RBP.dbp.barlessPlate_targetGlowColor = {1, 0.75, 0}
-- Barless Plate: Player Name Text
RBP.dbp.barlessPlate_showText = true
RBP.dbp.barlessPlate_textFont = RBP.BlizzFontKey
RBP.dbp.barlessPlate_textSize = 14
RBP.dbp.barlessPlate_textOutline = "OUTLINE"
RBP.dbp.barlessPlate_offset = 0
RBP.dbp.barlessPlate_textColor = {0.1, 0, 1}
RBP.dbp.barlessPlate_nameColorByHP = false
RBP.dbp.barlessPlate_classColors = true
-- Barless Plate: NPC Name Text
RBP.dbp.barlessPlate_showNPCtext = true
RBP.dbp.barlessPlate_NPCtextFont = RBP.RefinedFontKey
RBP.dbp.barlessPlate_NPCtextSize = 13
RBP.dbp.barlessPlate_NPCtextOutline = "OUTLINE"
RBP.dbp.barlessPlate_NPCoffset = 0
RBP.dbp.barlessPlate_NPCtextColor = {0, 1, 0.1}
RBP.dbp.barlessPlate_NPCnameColorByHP = false
-- Barless Plate: Player Health Text
RBP.dbp.barlessPlate_showHealthText = true
RBP.dbp.barlessPlate_healthTextAnchor = "Bottom"
RBP.dbp.barlessPlate_healthTextOffsetX = 0
RBP.dbp.barlessPlate_healthTextOffsetY = 0
RBP.dbp.barlessPlate_healthTextFont = RBP.RefinedFontKey
RBP.dbp.barlessPlate_healthTextSize = 11
RBP.dbp.barlessPlate_healthTextOutline = "OUTLINE"
-- Barless Plate: NPC Health Text
RBP.dbp.barlessPlate_showNPCHealthText = false
RBP.dbp.barlessPlate_NPChealthTextAnchor = "Bottom"
RBP.dbp.barlessPlate_NPChealthTextOffsetX = 0
RBP.dbp.barlessPlate_NPChealthTextOffsetY = 0
RBP.dbp.barlessPlate_NPChealthTextFont = RBP.RefinedFontKey
RBP.dbp.barlessPlate_NPChealthTextSize = 11
RBP.dbp.barlessPlate_NPChealthTextOutline = "OUTLINE"
-- Barless Plate: Raid Target Icon
RBP.dbp.barlessPlate_showRaidTarget = false
RBP.dbp.barlessPlate_raidTargetIconSize = 30
RBP.dbp.barlessPlate_raidTargetIconAnchor = "Top"
RBP.dbp.barlessPlate_raidTargetIconOffsetX = 0
RBP.dbp.barlessPlate_raidTargetIconOffsetY = 0
-- Barless Plate: Class Icon
RBP.dbp.barlessPlate_showClassIcon = false
RBP.dbp.barlessPlate_classIconSize = 32
RBP.dbp.barlessPlate_classIconAnchor = "Top"
RBP.dbp.barlessPlate_classIconOffsetX = 0
RBP.dbp.barlessPlate_classIconOffsetY = 0
-- Barless Plate: BG Healer Icon
RBP.dbp.barlessPlate_BGHiconSize = 36
RBP.dbp.barlessPlate_BGHiconAnchor = "Top"
RBP.dbp.barlessPlate_BGHiconOffsetX = 0
RBP.dbp.barlessPlate_BGHiconOffsetY = 0
-- Totem Plate
RBP.dbp.totemSize = 27 -- Size of the totem (or NPC) icon replacing the nameplate
RBP.dbp.totemOffset = 0 -- Vertical offset for totem icon
RBP.dbp.showTotemBorder = true -- Colors the totem border green (friendly) or red (enemy)
RBP.dbp.hideFriendlyTotem = false
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
			name = L["General"],
			type = "group",
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				general_header = {
					order = 2,
					type = "header",
					name = L["General Settings"],
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				healthBar_border = {
					order = 4,
					type = "select",
					name = L["Nameplate Style Preset"],
					desc = L["This will override some of your current settings to match the preset."],
					confirm = true,
					confirmText = L["This will override some of your current settings to match the preset."],
					values = {
						["Refined"] = "Refined",
						["Blizzard"] = "Blizzard",
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:ApplyPreset()
					end,
				},
				lineBreak3 = {order = 5, type = "description", name = ""},
				lineBreak4 = {order = 6, type = "description", name = ""},
				lineBreak5 = {order = 7, type = "description", name = ""},
				globalScale = {
					order = 8,
					type = "range",
					name = L["Global Scale"],
					desc = L["Scales both the visual size and the clickbox of nameplates."],
					min = 0.5,
					max = 2.5,
					step = 0.01,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllVirtualsScale()
						RBP:UpdateClickboxAttributes()
					end,
				},
				globalOffsetX = {
					order = 9,
					type = "range",
					name = L["Global Offset X"],
					desc = L["Affects only the nameplate's visual regions. The clickbox can't be moved using this feature."],
					min = -50,
					max = 50,
					step = 0.1,
					set = function(info, val)
						RBP.dbp.globalOffsetX = val
						RBP:UpdateAllShownPlates()
					end,
				},
				globalOffsetY = {
					order = 10,
					type = "range",
					name = L["Global Offset Y"],
					desc = L["Affects only the nameplate's visual regions. The clickbox can't be moved using this feature."],
					min = -50,
					max = 50,
					step = 0.1,
					set = function(info, val)
						RBP.dbp.globalOffsetY = val
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak6 = {order = 11, type = "description", name = ""},
				lineBreak7 = {order = 12, type = "description", name = ""},
				targetScale = {
					order = 13,
					type = "range",
					name = L["Target Scale Factor"],
					desc = L["Adjusts the target nameplate’s scale, applied multiplicatively with the global scale."],
					min = 1,
					max = 1.5,
					step = 0.01,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllVirtualsScale()
					end,
				},
				friendlyScale = {
					order = 14,
					type = "range",
					name = L["Friendly Scale Factor"],
					desc = L["Adjusts friendly nameplate scale, applied multiplicatively with the global scale. Affects the visual size and the clickbox."],
					min = 0.5,
					max = 1,
					step = 0.01,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllVirtualsScale()
						RBP:UpdateClickboxAttributes()
					end,
				},
				lineBreak8 = {order = 15, type = "description", name = ""},
				lineBreak9 = {order = 16, type = "description", name = ""},
				modNonTargetAlpha = {
					order = 17,
					type = "toggle",
					name = L["Non-target Alpha Mod"],
					desc = L["Overrides non-target nameplate opacity. May slightly increase CPU usage."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateNonTargetAlphaDriver()
					end,
				},
				nonTargetAlpha = {
					order = 18,
					type = "range",
					name = L["Non-target Alpha"],
					min = 0,
					max = 0.99,
					step = 0.01,
					isPercent = true,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
					end,
					disabled = function()
						return not RBP.dbp.modNonTargetAlpha
					end,
				},
				lineBreak10 = {order = 19, type = "description", name = ""},
				lineBreak11 = {order = 20, type = "description", name = ""},
				clickbox_header = {
					order = 21,
					type = "header",
					name = L["Box Selection Space"],
				},
				lineBreak12 = {order = 22, type = "description", name = ""},
				lineBreak13 = {order = 23, type = "description", name = ""},
				clickboxWidthFactor = {
					order = 24,
					type = "range",
					name = L["Clickbox Width Factor"],
					desc = L["Scales the nameplate clickbox relative to its original size. Recommended to change this setting while out of combat."],
					min = 0.25,
					max = 1.5,
					step = 0.01,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
						RBP:UpdateClickboxAttributes()
					end,
				},
				clickboxHeightFactor = {
					order = 25,
					type = "range",
					name = L["Clickbox Height Factor"],
					desc = L["Scales the nameplate clickbox relative to its original size. Recommended to change this setting while out of combat."],
					min = 0.25,
					max = 1.5,
					step = 0.01,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
						RBP:UpdateClickboxAttributes()
					end,
				},
				friendlyClickthrough = {
					order = 26,
					type = "toggle",
					name = L["Click-through Friendly Nameplates"],
					desc = L["Disable friendly nameplates clickboxes inside PvE and PvP instances."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
						RBP:UpdateClickboxAttributes()
					end,
				},
				showClickbox = {
					order = 27,
					type = "toggle",
					name = L["Show Clickbox"],
					desc = L["Displays the Box Selection Space (Clickbox) of nameplates"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllClickboxTextures()
					end,
				},
				lineBreak14 = {order = 28, type = "description", name = ""},
				lineBreak15 = {order = 29, type = "description", name = ""},
				misc_header = {
					order = 30,
					type = "header",
					name = L["Miscellaneous Settings"],
				},
				lineBreak16 = {order = 31, type = "description", name = ""},
				clampTarget = {
					order = 32,
					type = "toggle",
					name = L["Clamp Target"],
					desc = L["Prevents targeted enemy nameplate from going above the top of the screen."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateWorldFrameHeight()
						RBP:UpdateAllShownPlates()
					end,					
				},
				clampBoss = {
					order = 33,
					type = "toggle",
					name = L["Clamp Bosses"],
					desc = L["Prevents boss nameplates inside instances from going above the top of the screen."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateWorldFrameHeight()
						RBP:UpdateAllShownPlates()
					end,		
				},
				upperborder = {
					order = 34,
					type = "range",
					name = L["Clamping Top Inset"],
					desc = L["Adjusts the distance below the top of the screen where clamped nameplates will stop."],
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
				levelFilter = {
					order = 35,
					type = "range",
					name = L["Level Filter"],
					desc = L["Minimum unit level required for the nameplate to be shown."],
					min = 1,
					max = 80,
					step = 1,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},
				LDWfix = {
					order = 36,
					type = "toggle",
					name = L["Hide on LDW MC"],
					desc = L["Hide nameplates when mind-controlled by Lady Deathwhisper."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateLDWfix()
					end,
				},
				lineBreak17 = {order = 37, type = "description", name = ""},
				lineBreak18 = {order = 38, type = "description", name = ""},
				stacking_header = {
					order = 39,
					type = "header",
					name = L["Retail-like Stacking"],
				},
				lineBreak19 = {order = 40, type = "description", name = ""},
				stackingEnabled = {
					order = 41,
					type = "toggle",
					name = L["Enable"],
					desc = L["Simulates Retail's nameplate stacking for enemies. This feature has a high CPU cost, use it with discretion."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateCVars()
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak20 = {order = 42, type = "description", name = ""},
				lineBreak21 = {order = 43, type = "description", name = ""},
				xspace = {
					order = 44,
					type = "range",
					name = L["Collider Width"],
					desc = L["Sets the width of the virtual collider centered on each nameplate used to detect overlaps."],
					min = 20,
					max = 200,
					step = 1,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				yspace = {
					order = 45,
					type = "range",
					name = L["Collider Height"],
					desc = L["Sets the height of the virtual collider centered on each nameplate used to detect overlaps."],
					min = 5,
					max = 50,
					step = 1,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				originpos = {
					order = 46,
					type = "range",
					name = L["Vertical Offset"],
					desc = L["Vertically offsets the entire nameplate, including its clickbox."],
					min = 0,
					max = 50,
					step = 1,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				yspeed = {
					order = 47,
					type = "range",
					name = L["Stacking Speed"],
					desc = L["Speed at which nameplates move to resolve overlaps."],
					min = 100,
					max = 320,
					step = 1,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				FreezeMouseover = {
					order = 48,
					type = "toggle",
					name = L["Freeze Mouseover"],
					desc = L["Stops the nameplate you're mousing over from moving for better selection."],
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				stackingInInstance = {
					order = 49,
					type = "toggle",
					name = L["Disable in Open World"],
					desc = L["Only process stacking inside PvE and PvP instances. This will reduce CPU usage in the open world."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not RBP.dbp.stackingEnabled
					end,
				},
				lineBreak22 = {order = 50, type = "description", name = ""},
				lineBreak23 = {order = 51, type = "description", name = ""},
				depth_header = {
					order = 52,
					type = "header",
					name = L["Depth Perspective"],
					hidden = function() return not RBP.hasModernAPI end,
				},
				lineBreak24 = {order = 53, type = "description", name = ""},
				depthScaling = {
					order = 54,
					type = "toggle",
					name = L["Depth Scaling"],
					desc = L["Scales nameplates by camera distance, so distant plates appear smaller. This feature has a high CPU cost, use it with discretion. Not recommended to use together with Retail-like Stacking."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						if not val then
							RBP:ResetDynamicScales()
							RBP:UpdateAllShownPlates()
						end
					end,
					hidden = function() return not RBP.hasModernAPI end,
				},
				depthPivot = {
					order = 55,
					type = "range",
					name = L["Depth Pivot"],
					desc = L["Reference depth where plates keep their normal size. Beyond it, they shrink."],
					min = 40,
					max = 120,
					step = 1,
					disabled = function() return not RBP.dbp.depthScaling end,
					hidden = function() return not RBP.hasModernAPI end,
				},
				minScaleFactor = {
					order = 56,
					type = "range",
					name = L["Min Scale Factor"],
					desc = L["The smallest scale a distant nameplate can reach."],
					min = 0.1,
					max = 1.0,
					step = 0.01,
					disabled = function() return not RBP.dbp.depthScaling end,
					hidden = function() return not RBP.hasModernAPI end,
				},
				lineBreak25 = {order = 57, type = "description", name = ""},
				depthFading = {
					order = 58,
					type = "toggle",
					name = L["Depth Fading"],
					desc = L["Fades nameplates as they move further from the camera. This feature has a high CPU cost, use it with discretion. Not recommended to use together with Retail-like Stacking."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						if not val then
							RBP:ResetAllRegionsAlpha()
							RBP:ResetPBFlags()
						end
					end,
					hidden = function() return not RBP.hasModernAPI end,
				},
				depthFadeStart = {
					order = 59,
					type = "range",
					name = L["Fade Start Depth"],
					desc = L["Depth where fading begins. Closer plates stay fully visible."],
					min = 40,
					max = 140,
					step = 1,
					disabled = function() return not RBP.dbp.depthFading end,
					hidden = function() return not RBP.hasModernAPI end,
				},
				depthFadeRange = {
					order = 60,
					type = "range",
					name = L["Fade Range"],
					desc = L["Depth distance over which nameplates fade out completely."],
					min = 1,
					max = 60,
					step = 1,
					disabled = function() return not RBP.dbp.depthFading end,
					hidden = function() return not RBP.hasModernAPI end,
				},
				fadeNPCs = {
					order = 61,
					type = "toggle",
					name = L["Hide Distant NPCs"],
					desc = L["Hides NPC nameplates at very long distances."],
					disabled = function() return not RBP.dbp.depthFading end,					
					hidden = function() return not RBP.hasModernAPI end,
				},
				fadePlateBuffs = {
					order = 62,
					type = "toggle",
					name = L["Fade PlateBuffs"],
					desc = L["Fades PlateBuffs icons on distant nameplates. Improves performance."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						if not val then
							RBP:ResetPBFlags()
						end
					end,
					disabled = function() return not RBP.dbp.depthFading end,					
					hidden = function() return not RBP.hasModernAPI end,
				},
				nameplateDistance = {
					order = 63,
					type = "range",
					name = L["Extended Draw Distance"],
					desc = L["Extends the distance at which nameplates are drawn."],
					min = 0,
					max = 1,
					isPercent = true,
					width = "full",
					step = 0.01,
					get = function()
						local val = tonumber(GetCVar("nameplateDistance")) or 41
						return math.log(val / 41) / math.log(500 / 41)
					end,
					set = function(_, val)
						SetCVar("nameplateDistance", 41 * (500 / 41)^val)
					end,
					hidden = function() return not RBP.hasModernAPI end,
				},
				cameraFov = {
					order = 64,
					type = "range",
					name = L["Field of View"],
					desc = L["Adjusts the camera field of view."],
					min = 60,
					max = 120,
					width = "full",
					step = 1,
					get = function()
						return tonumber(GetCVar("cameraFov"))
					end,
					set = function(_, val)
						SetCVar("cameraFov", val)
					end,
					hidden = function() return not RBP.hasModernAPI end,
				},
				lineBreak26 = {order = 65, type = "description", name = ""},
				lineBreak27 = {order = 66, type = "description", name = ""},
			},
		},
		Text = {
			order = 2,
			name = L["Text"],
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
					name = L["Name Text"],
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				nameText_font = {
					order = 4,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_size = {
					order = 5,
					type = "range",
					name = L["Font Size"],
					min = 5,
					max = 18,
					step = 0.1,
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_outline = {
					order = 6,
					type = "select", 
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_anchor = {
					order = 7,
					type = "select", 
					name = L["Anchor"],
					values = {
						["LEFT"] = L["Left"],
						["CENTER"] = L["Center"],
						["RIGHT"] = L["Right"],
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
					name = L["Offset X"],
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
					name = L["Offset Y"],
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
					name = L["Base Text Color"],
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
					name = L["Class Colors on Friends"],
					desc = L["Use class colors for friendly player names (only works for party or raid members)."],
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_classColorEnemies = {
					order = 12,
					type = "toggle",
					name = L["Class Colors on Enemies"],
					desc = L["Use class colors for enemy player names. 'Class Colors in Nameplates' must be enabled."],
					disabled = function()
						return RBP.dbp.nameText_hide
					end,
				},
				nameText_width = {
					order = 13,
					type = "range",
					name = L["Width"],
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
					name = L["Hide Name Text"],
				},
				lineBreak3 = {order = 15, type = "description", name = ""},
				lineBreak4 = {order = 16, type = "description", name = ""},
				levelText_header = {
					order = 17,
					type = "header",
					name = L["Level Text"],
				},
				lineBreak5 = {order = 18, type = "description", name = ""},
				levelText_font = {
					order = 19,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.levelText_hide
					end,
				},
				levelText_size = {
					order = 20,
					type = "range",
					name = L["Font Size"],
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
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return RBP.dbp.levelText_hide
					end,
				},
				levelText_anchor = {
					order = 22,
					type = "select", 
					name = L["Anchor"],
					values = {
						["Left"] = L["Left"],
						["Center"] = L["Center"],
						["Right"] = L["Right"],
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
					name = L["Offset X"],
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
					name = L["Offset Y"],
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
					name = L["Hide Level Text"],
				},
				lineBreak6 = {order = 26, type = "description", name = ""},
				ArenaIDText_header = {
					order = 27,
					type = "header",
					name = L["Arena/Party ID Text"],
				},
				lineBreak7 = {order = 28, type = "description", name = ""},
				lineBreak8 = {order = 29, type = "description", name = ""},
				ArenaIDText_SharedConfig = {
					order = 30, 
					type = "description", 
					name = L["Shared Settings"],
					fontSize = "medium",
				},
				lineBreak9 = {order = 31, type = "description", name = ""},
				ArenaIDText_font = {
					order = 32,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return not RBP.dbp.ArenaIDText_show and not RBP.dbp.PartyIDText_show
					end,
				},
				ArenaIDText_size = {
					order = 33,
					type = "range",
					name = L["Font Size"],
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
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return not RBP.dbp.ArenaIDText_show and not RBP.dbp.PartyIDText_show
					end,
				},
				ArenaIDText_anchor = {
					order = 35,
					type = "select", 
					name = L["Anchor"],
					values = {
						["Left"] = L["Left"],
						["Center"] = L["Center"],
						["Right"] = L["Right"],
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
					name = L["Offset X"],
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
					name = L["Offset Y"],
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
					name = L["Show ArenaID"],
					desc = L["Shows Arena ID numbers on nameplates in arena"],
					width = "full",
				},
				ArenaIDText_color = {
					order = 41,
					type = "color",
					name = L["ArenaID Color"],
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
					name = L["Hide Enemy Name"],
					desc = L["Hide name text on arena enemies"],
					disabled = function()
						return not RBP.dbp.ArenaIDText_show or RBP.dbp.nameText_hide
					end,
				},
				ArenaIDText_HideLevel = {
					order = 43,
					type = "toggle",
					name = L["Hide Enemy Level"],
					desc = L["Hide level text on arena enemies"],
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
					name = L["Show PartyID"],
					desc = L["Shows Party ID numbers on nameplates in arena"],
					width = "full",
				},
				PartyIDText_color = {
					order = 48,
					type = "color",
					name = L["PartyID Color"],
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
					name = L["Hide Friend Name"],
					desc = L["Hide name text on party"],
					disabled = function()
						return not RBP.dbp.PartyIDText_show or RBP.dbp.nameText_hide
					end,
				},
				PartyIDText_HideLevel = {
					order = 50,
					type = "toggle",
					name = L["Hide Friend Level"],
					desc = L["Hide level text on party"],
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
			name = L["Health Bar"],
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
					name = L["Appearance"],
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				healthBar_friendlyPlayerTex = {
					order = 4,
					type = "select",
					name = L["Friendly Player Texture"],
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllShownPlates()
					end,
				},
				healthBar_hostilePlayerTex = {
					order = 5,
					type = "select",
					name = L["Hostile Player Texture"],
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllShownPlates()
					end,
				},		
				healthBar_npcTex = {
					order = 6,
					type = "select",
					name = L["NPC Texture"],
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllShownPlates()
					end,
				},
				healthBar_borderTint = {
					order = 7,
					type = "color",
					name = L["Border Tint"],
					desc = L["This is a tint overlay, not a regular color. 'White' keeps the original look."],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllHealthBars()
					end,
				},
				healthBar_progressiveTexCrop = {
					order = 8,
					type = "toggle",
					name = L["Progressive Texture Cropping"],
				},
				healthBar_friendColor = {
					order = 9,
					type = "color",
					name = L["Party/Raid Color"],
					desc = L["Use a custom color for party and raid member nameplates."],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllShownPlates()
					end,
				},
				healthBar_friendClassColor = {
					order = 10,
					type = "toggle",
					name = L["Party/Raid Class Colors"],
					desc = L["Use class colors for party and raid member nameplates."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak3 = {order = 11, type = "description", name = ""},
				healthBar_bgHeader = {
					order = 12,
					type = "header",
					name = L["Background"],
				},
				lineBreak4 = {order = 13, type = "description", name = ""},
				healthBar_bgTex = {
					order = 14,
					type = "select",
					name = L["Texture"],
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllShownPlates()
					end,
				},
				healthBar_bgColor = {
					order = 15,
					type = "color",
					name = L["Color"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllShownPlates()
					end,
				},
				healthBar_bgAlpha = {
					order = 16,
					type = "range",
					name = L["Alpha"],
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllHealthBars()
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak5 = {order = 17, type = "description", name = ""},
				lineBreak6 = {order = 18, type = "description", name = ""},
				healthBarGlow_header = {
					order = 19,
					type = "header",
					name = L["Glows"],
				},
				lineBreak7 = {order = 20, type = "description", name = ""},
				showTargetGlowBorder = {
					order = 21,
					type = "toggle",
					name = L["Target Glow Border"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllGlows()
						RBP:UpdateAllShownPlates()
					end,
				},
				targetGlow_Color = {
					order = 22,
					type = "color",
					name = L["Target Glow Color"],
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
				targetGlow_Alpha = {
					order = 23,
					type = "range",
					name = L["Target Glow Alpha"],
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllGlows()
						RBP:UpdateAllShownPlates()
					end,
				},
				targetGlow_Gradient = {
					order = 24,
					type = "toggle",
					name = L["Target Glow Gradient"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllGlows()
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak8 = {order = 25, type = "description", name = ""},
				showMouseoverGlowBorder = {
					order = 26,
					type = "toggle",
					name = L["Mouseover Glow Border"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllGlows()
						RBP:UpdateAllShownPlates()
					end,
				},
				mouseoverGlow_Color = {
					order = 27,
					type = "color",
					name = L["Mouseover Glow Color"],
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
				mouseoverGlow_Alpha = {
					order = 28,
					type = "range",
					name = L["Mouseover Glow Alpha"],
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllGlows()
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak9 = {order = 29, type = "description", name = ""},
				lineBreak10 = {order = 30, type = "description",	name = ""},
				healthText_header = {
					order = 31,
					type = "header",
					name = L["Health Text"],
				},
				lineBreak11 = {order = 32, type = "description", name = ""},
				healthText_format = {
					order = 33,
					type = "select", 
					name = L["Format"],
					values = {
						[1] = L["Percent 0 dec."],
						[2] = L["Percent 1 dec."],
						[3] = L["Current"],
						[4] = L["Current / Max"],
						[5] = L["Current (Perc.)"],
						[6] = L["Deficit"],
					},
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_hideMax = {
					order = 34,
					type = "toggle",
					name = L["Hide on max health"],
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_color = {
					order = 35,
					type = "color",
					name = L["Text Color"],
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
				healthText_font = {
					order = 36,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_size = {
					order = 37,
					type = "range",
					name = L["Font Size"],
					min = 5,
					max = 18,
					step = 0.1,
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_outline = {
					order = 38,
					type = "select", 
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_anchor = {
					order = 39,
					type = "select", 
					name = L["Anchor"],
					values = {
						["LEFT"] = L["Left"],
						["CENTER"] = L["Center"],
						["RIGHT"] = L["Right"],
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
					order = 40,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_offsetY = {
					order = 41,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.healthText_hide
					end,
				},
				healthText_hide = {
					order = 42,
					type = "toggle",
					name = L["Hide Health Text"],
				},
				lineBreak12 = {order = 43, type = "description", name = ""},
				lineBreak13 = {order = 44, type = "description", name = ""},
				lowHpColoring_header = {
					order = 45,
					type = "header",
					name = L["Low Health Coloring"],
				},
				lowHpColor_EnemyPlayers = {
					order = 46,
					type = "toggle",
					name = L["Enemy Players"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},
				lowHpColor_EnemyNPCs = {
					order = 47,
					type = "toggle",
					name = L["Enemy NPCs"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},
				lowHpColor_FriendlyPlayers = {
					order = 48,
					type = "toggle",
					name = L["Friendly Players"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},
				lowHpColor_FriendlyNPCs = {
					order = 49,
					type = "toggle",
					name = L["Friendly NPCs"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},		
				lineBreak14 = {order = 50, type = "description", name = ""},
				lowHpColor_threshold = {
					order = 51,
					type = "range",
					name = L["Threshold"],
					desc = L["Overrides health bar colors when health is at or below the configured percentage threshold."],
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not (RBP.dbp.lowHpColor_EnemyPlayers or RBP.dbp.lowHpColor_EnemyNPCs or RBP.dbp.lowHpColor_FriendlyPlayers or RBP.dbp.lowHpColor_FriendlyNPCs)
					end,
				},
				lowHpColor_color = {
					order = 52,
					type = "color",
					name = L["Color"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not (RBP.dbp.lowHpColor_EnemyPlayers or RBP.dbp.lowHpColor_EnemyNPCs or RBP.dbp.lowHpColor_FriendlyPlayers or RBP.dbp.lowHpColor_FriendlyNPCs)
					end,
				},
				lineBreak15 = {order = 53, type = "description", name = ""},
				lineBreak16 = {order = 54, type = "description", name = ""},						
				aggroOverlay_header = {
					order = 55,
					type = "header",
					name = L["Aggro Coloring"],
				},
				lineBreak17 = {order = 56, type = "description", name = ""},
				enableAggroColoring = {
					order = 57,
					type = "toggle",
					name = L["Enable"],
					desc = L["Changes NPC health bar color based on aggro status."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateCVars()
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak18 = {order = 58, type = "description", name = ""},
				lineBreak19 = {order = 59, type = "description", name = ""},
				aggroColor = {
					order = 60,
					type = "color",
					name = L["Aggro"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
					end,
					disabled = function()
						return not RBP.dbp.enableAggroColoring
					end,
				},
				gainingAggroColor = {
					order = 61,
					type = "color",
					name = L["Gaining Aggro"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
					end,
					disabled = function()
						return not RBP.dbp.enableAggroColoring
					end,
				},
				losingAggroColor = {
					order = 62,
					type = "color",
					name = L["Losing Aggro"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
					end,
					disabled = function()
						return not RBP.dbp.enableAggroColoring
					end,
				},
				disableAggroOpenworld = {
					order = 63,
					type = "toggle",
					name = L["Disable in Open World"],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateCVars()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not RBP.dbp.enableAggroColoring
					end,
				},
				lineBreak20 = {order = 64, type = "description", name = ""},
				lineBreak21 = {order = 65, type = "description", name = ""},
			},
		},
		CastBar = {
			order = 4,
			name = L["Cast Bar"],
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
					name = L["Appearance"],
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				castBar_Tex = {
					order = 4,
					type = "select",
					name = L["Bar Texture"],
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
				},
				castBar_color = {
					order = 5,
					type = "color",
					name = L["Casting Color"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllCastBars()
					end,
				},
				castBar_channelingColor = {
					order = 6,
					type = "color",
					name = L["Channeling Color"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllCastBars()
					end,
				},
				castBar_progressiveTexCrop = {
					order = 7,
					type = "toggle",
					name = L["Progressive Texture Cropping"],
				},
				castBar_showSpark = {
					order = 8,
					type = "toggle",
					name = L["Show Spark"],
				},
				castBar_nonTargetPatch = {
					order = 9,
					type = "toggle",
					name = L["Non-target units fade"],
					desc = L["Improves the non-target castbar fade effect when using the corresponding patch. Leave this option disabled if the patch is not installed."],
				},
				castBar_borderTint = {
					order = 10,
					type = "color",
					name = L["Border Tint"],
					desc = L["This is a tint overlay, not a regular color. 'White' keeps the original look."],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllCastBars()
					end,
				},
				castBar_protectedBorderTint = {
					order = 11,
					type = "color",
					name = L["Protected Border Tint"],
					desc = L["This is a tint overlay, not a regular color. 'White' keeps the original look."],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllCastBars()
					end,
				},
				lineBreak3 = {order = 12, type = "description", name = ""},
				castBar_bgHeader = {
					order = 13,
					type = "header",
					name = L["Background"],
				},
				lineBreak4 = {order = 14, type = "description", name = ""},
				castBar_bgTex = {
					order = 15,
					type = "select",
					name = L["Texture"],
					dialogControl = "LSM30_Statusbar",
					values = AceGUIWidgetLSMlists.statusbar,
				},
				castBar_bgColor = {
					order = 16,
					type = "color",
					name = L["Color"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllCastBars()
					end,
				},
				castBar_bgAlpha = {
					order = 17,
					type = "range",
					name = L["Alpha"],
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
				},
				lineBreak5 = {order = 18, type = "description", name = ""},
				castText_header = {
					order = 19,
					type = "header",
					name = L["Cast Text"],
				},
				lineBreak6 = {order = 20, type = "description", name = ""},
				castText_font = {
					order = 21,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_size = {
					order = 22,
					type = "range",
					name = L["Font Size"],
					min = 5,
					max = 18,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_outline = {
					order = 23,
					type = "select", 
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_anchor = {
					order = 24,
					type = "select", 
					name = L["Anchor"],
					values = {
						["LEFT"] = L["Left"],
						["CENTER"] = L["Center"],
						["RIGHT"] = L["Right"],
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
					order = 25,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_offsetY = {
					order = 26,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_width = {
					order = 27,
					type = "range",
					name = L["Width"],
					min = 50,
					max = 250,
					step = 1,
					disabled = function()
						return RBP.dbp.castText_hide
					end,
				},
				castText_color = {
					order = 28,
					type = "color",
					name = L["Text Color"],
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
					order = 29,
					type = "toggle",
					name = L["Hide Cast Text"],
				},
				lineBreak7 = {order = 30, type = "description", name = ""},
				lineBreak8 = {order = 31, type = "description",	name = ""},
				castTimerText_header = {
					order = 32,
					type = "header",
					name = L["Cast Timer Text"],
				},
				lineBreak9 = {order = 33, type = "description", name = ""},
				castTimerText_font = {
					order = 34,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_size = {
					order = 35,
					type = "range",
					name = L["Font Size"],
					min = 5,
					max = 18,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_outline = {
					order = 36,
					type = "select", 
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_anchor = {
					order = 37,
					type = "select", 
					name = L["Anchor"],
					values = {
						["LEFT"] = L["Left"],
						["CENTER"] = L["Center"],
						["RIGHT"] = L["Right"],
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
					order = 38,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_offsetY = {
					order = 39,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return RBP.dbp.castTimerText_hide
					end,
				},
				castTimerText_color = {
					order = 40,
					type = "color",
					name = L["Text Color"],
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
					order = 41,
					type = "toggle",
					name = L["Hide Cast Timer Text"],
				},
				lineBreak10 = {order = 42, type = "description", name = ""},
				lineBreak11 = {order = 43, type = "description", name = ""},
			},
		},
		Icons = {
			order = 5,
			name = L["Icons"],
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
					name = L["Elite Icon"],
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				eliteIcon_style = {
					order = 4,
					type = "select", 
					name = L["Style"],
					values = {
						["Default"] = L["Default"],
						["Modern"] = L["Modern"],
						["Minimalist"] = L["Minimalist"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
				},
				eliteIcon_widthScale = {
					order = 5,
					type = "range",
					name = L["Width Factor"],
					min = 0.5,
					max = 1.5,
					step = 0.01,
				},
				eliteIcon_heightScale = {
					order = 6,
					type = "range",
					name = L["Height Factor"],
					min = 0.5,
					max = 1.5,
					step = 0.01,
				},
				eliteIcon_anchor = {
					order = 7,
					type = "select", 
					name = L["Anchor"],
					values = {
						["Left"] = L["Left"],
						["Right"] = L["Right"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.eliteIcon_offsetX = 0
						RBP.dbp.eliteIcon_offsetY = 0
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
				},
				eliteIcon_offsetX = {
					order = 8,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
				},
				eliteIcon_offsetY = {
					order = 9,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
				},
				eliteIcon_Tint = {
					order = 10,
					type = "color",
					name = L["Tint"],
					desc = L["This is a tint overlay, not a regular color. 'White' keeps the original look."],
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
				lineBreak3 = {order = 11, type = "description", name = ""},
				lineBreak4 = {order = 12, type = "description", name = ""},
				bossIcon_header = {
					order = 13,
					type = "header",
					name = L["Boss Icon"],
				},
				lineBreak5 = {order = 14, type = "description", name = ""},
				bossIcon_anchor = {
					order = 15,
					type = "select", 
					name = L["Anchor"],
					values = {
						["Left"] = L["Left"],
						["Top"] = L["Top"],
						["Right"] = L["Right"],
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
					order = 16,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
				},
				bossIcon_offsetY = {
					order = 17,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
				},
				bossIcon_size = {
					order = 18,
					type = "range",
					name = L["Icon Size"],
					min = 10,
					max = 30,
					step = 0.1,
				},
				lineBreak6 = {order = 19, type = "description",	name = ""},
				lineBreak7 = {order = 20, type = "description", name = ""},
				raidTargetIcon_header = {
					order = 21,
					type = "header",
					name = L["Raid Target Icon"],
				},
				lineBreak8 = {order = 22, type = "description",	name = ""},
				raidTargetIcon_anchor = {
					order = 23,
					type = "select", 
					name = L["Anchor"],
					values = {
						["Left"] = L["Left"],
						["Top"] = L["Top"],
						["Right"] = L["Right"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.raidTargetIcon_offsetX = 0
						RBP.dbp.raidTargetIcon_offsetY = 0
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return RBP.dbp.raidTargetIcon_hide
					end,
				},
				raidTargetIcon_offsetX = {
					order = 24,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return RBP.dbp.raidTargetIcon_hide
					end,
				},
				raidTargetIcon_offsetY = {
					order = 25,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return RBP.dbp.raidTargetIcon_hide
					end,
				},
				raidTargetIcon_size = {
					order = 26,
					type = "range",
					name = L["Icon Size"],
					min = 15,
					max = 50,
					step = 0.1,
					disabled = function() 
						return RBP.dbp.raidTargetIcon_hide
					end,
				},
				raidTargetIcon_hide = {
					order = 27,
					type = "toggle",
					name = L["Hide Icon"],
				},
				lineBreak9 = {order = 28, type = "description", name = ""},
				lineBreak10 = {order = 29, type = "description", name = ""},
				classIcon_header = {
					order = 30,
					type = "header",
					name = L["Class Icon"],
				},
				lineBreak11 = {order = 31, type = "description", name = ""},
				classIcon_anchor = {
					order = 32,
					type = "select", 
					name = L["Anchor"],
					values = {
						["Left"] = L["Left"],
						["Top"] = L["Top"],
						["Right"] = L["Right"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.classIcon_offsetX = 0
						RBP.dbp.classIcon_offsetY = 0
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return not (RBP.dbp.showClassOnFriends or RBP.dbp.showClassOnEnemies)
					end,
				},
				classIcon_offsetX = {
					order = 33,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not (RBP.dbp.showClassOnFriends or RBP.dbp.showClassOnEnemies)
					end,
				},
				classIcon_offsetY = {
					order = 34,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not (RBP.dbp.showClassOnFriends or RBP.dbp.showClassOnEnemies)
					end,
				},
				classIcon_size = {
					order = 35,
					type = "range",
					name = L["Icon Size"],
					min = 15,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not (RBP.dbp.showClassOnFriends or RBP.dbp.showClassOnEnemies)
					end,
				},
				showClassOnFriends = {
					order = 36,
					type = "toggle",
					name = L["Show on Friends"],
					desc = L["Class icons will only be shown inside PvE or PvP instances."],
				},
				showClassOnEnemies = {
					order = 37,
					type = "toggle",
					name = L["Show on Enemies"],
					desc = L["Class icons will only be shown inside PvE or PvP instances."],
				},
				lineBreak12 = {order = 38, type = "description", name = ""},
				lineBreak13 = {order = 39, type = "description", name = ""},
			},
		},
		BarlessPlate = {
			order = 6,
			name = L["Barless Plate"],
			type = "group",
			set = function(info, val)
				RBP.dbp[info[#info]] = val
				RBP:UpdateAllBarlessPlates()
				RBP:UpdateAllShownPlates()
			end,
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				barlessPlate_enableHeader = {
					order = 2,
					type = "header",
					name = L["Enable Filters"],
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				lineBreak3 = {order = 4, type = "description", name = ""},
				barlessPlate_filterOpenWorld = {
					order = 5,
					type = "select",
					name = L["Open World"],
					values = BarlessPlateFilterValues,
				},
				barlessPlate_filterPvE = {
					order = 6,
					type = "select",
					name = L["PvE Instances"],
					values = BarlessPlateFilterValues,
				},
				barlessPlate_filterBG = {
					order = 7,
					type = "select",
					name = L["Battlegrounds"],
					values = BarlessPlateFilterValues,
				},
				barlessPlate_filterArena = {
					order = 8,
					type = "select",
					name = L["Arenas"],
					values = BarlessPlateFilterValues,
				},
				lineBreak4 = {order = 9, type = "description", name = ""},
				lineBreak5 = {order = 10, type = "description", name = ""},
				barlessPlate_targetHeader = {
					order = 11,
					type = "header",
					name = L["Target Settings"],
				},
				lineBreak6 = {order = 12, type = "description", name = ""},
				lineBreak7 = {order = 13, type = "description", name = ""},
				barlessPlate_excludeTarget = {
					order = 14,
					type = "toggle",
					name = L["Exclude Target"],
					desc = L["Shows the normal layout on your target's nameplate."],
					disabled = function()
						return IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_targetGlowColor = {
					order = 15,
					type = "color",
					name = L["Target Glow Color"],
					get = function(info)
						local c = RBP.dbp[info[#info]]
						return c[1], c[2], c[3]
					end,
					set = function(info, r, g, b)
						RBP.dbp[info[#info]] = {r, g, b}
						RBP:UpdateAllBarlessPlates()
					end,
					disabled = function()
						return RBP.dbp.barlessPlate_excludeTarget or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_targetGlowAlpha = {
					order = 16,
					type = "range",
					name = L["Target Glow Alpha"],
					min = 0,
					max = 1,
					step = 0.01,
					isPercent = true,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllBarlessPlates()
					end,
					disabled = function()
						return RBP.dbp.barlessPlate_excludeTarget or IsBarlessPlateDisabled()
					end,
				},
				lineBreak8 = {order = 17, type = "description", name = ""},
				lineBreak9 = {order = 18, type = "description", name = ""},
				barlessPlate_nameHeader = {
					order = 19,
					type = "header",
					name = L["Player Name Text"],
				},
				lineBreak10 = {order = 20, type = "description", name = ""},
				barlessPlate_showText = {
					order = 21,
					type = "toggle",
					name = L["Enable"],
					desc = L["The name text is used as the indicators' anchor reference, even when disabled."],
					disabled = function()
						return IsBarlessPlateDisabled()
					end,
				},
				lineBreak11 = {order = 22, type = "description", name = ""},			
				barlessPlate_textFont = {
					order = 23,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return not RBP.dbp.barlessPlate_showText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_textSize = {
					order = 24,
					type = "range",
					name = L["Font Size"],
					min = 8,
					max = 20,
					step = 0.1,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
						RBP:UpdateClickboxAttributes()
					end,
					disabled = function()
						return not RBP.dbp.barlessPlate_showText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_textOutline = {
					order = 25,
					type = "select", 
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return not RBP.dbp.barlessPlate_showText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_offset = {
					order = 26,
					type = "range",
					name = L["Offset Y"],
					desc = L["Adjusts the visual vertical position (does not affect the clickbox)."],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_textColor = {
					order = 27,
					type = "color",
					name = L["Text Color"],
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
						return not RBP.dbp.barlessPlate_showText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_nameColorByHP = {
					order = 28,
					type = "toggle",
					name = L["Gray Out by Health %"],
					desc = L["Progressively grays the name from right to left based on remaining health."],
					disabled = function()
						return not RBP.dbp.barlessPlate_showText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_classColors = {
					order = 29,
					type = "toggle",
					name = L["Use class color"],
					disabled = function()
						return not RBP.dbp.barlessPlate_showText or IsBarlessPlateDisabled()
					end,
				},
				lineBreak12 = {order = 30, type = "description", name = ""},
				lineBreak13 = {order = 31, type = "description", name = ""},
				barlessPlate_NPCnameHeader = {
					order = 32,
					type = "header",
					name = L["NPC Name Text"],
				},
				lineBreak14 = {order = 33, type = "description", name = ""},
				barlessPlate_showNPCtext = {
					order = 34,
					type = "toggle",
					name = L["Enable"],
					desc = L["The name text is used as the indicators' anchor reference, even when disabled."],
					disabled = function()
						return IsBarlessPlateDisabled()
					end,
				},
				lineBreak15 = {order = 35, type = "description", name = ""},
				barlessPlate_NPCtextFont = {
					order = 36,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCtext or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPCtextSize = {
					order = 37,
					type = "range",
					name = L["Font Size"],
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCtext or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPCtextOutline = {
					order = 38,
					type = "select", 
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCtext or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPCoffset = {
					order = 39,
					type = "range",
					name = L["Offset Y"],
					desc = L["Adjusts the visual vertical position (does not affect the clickbox)."],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCtext or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPCtextColor = {
					order = 40,
					type = "color",
					name = L["Text Color"],
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
						return not RBP.dbp.barlessPlate_showNPCtext or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPCnameColorByHP = {
					order = 41,
					type = "toggle",
					name = L["Gray Out by Health %"],
					desc = L["Progressively grays the name from right to left based on remaining health."],
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCtext or IsBarlessPlateDisabled()
					end,
				},
				lineBreak16 = {order = 42, type = "description", name = ""},
				lineBreak17 = {order = 43, type = "description", name = ""},
				barlessPlate_healthHeader = {
					order = 44,
					type = "header",
					name = L["Player Health Text"],
				},				
				lineBreak18 = {order = 45, type = "description", name = ""},
				barlessPlate_showHealthText = {
					order = 46,
					type = "toggle",
					name = L["Enable"],
					disabled = function()
						return IsBarlessPlateDisabled()
					end,
				},
				lineBreak19 = {order = 47, type = "description", name = ""},
				barlessPlate_healthTextAnchor = {
					order = 48,
					type = "select", 
					name = L["Anchor"],
					desc = L["Sets the anchor point relative to the name text."],
					values = {
						["Left"] = L["Left"],
						["Top"] = L["Top"],
						["Right"] = L["Right"],
						["Bottom"] = L["Bottom"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_healthTextOffsetX = 0
						RBP.dbp.barlessPlate_healthTextOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not RBP.dbp.barlessPlate_showHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_healthTextOffsetX = {
					order = 49,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_healthTextOffsetY = {
					order = 50,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_healthTextFont = {
					order = 51,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return not RBP.dbp.barlessPlate_showHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_healthTextSize = {
					order = 52,
					type = "range",
					name = L["Font Size"],
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_healthTextOutline = {
					order = 53,
					type = "select", 
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return not RBP.dbp.barlessPlate_showHealthText or IsBarlessPlateDisabled()
					end,
				},
				lineBreak20 = {order = 54, type = "description", name = ""},
				lineBreak21 = {order = 55, type = "description", name = ""},
				barlessPlate_NPChealthHeader = {
					order = 56,
					type = "header",
					name = L["NPC Health Text"],
				},				
				lineBreak22 = {order = 57, type = "description", name = ""},
				barlessPlate_showNPCHealthText = {
					order = 58,
					type = "toggle",
					name = L["Enable"],
					disabled = function()
						return IsBarlessPlateDisabled()
					end,
				},
				lineBreak23 = {order = 59, type = "description", name = ""},
				barlessPlate_NPChealthTextAnchor = {
					order = 60,
					type = "select", 
					name = L["Anchor"],
					desc = L["Sets the anchor point relative to the name text."],
					values = {
						["Left"] = L["Left"],
						["Top"] = L["Top"],
						["Right"] = L["Right"],
						["Bottom"] = L["Bottom"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_NPChealthTextOffsetX = 0
						RBP.dbp.barlessPlate_NPChealthTextOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPChealthTextOffsetX = {
					order = 61,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPChealthTextOffsetY = {
					order = 62,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPChealthTextFont = {
					order = 63,
					type = "select",
					name = L["Text Font"],
					values = RBP.LSM:HashTable("font"),
					dialogControl = "LSM30_Font",
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPChealthTextSize = {
					order = 64,
					type = "range",
					name = L["Font Size"],
					min = 8,
					max = 20,
					step = 0.1,
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCHealthText or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_NPChealthTextOutline = {
					order = 65,
					type = "select", 
					name = L["Outline"],
					values = {
						[""] = L["None"],
						["OUTLINE"] = L["Outline"],
						["THICKOUTLINE"] = L["Thick Outline"],
						["MONOCHROME"] = L["Monochrome"],
						["OUTLINE,MONOCHROME"] = L["Monochrome Outline"],
						["THICKOUTLINE,MONOCHROME"] = L["Monochrome Thick Outline"],
					},
					disabled = function()
						return not RBP.dbp.barlessPlate_showNPCHealthText or IsBarlessPlateDisabled()
					end,
				},
				lineBreak24 = {order = 66, type = "description", name = ""},
				lineBreak25 = {order = 67, type = "description", name = ""},
				barlessPlate_raidIconHeader = {
					order = 68,
					type = "header",
					name = L["Raid Target Icon"],
				},				
				lineBreak26 = {order = 69, type = "description", name = ""},
				barlessPlate_showRaidTarget = {
					order = 70,
					type = "toggle",
					name = L["Enable"],
					width = "full",
					disabled = function()
						return IsBarlessPlateDisabled()
					end,
				},
				lineBreak27 = {order = 71, type = "description", name = ""},
				barlessPlate_raidTargetIconAnchor = {
					order = 72,
					type = "select", 
					name = L["Anchor"],
					desc = L["Sets the anchor point relative to the name text."],
					values = {
						["Left"] = L["Left"],
						["Top"] = L["Top"],
						["Right"] = L["Right"],
						["Bottom"] = L["Bottom"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_raidTargetIconOffsetX = 0
						RBP.dbp.barlessPlate_raidTargetIconOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showRaidTarget or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_raidTargetIconOffsetX = {
					order = 73,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showRaidTarget or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_raidTargetIconOffsetY = {
					order = 74,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showRaidTarget or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_raidTargetIconSize = {
					order = 75,
					type = "range",
					name = L["Icon Size"],
					min = 20,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showRaidTarget or IsBarlessPlateDisabled()
					end,
				},
				lineBreak28 = {order = 76, type = "description", name = ""},
				lineBreak29 = {order = 77, type = "description", name = ""},
				barlessPlate_classIconHeader = {
					order = 78,
					type = "header",
					name = L["Class Icon"],
				},				
				lineBreak30 = {order = 79, type = "description", name = ""},
				barlessPlate_showClassIcon = {
					order = 80,
					type = "toggle",
					name = L["Enable"],
					disabled = function() 
						return IsBarlessPlateDisabled()
					end,
				},
				lineBreak31 = {order = 81, type = "description", name = ""},
				barlessPlate_classIconAnchor = {
					order = 82,
					type = "select", 
					name = L["Anchor"],
					desc = L["Sets the anchor point relative to the name text."],
					values = {
						["Left"] = L["Left"],
						["Top"] = L["Top"],
						["Right"] = L["Right"],
						["Bottom"] = L["Bottom"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_classIconOffsetX = 0
						RBP.dbp.barlessPlate_classIconOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showClassIcon or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_classIconOffsetX = {
					order = 83,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showClassIcon or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_classIconOffsetY = {
					order = 84,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showClassIcon or IsBarlessPlateDisabled()
					end,
				},
				barlessPlate_classIconSize = {
					order = 85,
					type = "range",
					name = L["Icon Size"],
					min = 20,
					max = 50,
					step = 0.1,
					disabled = function() 
						return not RBP.dbp.barlessPlate_showClassIcon or IsBarlessPlateDisabled()
					end,
				},
				lineBreak32 = {order = 86, type = "description", name = ""},
				lineBreak33 = {order = 87, type = "description", name = ""},
				barlessPlate_BGHiconHeader = {
					order = 88,
					type = "header",
					name = L["BG Healer Icon"],
				},				
				lineBreak34 = {order = 89, type = "description", name = ""},
				lineBreak35 = {order = 90, type = "description", name = ""},
				barlessPlate_BGHiconDesc = {
					order = 91,
					type = "description",
					fontSize = "medium",
					name = function()
						if not IsAddOnLoaded("BattleGroundHealers") then
							return "|cff808080" .. L["This feature is available only when BattleGroundHealers is loaded."] .. "|r"
						elseif RBP.dbp.barlessPlate_filterBG <= 1 then
							return "|cff808080" .. L["These settings will replace some of BattleGroundHealers’ icon configuration for Barless Plates."] .. "|r"
						else
							return L["These settings will replace some of BattleGroundHealers’ icon configuration for Barless Plates."]
						end
					end,
				},
				lineBreak36 = {order = 92, type = "description", name = ""},
				lineBreak37 = {order = 93, type = "description", name = ""},
				barlessPlate_BGHiconAnchor = {
					order = 94,
					type = "select", 
					name = L["Anchor"],
					desc = L["Sets the anchor point relative to the name text."],
					values = {
						["Left"] = L["Left"],
						["Top"] = L["Top"],
						["Right"] = L["Right"],
						["Bottom"] = L["Bottom"],
					},
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP.dbp.barlessPlate_BGHiconOffsetX = 0
						RBP.dbp.barlessPlate_BGHiconOffsetY = 0
						RBP:UpdateAllBarlessPlates()
						RBP:UpdateAllShownPlates()
					end,
					disabled = function() 
						return RBP.dbp.barlessPlate_filterBG <= 1 or not IsAddOnLoaded("BattleGroundHealers")
					end,
				},
				barlessPlate_BGHiconOffsetX = {
					order = 95,
					type = "range",
					name = L["Offset X"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return RBP.dbp.barlessPlate_filterBG <= 1 or not IsAddOnLoaded("BattleGroundHealers")
					end,
				},
				barlessPlate_BGHiconOffsetY = {
					order = 96,
					type = "range",
					name = L["Offset Y"],
					min = -50,
					max = 50,
					step = 0.1,
					disabled = function() 
						return RBP.dbp.barlessPlate_filterBG <= 1 or not IsAddOnLoaded("BattleGroundHealers")
					end,
				},
				barlessPlate_BGHiconSize = {
					order = 97,
					type = "range",
					name = L["Icon Size"],
					min = 20,
					max = 60,
					step = 0.1,
					disabled = function() 
						return RBP.dbp.barlessPlate_filterBG <= 1 or not IsAddOnLoaded("BattleGroundHealers")
					end,
				},
				lineBreak38 = {order = 98, type = "description", name = ""},
				lineBreak39 = {order = 99, type = "description", name = ""},
			},
		},
		Totems = {
			order = 7,
			name = L["Totems"],
			type = "group",
			args = {
				lineBreak1 = {order = 1, type = "description", name = ""},
				Totem_header = {
					order = 2,
					type = "header",
					name = L["Totem Icon"],
				},
				lineBreak2 = {order = 3, type = "description", name = ""},
				lineBreak3 = {order = 4, type = "description", name = ""},	
				totemSize = {
					order = 5,
					type = "range",
					name = L["Icon Size"],
					desc = L["Adjusts the icon size of all Totem and Blacklisted units."],
					min = 15,
					max = 35,
					step = 0.1,
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllIcons()
						RBP:UpdateAllShownPlates()
						RBP:UpdateClickboxAttributes()
					end,
				},
				totemOffset = {
					order = 6,
					type = "range",
					name = L["Offset Y"],
					desc = L["Adjusts the icon's vertical position for all Totem and Blacklisted units (does not affect plate clickbox)."],
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
					name = L["Show Reaction Border"],
					desc = L["Displays a reaction-colored border around the icons of all Totem and Blacklisted units."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},
				hideFriendlyTotem = {
					order = 8,
					type = "toggle",
					name = L["Hide Friendly"],
					desc = L["Hides icons of friendly Totems and friendly Blacklisted units."],
					set = function(info, val)
						RBP.dbp[info[#info]] = val
						RBP:UpdateAllShownPlates()
					end,
				},
				lineBreak4 = {order = 9, type = "description", name = ""},
				lineBreak5 = {order = 10, type = "description", name = ""},
				lineBreak6 = {order = 11, type = "description", name = ""},	
			}
		},
		BlackList = {
			order = 8,
			name = L["Blacklist"],
			type = "group",
			args = {
				inputName = {
					order = 1,
					type = "input",
					name = L["Unit name"],
					desc = L["Add the exact name of a unit whose nameplate you want to hide or replace with an icon."],
					get = function() return tmpNewName end,
					set = function(_, val) tmpNewName = val end,
				},
				targetName = {
					order = 2,
					type = "execute",
					name = L["Set target name"],
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
					name = L["Add to blacklist"],
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
					name = L["Reset"],
					desc = L["Restore the default blacklist"],
					confirm = true,
					confirmText = L["Are you sure you want to restore the default blacklist?"],
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
			order = 10*i + j + 1,
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
					name = L["Enable TotemPlate"],
					desc = L["Replaces the nameplate with a totem icon."],
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
					name = L["Hide Totem"],
					desc = L["Completely hides the nameplate and the totemplate for this totem."],
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
                    name = L["Icon Path"],
					desc = L["Enter the path to an icon texture to replace the nameplate, or leave it empty to hide it completely."],
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
                    name = L["Remove"],
					desc = L["Remove this unit from the blacklist"],
					confirm = true,
					confirmText = L["Are you sure you want to remove this unit from the blacklist?"],
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