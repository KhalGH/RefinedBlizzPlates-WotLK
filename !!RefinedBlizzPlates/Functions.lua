
local AddonFile, RBP = ... -- namespace
local L = RBP.L
local hasModernEngine = RBP.hasModernEngine
local hasLegacyStacking = RBP.hasLegacyStacking
local hasModernStacking = RBP.hasModernStacking
local hasAlphaOverride = RBP.hasAlphaOverride

----------------------------- API -----------------------------
local pairs, ipairs, unpack, tonumber, tostring, select, next, math_exp, math_floor, math_abs, string_format, string_char, string_sub, table_insert, GetCVar, sort, wipe, WorldFrame, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, ToggleFrame, C_NamePlate =
      pairs, ipairs, unpack, tonumber, tostring, select, next, math.exp, math.floor, math.abs, string.format, string.char, string.sub, table.insert, GetCVar, sort, wipe, WorldFrame, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, ToggleFrame, C_NamePlate

------------------------- Core Variables -------------------------
local VirtualPlates = {}      	-- Storage table: Virtual nameplate frames
local PlatesVisible = {}      	-- Storage table: currently active nameplates
local PlateOverrides = {}	 	-- Storage table: [MethodName] = override function for virtual plates
local ClassByFriendName = {}  	-- Storage table: maps friendly player names (party/raid) to their class
local ArenaID = {}            	-- Storage table: maps arena names to their ID number
local PartyID = {}           	-- Storage table: maps party names to their ID number
local StackablePlates = {}    	-- Storage table: Plates filtered for improved stacking
local StackableList = {}		-- Storage table: StackablePlates entries packed in a dense array for fast iteration
local StackableCount = 0		-- Number of entries in StackableList
local PlateLevels = 3			-- Frame level difference between plates so one plate's children don't overlap the next closest plate
local NextUpdate = 0.05		 	-- Time controller for PlatesUpdate
local UpdateRate = 0.05	     	-- Minimum time between PlatesUpdate
local NextSecUpdate = 0.2    	-- Time controller for PlatesSecUpdate
local SecUpdateRate = 0.2	 	-- Minimum time between PlatesSecUpdate
local ExistsVisiblePlates = false
local nameplateSizeChecked = false
local ASSETS = "Interface\\AddOns\\" .. AddonFile .. "\\Assets\\"
local EventHandler = CreateFrame("Frame", nil, WorldFrame)
local SetFrameLevel = EventHandler.SetFrameLevel
local SetScale = EventHandler.SetScale
local SetAlpha = EventHandler.SetAlpha
local GetAlpha = EventHandler.GetAlpha

-- Status Flags
RBP.hasTarget = false
RBP.inCombat = false
RBP.inInstance = false
RBP.inOpenWorld = false
RBP.inPvEInstance = false
RBP.inPvPInstance = false
RBP.inBG = false
RBP.inArena = false
RBP.inICC = false
RBP.inLDWZone = false
RBP.playerLevel = UnitLevel("player")
RBP.playerClass = select(2, UnitClass("player"))
RBP.hasComboPoints = ({ROGUE = true, DRUID = true})[RBP.playerClass]
RBP.NP_WIDTH = 128
RBP.NP_HEIGHT = 32
RBP.NP_SCALE = 1
RBP.HB_CENTER_X = -8.5759733829502
RBP.HB_CENTER_Y = -7.5040053203105
RBP.HB_BOTTOMLEFT_X = 3.9680000548363
RBP.HB_BOTTOMLEFT_Y = 4
RBP.TG_TOP_X = -1.28
RBP.TG_TOP_Y = -8.32

local Styles = {
	Refined = {
		healthBorder = ASSETS .. "PlateRegions\\Refined-HealthBar-Border",
		threatGlow = ASSETS .. "PlateRegions\\Refined-HealthBar-ThreatGlow",
		targetGlow = ASSETS .. "PlateRegions\\Refined-HealthBar-TargetGlow",
		targetGlowGradient = ASSETS .. "PlateRegions\\Refined-HealthBar-TargetGlow_Gradient",
		mouseoverGlow = ASSETS .. "PlateRegions\\Refined-HealthBar-MouseoverGlow",
		targetGlowNoBorder = ASSETS .. "PlateRegions\\Refined-HealthBar-TargetGlow_NoBorder",
		mouseoverGlowNoBorder = ASSETS .. "PlateRegions\\Refined-HealthBar-MouseoverGlow_NoBorder",
		castBorder = ASSETS .. "PlateRegions\\Refined-CastBar-Border",
		shieldBorder = ASSETS .. "PlateRegions\\Refined-CastBar-ShieldBorder",
		shieldX = 0.572, shieldY = -11.439, shieldWf = 0.926, shieldHf = 1, shieldCoord = {0, 1, 0, 1},
		castGlow = ASSETS .. "PlateRegions\\Refined-CastBar-Glow",
		castGlowWf = 1.852, castGlowHf = 2, castGlowX = 0, castGlowY = 0,
		castBarW = 96.01, castBarH = 8.99,
		castBoxX = -9.397, castBoxY = -14.7, castBoxWf = 0.926, castBoxHf = 1,
		normal = {barX = -3.8, barY = 4.5, iconX = 11.93, iconY = 8.58, iconSize = 12.91},
		shield = {barX = -3, barY = 0.5, iconX = 10.6, iconY = 4.5, iconSize = 13.73},
		castTextX = -7, castTimerX = -2.5, castTextY = 0.82,
		icons = {
			raid = {
				Left  = {point = "RIGHT",  relPoint = "LEFT",  x = -2.5, y = 0.8},
				Top   = {point = "BOTTOM", relPoint = "TOP",   x = 0,    y = 4.1},
				Right = {point = "LEFT",   relPoint = "RIGHT", x = 2.5,  y = 0.8},
			},
			class = {
				Left  = {point = "RIGHT",  relPoint = "LEFT",  x = -0.4, y = 0},
				Top   = {point = "BOTTOM", relPoint = "TOP",   x = 0,    y = 2.5},
				Right = {point = "LEFT",   relPoint = "RIGHT", x = 0.4,  y = 0},
			},
			elite = {
				Modern = {
					Left  = {point = "LEFT",  relPoint = "LEFT",  x = -12.665, y = 0.245},
					Right = {point = "RIGHT", relPoint = "RIGHT", x = 12.665,  y = 0.245},
				},
				Minimalist = {
					Left  = {point = "LEFT",  relPoint = "LEFT",  x = -14.708, y = 0},
					Right = {point = "RIGHT", relPoint = "RIGHT", x = 14.708,  y = 0},
				},
				Default = {
					Left  = {point = "LEFT",  relPoint = "LEFT",  x = -14.708, y = -1.226},
					Right = {point = "RIGHT", relPoint = "RIGHT", x = 14.708,  y = -1.226},
				},
			},
		},
	},
	Blizzard = {
		healthBorder = ASSETS .. "PlateRegions\\Classic-HealthBar-Border",
		threatGlow = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash",
		targetGlow = ASSETS .. "PlateRegions\\Classic-HealthBar-TargetGlow",
		targetGlowGradient = ASSETS .. "PlateRegions\\Classic-HealthBar-TargetGlow_Gradient",
		mouseoverGlow = ASSETS .. "PlateRegions\\Classic-HealthBar-MouseoverGlow",
		targetGlowNoBorder = ASSETS .. "PlateRegions\\Refined-HealthBar-TargetGlow_NoBorder",
		mouseoverGlowNoBorder = ASSETS .. "PlateRegions\\Refined-HealthBar-MouseoverGlow_NoBorder",
		castBorder = ASSETS .. "PlateRegions\\Refined-CastBar-Border",
		shieldBorder = ASSETS .. "PlateRegions\\Refined-CastBar-ShieldBorder",
		shieldX = 0.572, shieldY = -11.439, shieldWf = 1.017, shieldHf = 1, shieldCoord = {0, 1, 0, 1},
		castGlow = ASSETS .. "PlateRegions\\Refined-CastBar-Glow",
		castGlowWf = 2.034, castGlowHf = 2, castGlowX = 0, castGlowY = 0,
		castBarW = 105.41, castBarH = 8.99,
		castBoxX = -0.831, castBoxY = -14.7, castBoxWf = 1.017, castBoxHf = 1,
		normal = {barX = -3.8, barY = 4.5, iconX = 13.16, iconY = 8.58, iconSize = 13.73},
		shield = {barX = -3, barY = 0.5, iconX = 11.8, iconY = 4.5, iconSize = 13.73},
		castTextX = -7, castTimerX = -2.5, castTextY = 0.57,
		icons = {
			raid = {
				Left  = {point = "RIGHT",  relPoint = "LEFT",  x = -2.5, y = 0.8},
				Top   = {point = "BOTTOM", relPoint = "TOP",   x = 0,    y = 4.1},
				Right = {point = "LEFT",   relPoint = "RIGHT", x = 19.6, y = 0.8},
			},
			class = {
				Left  = {point = "RIGHT",  relPoint = "LEFT",  x = -0.4, y = 0},
				Top   = {point = "BOTTOM", relPoint = "TOP",   x = 0,    y = 2.5},
				Right = {point = "LEFT",   relPoint = "RIGHT", x = 18,   y = 0},
			},
			elite = {
				Modern = {
					Left  = {point = "LEFT",  relPoint = "LEFT",  x = -12.665, y = 0.245},
					Right = {point = "RIGHT", relPoint = "RIGHT", x = 29.824,  y = 0.245},
				},
				Minimalist = {
					Left  = {point = "LEFT",  relPoint = "LEFT",  x = -14.708, y = 0},
					Right = {point = "RIGHT", relPoint = "RIGHT", x = 32.276,  y = 0},
				},
				Default = {
					Left  = {point = "LEFT",   relPoint = "LEFT",   x = -14.708, y = -1.226},
					Right = {point = "CENTER", relPoint = "CENTER", x = 56.064,  y = -8.192, plateX = true, plateY = true},
				},
			},
		},
	},
	Clean = {
		healthBorder = ASSETS .. "PlateRegions\\Clean-HealthBar-Border",
		threatGlow = ASSETS .. "PlateRegions\\Clean-HealthBar-ThreatGlow",
		targetGlow = ASSETS .. "PlateRegions\\Clean-HealthBar-TargetGlow",
		targetGlowGradient = ASSETS .. "PlateRegions\\Clean-HealthBar-TargetGlow_Gradient",
		mouseoverGlow = ASSETS .. "PlateRegions\\Clean-HealthBar-MouseoverGlow",
		targetGlowNoBorder = ASSETS .. "PlateRegions\\Clean-HealthBar-TargetGlow_NoBorder",
		mouseoverGlowNoBorder = ASSETS .. "PlateRegions\\Clean-HealthBar-MouseoverGlow_NoBorder",
		castBorder = ASSETS .. "PlateRegions\\Clean-CastBar-Border",
		shieldBorder = ASSETS .. "PlateRegions\\Clean-CastBar-ShieldBorder",
		shieldX = 0, shieldY = 0, shieldWf = 1, shieldHf = 1, shieldCoord = {1, 0, 0, 1},
		castGlow = ASSETS .. "PlateRegions\\Clean-CastBar-Glow",
		castGlowWf = 2, castGlowHf = 2, castGlowX = 0, castGlowY = 0,
		castBarW = 92, castBarH = 10,
		castBoxX = 0, castBoxY = -12, castBoxWf = 1, castBoxHf = 1,
		normal = {barX = -21, barY = 3, iconX = 9, iconY = 8, iconSize = 10},
		shield = {barX = -21, barY = 3, iconX = 9, iconY = 8, iconSize = 10},
		castTextX = -5.576, castTimerX = -1.274, castTextY = 0.82,
		iconCoord = {0.08, 0.92, 0.08, 0.92},
	},
}
Styles.Clean.icons = Styles.Refined.icons

local FixedAnchors = {
	boss = {
		Left  = {point = "RIGHT",  relPoint = "LEFT",   x = -0.8, y = 0},
		Top   = {point = "BOTTOM", relPoint = "TOP",    x = 0,    y = 2.9},
		Right = {point = "CENTER", relPoint = "CENTER", x = 61.1, y = 0.5},
	},
	level = {
		Left   = {point = "CENTER", relPoint = "LEFT",   x = -11.03, y = 0.57},
		Center = {point = "CENTER", relPoint = "CENTER", x = 0,      y = 0.57},
		Right  = {point = "CENTER", relPoint = "RIGHT",  x = 9.15,   y = 0.57},
	},
	arena = {
		Left   = {point = "CENTER", relPoint = "LEFT",   x = -6.54, y = 0.33},
		Center = {point = "CENTER", relPoint = "CENTER", x = 0,     y = 0.33},
		Right  = {point = "CENTER", relPoint = "RIGHT",  x = 9.81,  y = 0.66},
	},
}

local function GetStyle()
	return Styles[RBP.dbp.healthBar_border] or Styles.Refined
end

local function PlaceOnHealthBar(region, Virtual, spec, offsetX, offsetY)
	local x, y = offsetX + spec.x * RBP.NP_SCALE, offsetY + spec.y * RBP.NP_SCALE
	if spec.plateX then x = x - RBP.HB_CENTER_X end
	if spec.plateY then y = y - RBP.HB_CENTER_Y end
	region:ClearAllPoints()
	region:SetPoint(spec.point, Virtual.RBP_healthBar, spec.relPoint, x, y)
end

------------------------- Customization Functions -------------------------
local function InitBarTextures(Virtual)
	Virtual.RBP_healthBar:SetFrameLevel(Virtual:GetFrameLevel())
	Virtual.RBP_castBar:SetFrameLevel(Virtual:GetFrameLevel())
	Virtual.RBP_ogCastBarBorder:SetTexture(nil)
	Virtual.RBP_ogShieldCastBarBorder:SetTexture(nil)
	Virtual.RBP_spellIcon:SetDrawLayer("BORDER")
	Virtual.RBP_ogHealthBarTex:SetTexture(nil)
	Virtual.RBP_ogHealthBarBorder:SetPoint("TOPLEFT", Virtual)
	Virtual.RBP_ogHealthBarBorder:SetPoint("BOTTOMRIGHT", Virtual)
	Virtual.RBP_ogHealthBarBorder:Hide()
	Virtual.RBP_ogNameText:SetPoint("BOTTOM", Virtual, "CENTER")
	Virtual.RBP_ogNameText:Hide()
	Virtual.RBP_ogCastBarTex:SetTexture(nil)
end

local function SetupRegionsWrapper(Virtual)
	if Virtual.RBP_regionsWrapper then return end
	Virtual.RBP_regionsWrapper = CreateFrame("Frame", nil, Virtual)
	Virtual.RBP_regionsWrapper:SetAllPoints(Virtual)
	Virtual.RBP_regionsWrapper:SetFrameLevel(Virtual:GetFrameLevel())
end

local function SetupThreatGlow(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_threatGlow:SetPoint("TOP", Virtual, RBP.TG_TOP_X + dbp.globalOffsetX - RBP.HB_CENTER_X, RBP.TG_TOP_Y + dbp.globalOffsetY)
	Virtual.RBP_threatGlow:SetTexture(GetStyle().threatGlow)
end

local function UpdateHealthBorder(Virtual)
	if not Virtual.RBP_healthBarBorder then return end
	local dbp = RBP.dbp
	Virtual.RBP_healthBarBorder:SetPoint("CENTER", Virtual.RBP_healthBar, -RBP.HB_CENTER_X, -RBP.HB_CENTER_Y)
	Virtual.RBP_healthBarBorder:SetTexture(GetStyle().healthBorder)
	if dbp.healthBar_border == "Clean" then
		Virtual.RBP_healthBarBorder:SetVertexColor(0, 0, 0, 1)
	else
		Virtual.RBP_healthBarBorder:SetVertexColor(unpack(dbp.healthBar_borderColor))
	end
end

local function SetupHealthBorder(Virtual)
	if Virtual.RBP_healthBarBorder then return end
	Virtual.RBP_healthBarBorder = Virtual.RBP_regionsWrapper:CreateTexture(nil, "ARTWORK")
	Virtual.RBP_healthBarBorder:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
	UpdateHealthBorder(Virtual)
end

local function UpdateNameText(Virtual)
	if not Virtual.RBP_nameText then return end
	local dbp, S = RBP.dbp, RBP.NP_SCALE
	Virtual.RBP_nameText:SetFont(RBP.LSM:Fetch("font", dbp.nameText_font), dbp.nameText_size * S, dbp.nameText_outline)
	Virtual.RBP_nameText:ClearAllPoints()
	Virtual.RBP_nameText:SetPoint(dbp.nameText_anchor, Virtual.RBP_healthBar, dbp.nameText_offsetX, dbp.nameText_offsetY + 0.57 * S)
	Virtual.RBP_nameText:SetWidth(dbp.nameText_width)
	Virtual.RBP_nameText:SetJustifyH(dbp.nameText_anchor)
	Virtual.RBP_nameText:SetTextColor(unpack(dbp.nameText_color))
end

local function SetupNameText(Virtual)
	if Virtual.RBP_nameText then return end
	Virtual.RBP_nameText = Virtual.RBP_regionsWrapper:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_nameText:SetShadowOffset(0.5, -0.5)
	Virtual.RBP_nameText:SetNonSpaceWrap(false)
	Virtual.RBP_nameText:SetWordWrap(false)
	Virtual.RBP_nameText:Hide()
	UpdateNameText(Virtual)
end

local function UpdateLevelText(Virtual)
	if not Virtual.RBP_levelText then return end
	local dbp, level = RBP.dbp, FixedAnchors.level
	Virtual.RBP_levelText:SetFont(RBP.LSM:Fetch("font", dbp.levelText_font), dbp.levelText_size * RBP.NP_SCALE, dbp.levelText_outline)
	PlaceOnHealthBar(Virtual.RBP_levelText, Virtual, level[dbp.levelText_anchor] or level.Right, dbp.levelText_offsetX, dbp.levelText_offsetY)
end

local function UpdateArenaIDText(Virtual)
	local dbp, arena = RBP.dbp, FixedAnchors.arena
	Virtual.RBP_ArenaIDText:SetFont(RBP.LSM:Fetch("font", dbp.ArenaIDText_font), dbp.ArenaIDText_size * RBP.NP_SCALE, dbp.ArenaIDText_outline)
	PlaceOnHealthBar(Virtual.RBP_ArenaIDText, Virtual, arena[dbp.ArenaIDText_anchor] or arena.Right, dbp.ArenaIDText_offsetX, dbp.ArenaIDText_offsetY)
end

local function SetupArenaIDText(Virtual)
	if Virtual.RBP_ArenaIDText then return end
	Virtual.RBP_ArenaIDText = Virtual.RBP_healthBar:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_ArenaIDText:SetShadowOffset(0.5, -0.5)
	Virtual.RBP_ArenaIDText:Hide()
	UpdateArenaIDText(Virtual)
end

local function UpdateBarlessHealthText(healthText, percent)
	if percent < 100 and percent > 0 then
		local r, g, b = 1, 1, 0
		if percent <= 15 then
			g = 0
		elseif percent < 60 then
			g = (percent - 15) / 45
		else
			r = 1 - (percent - 60) / 40
		end
		healthText:SetText(percent .. "%")
		healthText:SetTextColor(r, g, b)
	else
		healthText:SetText("")
	end
end

local function utf8chars(str)
    local chars = {}
    local i = 1
    while i <= #str do
        local c = str:byte(i)
        if c < 128 then
            table_insert(chars, string_char(c))
            i = i + 1
        elseif c < 224 then
            table_insert(chars, string_sub(str, i, i+1))
            i = i + 2
        elseif c < 240 then
            table_insert(chars, string_sub(str, i, i+2))
            i = i + 3
        else
            table_insert(chars, string_sub(str, i, i+3))
            i = i + 4
        end
    end
    return chars
end

local function utf8len(str)
    local count = 0
    local i = 1
    while i <= #str do
        local c = str:byte(i)
        if c < 128 then
            i = i + 1
        elseif c < 224 then
            i = i + 2
        elseif c < 240 then
            i = i + 3
        else
            i = i + 4
        end
        count = count + 1
    end
    return count
end

local function UpdateBarlessNameText(Virtual, percent)
	local name = Virtual.RBP_nameString
	local nameLen = utf8len(name)
	if nameLen > 0 then
		local chars = utf8chars(name)
		local grayLength = nameLen * (100 - percent) / 100
		local grayCountFloor = math_floor(grayLength)
		local grayFraction = grayLength - grayCountFloor
		local i_start = nameLen - grayCountFloor + 1
		local i_fraction = i_start - 1
		local nameColor = Virtual.RBP_barlessNameTextRGB
		local coloredText = ""
		for i = 1, nameLen do
			local r, g, b
			if i >= i_start then
				r, g, b = 0.35, 0.35, 0.35
			elseif i == i_fraction and grayFraction > 0 then
				local colorFraction = 1 - grayFraction
				r = nameColor[1] * colorFraction + 0.35 * grayFraction
				g = nameColor[2] * colorFraction + 0.35 * grayFraction
				b = nameColor[3] * colorFraction + 0.35 * grayFraction
			else
				r, g, b = nameColor[1], nameColor[2], nameColor[3]
			end
			coloredText = coloredText .. string_format("|cff%02x%02x%02x%s|r", math_floor(r * 255), math_floor(g * 255), math_floor(b * 255), chars[i])
		end
		Virtual.RBP_barlessPlate_nameText:SetText(coloredText)
	end
end

local function SmartValue(v)
	if v >= 1e6 then
		return string_format("%.1fm", v / 1e6)
	elseif v >= 1e3 then
		return string_format("%.1fk", v / 1e3)
	else
		return v
	end
end

local function UpdateHealthTextValue(healthBar, value)
	local Virtual = healthBar.VirtualPlate
	local min, max = healthBar:GetMinMaxValues()
	local dbp = RBP.dbp
	if max > 0 then
		local val = value or healthBar:GetValue()
		local percent = val / max
		local text = ""
		if val > 1 and not (dbp.healthText_hideMax and val == max) then
			local format = dbp.healthText_format
			if format == 1 then
				text = math_floor(percent * 100) .. "%"
			elseif format == 2 then
				if val == max then
					text = "100%"
				else
					text = string_format("%.1f%%", math_floor(percent * 1000) / 10)
				end
			elseif format == 3 then
				text = SmartValue(val)
			elseif format == 4 then
				text = SmartValue(val) .. " / " .. SmartValue(max)
			elseif format == 5 then
				text = SmartValue(val) .. " (" .. math_floor(percent * 100) .. "%)"
			elseif format == 6 and val < max then
				text = "- " .. SmartValue(max - val)
			end
		end
		Virtual.RBP_healthText:SetText(text)
		if Virtual.RBP_healthBarIsShown then
			if Virtual.RBP_healthBarTexCrop then
				Virtual.RBP_healthBarTex:SetTexCoord(0, percent, 0, 1)
			else
				Virtual.RBP_healthBarTex:SetTexCoord(0, 1, 0, 1)
			end
		end
		Virtual.RBP_lowHp = Virtual.RBP_lowHpColoring and percent <= dbp.lowHpColor_threshold
		percent = math_floor(percent * 100)
		if Virtual.RBP_barlessPlateIsShown then
			if Virtual.RBP_BarlessHealthTextIsShown then
				UpdateBarlessHealthText(Virtual.RBP_barlessPlate_healthText, percent)
			end
			if Virtual.RBP_barlessNameTextGrayOut then
				UpdateBarlessNameText(Virtual, percent)
			end
		end
	else
		Virtual.RBP_lowHp = nil
		Virtual.RBP_healthText:SetText("")
		if Virtual.RBP_barlessPlateIsShown then
			if Virtual.RBP_BarlessHealthTextIsShown then
				Virtual.RBP_barlessPlate_healthText:SetText("")
			end
			if Virtual.RBP_barlessNameTextGrayOut then
				UpdateBarlessNameText(Virtual, 0)
			end
		end
	end
end

local function UpdateHealthText(Virtual)
	if not Virtual.RBP_healthText then return end
	local dbp = RBP.dbp
	Virtual.RBP_healthText:SetFont(RBP.LSM:Fetch("font", dbp.healthText_font), dbp.healthText_size * RBP.NP_SCALE, dbp.healthText_outline)
	Virtual.RBP_healthText:ClearAllPoints()
	Virtual.RBP_healthText:SetPoint(dbp.healthText_anchor, Virtual.RBP_healthBar, dbp.healthText_offsetX, dbp.healthText_offsetY + 0.57 * RBP.NP_SCALE)
	Virtual.RBP_healthText:SetTextColor(unpack(dbp.healthText_color))
end

local function SetupHealthText(Virtual)
	if Virtual.RBP_healthText then return end
	Virtual.RBP_healthText = Virtual.RBP_regionsWrapper:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_healthText:SetShadowOffset(0.5, -0.5)
	UpdateHealthText(Virtual)
	local healthText = Virtual.RBP_healthText
	Virtual.RBP_healthBar:HookScript("OnValueChanged", UpdateHealthTextValue)
	if RBP.dbp.healthText_hide then
		healthText:Hide()
	end
end

local function SetupHealthBarTex(Virtual)
	if Virtual.RBP_healthBarTex then return end
	Virtual.RBP_healthBarTex = Virtual.RBP_healthBar:CreateTexture(nil, "BORDER")
	Virtual.RBP_healthBarTex:SetAllPoints(Virtual.RBP_ogHealthBarTex)
end

local function UpdateHealthBarBg(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_healthBarBg:SetTexture(RBP.LSM:Fetch("statusbar", dbp.healthBar_bgTex))
	Virtual.RBP_healthBarBg:SetVertexColor(unpack(dbp.healthBar_bgColor))
	Virtual.RBP_healthBarBg:SetAlpha(dbp.healthBar_bgAlpha)
end

local function SetupHealthBarBg(Virtual)
	if Virtual.RBP_healthBarBg then return end
	Virtual.RBP_healthBarBg = Virtual.RBP_healthBar:CreateTexture(nil, "BACKGROUND")
	local outset = 0.6 * RBP.NP_SCALE
	Virtual.RBP_healthBarBg:SetPoint("TOPLEFT", -outset, outset)
	Virtual.RBP_healthBarBg:SetPoint("BOTTOMRIGHT", outset, -outset)
	UpdateHealthBarBg(Virtual)
end

local function UpdateHealthBarTex(Virtual)
	if Virtual.RBP_classKey == "FRIENDLY_PLAYER" then
		Virtual.RBP_healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_friendlyPlayerTex))
	elseif Virtual.RBP_classKey then
		Virtual.RBP_healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_hostilePlayerTex))
	else
		Virtual.RBP_healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
	end
end

local function UpdateTargetGlow(Virtual)
	if not Virtual.RBP_targetGlow then return end
	local dbp = RBP.dbp
	Virtual.RBP_targetGlow:SetVertexColor(unpack(dbp.targetGlow_Color))
	Virtual.RBP_targetGlow:SetAlpha(dbp.targetGlow_Alpha)
	Virtual.RBP_targetGlow:SetSize(RBP.NP_WIDTH * 2, RBP.NP_HEIGHT * 2)
	Virtual.RBP_targetGlow:SetPoint("CENTER", -RBP.HB_CENTER_X, -RBP.HB_CENTER_Y)
	local style = GetStyle()
	if dbp.showTargetGlowBorder then
		Virtual.RBP_targetGlow:SetTexture(dbp.targetGlow_Gradient and style.targetGlowGradient or style.targetGlow)
	else
		Virtual.RBP_targetGlow:SetTexture(style.targetGlowNoBorder)
	end
end

local function SetupTargetGlow(Virtual)
	if Virtual.RBP_targetGlow then return end
	Virtual.RBP_targetGlow = Virtual.RBP_healthBar:CreateTexture(nil, "OVERLAY")
	Virtual.RBP_targetGlow:Hide()
	UpdateTargetGlow(Virtual)
end

local function UpdateMouseoverGlow(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_healthBarHighlight:SetVertexColor(unpack(dbp.mouseoverGlow_Color))
	Virtual.RBP_healthBarHighlight:SetAlpha(dbp.mouseoverGlow_Alpha)
	Virtual.RBP_healthBarHighlight:ClearAllPoints()
	Virtual.RBP_healthBarHighlight:SetSize(RBP.NP_WIDTH * 2, RBP.NP_HEIGHT * 2)
	Virtual.RBP_healthBarHighlight:SetPoint("CENTER", dbp.globalOffsetX - RBP.HB_CENTER_X, dbp.globalOffsetY)
	local style = GetStyle()
	Virtual.RBP_healthBarHighlight:SetTexture(dbp.showMouseoverGlowBorder and style.mouseoverGlow or style.mouseoverGlowNoBorder)
end

local function SetupCastBarBorder(Virtual)
	if Virtual.RBP_castBarBorder then return end
	Virtual.RBP_castBarBorder = Virtual.RBP_regionsWrapper:CreateTexture(nil, "ARTWORK")
	Virtual.RBP_castBarBorder:SetAllPoints(Virtual.RBP_ogCastBarBorder)
	Virtual.RBP_castBarBorder:Hide()
end

local function UpdateCastBarArt(Virtual)
	local dbp, style, S = RBP.dbp, GetStyle(), RBP.NP_SCALE
	local border, shield = Virtual.RBP_castBarBorder, Virtual.RBP_shieldCastBarBorder
	border:SetTexture(style.castBorder)
	border:SetTexCoord(1, 0, 0, 1)
	shield:SetTexture(style.shieldBorder)
	shield:SetTexCoord(unpack(style.shieldCoord))
	if dbp.healthBar_border == "Clean" then
		border:SetVertexColor(0, 0, 0)
		shield:SetVertexColor(0, 0, 0)
	else
		border:SetVertexColor(unpack(dbp.castBar_borderColor))
		shield:SetVertexColor(unpack(dbp.castBar_protectedBorderColor))
	end
	shield:SetPoint("CENTER", Virtual.RBP_ogCastBarBorder, style.shieldX * S, style.shieldY * S)
	shield:SetSize(RBP.NP_WIDTH * style.shieldWf, RBP.NP_HEIGHT * style.shieldHf)
	local icon = Virtual.RBP_spellIcon
	if style.iconCoord then
		if not Virtual.RBP_spellIconNativeCoord then
			Virtual.RBP_spellIconNativeCoord = {icon:GetTexCoord()}
		end
		icon:SetTexCoord(unpack(style.iconCoord))
	elseif Virtual.RBP_spellIconNativeCoord then
		icon:SetTexCoord(unpack(Virtual.RBP_spellIconNativeCoord))
		Virtual.RBP_spellIconNativeCoord = nil
	end
	if Virtual.RBP_castGlow then
		Virtual.RBP_castGlow:SetTexture(style.castGlow)
		Virtual.RBP_castGlow:SetPoint("CENTER", Virtual.RBP_castBarBorder, style.castGlowX * S, style.castGlowY * S)
		Virtual.RBP_castGlow:SetSize(RBP.NP_WIDTH * style.castGlowWf, RBP.NP_HEIGHT * style.castGlowHf)
	end
end

local function SetupShieldCastBarBorder(Virtual)
	if Virtual.RBP_shieldCastBarBorder then return end
	Virtual.RBP_shieldCastBarBorder = Virtual.RBP_regionsWrapper:CreateTexture(nil, "ARTWORK")
	Virtual.RBP_shieldCastBarBorder:Hide()
	UpdateCastBarArt(Virtual)
end

local function SetupCastBarTex(Virtual)
	if Virtual.RBP_castBarTex then return end
	local dbp = RBP.dbp
	Virtual.RBP_castBarTex = Virtual.RBP_castBar:CreateTexture(nil, "BORDER")
	Virtual.RBP_castBarTex:SetAllPoints(Virtual.RBP_ogCastBarTex)
	Virtual.RBP_castBarTex:SetTexture(RBP.LSM:Fetch("statusbar", dbp.castBar_Tex))
	Virtual.RBP_castBarTex:SetVertexColor(unpack(dbp.castBar_color))
end

local function UpdateCastBarBg(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_castBarBg:SetTexture(RBP.LSM:Fetch("statusbar", dbp.castBar_bgTex))
	Virtual.RBP_castBarBg:SetVertexColor(unpack(dbp.castBar_bgColor))
	Virtual.RBP_castBarBg:SetAlpha(dbp.castBar_bgAlpha)
end

local function SetupCastBarBg(Virtual)
	if Virtual.RBP_castBarBg then return end
	Virtual.RBP_castBarBg = Virtual.RBP_castBar:CreateTexture(nil, "BACKGROUND")
	local outset = 0.6 * RBP.NP_SCALE
	Virtual.RBP_castBarBg:SetPoint("TOPLEFT", -outset, outset)
	Virtual.RBP_castBarBg:SetPoint("BOTTOMRIGHT", outset, -outset)
	UpdateCastBarBg(Virtual)
end

local function UpdateCastText(Virtual)
	if not Virtual.RBP_castText then return end
	local dbp = RBP.dbp
	Virtual.RBP_castText:SetFont(RBP.LSM:Fetch("font", dbp.castText_font), dbp.castText_size * RBP.NP_SCALE, dbp.castText_outline)
	Virtual.RBP_castText:SetTextColor(unpack(dbp.castText_color))
	Virtual.RBP_castText:SetJustifyH(dbp.castText_anchor)
	Virtual.RBP_castText:SetWidth(dbp.castText_width)
	Virtual.RBP_castText:ClearAllPoints()
	local style = GetStyle()
	Virtual.RBP_castText:SetPoint(dbp.castText_anchor, Virtual.RBP_castBar, dbp.castText_offsetX + style.castTextX * RBP.NP_SCALE, dbp.castText_offsetY + style.castTextY * RBP.NP_SCALE)
end

local function SetupCastText(Virtual)
	if Virtual.RBP_castText then return end
	Virtual.RBP_castText = Virtual.RBP_regionsWrapper:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_castText:SetNonSpaceWrap(false)
	Virtual.RBP_castText:SetWordWrap(false)
	Virtual.RBP_castText:SetShadowOffset(0.5, -0.5)
	UpdateCastText(Virtual)
	Virtual.RBP_castText:SetText("")
	if RBP.dbp.castText_hide then
		Virtual.RBP_castText:Hide()
	end
end

local function UpdateCastTimer(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_castTimerText:SetFont(RBP.LSM:Fetch("font", dbp.castTimerText_font), dbp.castTimerText_size * RBP.NP_SCALE, dbp.castTimerText_outline)
	Virtual.RBP_castTimerText:SetTextColor(unpack(dbp.castTimerText_color))
	Virtual.RBP_castTimerText:ClearAllPoints()
	local style = GetStyle()
	Virtual.RBP_castTimerText:SetPoint(dbp.castTimerText_anchor, Virtual.RBP_castBar, dbp.castTimerText_offsetX + style.castTimerX * RBP.NP_SCALE, dbp.castTimerText_offsetY + style.castTextY * RBP.NP_SCALE)
end

local function SetupCastTimer(Virtual)
	if Virtual.RBP_castTimerText then return end
	Virtual.RBP_castTimerText = Virtual.RBP_regionsWrapper:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_castTimerText:SetShadowOffset(0.5, -0.5)
	Virtual.RBP_castTimerText:Hide()
	UpdateCastTimer(Virtual)
end

local function UpdateCastTextString(Virtual, unit)
	if unit then
		local spellName = UnitCastingInfo(unit)
		if spellName then
			Virtual.RBP_channelingFlag = 0
		else
			spellName = UnitChannelInfo(unit)
			if spellName then
				Virtual.RBP_channelingFlag = 1
			end
		end
		if spellName then
			Virtual.RBP_castText:SetText(spellName)
			if not RBP.dbp.castTimerText_hide then
				Virtual.RBP_castTimerText:Show()
			else
				Virtual.RBP_castTimerText:Hide()
			end
		else
			Virtual.RBP_castText:SetText("")
			Virtual.RBP_castTimerText:Hide()
		end
	else
		Virtual.RBP_castText:SetText("")
		Virtual.RBP_castTimerText:Hide()
	end
end

local function UpdateCastBarRegionsVisibility(Virtual)
	local style = GetStyle()
	Virtual.RBP_castBarBorder:SetAlpha(1)
	Virtual.RBP_shieldCastBarBorder:SetAlpha(1)
	if Virtual.RBP_ogShieldCastBarBorderIsShown then
		Virtual.RBP_castBarBorder:Hide()
		Virtual.RBP_shieldCastBarBorder:Show()
		Virtual.RBP_castBarExpectedY = style.shield.barY * RBP.NP_SCALE
	else
		Virtual.RBP_castBarBorder:Show()
		Virtual.RBP_shieldCastBarBorder:Hide()
		Virtual.RBP_castBarExpectedY = style.normal.barY * RBP.NP_SCALE
	end
end

local function UpdateCastBarRegionsAnchor(Virtual)
	local style, S = GetStyle(), RBP.NP_SCALE
	local state = Virtual.RBP_ogShieldCastBarBorderIsShown and style.shield or style.normal
	Virtual.RBP_castBar:SetPoint("BOTTOMRIGHT", Virtual.RBP_ogCastBarBorder, state.barX * S, Virtual.RBP_castBarExpectedY)
	Virtual.RBP_spellIcon:SetPoint("CENTER", Virtual.RBP_ogCastBarBorder, "BOTTOMLEFT", state.iconX * S, state.iconY * S)
	Virtual.RBP_spellIcon:SetSize(state.iconSize * S, state.iconSize * S)
end

local function SetupCastSpark(Virtual)
	if Virtual.RBP_castSpark then return end
	Virtual.RBP_castSpark = Virtual.RBP_castBar:CreateTexture(nil, "ARTWORK")
	Virtual.RBP_castSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	Virtual.RBP_castSpark:SetBlendMode("ADD")
	Virtual.RBP_castSpark:SetPoint("CENTER", Virtual.RBP_ogCastBarTex, "RIGHT")
	Virtual.RBP_castSpark:SetSize(10, 22)
	Virtual.RBP_castSpark:Hide()
end

local function SetupCastGlow(Virtual)
	if Virtual.RBP_castGlow then return end
	Virtual.RBP_castGlow = Virtual:CreateTexture(nil, "OVERLAY")
	Virtual.RBP_castGlow:SetVertexColor(0.25, 0.75, 0.25)
	UpdateCastBarArt(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_castGlow:Hide()
	if dbp.enableCastGlow then
		Virtual.RBP_castBar:HookScript("OnShow", function()
			local unit = Virtual.namePlateUnitToken or Virtual.RBP_unitToken
			if unit and UnitIsUnit(unit.."target", "player") and not UnitIsUnit("target", unit) and Virtual.RBP_ogCastBarBorder:IsShown() then
				if UnitCanAttack("player", unit) then
					Virtual.RBP_castGlow:SetVertexColor(1, 0, 0)
				else
					Virtual.RBP_castGlow:SetVertexColor(0.25, 0.75, 0.25)
				end
				Virtual.RBP_castGlow:Show()
				Virtual.RBP_castGlowIsShown = true
			end
		end)
		Virtual.RBP_castBar:HookScript("OnValueChanged", function()
			if Virtual.RBP_castGlowIsShown and Virtual.RBP_isTarget then
				Virtual.RBP_castGlow:Hide()
				Virtual.RBP_castGlowIsShown = nil
			end
		end)
		Virtual.RBP_castBar:HookScript("OnHide", function()
			Virtual.RBP_castGlow:Hide()
			Virtual.RBP_castGlowIsShown = nil
		end)
	end
end

local function SetupCastBarTexFull(Virtual)
	if Virtual.RBP_castBarTexFull then return end
	Virtual.RBP_castBarTexFull = Virtual:CreateTexture(nil, "BORDER")
	Virtual.RBP_castBarTexFull:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.castBar_Tex))
	Virtual.RBP_castBarTexFull:SetAllPoints(Virtual.RBP_castBar)
	Virtual.RBP_castBarTexFull:Hide()
end

local function UpdateCastBarSize(Virtual)
	local dbp, style, S = RBP.dbp, GetStyle(), RBP.NP_SCALE
	Virtual.RBP_castBar:SetSize(style.castBarW * S, style.castBarH * S)
	Virtual.RBP_ogCastBarBorder:SetPoint("CENTER", dbp.globalOffsetX - RBP.HB_CENTER_X + style.castBoxX * S, dbp.globalOffsetY + style.castBoxY * S)
	Virtual.RBP_ogCastBarBorder:SetSize(RBP.NP_WIDTH * style.castBoxWf, RBP.NP_HEIGHT * style.castBoxHf)
end

local function HookCastBarScripts(Virtual)
	local Plate = Virtual.RealPlate
	local castBar = Virtual.RBP_castBar
	local castBarBorder = Virtual.RBP_castBarBorder
	local shieldCastBarBorder = Virtual.RBP_shieldCastBarBorder
	local spellIcon = Virtual.RBP_spellIcon
	local castBarTex = Virtual.RBP_castBarTex
	local castBarTexFull = Virtual.RBP_castBarTexFull
	local castText = Virtual.RBP_castText
	local castTimerText = Virtual.RBP_castTimerText
	local firstCastVal, secondCastVal, currCastVal, maxCastVal, lastOVC, channelingCompleted, castingFailed, alpha, lastTimerTenths, texCropped, castDelta, anchorCheckPending
	local delayedCastBarOnShow = CreateFrame("Frame")
	delayedCastBarOnShow:SetScript("OnUpdate", function(self)
		self:Hide()
		if not castBar:IsShown() or not Virtual.RBP_isShown then return end
		local max = select(2, castBar:GetMinMaxValues())
		local dbp = RBP.dbp
		maxCastVal = max and max > 0 and max or nil
		if Virtual.RBP_healthBarIsShown and maxCastVal then
			Virtual.RBP_castBarIsShown = true
			local unit = Virtual.namePlateUnitToken or Virtual.RBP_unitToken or (Virtual.RBP_isTarget and "target")
			UpdateCastTextString(Virtual, unit)
			UpdateCastBarRegionsVisibility(Virtual)
			UpdateCastBarRegionsAnchor(Virtual)
			if dbp.castBar_showSpark then
				Virtual.RBP_castSpark:Hide()
				Virtual.RBP_castBarInitSpark = true
			end
			if Virtual.RBP_channelingFlag == 1 then
				Virtual.RBP_castBarTex:SetVertexColor(unpack(dbp.castBar_channelingColor))
			else
				Virtual.RBP_castBarTex:SetVertexColor(unpack(dbp.castBar_color))
			end
			if dbp.castBar_progressiveTexCrop then
				Virtual.RBP_castBarTexCrop = true
			end
		else
			Virtual.RBP_castBarIsShown = nil
			castBar:Hide()
			castBarBorder:Hide()
			shieldCastBarBorder:Hide()
			spellIcon:Hide()
		end
	end)
	local castBarRegionsFadeOut = CreateFrame("Frame")
	castBarRegionsFadeOut.elapsed = 0
	castBarRegionsFadeOut:Hide()
	castBarRegionsFadeOut:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if maxCastVal and Virtual.RBP_isShown and self.elapsed < (castingFailed and 1.5 or 0.75) then
			if castingFailed then
				if self.elapsed < 0.75 then
					alpha = 1
				else
					alpha = 2 - (self.elapsed / 0.75)
				end
			else
				alpha = 1 - (self.elapsed / 0.75)
			end
			if Virtual.RBP_ogShieldCastBarBorderIsShown then
				shieldCastBarBorder:SetAlpha(alpha)
			else
				castBarBorder:SetAlpha(alpha)
			end
			if channelingCompleted then
				castBarTexFull:SetAlpha(0.5 * alpha)
			else
				castBarTexFull:SetAlpha(alpha)
			end
			spellIcon:SetAlpha(alpha)
			castText:SetAlpha(alpha)
		else
			self:Hide()
			self.elapsed = 0
			maxCastVal = nil
			channelingCompleted = nil
			castingFailed = nil
			castBarBorder:Hide()
			shieldCastBarBorder:Hide()
			spellIcon:SetAlpha(1)
			spellIcon:Hide()
			castBarTexFull:Hide()
			castBarTexFull:SetAlpha(1)
			castText:SetAlpha(1)
			castText:SetText("")
		end
	end)
	local delayedCastBarOnHide = CreateFrame("Frame")
	delayedCastBarOnHide:Hide()
	delayedCastBarOnHide:SetScript("OnUpdate", function(self)
		self:Hide()
		if castBar:IsShown() then return end
		local isTargetNow
		if hasModernEngine then
			isTargetNow = Plate == C_NamePlate.GetNamePlateForUnit("target")
		else
			isTargetNow = RBP.hasTarget and Plate:GetAlpha() == 1
		end
		if maxCastVal and Virtual.RBP_healthBarIsShown and Virtual.RBP_isTarget == isTargetNow then
			UpdateCastBarRegionsVisibility(Virtual)
			UpdateCastBarRegionsAnchor(Virtual)
			spellIcon:Show()
			castBarTexFull:Show()
			castBarRegionsFadeOut:Show()
		else
			maxCastVal = nil
			castBarBorder:Hide()
			shieldCastBarBorder:Hide()
			castText:SetAlpha(1)
			castText:SetText("")			
		end
	end)
	castBar:HookScript("OnShow", function(self)
		maxCastVal = nil
		castText:SetAlpha(1)
		castText:SetText("")
		lastTimerTenths = nil
		if castBarRegionsFadeOut:IsShown() then
			castBarRegionsFadeOut:Hide()
			castBarRegionsFadeOut.elapsed = 0
			channelingCompleted = nil
			castingFailed = nil
			castBarTexFull:Hide()
			castBarTexFull:SetAlpha(1)
			spellIcon:SetAlpha(1)
		end
		Virtual.RBP_ogShieldCastBarBorderIsShown = Virtual.RBP_ogShieldCastBarBorder:IsShown()
		delayedCastBarOnShow:Show()
	end)
	castBar:HookScript("OnHide", function(self)
		delayedCastBarOnShow:Hide()
		castTimerText:Hide()
		Virtual.RBP_castBarIsShown = nil
		Virtual.RBP_castBarInitSpark = nil
		Virtual.RBP_castBarTexCrop = nil
		Virtual.RBP_channelingFlag = nil
		Virtual.RBP_castBarExpectedY = nil
		firstCastVal = nil
		secondCastVal = nil
		currCastVal = nil
		castDelta = nil
		anchorCheckPending = nil
		lastOVC = nil
		if RBP.dbp.castBar_forcedFading then
			delayedCastBarOnHide:Show()
		else
			maxCastVal = nil
			castBarBorder:Hide()
			shieldCastBarBorder:Hide()
			castText:SetAlpha(1)
			castText:SetText("")
		end
	end)
	castBar:HookScript("OnValueChanged", function(self, val)
		local pushed
		if val < 0.002 then
			if RBP.dbp.castBar_forcedFading and currCastVal and maxCastVal and not lastOVC then
				lastOVC = true
				channelingCompleted = nil
				castingFailed = nil
				if Virtual.RBP_channelingFlag == 1 then
					if currCastVal < RBP.dbp.castBar_completionTol then
						castBarTexFull:SetVertexColor(0, 0, 0, 0.5)
						channelingCompleted = true
					else
						castBarTexFull:SetVertexColor(unpack(RBP.dbp.castBar_channelingColor))
					end
				else
					if maxCastVal - currCastVal < RBP.dbp.castBar_completionTol then
						castBarTexFull:SetVertexColor(0, 1, 0)
					else
						castBarTexFull:SetVertexColor(1, 0, 0)
						castingFailed = true
						if castText:GetText() then
							castText:SetText(L["Failed"])
						end
					end
				end
			end
		else
			if not firstCastVal then
				firstCastVal = val
			elseif not secondCastVal then
				secondCastVal = val
				if not Virtual.RBP_channelingFlag then
					if secondCastVal < firstCastVal then
						Virtual.RBP_channelingFlag = 1
						Virtual.RBP_castBarTex:SetVertexColor(unpack(RBP.dbp.castBar_channelingColor))
					else
						Virtual.RBP_channelingFlag = 0
						Virtual.RBP_castBarTex:SetVertexColor(unpack(RBP.dbp.castBar_color))
					end
				end
			end
			if currCastVal and Virtual.RBP_castBarIsShown then
				local delta = val - currCastVal
				local flag = Virtual.RBP_channelingFlag
				if flag == 1 then
					if delta > 0 or castDelta and delta < castDelta * 1.5 - 0.01 then
						pushed = true
						if castDelta then castDelta = castDelta * 1.5 end
					elseif delta < 0 then
						castDelta = delta
					end
				elseif flag == 0 and delta < 0 then
					pushed = true
				end
			end
		end
		currCastVal = val
		if Virtual.RBP_castBarInitSpark then
			Virtual.RBP_castBarInitSpark = nil
			Virtual.RBP_castSpark:Show()
		end
		if Virtual.RBP_castBarIsShown then
			local min, max = self:GetMinMaxValues()
			if max > 0 then
				if Virtual.RBP_castBarTexCrop then
					castBarTex:SetTexCoord(0, val / max, 0, 1)
					texCropped = true
				elseif texCropped then
					castBarTex:SetTexCoord(0, 1, 0, 1)
					texCropped = nil
				end
				local t = Virtual.RBP_channelingFlag == 1 and val or max - val
				local tenths = math_floor(t * 10 + 0.5)
				local checkAnchor = pushed or anchorCheckPending
				anchorCheckPending = pushed
				if lastTimerTenths ~= tenths then
					lastTimerTenths = tenths
					if castTimerText:IsShown() then
						castTimerText:SetFormattedText("%.1f", t)
					end
					checkAnchor = true
				end
				if checkAnchor then
					local expectedY = Virtual.RBP_castBarExpectedY
					if expectedY then
						local _, _, _, _, y = self:GetPoint(1)
						if math_abs(y - expectedY) > 0.01 then
							UpdateCastBarRegionsAnchor(Virtual)
						end
					end
				end
			end
		end
	end)
end

local function SetupBossIcon(Virtual)
	local dbp = RBP.dbp
	local boss = FixedAnchors.boss
	Virtual.RBP_bossIcon:SetSize(dbp.bossIcon_size * RBP.NP_SCALE, dbp.bossIcon_size * RBP.NP_SCALE)
	PlaceOnHealthBar(Virtual.RBP_bossIcon, Virtual, boss[dbp.bossIcon_anchor] or boss.Right, dbp.bossIcon_offsetX, dbp.bossIcon_offsetY)
end

local function SetupRaidTargetIcon(Virtual)
	local dbp = RBP.dbp
	local raid = GetStyle().icons.raid
	Virtual.RBP_raidTargetIcon:SetSize(dbp.raidTargetIcon_size * RBP.NP_SCALE, dbp.raidTargetIcon_size * RBP.NP_SCALE)
	PlaceOnHealthBar(Virtual.RBP_raidTargetIcon, Virtual, raid[dbp.raidTargetIcon_anchor] or raid.Right, dbp.raidTargetIcon_offsetX, dbp.raidTargetIcon_offsetY)
end

local function SetupEliteIcon(Virtual)
	local dbp = RBP.dbp
	local isLeft = dbp.eliteIcon_anchor == "Left"
	local elite = GetStyle().icons.elite
	local spec = elite[dbp.eliteIcon_style] or elite.Default
	Virtual.RBP_eliteIcon:SetVertexColor(unpack(dbp.eliteIcon_color))
	if dbp.eliteIcon_style == "Modern" then
		Virtual.RBP_eliteIcon:SetTexture(ASSETS .. "PlateRegions\\EliteIcon-Modern")
		Virtual.RBP_eliteIcon:SetSize(29.416 * dbp.eliteIcon_widthScale * RBP.NP_SCALE, 29.416 * dbp.eliteIcon_heightScale * RBP.NP_SCALE)
		if isLeft then
			Virtual.RBP_eliteIcon:SetTexCoord(0.9, 0.1, 0.9, 0.9, 0.1, 0.1, 0.1, 0.9)
		else
			Virtual.RBP_eliteIcon:SetTexCoord(0.1, 0.1, 0.1, 0.9, 0.9, 0.1, 0.9, 0.9)
		end
	elseif dbp.eliteIcon_style == "Minimalist" then
		Virtual.RBP_eliteIcon:SetTexture(ASSETS .. "PlateRegions\\EliteIcon-Small")
		Virtual.RBP_eliteIcon:SetSize(13.074 * dbp.eliteIcon_widthScale * RBP.NP_SCALE, 13.074 * dbp.eliteIcon_heightScale * RBP.NP_SCALE)
		if isLeft then
			Virtual.RBP_eliteIcon:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1)
		else
			Virtual.RBP_eliteIcon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
		end
	else
		Virtual.RBP_eliteIcon:SetTexture(ASSETS .. "PlateRegions\\EliteIcon-Classic")
		Virtual.RBP_eliteIcon:SetSize(37.63 * dbp.eliteIcon_widthScale * RBP.NP_SCALE, 27.52 * dbp.eliteIcon_heightScale * RBP.NP_SCALE)
		if isLeft then
			Virtual.RBP_eliteIcon:SetTexCoord(0.578125, 0, 0.578125, 0.84375, 0, 0, 0, 0.84375)
		else
			Virtual.RBP_eliteIcon:SetTexCoord(0, 0, 0, 0.84375, 0.578125, 0, 0.578125, 0.84375)
		end
	end
	PlaceOnHealthBar(Virtual.RBP_eliteIcon, Virtual, spec[isLeft and "Left" or "Right"], dbp.eliteIcon_offsetX, dbp.eliteIcon_offsetY)
end

local function SetupClassIcon(Virtual)
	local dbp = RBP.dbp
	if not Virtual.RBP_classIcon then
		Virtual.RBP_classIcon = Virtual.RBP_healthBar:CreateTexture(nil, "ARTWORK")
		Virtual.RBP_classIcon:Hide()
	end
	local class = GetStyle().icons.class
	Virtual.RBP_classIcon:SetSize(dbp.classIcon_size * RBP.NP_SCALE, dbp.classIcon_size * RBP.NP_SCALE)
	PlaceOnHealthBar(Virtual.RBP_classIcon, Virtual, class[dbp.classIcon_anchor] or class.Right, dbp.classIcon_offsetX, dbp.classIcon_offsetY)
end

local function UpdateClassIcon(Virtual)
	local dbp = RBP.dbp
	local class = Virtual.RBP_classKey
	local iconClass
	if class == "FRIENDLY_PLAYER" then
		if dbp.showClassOnFriends then
			iconClass = ClassByFriendName[Virtual.RBP_nameString]
		end
	elseif class and dbp.showClassOnEnemies then
		iconClass = class
	end
	if iconClass then
		Virtual.RBP_classIcon:SetTexture(ASSETS .. "Classes\\" .. iconClass)
		Virtual.RBP_classIcon:Show()
	else
		Virtual.RBP_classIcon:Hide()
	end
end

local function SetupTotemIcon(Virtual)
	if not Virtual.RBP_totemPlate then return end
	local dbp = RBP.dbp
	Virtual.RBP_totemPlate:SetPoint("TOP", Virtual.RealPlate, 0, dbp.totemOffset - 3)
	Virtual.RBP_totemPlate:SetSize(dbp.totemSize, dbp.totemSize)
	Virtual.RBP_totemPlate_targetGlow:SetSize(128*dbp.totemSize/88, 128*dbp.totemSize/88)
end

local function SetupTotemPlate(Virtual)
	if Virtual.RBP_totemPlate then return end
	Virtual.RBP_totemPlate = CreateFrame("Frame", nil, Virtual)
	Virtual.RBP_totemPlate:Hide()
	Virtual.RBP_totemPlate:SetFrameLevel(Virtual:GetFrameLevel())
	Virtual.RBP_totemPlate_icon = Virtual.RBP_totemPlate:CreateTexture(nil, "BORDER")
	Virtual.RBP_totemPlate_icon:SetAllPoints(Virtual.RBP_totemPlate)
	Virtual.RBP_totemPlate_targetGlow = Virtual.RBP_totemPlate:CreateTexture(nil, "OVERLAY")
	Virtual.RBP_totemPlate_targetGlow:SetTexture(ASSETS .. "PlateRegions\\TotemPlate-TargetGlow")
	Virtual.RBP_totemPlate_targetGlow:SetVertexColor(unpack(RBP.dbp.targetGlow_Color))
	Virtual.RBP_totemPlate_targetGlow:SetPoint("CENTER")
	Virtual.RBP_totemPlate_targetGlow:Hide()
	Virtual.RBP_totemPlate_border = Virtual.RBP_totemPlate:CreateTexture(nil, "ARTWORK")
	Virtual.RBP_totemPlate_border:SetTexture(ASSETS .. "PlateRegions\\TotemPlate-Border")
	Virtual.RBP_totemPlate_border:SetVertexColor(1, 0, 0)
	Virtual.RBP_totemPlate_border:SetAllPoints(Virtual.RBP_totemPlate)
	Virtual.RBP_totemPlate_border:Hide()
	SetupTotemIcon(Virtual)
end

local function GetBarlessUnitClass(Virtual)
	local class = ClassByFriendName[Virtual.RBP_nameString]
	if not class and hasModernEngine and Virtual.namePlateUnitToken then
		class = select(2, UnitClass(Virtual.namePlateUnitToken))
	end
	return class
end

local function UpdateBarlessPlate(Virtual)
	if not Virtual.RBP_isBarlessPlate then return end
	local dbp = RBP.dbp
	local barlessPlate_nameText = Virtual.RBP_barlessPlate_nameText
	local barlessPlate_healthText = Virtual.RBP_barlessPlate_healthText
	local barlessPlate_classIcon = Virtual.RBP_barlessPlate_classIcon
	local barlessPlate_raidTargetIcon = Virtual.RBP_barlessPlate_raidTargetIcon
	local barlessPlate_targetGlow = Virtual.RBP_barlessPlate_targetGlow
	local healthBarHighlight = Virtual.RBP_healthBarHighlight
	if Virtual.RBP_classKey then
		local unitClass = GetBarlessUnitClass(Virtual)
		local classColor = unitClass and dbp.healthBar_classColors[unitClass]
		if classColor and dbp.barlessPlate_classColors then
			Virtual.RBP_barlessNameTextRGB = classColor
		else
			Virtual.RBP_barlessNameTextRGB = dbp.barlessPlate_textColor
		end
		if dbp.barlessPlate_nameColorByHP then
			Virtual.RBP_barlessNameTextGrayOut = true
		else
			Virtual.RBP_barlessNameTextGrayOut = nil
		end
		if dbp.barlessPlate_showText then
			Virtual.RBP_barlessHideNameText = nil
		else
			Virtual.RBP_barlessHideNameText = true
		end
		barlessPlate_nameText:SetFont(RBP.LSM:Fetch("font", dbp.barlessPlate_textFont), dbp.barlessPlate_textSize, dbp.barlessPlate_textOutline)
		barlessPlate_nameText:SetPoint("TOP", 0, dbp.barlessPlate_offset)
		barlessPlate_healthText:SetFont(RBP.LSM:Fetch("font", dbp.barlessPlate_healthTextFont), dbp.barlessPlate_healthTextSize, dbp.barlessPlate_healthTextOutline)
		barlessPlate_healthText:ClearAllPoints()
		if dbp.barlessPlate_healthTextAnchor == "Left" then
			barlessPlate_healthText:SetPoint("RIGHT", barlessPlate_nameText, "LEFT", dbp.barlessPlate_healthTextOffsetX, dbp.barlessPlate_healthTextOffsetY)
		elseif dbp.barlessPlate_healthTextAnchor == "Right" then
			barlessPlate_healthText:SetPoint("LEFT", barlessPlate_nameText, "RIGHT", dbp.barlessPlate_healthTextOffsetX, dbp.barlessPlate_healthTextOffsetY)
		elseif dbp.barlessPlate_healthTextAnchor == "Bottom" then
			barlessPlate_healthText:SetPoint("TOP", barlessPlate_nameText, "BOTTOM", dbp.barlessPlate_healthTextOffsetX, dbp.barlessPlate_healthTextOffsetY)
		else
			barlessPlate_healthText:SetPoint("BOTTOM", barlessPlate_nameText, "TOP", dbp.barlessPlate_healthTextOffsetX, dbp.barlessPlate_healthTextOffsetY)
		end
		if dbp.barlessPlate_showHealthText then
			barlessPlate_healthText:Show()
			Virtual.RBP_BarlessHealthTextIsShown = true
		else
			barlessPlate_healthText:Hide()
			Virtual.RBP_BarlessHealthTextIsShown = nil
		end
		barlessPlate_classIcon:SetSize(dbp.barlessPlate_classIconSize, dbp.barlessPlate_classIconSize)
		barlessPlate_classIcon:ClearAllPoints()
		if dbp.barlessPlate_classIconAnchor == "Left" then
			barlessPlate_classIcon:SetPoint("RIGHT", barlessPlate_nameText, "LEFT", dbp.barlessPlate_classIconOffsetX, dbp.barlessPlate_classIconOffsetY)
		elseif dbp.barlessPlate_classIconAnchor == "Right" then
			barlessPlate_classIcon:SetPoint("LEFT", barlessPlate_nameText, "RIGHT", dbp.barlessPlate_classIconOffsetX, dbp.barlessPlate_classIconOffsetY)
		elseif dbp.barlessPlate_classIconAnchor == "Bottom" then
			barlessPlate_classIcon:SetPoint("TOP", barlessPlate_nameText, "BOTTOM", dbp.barlessPlate_classIconOffsetX, dbp.barlessPlate_classIconOffsetY)
		else
			barlessPlate_classIcon:SetPoint("BOTTOM", barlessPlate_nameText, "TOP", dbp.barlessPlate_classIconOffsetX, dbp.barlessPlate_classIconOffsetY)
		end
		if dbp.barlessPlate_showClassIcon and ClassByFriendName[Virtual.RBP_nameString] then
			barlessPlate_classIcon:SetTexture(ASSETS .. "Classes\\" .. ClassByFriendName[Virtual.RBP_nameString])
			barlessPlate_classIcon:Show()
		else
			barlessPlate_classIcon:SetTexture(nil)
			barlessPlate_classIcon:Hide()
		end
	else
		Virtual.RBP_barlessNameTextRGB = dbp.barlessPlate_NPCtextColor
		if dbp.barlessPlate_NPCnameColorByHP then
			Virtual.RBP_barlessNameTextGrayOut = true
		else
			Virtual.RBP_barlessNameTextGrayOut = nil
		end
		if dbp.barlessPlate_showNPCtext then
			Virtual.RBP_barlessHideNameText = nil
		else
			Virtual.RBP_barlessHideNameText = true
		end	
		barlessPlate_nameText:SetFont(RBP.LSM:Fetch("font", dbp.barlessPlate_NPCtextFont), dbp.barlessPlate_NPCtextSize, dbp.barlessPlate_NPCtextOutline)
		barlessPlate_nameText:SetPoint("TOP", 0, dbp.barlessPlate_NPCoffset)
		barlessPlate_healthText:SetFont(RBP.LSM:Fetch("font", dbp.barlessPlate_NPChealthTextFont), dbp.barlessPlate_NPChealthTextSize, dbp.barlessPlate_NPChealthTextOutline)
		barlessPlate_healthText:ClearAllPoints()
		if dbp.barlessPlate_NPChealthTextAnchor == "Left" then
			barlessPlate_healthText:SetPoint("RIGHT", barlessPlate_nameText, "LEFT", dbp.barlessPlate_NPChealthTextOffsetX, dbp.barlessPlate_NPChealthTextOffsetY)
		elseif dbp.barlessPlate_NPChealthTextAnchor == "Right" then
			barlessPlate_healthText:SetPoint("LEFT", barlessPlate_nameText, "RIGHT", dbp.barlessPlate_NPChealthTextOffsetX, dbp.barlessPlate_NPChealthTextOffsetY)
		elseif dbp.barlessPlate_NPChealthTextAnchor == "Bottom" then
			barlessPlate_healthText:SetPoint("TOP", barlessPlate_nameText, "BOTTOM", dbp.barlessPlate_NPChealthTextOffsetX, dbp.barlessPlate_NPChealthTextOffsetY)
		else
			barlessPlate_healthText:SetPoint("BOTTOM", barlessPlate_nameText, "TOP", dbp.barlessPlate_NPChealthTextOffsetX, dbp.barlessPlate_NPChealthTextOffsetY)
		end
		if dbp.barlessPlate_showNPCHealthText then
			barlessPlate_healthText:Show()
			Virtual.RBP_BarlessHealthTextIsShown = true
		else
			barlessPlate_healthText:Hide()
			Virtual.RBP_BarlessHealthTextIsShown = nil
		end
		barlessPlate_classIcon:SetTexture(nil)
		barlessPlate_classIcon:Hide()
	end
	barlessPlate_targetGlow:SetAlpha(dbp.barlessPlate_targetGlowAlpha)
	barlessPlate_targetGlow:SetVertexColor(unpack(dbp.barlessPlate_targetGlowColor))
	barlessPlate_raidTargetIcon:SetSize(dbp.barlessPlate_raidTargetIconSize, dbp.barlessPlate_raidTargetIconSize)
	barlessPlate_raidTargetIcon:ClearAllPoints()
	if dbp.barlessPlate_raidTargetIconAnchor == "Left" then
		barlessPlate_raidTargetIcon:SetPoint("RIGHT", barlessPlate_nameText, "LEFT", dbp.barlessPlate_raidTargetIconOffsetX, dbp.barlessPlate_raidTargetIconOffsetY)
	elseif dbp.barlessPlate_raidTargetIconAnchor == "Right" then
		barlessPlate_raidTargetIcon:SetPoint("LEFT", barlessPlate_nameText, "RIGHT", dbp.barlessPlate_raidTargetIconOffsetX, dbp.barlessPlate_raidTargetIconOffsetY)
	elseif dbp.barlessPlate_raidTargetIconAnchor == "Bottom" then
		barlessPlate_raidTargetIcon:SetPoint("TOP", barlessPlate_nameText, "BOTTOM", dbp.barlessPlate_raidTargetIconOffsetX, dbp.barlessPlate_raidTargetIconOffsetY)
	else
		barlessPlate_raidTargetIcon:SetPoint("BOTTOM", barlessPlate_nameText, "TOP", dbp.barlessPlate_raidTargetIconOffsetX, dbp.barlessPlate_raidTargetIconOffsetY)
	end
	if Virtual.RBP_raidIconIndex and dbp.barlessPlate_showRaidTarget then
		barlessPlate_raidTargetIcon:SetTexCoord(Virtual.RBP_raidTargetIcon:GetTexCoord())
		barlessPlate_raidTargetIcon:Show()
	else
		barlessPlate_raidTargetIcon:Hide()
	end
	barlessPlate_nameText:SetText(Virtual.RBP_nameString)
	barlessPlate_nameText:SetTextColor(unpack(Virtual.RBP_barlessNameTextRGB))
	if Virtual.RBP_barlessHideNameText then
		barlessPlate_nameText:Hide()	
		healthBarHighlight:SetTexture(nil)	
	else
		barlessPlate_nameText:Show()
		healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\BarlessPlate-MouseoverGlow")
		healthBarHighlight:ClearAllPoints()
		healthBarHighlight:SetPoint("TOPLEFT", barlessPlate_nameText, -15, 10)
		healthBarHighlight:SetPoint("BOTTOMRIGHT", barlessPlate_nameText, 15, -11)		
	end
end

local function SetupBarlessPlate(Virtual)
	if Virtual.RBP_barlessPlate then return end
	Virtual.RBP_barlessPlate = CreateFrame("Frame", nil, Virtual)
	Virtual.RBP_barlessPlate:SetSize(1, 1)
	Virtual.RBP_barlessPlate:SetPoint("TOP", Virtual.RealPlate)
	Virtual.RBP_barlessPlate:Hide()
	Virtual.RBP_barlessPlate:SetFrameLevel(Virtual:GetFrameLevel() + 1)
	Virtual.RBP_barlessPlate_nameText = Virtual.RBP_barlessPlate:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_barlessPlate_nameText:SetShadowOffset(0.5, -0.5)
	Virtual.RBP_barlessPlate_healthText = Virtual.RBP_barlessPlate:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_barlessPlate_healthText:SetShadowOffset(0.5, -0.5)
	Virtual.RBP_barlessPlate_healthText:Hide()
	Virtual.RBP_barlessPlate_raidTargetIcon = Virtual.RBP_barlessPlate:CreateTexture(nil, "BORDER")
	Virtual.RBP_barlessPlate_raidTargetIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	Virtual.RBP_barlessPlate_raidTargetIcon:Hide()
	Virtual.RBP_barlessPlate_classIcon = Virtual.RBP_barlessPlate:CreateTexture(nil, "ARTWORK")
	Virtual.RBP_barlessPlate_classIcon:Hide()
	Virtual.RBP_barlessPlate_targetGlow = Virtual.RBP_barlessPlate:CreateTexture(nil, "BACKGROUND")
	Virtual.RBP_barlessPlate_targetGlow:SetTexture(ASSETS .. "PlateRegions\\BarlessPlate-MouseoverGlow")
	Virtual.RBP_barlessPlate_targetGlow:SetPoint("TOPLEFT", Virtual.RBP_barlessPlate_nameText, -15, 10)
	Virtual.RBP_barlessPlate_targetGlow:SetPoint("BOTTOMRIGHT", Virtual.RBP_barlessPlate_nameText, 15, -11)
	Virtual.RBP_barlessPlate_targetGlow:Hide()
end

local function CheckBarlessPlate(Virtual)
	local filter = 0
	if RBP.inOpenWorld then
		filter = RBP.dbp.barlessPlate_filterOpenWorld
	elseif RBP.inPvEInstance then
		filter = RBP.dbp.barlessPlate_filterPvE
	elseif RBP.inBG then
		filter = RBP.dbp.barlessPlate_filterBG
	elseif RBP.inArena then
		filter = RBP.dbp.barlessPlate_filterArena
	end
	if Virtual.RBP_isFriendly and (filter == 3 or filter == (Virtual.RBP_classKey and 2 or 1)) then
		if not Virtual.RBP_barlessPlate then
			SetupBarlessPlate(Virtual)
		end
		Virtual.RBP_isBarlessPlate = true
		UpdateBarlessPlate(Virtual)
	end
end

local function HideVirtualPlateElements(Virtual)
	Virtual.RBP_healthBar:Hide()
	Virtual.RBP_regionsWrapper:Hide()
	Virtual.RBP_healthBarIsShown = nil
	Virtual.RBP_castBar:Hide()
	Virtual.RBP_castBarIsShown = nil
	Virtual.RBP_castBarBorder:Hide()
	Virtual.RBP_shieldCastBarBorder:Hide()
	Virtual.RBP_spellIcon:Hide()
	Virtual.RBP_levelText:Hide()
	Virtual.RBP_bossIcon:Hide()
	Virtual.RBP_raidTargetIcon:SetAlpha(0)
	Virtual.RBP_eliteIcon:Hide()
end

local function ModifyBarlessBGH(Virtual)
	local dbp = RBP.dbp
	if Virtual.BGHframe then
		if dbp.barlessPlate_BGHiconAnchor == "Left" then
			Virtual.BGHframe:ModifyIcon(true, dbp.barlessPlate_BGHiconSize, "RIGHT", Virtual.RBP_barlessPlate_nameText, "LEFT", dbp.barlessPlate_BGHiconOffsetX, dbp.barlessPlate_BGHiconOffsetY)
		elseif dbp.barlessPlate_BGHiconAnchor == "Right" then
			Virtual.BGHframe:ModifyIcon(true, dbp.barlessPlate_BGHiconSize, "LEFT", Virtual.RBP_barlessPlate_nameText, "RIGHT", dbp.barlessPlate_BGHiconOffsetX, dbp.barlessPlate_BGHiconOffsetY)
		elseif dbp.barlessPlate_BGHiconAnchor == "Bottom" then
			Virtual.BGHframe:ModifyIcon(true, dbp.barlessPlate_BGHiconSize, "TOP", Virtual.RBP_barlessPlate_nameText, "BOTTOM", dbp.barlessPlate_BGHiconOffsetX, dbp.barlessPlate_BGHiconOffsetY)
		else
			Virtual.BGHframe:ModifyIcon(true, dbp.barlessPlate_BGHiconSize, "BOTTOM", Virtual.RBP_barlessPlate_nameText, "TOP", dbp.barlessPlate_BGHiconOffsetX, dbp.barlessPlate_BGHiconOffsetY)
		end
	elseif Virtual.RBP_firstProcessing then
		if dbp.barlessPlate_BGHiconAnchor == "Left" then
			Virtual.shouldModifyBGH = {true, dbp.barlessPlate_BGHiconSize, "RIGHT", Virtual.RBP_barlessPlate_nameText, "LEFT", dbp.barlessPlate_BGHiconOffsetX, dbp.barlessPlate_BGHiconOffsetY}
		elseif dbp.barlessPlate_BGHiconAnchor == "Right" then
			Virtual.shouldModifyBGH = {true, dbp.barlessPlate_BGHiconSize, "LEFT", Virtual.RBP_barlessPlate_nameText, "RIGHT", dbp.barlessPlate_BGHiconOffsetX, dbp.barlessPlate_BGHiconOffsetY}
		elseif dbp.barlessPlate_BGHiconAnchor == "Bottom" then
			Virtual.shouldModifyBGH = {true, dbp.barlessPlate_BGHiconSize, "TOP", Virtual.RBP_barlessPlate_nameText, "BOTTOM", dbp.barlessPlate_BGHiconOffsetX, dbp.barlessPlate_BGHiconOffsetY}
		else
			Virtual.shouldModifyBGH = {true, dbp.barlessPlate_BGHiconSize, "BOTTOM", Virtual.RBP_barlessPlate_nameText, "TOP", dbp.barlessPlate_BGHiconOffsetX, dbp.barlessPlate_BGHiconOffsetY}
		end
	end
end

local function BarlessPlateVisibilityHandler(Virtual)
	if not Virtual.RBP_isBarlessPlate then return end
	local dbp = RBP.dbp
	Virtual.RBP_threatGlow:SetTexture(nil)
	Virtual.RBP_barlessPlate_targetGlow:Hide()
	if hasModernEngine and Virtual.RBP_classKey then
		local unitClass = GetBarlessUnitClass(Virtual)
		local unitClassColor = unitClass and dbp.healthBar_classColors[unitClass]
		if unitClassColor and dbp.barlessPlate_classColors then
			Virtual.RBP_barlessNameTextRGB = unitClassColor
			Virtual.RBP_barlessPlate_nameText:SetTextColor(unpack(unitClassColor))
		end
	end
	if Virtual.RBP_isTarget and dbp.barlessPlate_excludeTarget then
		Virtual.RBP_healthBar:Show()
		Virtual.RBP_regionsWrapper:Show()
		Virtual.RBP_healthBarIsShown = true
		if Virtual.RBP_hasBossIcon then
			Virtual.RBP_bossIcon:Show()
		elseif not dbp.levelText_hide and not (RBP.inArena and dbp.PartyIDText_show and dbp.PartyIDText_HideLevel) then
			UpdateLevelText(Virtual)
			Virtual.RBP_levelText:Show()
		end
		if Virtual.RBP_raidIconIndex and not dbp.raidTargetIcon_hide then
			Virtual.RBP_raidTargetIcon:SetAlpha(1)
		else
			Virtual.RBP_raidTargetIcon:SetAlpha(0)
		end
		if Virtual.RBP_hasEliteIcon then
			Virtual.RBP_eliteIcon:Show()
		end
		Virtual.RBP_barlessPlate:Hide()
		Virtual.RBP_barlessPlateIsShown = nil
		if Virtual.BGHframe then
			Virtual.BGHframe:ModifyIcon()
		end
	else
		Virtual.RBP_barlessPlate:Show()
		Virtual.RBP_barlessPlateIsShown = true
		if Virtual.RBP_isTarget and not Virtual.RBP_barlessHideNameText then
			Virtual.RBP_barlessPlate_targetGlow:Show()
		end
		HideVirtualPlateElements(Virtual)
		ModifyBarlessBGH(Virtual)
	end
end

local function UpdateLocalScale(Virtual)
	local dbp = RBP.dbp
    if Virtual.RBP_isTarget then
        Virtual.RBP_localScale = dbp.globalScale * dbp.targetScale
    elseif Virtual.RBP_totemPlateIsShown or Virtual.RBP_barlessPlateIsShown then
        Virtual.RBP_localScale = dbp.globalScale
    elseif Virtual.RBP_isFriendly then
        Virtual.RBP_localScale = dbp.globalScale * dbp.friendlyScale
    else
        Virtual.RBP_localScale = dbp.globalScale
    end
end

local function SetVirtualScale(Virtual)
	local scale = Virtual.RBP_localScale or RBP.dbp.globalScale
	if not Virtual.RBP_dynamicScale or Virtual.RBP_isTarget then
		SetScale(Virtual, scale)
	else
		SetScale(Virtual, scale * Virtual.RBP_dynamicScale)
	end
end

local function SetupClickboxTexture(Plate)
	if not RBP.dbp.showClickbox or Plate.clickboxTexture then return end
	Plate.clickboxTexture = Plate:CreateTexture(nil, "OVERLAY")
	Plate.clickboxTexture:SetTexture(0.8,0.1,0.1,0.5)
	Plate.clickboxTexture:SetAllPoints()
end

local clickboxesTimer = 0
local function UpdateClickboxesVisualizer(self, elapsed)
	clickboxesTimer = clickboxesTimer + elapsed
	if clickboxesTimer < 0.03 then return end
	clickboxesTimer = 0
	local nameplateHitboxWidthF = tonumber(GetCVar("nameplateHitboxWidthF")) or 1
	local nameplateHitboxWidthE = tonumber(GetCVar("nameplateHitboxWidthE")) or 1
	local nameplateHitboxHeightF = tonumber(GetCVar("nameplateHitboxHeightF")) or 1
	local nameplateHitboxHeightE = tonumber(GetCVar("nameplateHitboxHeightE")) or 1
	local anchor = tonumber(GetCVar("nameplateHitboxAnchor")) or 1
	for Plate, Virtual in pairs(PlatesVisible) do
		local clickboxTexture = Plate.clickboxTexture
		if clickboxTexture then
			local unit = Virtual.namePlateUnitToken
			local isFriendly = unit and UnitIsFriend("player", unit)
			local widthFactor  = isFriendly and nameplateHitboxWidthF or nameplateHitboxWidthE
			local heightFactor  = isFriendly and nameplateHitboxHeightF or nameplateHitboxHeightE
			if widthFactor == 0 then widthFactor = 0.001 end
			if heightFactor == 0 then heightFactor = 0.001 end
			clickboxTexture:SetSize(Plate:GetWidth() * widthFactor, Plate:GetHeight() * heightFactor)
			clickboxTexture:ClearAllPoints()
			if anchor == 0 then
				clickboxTexture:SetPoint("TOP")
			elseif anchor == 2 then
				clickboxTexture:SetPoint("BOTTOM")
			else
				clickboxTexture:SetPoint("CENTER")
			end
		end
	end
end

local ClickboxesDriver = CreateFrame("Frame")
function RBP:UpdateClickboxesDriver()
	if not RBP.hasClickboxModifier then return end
	clickboxesTimer = 0.03
	if RBP.dbp.showClickbox then
		ClickboxesDriver:SetScript("OnUpdate", UpdateClickboxesVisualizer)
	else
		ClickboxesDriver:SetScript("OnUpdate", nil)
	end
end

function RBP:UpdateAllClickboxTextures()
	local dbp = RBP.dbp
	for Plate in pairs(VirtualPlates) do
		if dbp.showClickbox then
			if not Plate.clickboxTexture then
				SetupClickboxTexture(Plate)
			end
			Plate.clickboxTexture:Show()
		elseif Plate.clickboxTexture then
			Plate.clickboxTexture:Hide()			
		end
	end
end

------------------------- Combo Points -------------------------
local UpdateComboPoints, CheckPlateComboPoints, ClearComboPlate
do
	local GetComboPoints = GetComboPoints
	local comboFrame	-- Single shared widget, created on first use
	local comboPlate	-- Virtual currently holding the widget

	local function HideComboPoints()
		if not comboPlate then return end
		comboPlate = nil
		comboFrame:Hide()
	end

	local function CreateComboFrame(Virtual)
		local healthBar = Virtual.RBP_healthBar
		comboFrame = CreateFrame("Frame", nil, healthBar)
		comboFrame.icon = comboFrame:CreateTexture(nil, "OVERLAY")
		comboFrame.icon:SetTexture(ASSETS .. "PlateRegions\\ComboPoints")
		comboFrame.icon:SetAllPoints(comboFrame)
		local size = RBP.dbp.comboPoints_size * RBP.NP_SCALE
		comboFrame:SetSize(size * 5, size)
	end

	local function ReparentComboFrame(Virtual)
		local dbp = RBP.dbp
		local healthBar = Virtual.RBP_healthBar
		comboPlate = Virtual
		comboFrame:SetParent(healthBar)
		comboFrame:SetFrameLevel(healthBar:GetFrameLevel() + 1)
		comboFrame:ClearAllPoints()
		comboFrame:SetPoint("CENTER", comboPlate.RBP_healthBar, "TOP", dbp.comboPoints_offsetX, dbp.comboPoints_offsetY + 3.5 * RBP.NP_SCALE)
	end

	local function ShowComboPoints(Virtual, points)
		if not comboFrame then
			CreateComboFrame(Virtual)
		end
		if comboPlate ~= Virtual then
			ReparentComboFrame(Virtual)
		end
		comboFrame.icon:SetTexCoord(0, 1, (points - 1) * 0.2, points * 0.2)
		comboFrame:Show()
	end

	function UpdateComboPoints()
		if not (RBP.hasComboPoints and RBP.dbp.comboPoints_enable) then
			HideComboPoints()
			return
		end
		if not hasModernEngine and RBP.GlobalDelayedUpdater:IsShown() then return end
		local targetedPlate
		if hasModernEngine then
			targetedPlate = C_NamePlate.GetNamePlateForUnit("target")
		else
			targetedPlate = RBP.targetedPlate
		end
		local targetedVirtual = targetedPlate and targetedPlate.VirtualPlate
		local points = GetComboPoints("player", "target")
		if points > 0 then
			if targetedVirtual and targetedVirtual.RBP_healthBarIsShown then
				ShowComboPoints(targetedVirtual, points)
			else
				HideComboPoints()
			end
			return
		end
		if hasModernEngine then
			if comboPlate and comboPlate ~= targetedVirtual then
				local token = comboPlate.namePlateUnitToken
				points = token and GetComboPoints("player", token) or 0
				if points > 0 then
					ShowComboPoints(comboPlate, points)
					return
				end
			end
			HideComboPoints()
			for _, Virtual in pairs(PlatesVisible) do
				local token = Virtual.namePlateUnitToken
				if token and Virtual ~= targetedVirtual and Virtual.RBP_healthBarIsShown and not Virtual.RBP_isFriendly then
					points = GetComboPoints("player", token)
					if points > 0 then
						ShowComboPoints(Virtual, points)
						return
					end
				end
			end
		else
			if targetedVirtual == comboPlate then
				HideComboPoints()
			end
		end
	end

	function CheckPlateComboPoints(Virtual)
		if not Virtual.RBP_healthBarIsShown or Virtual.RBP_isFriendly then return end
		local points = 0
		if hasModernEngine then
			local token = Virtual.namePlateUnitToken
			if token then
				points = GetComboPoints("player", token)
			end
		elseif Virtual.RBP_isTarget then
			points = GetComboPoints("player", "target")
		end
		if points > 0 then
			ShowComboPoints(Virtual, points)
		end
	end

	function ClearComboPlate(Virtual)
		if Virtual == comboPlate then
			HideComboPoints()
		end
	end

	function RBP:UpdateComboPointsSettings()
		local dbp = RBP.dbp
		if comboFrame then
			local size = dbp.comboPoints_size * RBP.NP_SCALE
			comboFrame:SetSize(size * 5, size)
		end
		if comboPlate then
			comboFrame:ClearAllPoints()
			comboFrame:SetPoint("CENTER", comboPlate.RBP_healthBar, "TOP", dbp.comboPoints_offsetX, dbp.comboPoints_offsetY + 3.5 * RBP.NP_SCALE)
		end
		UpdateComboPoints()
	end
end

local function DelayedUpdate(Virtual, fromOnShow)
	local Plate = Virtual.RealPlate
	local dbp = RBP.dbp
	if hasModernEngine then
		if fromOnShow then
			RBP.targetedPlate = C_NamePlate.GetNamePlateForUnit("target")		
		end
		Virtual.RBP_isTarget = Plate == RBP.targetedPlate
	else
		Virtual.RBP_isTarget = RBP.hasTarget and Plate:GetAlpha() == 1
		if Virtual.RBP_isTarget then
			RBP.targetedPlate = Plate
		end
	end
	if Virtual.RBP_isTarget then
		Virtual.RBP_targetGlow:Show()		
		if Virtual.RBP_totemPlate_targetGlow then
			Virtual.RBP_totemPlate_targetGlow:Show()
		end
		if Virtual.RBP_castBarIsShown and not Virtual.RBP_castText:GetText() then
			UpdateCastTextString(Virtual, "target")
		end
	else
		Virtual.RBP_targetGlow:Hide()
		if Virtual.RBP_totemPlate_targetGlow then 
			Virtual.RBP_totemPlate_targetGlow:Hide()
		end
	end
	if Virtual.RBP_isBarlessPlate then
		BarlessPlateVisibilityHandler(Virtual)
		UpdateHealthTextValue(Virtual.RBP_healthBar)
	end
	if not (hasModernStacking or hasLegacyStacking) and Virtual.RBP_isShown and not Virtual.RBP_isFriendly and not (dbp.stackingEnabled and (not dbp.stackingInInstance or RBP.inInstance)) then
		if (Virtual.RBP_isTarget and dbp.clampTarget) or (Virtual.RBP_hasBossIcon and dbp.clampBoss and RBP.inPvEInstance) then
			Plate:SetClampedToScreen(true)
			Plate:SetClampRectInsets(80*dbp.globalScale, -80*dbp.globalScale, dbp.upperborder, 0)
		else
			Plate:SetClampedToScreen(false)
			Plate:SetClampRectInsets(0, 0, 0, 0)
		end				
	end
	UpdateLocalScale(Virtual)
	SetVirtualScale(Virtual)
	if hasModernStacking and Plate.SetStackingEnabled then
		Plate:SetStackingEnabled(Virtual.RBP_healthBarIsShown == true and not Virtual.RBP_isBarlessPlate and Virtual.RBP_virtualAlpha ~= 0)
	end
	Virtual.RBP_firstProcessing = nil
end

local function SetupDelayedUpdater(Virtual)
	if Virtual.RBP_delayedUpdater then return end
	Virtual.RBP_delayedUpdater = CreateFrame("Frame")
	Virtual.RBP_delayedUpdater:Hide()
	Virtual.RBP_delayedUpdater:SetScript("OnUpdate", function(self)
		self:Hide()
		DelayedUpdate(Virtual, true)
		if RBP.hasComboPoints and RBP.dbp.comboPoints_enable then
			CheckPlateComboPoints(Virtual)
		end
	end)
end

local function UpdateRefinedPlateDelayed(Virtual)
	Virtual.RBP_delayedUpdater:Show()
end

RBP.GlobalDelayedUpdater = CreateFrame("Frame")
RBP.GlobalDelayedUpdater:Hide()
RBP.GlobalDelayedUpdater:SetScript("OnUpdate", function(self)
	self:Hide()
	if not hasModernEngine then
		RBP.targetedPlate = nil
	end
	for _, Virtual in pairs(PlatesVisible) do
		DelayedUpdate(Virtual)
	end
	if not hasModernEngine and RBP.hasComboPoints and RBP.dbp.comboPoints_enable then
		UpdateComboPoints()
	end
end)

local function UpdatePlateNonTargetAlpha(Virtual)
	if not Virtual.RBP_isShown then
		Virtual.RBP_nonTargetAlpha = nil
		return
	end
	local dbp = RBP.dbp
	if Virtual.RBP_totemPlateIsShown then
		Virtual.RBP_nonTargetAlpha = dbp.nonTargetAlpha_totem
	elseif Virtual.RBP_isBarlessPlate then
		Virtual.RBP_nonTargetAlpha = dbp.nonTargetAlpha_barless
	elseif Virtual.RBP_healthBarIsShown then
		if Virtual.RBP_isFriendly then
			Virtual.RBP_nonTargetAlpha = dbp.nonTargetAlpha_friendly
		else
			Virtual.RBP_nonTargetAlpha = dbp.nonTargetAlpha_enemy
		end
	else
		Virtual.RBP_nonTargetAlpha = nil
	end
end

local function UpdateNonTargetAlpha()
	for Plate, Virtual in pairs(PlatesVisible) do
		local alpha = Virtual.RBP_nonTargetAlpha
		if alpha and Virtual.RBP_virtualAlpha ~= 0 and GetAlpha(Plate) ~= 1 then
			SetAlpha(Plate, alpha)
		end
	end
end

local function SetupRefinedPlate(Virtual)
	Virtual.RBP_threatGlow, Virtual.RBP_ogHealthBarBorder, Virtual.RBP_ogCastBarBorder, Virtual.RBP_ogShieldCastBarBorder, Virtual.RBP_spellIcon, Virtual.RBP_healthBarHighlight, Virtual.RBP_ogNameText, Virtual.RBP_levelText, Virtual.RBP_bossIcon, Virtual.RBP_raidTargetIcon, Virtual.RBP_eliteIcon = Virtual:GetRegions()
	Virtual.RBP_healthBar, Virtual.RBP_castBar = Virtual:GetChildren()
	Virtual.RBP_ogHealthBarTex = Virtual.RBP_healthBar:GetRegions()
	Virtual.RBP_ogCastBarTex = Virtual.RBP_castBar:GetRegions()
	Virtual.RBP_healthBar.VirtualPlate = Virtual
	Virtual.RBP_firstProcessing = true
	InitBarTextures(Virtual)
	SetupRegionsWrapper(Virtual)
	SetupThreatGlow(Virtual)
	SetupHealthBorder(Virtual)
	SetupNameText(Virtual)
	UpdateLevelText(Virtual)
	SetupArenaIDText(Virtual)
	SetupTargetGlow(Virtual)
	SetupHealthText(Virtual)
	SetupHealthBarTex(Virtual)
	SetupHealthBarBg(Virtual)
	SetupCastBarBorder(Virtual)
	SetupShieldCastBarBorder(Virtual)
	SetupCastBarTex(Virtual)
	SetupCastBarBg(Virtual)
	SetupCastText(Virtual)
	SetupCastTimer(Virtual)
	SetupCastSpark(Virtual)
	SetupCastGlow(Virtual)
	SetupCastBarTexFull(Virtual)
	HookCastBarScripts(Virtual)
	SetupBossIcon(Virtual)
	SetupRaidTargetIcon(Virtual)
	SetupEliteIcon(Virtual)
	SetupClassIcon(Virtual)
	SetupDelayedUpdater(Virtual)
	SetupClickboxTexture(Virtual.RealPlate)
end

local ForceLevelHide
do
	local levelHideFrames = 0
	local firstChecked
	local ForceLevelHideHandler = CreateFrame("Frame")
	ForceLevelHideHandler:Hide()
	ForceLevelHideHandler:SetScript("OnUpdate", function(self)
		levelHideFrames = levelHideFrames + 1
		firstChecked = false
		for _, Virtual in pairs(PlatesVisible) do
			if not Virtual.RBP_hasBossIcon then
				if not firstChecked then
					firstChecked = true
					if not Virtual.RBP_levelText:IsShown() then
						break
					else
						self:Hide()
					end
				end
				Virtual.RBP_levelText:Hide()
			end
		end
		if not firstChecked or levelHideFrames >= 5 then
			self:Hide()
		end
	end)
	function ForceLevelHide()
		levelHideFrames = 0
		ForceLevelHideHandler:Show()
	end
end

function RBP:CheckLDWZone()
	RBP.inICC = false
	RBP.inLDWZone = false
	SetMapToCurrentZone()
	if GetCurrentMapAreaID() == 605 then
		RBP.inICC = true
		if GetSubZoneText() == RBP.LDWZoneText then
			RBP.inLDWZone = true
		end
	end
	if RBP.DominateMind then
		RBP.DominateMind = nil
		SetUIVisibility(true)
	end
end

function RBP:UpdateLDWfix()
	if RBP.dbp.LDWfix then
		RBP:CheckLDWZone()
	else
		RBP.inICC = false
		RBP.inLDWZone = false
		if RBP.DominateMind then
			RBP.DominateMind = nil 
			SetUIVisibility(true)
		end
	end
end

local function CheckLDWZoneIndoors()
	if GetSubZoneText() == RBP.LDWZoneText then
		RBP.inLDWZone = true
	else
		RBP.inLDWZone = false
	end
    if RBP.DominateMind then
        RBP.DominateMind = nil
		SetUIVisibility(true)
    end
end

local function CheckDominateMind()
    local i = 1
    while true do
        local spellID = select(11, UnitDebuff("player", i))
        if not spellID then break end
        if spellID == 71289 then
            if not RBP.DominateMind then
                RBP.DominateMind = true
                SetUIVisibility(false)
            end
            return
        end
        i = i + 1
    end
    if RBP.DominateMind then
        RBP.DominateMind = nil
		SetUIVisibility(true)
    end
end

local function UpdateGroupInfo()
	wipe(ClassByFriendName)
	wipe(PartyID)
	local partyID, name, class, _
	for i = 1 , GetNumPartyMembers() do
		partyID = "party" .. i
		name = UnitName(partyID)
		_, class = UnitClass(partyID)
		if name and class then
			name = name:match("([^%-]+).*") -- remove realm suffix
			PartyID[name] = tostring(i)
			ClassByFriendName[name] = class
		end
	end
	for i = 1 , GetNumRaidMembers() do
		name, _, _, _, _, class = GetRaidRosterInfo(i)
		if name and class then
			name = name:match("([^%-]+).*") -- remove realm suffix
			if not ClassByFriendName[name] then
				ClassByFriendName[name] = class
			end
		end
	end
end

local function UpdateArenaInfo()
	wipe(ArenaID)
	for i = 1, GetNumArenaOpponents() do
		local arenaName = UnitName("arena" .. i)
		if arenaName then
			ArenaID[arenaName] = tostring(i)
		end
	end
end

local function UpdateClassColor(Virtual)
	local class = Virtual.RBP_classKey
	local dbp = RBP.dbp
	local classColors = dbp.healthBar_classColors
	local classColor
	Virtual.RBP_customColor = nil
	if class == "FRIENDLY_PLAYER" then
		local friendClass = ClassByFriendName[Virtual.RBP_nameString]
		if friendClass then
			classColor = classColors[friendClass]
			Virtual.RBP_customColor = dbp.healthBar_friendClassColor and classColor or dbp.healthBar_friendColor
		else
			Virtual.RBP_customColor = dbp.healthBar_friendlyPlayerColor
		end
	elseif class then
		classColor = classColors[class]
		Virtual.RBP_customColor = classColor
	else
		local reaction = Virtual.RBP_reaction
		if reaction == 4 then
			Virtual.RBP_customColor = dbp.healthBar_neutralColor
		elseif reaction == 5 then
			Virtual.RBP_customColor = dbp.healthBar_friendlyNPCColor
		else
			Virtual.RBP_customColor = dbp.healthBar_hostileColor
		end
	end
	if classColor and ((class == "FRIENDLY_PLAYER" and dbp.nameText_classColorFriends) or (class ~= "FRIENDLY_PLAYER" and dbp.nameText_classColorEnemies)) then
		Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB = classColor[1], classColor[2], classColor[3]
	else
		Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB = unpack(dbp.nameText_color)
	end
	Virtual.RBP_nameText:SetTextColor(Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB)
	Virtual.RBP_nameTextIsYellow = false
end

local function GetAggroStatus(threatGlow)
	if not threatGlow:IsVisible() then return 0 end
	local r, g, b = threatGlow:GetVertexColor()
	if b > 0.5 then return 0 end
	if g < 0.5 then return 3 end
	if g < 0.9 then return 2 end
	return 1
end

local function UpdateHealthBarColor(Virtual)
	local dbp = RBP.dbp
	local color = Virtual.RBP_customColor
	if Virtual.RBP_lowHp then
		color = dbp.lowHpColor_color
	elseif Virtual.RBP_aggroColoring then
		local aggroStatus = GetAggroStatus(Virtual.RBP_threatGlow)
		if aggroStatus == 3 then
			color = dbp.aggroColor
		elseif aggroStatus == 2 then
			color = dbp.losingAggroColor
		elseif aggroStatus == 1 then
			color = dbp.gainingAggroColor
		end
	end
	Virtual.RBP_healthBarTex:SetVertexColor(unpack(color))
end

-- SecureHandlers System: Manages nameplate clickbox resizing while in combat
local TriggerFrames = {}
local ResizeClickbox = CreateFrame("Frame", "ResizeClickboxSecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
ResizeClickbox:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(ResizeClickbox, "OnShow", ResizeClickbox,
	[[
	RBP_Plates = RBP_Plates or newtable()
	for plate, shown in pairs(RBP_Plates) do
		if shown and not plate:IsShown() then
			RBP_Plates[plate] = nil
		end
	end
	local WorldFrame = self:GetFrameRef("WorldFrame")
	local ID = WorldFrame:GetID()
	for i, nameplate in pairs(newtable(WorldFrame:GetChildren())) do
		if not RBP_Plates[nameplate] and nameplate:IsShown() and nameplate:IsProtected() then
			RBP_Plates[nameplate] = true
			if ID == 0 then
				nameplate:SetWidth(self:GetAttribute("normalWidth"))
				nameplate:SetHeight(self:GetAttribute("normalHeight"))
			elseif ID == 1 then
				nameplate:SetWidth(0.01)
				nameplate:SetHeight(0.01)
			elseif ID == 2 then
				nameplate:SetWidth(self:GetAttribute("totemWidth"))
				nameplate:SetHeight(self:GetAttribute("totemHeight"))
			elseif ID == 3 then
				nameplate:SetWidth(self:GetAttribute("barlessWidth"))
				nameplate:SetHeight(self:GetAttribute("barlessHeight"))
			elseif ID == 4 then
				nameplate:SetWidth(self:GetAttribute("friendlyWidth"))
				nameplate:SetHeight(self:GetAttribute("friendlyHeight"))
			end
		end
	end
	]]
)
TriggerFrames["ResizeClickboxSecureHandler"] = ResizeClickbox
RBP.ResizeClickbox = ResizeClickbox
local function ExecuteClickboxSecureScript()
    ToggleFrame(ResizeClickbox)
	ToggleFrame(ResizeClickbox)
end
local SetWorldFrameID0 = CreateFrame("Frame", "SetWorldFrameID0SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID0:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID0, "OnShow", SetWorldFrameID0, [[self:GetFrameRef("WorldFrame"):SetID(0)]])
TriggerFrames["SetWorldFrameID0SecureHandler"] = SetWorldFrameID0
local function SetNormalClickbox()
	if WorldFrame:GetID() ~= 0 then
		ToggleFrame(SetWorldFrameID0)
		ToggleFrame(SetWorldFrameID0)
	end
end
local SetWorldFrameID1 = CreateFrame("Frame", "SetWorldFrameID1SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID1:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID1, "OnShow", SetWorldFrameID1, [[self:GetFrameRef("WorldFrame"):SetID(1)]])
TriggerFrames["SetWorldFrameID1SecureHandler"] = SetWorldFrameID1
local function SetNullClickbox()
	if WorldFrame:GetID() ~= 1 then
		ToggleFrame(SetWorldFrameID1)
		ToggleFrame(SetWorldFrameID1)
	end
end
local SetWorldFrameID2 = CreateFrame("Frame", "SetWorldFrameID2SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID2:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID2, "OnShow", SetWorldFrameID2, [[self:GetFrameRef("WorldFrame"):SetID(2)]])
TriggerFrames["SetWorldFrameID2SecureHandler"] = SetWorldFrameID2
local function SetTotemClickbox()
	if WorldFrame:GetID() ~= 2 then
		ToggleFrame(SetWorldFrameID2)
		ToggleFrame(SetWorldFrameID2)
	end
end
local SetWorldFrameID3 = CreateFrame("Frame", "SetWorldFrameID3SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID3:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID3, "OnShow", SetWorldFrameID3, [[self:GetFrameRef("WorldFrame"):SetID(3)]])
TriggerFrames["SetWorldFrameID3SecureHandler"] = SetWorldFrameID3
local function SetBarlessClickbox()
	if WorldFrame:GetID() ~= 3 then
		ToggleFrame(SetWorldFrameID3)
		ToggleFrame(SetWorldFrameID3)
	end
end
local SetWorldFrameID4 = CreateFrame("Frame", "SetWorldFrameID4SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID4:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID4, "OnShow", SetWorldFrameID4, [[self:GetFrameRef("WorldFrame"):SetID(4)]])
TriggerFrames["SetWorldFrameID4SecureHandler"] = SetWorldFrameID4
local function SetFriendlyClickbox()
	if WorldFrame:GetID() ~= 4 then
		ToggleFrame(SetWorldFrameID4)
		ToggleFrame(SetWorldFrameID4)
	end
end
local SetWorldFrameID5 = CreateFrame("Frame", "SetWorldFrameID5SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID5:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID5, "OnShow", SetWorldFrameID5, [[self:GetFrameRef("WorldFrame"):SetID(5)]])
TriggerFrames["SetWorldFrameID5SecureHandler"] = SetWorldFrameID5
local function InitPlatesClickboxes()
	if WorldFrame:GetID() ~= 5 then
		ToggleFrame(SetWorldFrameID5)
		ToggleFrame(SetWorldFrameID5)
	end
end
for name, frame in pairs(TriggerFrames) do
    if not UIPanelWindows[name] or true then   
        UIPanelWindows[name] = {area = "left", pushable = 8, whileDead = 1}
        frame:SetAttribute("UIPanelLayout-defined", true)
        for attribute, value in pairs(UIPanelWindows[name]) do
            frame:SetAttribute("UIPanelLayout-"..attribute, value)
        end
        frame:SetAttribute("UIPanelLayout-enabled", true)
    end
end

local function ClickboxAttributeUpdater()
	local dbp = RBP.dbp
	RBP.ResizeClickbox:SetAttribute("normalWidth", RBP.NP_WIDTH * dbp.globalScale * dbp.clickboxWidthFactor)
	RBP.ResizeClickbox:SetAttribute("normalHeight", RBP.NP_HEIGHT * dbp.globalScale * dbp.clickboxHeightFactor)
	RBP.ResizeClickbox:SetAttribute("friendlyWidth", RBP.NP_WIDTH * dbp.globalScale * dbp.friendlyScale * dbp.clickboxWidthFactor)
	RBP.ResizeClickbox:SetAttribute("friendlyHeight", RBP.NP_HEIGHT * dbp.globalScale * dbp.friendlyScale * dbp.clickboxHeightFactor)
	RBP.ResizeClickbox:SetAttribute("totemWidth", dbp.totemSize * 1.2 * dbp.globalScale)
	RBP.ResizeClickbox:SetAttribute("totemHeight", dbp.totemSize * 1.2 * dbp.globalScale)
	RBP.ResizeClickbox:SetAttribute("barlessWidth", (dbp.barlessPlate_textSize * 2 + 50) * dbp.globalScale)
	RBP.ResizeClickbox:SetAttribute("barlessHeight",(dbp.barlessPlate_textSize + 5) * dbp.globalScale)
end

local function UpdateClickboxInCombat(Virtual)
	if not Virtual.RBP_isShown or (Virtual.RBP_isFriendly and RBP.dbp.friendlyClickthrough and RBP.inInstance) or (Virtual.RBP_isBarlessPlate and Virtual.RBP_barlessHideNameText) then
		SetNullClickbox()
	elseif Virtual.RBP_totemPlateIsShown then
		SetTotemClickbox()
	elseif Virtual.RBP_isBarlessPlate then
		SetBarlessClickbox()
	elseif Virtual.RBP_isFriendly then
		SetFriendlyClickbox()
	else
		SetNormalClickbox()
	end
	ExecuteClickboxSecureScript()
end

local function UpdateClickboxOutOfCombat(Virtual)
	local dbp = RBP.dbp
	local dynamicScale = Virtual.RBP_dynamicScale or 1
	local width, height
	if not Virtual.RBP_isShown or Virtual.RBP_virtualAlpha == 0 or (Virtual.RBP_isFriendly and dbp.friendlyClickthrough and RBP.inInstance) or (Virtual.RBP_isBarlessPlate and Virtual.RBP_barlessHideNameText) then
		width, height = 0.01, 0.01
	elseif Virtual.RBP_totemPlateIsShown then
		local size = dbp.totemSize * 1.2 * dbp.globalScale * dynamicScale
		width, height = size, size
	elseif Virtual.RBP_isBarlessPlate then
		local textSize = dbp.barlessPlate_textSize
		width = (2 * textSize + 50) * dbp.globalScale * dynamicScale
		height = (textSize + 5) * dbp.globalScale * dynamicScale
	else
		local scale = dbp.globalScale * dynamicScale
		if Virtual.RBP_isFriendly then
			scale = scale * dbp.friendlyScale
		end
		width = RBP.NP_WIDTH  * dbp.clickboxWidthFactor  * scale
		height = RBP.NP_HEIGHT * dbp.clickboxHeightFactor * scale
	end
	Virtual.RealPlate:SetSize(width, height)
end

local function UpdateClickbox(Virtual)
	if RBP.inCombat then
		UpdateClickboxInCombat(Virtual)
	else
		UpdateClickboxOutOfCombat(Virtual)
	end
end

local function CheckNameplateSize(Plate)
	if nameplateSizeChecked then return end
	nameplateSizeChecked = true
	RBP.NP_WIDTH, RBP.NP_HEIGHT = Plate:GetSize()
	RBP.NP_SCALE = RBP.NP_WIDTH/128
	local healthBar = Plate:GetChildren()
	local NPx, NPy = Plate:GetCenter()
	local HBx, HBy = healthBar:GetCenter()
	if NPy and HBy then
		RBP.HB_CENTER_X, RBP.HB_CENTER_Y = HBx - NPx, HBy - NPy
		RBP.HB_BOTTOMLEFT_X, RBP.HB_BOTTOMLEFT_Y = select(4, healthBar:GetPoint(1))
		RBP.TG_TOP_X, RBP.TG_TOP_Y = select(4,Plate:GetRegions():GetPoint(1))
	else
		RBP.HB_CENTER_X, RBP.HB_CENTER_Y = RBP.HB_CENTER_X * RBP.NP_SCALE, RBP.HB_CENTER_Y * RBP.NP_SCALE
		RBP.HB_BOTTOMLEFT_X, RBP.HB_BOTTOMLEFT_Y = RBP.HB_BOTTOMLEFT_X * RBP.NP_SCALE, RBP.HB_BOTTOMLEFT_Y * RBP.NP_SCALE
		RBP.TG_TOP_X, RBP.TG_TOP_Y = RBP.TG_TOP_X * RBP.NP_SCALE, RBP.TG_TOP_Y * RBP.NP_SCALE
	end
	RBP:UpdateClickboxAttributes()
end

local function SyncFrameLevel(frame, level)
	if frame and frame:GetFrameLevel() ~= level then
		frame:SetFrameLevel(level)
	end
end

local function RefreshFrameLevels(Virtual)
	local base = Virtual:GetFrameLevel()
	SyncFrameLevel(Virtual.RBP_healthBar, base)
	SyncFrameLevel(Virtual.RBP_castBar, base)
	SyncFrameLevel(Virtual.RBP_regionsWrapper, base)
	SyncFrameLevel(Virtual.RBP_totemPlate, base)
	SyncFrameLevel(Virtual.RBP_barlessPlate, base + 1)
end

local function ReactionByPlateColor(r, g, b)
	if r > .99 and g > .99 and b < .01 then
		return 4 -- Neutral
	elseif r < 0.01 and ((g > 0.99 and b < 0.01) or (g < 0.01 and b > 0.99)) then
		return 5 -- Friendly
	else
		return 3 -- Hostile
	end
end

local ClassByPlateColorKey = {
	[000] = "FRIENDLY_PLAYER",
	[019] = "DEATHKNIGHT",
	[058] = "DRUID",
	[089] = "HUNTER",
	[085] = "MAGE",
	[065] = "PALADIN",
	[110] = "PRIEST",
	[106] = "ROGUE",
	[044] = "SHAMAN",
	[057] = "WARLOCK",
	[068] = "WARRIOR",
}

local function UpdatePlateReactionFlags(Virtual, r, g, b, reaction)
	Virtual.RBP_reaction = reaction
	Virtual.RBP_isFriendly = reaction == 5
	Virtual.RBP_classKey = ClassByPlateColorKey[math_floor(r * 10 + g * 100 + b)]
end

local function UpdatePlateFlags(Virtual)
	local r, g, b = Virtual.RBP_healthBar:GetStatusBarColor()
	local reaction = ReactionByPlateColor(r, g, b)
	UpdatePlateReactionFlags(Virtual, r, g, b, reaction)
	Virtual.RBP_hasEliteIcon = Virtual.RBP_eliteIcon:IsShown() and true
	Virtual.RBP_hasBossIcon = Virtual.RBP_bossIcon:IsShown() and true
	Virtual.RBP_levelNumber = tonumber(Virtual.RBP_levelText:GetText())
	Virtual.RBP_nameString = Virtual.RBP_ogNameText:GetText()
	Virtual.RBP_nameText:SetText(Virtual.RBP_nameString)
end

local function ResetPlateFlags(Virtual)
	if RBP.targetedPlate == Virtual.RealPlate then
		RBP.targetedPlate = nil
	end
	Virtual.RBP_isTarget = nil
	Virtual.RBP_reaction = nil
	Virtual.RBP_isFriendly = nil
	Virtual.RBP_classKey = nil
	Virtual.RBP_hasEliteIcon = nil
	Virtual.RBP_hasBossIcon = nil
	Virtual.RBP_levelNumber = nil
	Virtual.RBP_nameString = nil
end

local function GetRaidIconIndex(tex)
	if tex:IsShown() then
		local x, y = tex:GetTexCoord()
		local i = math_floor(4 * x + 16 * y + 1.5)
		if i >= 1 and i <= 8 then
			return i
		end
	end
end

local function UpdateRaidIcon(Virtual)
    local iconIndex = GetRaidIconIndex(Virtual.RBP_raidTargetIcon)
    if Virtual.RBP_raidIconIndex == iconIndex then return end
    Virtual.RBP_raidIconIndex = iconIndex
    if Virtual.RBP_healthBarIsShown and iconIndex and not RBP.dbp.raidTargetIcon_hide then
        Virtual.RBP_raidTargetIcon:SetAlpha(1)
    else
        Virtual.RBP_raidTargetIcon:SetAlpha(0)
    end
    if Virtual.RBP_isBarlessPlate then
        if iconIndex and RBP.dbp.barlessPlate_showRaidTarget then
			Virtual.RBP_barlessPlate_raidTargetIcon:SetTexCoord(Virtual.RBP_raidTargetIcon:GetTexCoord())
            Virtual.RBP_barlessPlate_raidTargetIcon:Show()
        else
            Virtual.RBP_barlessPlate_raidTargetIcon:Hide()
        end
    end
end

local function AddStackablePlate(Plate)
    if StackablePlates[Plate] then return end
    local Data = {xpos = 0, ypos = 0, position = 0, Plate = Plate}
    StackablePlates[Plate] = Data
    StackableCount = StackableCount + 1
    Data.index = StackableCount
    StackableList[StackableCount] = Data
end

local function RemoveStackablePlate(Plate)
    local Data = StackablePlates[Plate]
    if not Data then return end
    local index = Data.index
    local last = StackableList[StackableCount]
    StackableList[index] = last
    last.index = index
    StackableList[StackableCount] = nil
    StackableCount = StackableCount - 1
    StackablePlates[Plate] = nil
end

local function UpdateRefinedPlate(Virtual)
	local dbp = RBP.dbp
	local name = Virtual.RBP_nameString
	local level = Virtual.RBP_levelNumber
	Virtual.RBP_healthBar:SetPoint("BOTTOMLEFT", Virtual, RBP.HB_BOTTOMLEFT_X + dbp.globalOffsetX - RBP.HB_CENTER_X, RBP.HB_BOTTOMLEFT_Y + dbp.globalOffsetY)
	Virtual.RBP_raidIconIndex = GetRaidIconIndex(Virtual.RBP_raidTargetIcon)
	if not level or level >= dbp.levelFilter or Virtual.RBP_hasBossIcon then
		local totemKey = RBP.Totems[name]
		local totemCheck = dbp.TotemsCheck[totemKey]
		local blacklisted = dbp.Blacklist[name]
		if totemCheck or blacklisted then
			------------------------ TotemPlates Handling ------------------------
			if blacklisted and (blacklisted == "" or blacklisted:match("^%s")) then
				blacklisted = nil
			end
			local iconTexture = totemCheck == 1 and ASSETS .. "Icons\\" .. totemKey or blacklisted
			if iconTexture and iconTexture ~= "" and not (Virtual.RBP_isFriendly and dbp.hideFriendlyTotem) then
				if not Virtual.RBP_totemPlate then
					SetupTotemPlate(Virtual) -- Setup TotemPlate on the fly
				end
				Virtual.RBP_totemPlate:Show()
				Virtual.RBP_totemPlateIsShown = true
				Virtual.RBP_totemPlate_icon:SetTexture(iconTexture)
				local healthBarHighlight = Virtual.RBP_healthBarHighlight
				healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\TotemPlate-MouseoverGlow")
				healthBarHighlight:ClearAllPoints()
				local pad = dbp.totemSize * 5/22
				healthBarHighlight:SetPoint("TOPLEFT", Virtual.RBP_totemPlate, -pad, pad)
				healthBarHighlight:SetPoint("BOTTOMRIGHT", Virtual.RBP_totemPlate, pad, -pad)
				if dbp.showTotemBorder then
					Virtual.RBP_totemPlate_border:Show()
					if Virtual.RBP_isFriendly then
						Virtual.RBP_totemPlate_border:SetVertexColor(0, 1, 0)
					else
						Virtual.RBP_totemPlate_border:SetVertexColor(1, 0, 0)
					end
				end
				Virtual:Show()
				Virtual.RBP_isShown = true
				HideVirtualPlateElements(Virtual)
			end	
			Virtual.RBP_threatGlow:SetTexture(nil)	
		else
			local levelText = Virtual.RBP_levelText
			local nameText = Virtual.RBP_nameText
			local raidTargetIcon = Virtual.RBP_raidTargetIcon
			local eliteIcon = Virtual.RBP_eliteIcon
			local bossIcon = Virtual.RBP_bossIcon
			local class = Virtual.RBP_classKey
			Virtual:Show()
			Virtual.RBP_isShown = true
			Virtual.RBP_healthBar:Show()
			Virtual.RBP_regionsWrapper:Show()
			Virtual.RBP_healthBarIsShown = true
			UpdateCastBarSize(Virtual)
			UpdateMouseoverGlow(Virtual)
			SetupThreatGlow(Virtual)
			UpdateHealthBarTex(Virtual)
			if dbp.healthBar_progressiveTexCrop then
				Virtual.RBP_healthBarTexCrop = true				
			end
			if Virtual.RBP_hasBossIcon then
				bossIcon:Show()
				levelText:Hide()
			else
				bossIcon:Hide()
				UpdateLevelText(Virtual)
				levelText:Show()
			end
			if dbp.levelText_hide then
				levelText:Hide()
			end
			if dbp.nameText_hide then
				nameText:Hide()
			else
				nameText:Show()	
			end
			if Virtual.RBP_hasEliteIcon then
				eliteIcon:Show()
			else
				eliteIcon:Hide()
			end
			if Virtual.RBP_raidIconIndex and not dbp.raidTargetIcon_hide then
				raidTargetIcon:SetAlpha(1)
			else
				raidTargetIcon:SetAlpha(0)
			end
			if class then
				if class == "FRIENDLY_PLAYER" then
					bossIcon:Hide()
				elseif not bossIcon:IsShown() and level and level - RBP.playerLevel >= 10 then
					bossIcon:Show()
					levelText:Hide()
				end
				------------------------ Show Arena IDs ------------------------
				if RBP.inArena then
					local ArenaIDText = Virtual.RBP_ArenaIDText
					if class == "FRIENDLY_PLAYER" then
						local partyID = PartyID[name]
						if not partyID then
							UpdateGroupInfo()
							partyID = PartyID[name]
						end
						if partyID then
							Virtual.RBP_unitToken = "party" .. partyID
							if dbp.PartyIDText_show then
								ArenaIDText:SetTextColor(unpack(dbp.PartyIDText_color))
								ArenaIDText:SetText(partyID)
								ArenaIDText:Show()
								if dbp.PartyIDText_HideLevel then
									levelText:Hide()
								end
								if dbp.PartyIDText_HideName then
									nameText:Hide()
								end
							end							
						end
					else
						local arenaID = ArenaID[name]
						if not arenaID then
							UpdateArenaInfo()
							arenaID = ArenaID[name]
						end
						if arenaID then
							Virtual.RBP_unitToken = "arena" .. arenaID
							if dbp.ArenaIDText_show then
								ArenaIDText:SetTextColor(unpack(dbp.ArenaIDText_color))
								ArenaIDText:SetText(arenaID)
								ArenaIDText:Show()
								if dbp.ArenaIDText_HideLevel then
									levelText:Hide()
								end
								if dbp.ArenaIDText_HideName then
									nameText:Hide()
								end
							end
						end
					end
				end
				UpdateClassIcon(Virtual)
				if Virtual.RBP_isFriendly then
					Virtual.RBP_lowHpColoring = dbp.lowHpColor_FriendlyPlayers
				else
					Virtual.RBP_lowHpColoring = dbp.lowHpColor_EnemyPlayers
				end
			else
				if Virtual.RBP_isFriendly then
					Virtual.RBP_lowHpColoring = dbp.lowHpColor_FriendlyNPCs
				else
					Virtual.RBP_lowHpColoring = dbp.lowHpColor_EnemyNPCs
				end
				if dbp.enableAggroColoring and not RBP.inPvPInstance and (RBP.inPvEInstance or not dbp.disableAggroOpenworld) then
					Virtual.RBP_threatGlow:SetTexture(nil)
					Virtual.RBP_aggroColoring = true
				end
			end
			UpdateClassColor(Virtual)
			UpdateHealthTextValue(Virtual.RBP_healthBar)
			UpdateHealthBarColor(Virtual)
			CheckBarlessPlate(Virtual)
			----------------- Init Enhanced Plate Stacking -----------------
			if not hasModernStacking then
				local Plate = Virtual.RealPlate
				local isFriendly = Virtual.RBP_isFriendly
				if dbp.stackingEnabled and (not dbp.stackingInInstance or RBP.inInstance) then
					if not hasLegacyStacking then
						if isFriendly then -- allies never collide: the only thing they can get is the offset
							if dbp.friendlyStackOffset and not Virtual.RBP_isBarlessPlate then
								Virtual.RBP_offsetOnly = true
							end
						elseif dbp.disableCollisions then
							Virtual.RBP_offsetOnly = true
						else
							AddStackablePlate(Plate)
						end
					end
				elseif not isFriendly and not hasLegacyStacking and Virtual.RBP_hasBossIcon and dbp.clampBoss and RBP.inPvEInstance then
					Plate:SetClampedToScreen(true)
					Plate:SetClampRectInsets(80 * dbp.globalScale, -80 * dbp.globalScale, dbp.upperborder, 0)
				end
			end
		end	
	end
	UpdatePlateNonTargetAlpha(Virtual)
end

local function ResetRefinedPlate(Virtual)
	local Plate = Virtual.RealPlate
	Virtual:Hide()
	Virtual.RBP_localScale = RBP.dbp.globalScale
	SetScale(Virtual, Virtual.RBP_localScale)
	Virtual.RBP_levelIdx = nil
	Virtual.RBP_dynamicScale = nil
	Virtual.RBP_regionsAlpha = nil
	Virtual.RBP_virtualAlpha = nil
	Virtual.RBP_pbAlpha = nil
	Virtual.RBP_nonTargetAlpha = nil
	SetAlpha(Virtual, 1)
    Virtual.RBP_regionsWrapper:SetAlpha(1)
    if Virtual.PB_parentFrame then
        Virtual.PB_parentFrame:SetAlpha(1)
    end
    Virtual.PB_stopIconUpdate = nil
	Virtual.RBP_classIcon:Hide()
	Virtual.RBP_ArenaIDText:Hide()
	Virtual.RBP_isShown = nil
	Virtual.RBP_healthBarIsShown = nil
	Virtual.RBP_nameTextIsYellow = nil
	Virtual.RBP_healthBarTexCrop = nil
	Virtual.RBP_raidIconIndex = nil
	Virtual.RBP_lowHpColoring = nil
	Virtual.RBP_aggroColoring = nil
	Virtual.RBP_lowHp = nil
	Virtual.RBP_customColor = nil
	Virtual.RBP_unitToken = nil
	Virtual.RBP_totemPlateIsShown = nil
	if Virtual.RBP_totemPlate then
		Virtual.RBP_totemPlate:Hide()
		Virtual.RBP_totemPlate_border:Hide()
	end
	if Virtual.RBP_barlessPlate then
		Virtual.RBP_barlessPlate:Hide()
	end
	Virtual.RBP_isBarlessPlate = nil
	Virtual.RBP_barlessHideNameText = nil
	Virtual.RBP_barlessPlateIsShown = nil
	Virtual.RBP_BarlessHealthTextIsShown = nil
	Virtual.RBP_barlessNameTextRGB = nil
	Virtual.RBP_barlessNameTextGrayOut = nil
	Virtual.RBP_offsetOnly = nil
	Virtual.RBP_castBarBorder:Hide()
	Virtual.RBP_shieldCastBarBorder:Hide()
	if not hasModernStacking then
		RemoveStackablePlate(Plate)
		if not hasLegacyStacking then
			Plate:SetClampedToScreen(false)
			Plate:SetClampRectInsets(0, 0, 0, 0)
		end
	end
	Virtual.RBP_castText:SetText("")
	if Virtual.BGHframe then
		Virtual.BGHframe:ModifyIcon()
	else
		Virtual.shouldModifyBGH = nil
	end
end

local SortOrder, Depths = {}, {}
local PlatesUpdate
do
	--- Update all visible nameplates
	local depthScaling, depthFading, modifyPerspective, fadePlateBuffs, fadeNPCs, depthPivot
	local minScaleFactor, depthFadeStart, depthFadeRange, depthScaleEnd, depthFadeEnd, depthHideEnd
	local dynamicScale, alpha, virtualAlpha, regionsAlpha, pbAlpha
	function PlatesUpdate(dbp)
		depthScaling = dbp.depthScaling
		depthFading = dbp.depthFading
		modifyPerspective = depthScaling or depthFading
		if modifyPerspective then
			fadePlateBuffs = dbp.fadePlateBuffs
			fadeNPCs = dbp.fadeNPCs
			depthPivot = dbp.depthPivot
			minScaleFactor = dbp.minScaleFactor
			depthFadeStart = dbp.depthFadeStart
			depthFadeRange = dbp.depthFadeRange
			depthScaleEnd = depthPivot / minScaleFactor
			depthFadeEnd = depthFadeStart + depthFadeRange
			depthHideEnd = depthFadeEnd + depthFadeRange
		end
		local mouseoverName = UnitName("mouseover")
		local Depth
		for Plate, Virtual in pairs(PlatesVisible) do
			if Virtual.RBP_isShown then
				Depth = Virtual:GetEffectiveDepth()
				if Depth > 0 then
					----------------------- Improved mouseover highlight -----------------------
					if Virtual.RBP_healthBarHighlight:IsShown() then
						if Virtual.RBP_nameString ~= mouseoverName then
							Virtual.RBP_healthBarHighlight:Hide()
						elseif not Virtual.RBP_nameTextIsYellow then
							Virtual.RBP_nameText:SetTextColor(1, 1, 0)
							Virtual.RBP_nameTextIsYellow  = true
							if Virtual.RBP_castBarIsShown and not Virtual.RBP_castText:GetText() then
								UpdateCastTextString(Virtual, "mouseover")
							end
						end
					elseif Virtual.RBP_nameTextIsYellow then
						Virtual.RBP_nameText:SetTextColor(Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB)
						Virtual.RBP_nameTextIsYellow = false
					end
					-------------------- Depth perception based on camera distance --------------------
					if modifyPerspective then
						if Virtual.RBP_isTarget then
							if depthFading then
								if Virtual.RBP_regionsAlpha ~= 1 then
									Virtual.RBP_regionsAlpha = 1
									Virtual.RBP_regionsWrapper:SetAlpha(1)
								end
								if Virtual.RBP_virtualAlpha ~= 1 then
									local wasHidden = Virtual.RBP_virtualAlpha == 0
									if wasHidden and hasModernStacking then
										Plate:SetStackingEnabled(Virtual.RBP_healthBarIsShown == true and not Virtual.RBP_isBarlessPlate)
									end
									Virtual.RBP_virtualAlpha = 1
									SetAlpha(Virtual, 1)
									if wasHidden and not RBP.inCombat then
										UpdateClickboxOutOfCombat(Virtual)
									end
								end
								if fadePlateBuffs and Virtual.PB_parentFrame and Virtual.RBP_pbAlpha ~= 1 then
									Virtual.RBP_pbAlpha = 1
									Virtual.PB_parentFrame:SetAlpha(1)
									Virtual.PB_stopIconUpdate = nil
								end
							end
							if depthScaling and Virtual.RBP_dynamicScale ~= 1 then
								Virtual.RBP_dynamicScale = 1
								SetVirtualScale(Virtual)
								if not RBP.inCombat then
									UpdateClickboxOutOfCombat(Virtual)
								end
							end
						else
							virtualAlpha = 1
							if depthFading then
								if Depth <= depthFadeStart then
									regionsAlpha, pbAlpha = 1, 1
								elseif Depth <= depthFadeEnd then
									regionsAlpha = (depthFadeEnd - Depth) / depthFadeRange
									pbAlpha = 1
								else
									alpha = (depthHideEnd - Depth) / depthFadeRange
									if alpha < 0 then alpha = 0 end
									regionsAlpha = 0
									if Virtual.RBP_classKey or not fadeNPCs then
										virtualAlpha = 1
									else
										virtualAlpha = alpha
									end
									pbAlpha = alpha
								end
								if Virtual.RBP_regionsAlpha ~= regionsAlpha then
									Virtual.RBP_regionsAlpha = regionsAlpha
									Virtual.RBP_regionsWrapper:SetAlpha(regionsAlpha)
								end
								if Virtual.RBP_virtualAlpha ~= virtualAlpha then
									local crossesZero = virtualAlpha == 0 or Virtual.RBP_virtualAlpha == 0
									if crossesZero and hasModernStacking then
										Plate:SetStackingEnabled(Virtual.RBP_healthBarIsShown == true and not Virtual.RBP_isBarlessPlate and virtualAlpha ~= 0)
									end
									Virtual.RBP_virtualAlpha = virtualAlpha
									SetAlpha(Virtual, virtualAlpha)
									if crossesZero and not RBP.inCombat then
										UpdateClickboxOutOfCombat(Virtual)
									end
								end
								if fadePlateBuffs and Virtual.PB_parentFrame and Virtual.RBP_pbAlpha ~= pbAlpha then
									Virtual.RBP_pbAlpha = pbAlpha
									Virtual.PB_parentFrame:SetAlpha(pbAlpha)
									Virtual.PB_stopIconUpdate = pbAlpha == 0 or nil
								end
							end
							if depthScaling then
								if virtualAlpha == 0 then
									if Virtual.RBP_dynamicScale ~= minScaleFactor then
										Virtual.RBP_dynamicScale = minScaleFactor
										SetVirtualScale(Virtual)
									end
								else
									if Depth <= depthPivot then
										dynamicScale = 1
									elseif Depth >= depthScaleEnd then
										dynamicScale = minScaleFactor
									else
										dynamicScale = depthPivot / Depth
									end
									if Virtual.RBP_dynamicScale ~= dynamicScale then
										Virtual.RBP_dynamicScale = dynamicScale
										SetVirtualScale(Virtual)
										if not RBP.inCombat then
											UpdateClickboxOutOfCombat(Virtual)
										end
									end
								end
							end
						end
					end
					------- Candidates for frame level sorting (non-AwesomeWotlk) -------
					if not hasModernEngine and Virtual.RBP_virtualAlpha ~= 0 then
						SortOrder[#SortOrder + 1] = Virtual
						Depths[Virtual] = Virtual.RBP_isTarget and -1 or Depth
					end
				end
			end
		end
		------- FrameLevels update based on sorting so regions don't overlap -------
		if #SortOrder > 0 then
			sort(SortOrder, function(a, b) return Depths[a] > Depths[b] end)
			for i, Virtual in ipairs(SortOrder) do
				if Virtual.RBP_levelIdx ~= i then
					Virtual.RBP_levelIdx = i
					SetFrameLevel(Virtual, i * PlateLevels)
				end
			end
			wipe(SortOrder)
		end
	end
end

local function PlatesSecUpdate()
	local r, g, b, reaction
	for _, Virtual in pairs(PlatesVisible) do
		r, g, b = Virtual.RBP_healthBar:GetStatusBarColor()
		reaction = ReactionByPlateColor(r, g, b)
		if reaction ~= Virtual.RBP_reaction then
			UpdatePlateReactionFlags(Virtual, r, g, b, reaction)
			ResetRefinedPlate(Virtual)
			UpdateRefinedPlate(Virtual)
			UpdateRefinedPlateDelayed(Virtual)
			if not RBP.inCombat then
				UpdateClickboxOutOfCombat(Virtual)
			end
		end
		if Virtual.RBP_lowHpColoring or Virtual.RBP_aggroColoring then
			UpdateHealthBarColor(Virtual)
		end
	end
end

local function RefreshGroupVisuals()
	for _, Virtual in pairs(PlatesVisible) do
		UpdateClassColor(Virtual)
		UpdateClassIcon(Virtual)
		if Virtual.RBP_isBarlessPlate then
			UpdateBarlessPlate(Virtual)
		end
		UpdateHealthTextValue(Virtual.RBP_healthBar)
		UpdateHealthBarColor(Virtual)
	end
end

local NP_COEF_CONST  = 49.5902306216304
local NP_COEF_LINEAR = 54.5639472689393
local NP_COEF_QUAD   = 3.18253482362832
local function EstimateNameplateSize()
	local w, h = GetScreenWidth(), GetScreenHeight()
	if not w or not h or h == 0 then
		return 128, 32
	end
	local r = w / h
	local width = NP_COEF_CONST + NP_COEF_LINEAR * r + NP_COEF_QUAD * r^2
	local height = width / 4
	return width, height
end

function RBP:OverrideNameplateSize()
	RBP.NP_WIDTH, RBP.NP_HEIGHT = EstimateNameplateSize()
	RBP.NP_SCALE = RBP.NP_WIDTH/128	
end

-- Enlarging of WorldFrame, so that nameplates are displayed even if they are very high up, as is the case with large bosses.
RBP.WorldFrameWidth = WorldFrame:GetWidth()
local function ExtendWorldFrameHeight(shouldExtend)
	WorldFrame:ClearAllPoints()
	WorldFrame:SetPoint("BOTTOM")
	WorldFrame:SetWidth(RBP.WorldFrameWidth)
	WorldFrame:SetHeight(768 * (shouldExtend and 50 or 1))
	-- Override WorldFrame:GetHeight() so Blizzard_CombatText gets the original value
	WorldFrame.GetHeight = function(self)
		return 768
	end
end

-- Retail-like Nameplate Stacking (Adapted from Cheeta's WeakAura)
-- All visible enemy nameplates are iterated and the minimum distance to the next nameplate is determined.
-- If there is no other nameplate in the immediate vicinity of the original position, the position is reset (to prevent the nameplates from rising higher and higher).
-- Depending on whether the position is to be reset or the nameplate is above or below the closest one different functions are used for a smooth movement.
local delta = 3
local function UpdateStacking(dbp, elapsed)
	if dbp.stackingInInstance and not RBP.inInstance and not hasLegacyStacking then return end
	if hasLegacyStacking and not (dbp.clampTarget or dbp.clampBoss) then return end
	local originY = dbp.originpos
	local clampTop = dbp.upperborder
	local clampTarget = dbp.clampTarget
	local clampBoss = dbp.clampBoss
	local inPvEInstance = RBP.inPvEInstance
	local globalScale = dbp.globalScale
	local hideInset = -1.5 * RBP.NP_HEIGHT * globalScale * dbp.targetScale
	if hasLegacyStacking then
		originY = tonumber(GetCVar("nameplateOriginPos")) or 0
		for Plate, Virtual in pairs(PlatesVisible) do
			local _, _, _, _, y = Plate:GetPoint(1)
			local width, height = Plate:GetSize()
			local halfW = width * 0.5
			local bottomInset = -y - originY + height * 0.5
			Plate:SetClampedToScreen(true)
			if (Virtual.RBP_isTarget and clampTarget) or (Virtual.RBP_hasBossIcon and clampBoss and inPvEInstance) then
				Plate:SetClampRectInsets(halfW, -halfW, clampTop, bottomInset)
			else
				Plate:SetClampRectInsets(halfW, -halfW, hideInset, bottomInset)
			end
		end
		return
	end
	local disableCollisions = dbp.disableCollisions
	if disableCollisions or dbp.friendlyStackOffset then
		for Plate, Virtual in pairs(PlatesVisible) do
			if Virtual.RBP_offsetOnly then
				local _, _, _, _, y = Plate:GetPoint(1)
				local width, height = Plate:GetSize()
				local halfW = width * 0.5
				local bottomInset = -y - originY + height
				Plate:SetClampedToScreen(true)
				if (Virtual.RBP_isTarget and clampTarget) or (Virtual.RBP_hasBossIcon and clampBoss and inPvEInstance) then
					Plate:SetClampRectInsets(halfW, -halfW, clampTop, bottomInset)
				else
					Plate:SetClampRectInsets(halfW, -halfW, hideInset, bottomInset)
				end
			end
		end
	end
	if disableCollisions then return end
	if StackableCount == 0 then return end
	local dt = elapsed or 0.016
	if dt > 0.05 then dt = 0.05 end
	local step = dbp.yspeed * dt
	local colliderW = dbp.xspace * globalScale
	local colliderH = dbp.yspace * globalScale
	local freeze = dbp.FreezeMouseover
	local worldWidth = RBP.WorldFrameWidth
	local negWorldWidth = -2 * worldWidth
	local hasCollisions = StackableCount > 1
	for i = 1, StackableCount do
		local Data1 = StackableList[i]
		local Plate1 = Data1.Plate
		local Virtual1 = Plate1.VirtualPlate
		local _, _, _, x, y = Plate1:GetPoint(1)
		local width, height = Plate1:GetSize()
		local halfWidth = width * 0.5
		local negHalfWidth = -halfWidth
		Data1.xpos = x
		Data1.ypos = y
		Plate1:SetClampedToScreen(true)
		if freeze and Virtual1.RBP_healthBarHighlight:IsShown() then -- Freeze Mouseover Nameplate
			local cx, cy = Plate1:GetCenter() -- actual visual center (GetPoint returns the anchor)
			local halfPlateHeight = height * 0.5
			Data1.position = cy - y - originY + halfPlateHeight
			Data1.xpos = cx
			Plate1:SetClampRectInsets(negWorldWidth, worldWidth - cx - halfWidth, 768 - cy - halfPlateHeight, -1536)
		else
			local gapAbove = 1000
			local isolated = true
			local offset = Data1.position or 0
			if offset < 0 then offset = 0 end
			local effY = y + offset
			if hasCollisions then
				for j = 1, StackableCount do
					if i ~= j then
						local Data2 = StackableList[j]
						local dx = x - Data2.xpos
						if dx > -colliderW and dx < colliderW then -- only consider plates within collider width
							local peerY = Data2.ypos + Data2.position
							local dy = effY - peerY
							if dy >= 0 and dy < gapAbove then -- track closest plate below this one
								gapAbove = dy
							end
							local baseGap = y - peerY
							if baseGap < colliderH and baseGap > -colliderH then
								isolated = false -- no reset if nameplate near origin position
							end
						end
					end
				end
			end
			local newOffset = offset
			if offset >= delta and isolated then -- reset
				newOffset = offset - math_exp(-10 / offset) * step
			elseif gapAbove < colliderH then -- raise
				newOffset = offset + math_exp(-gapAbove / colliderH) * step
			elseif offset >= delta and gapAbove > colliderH + delta then -- lower
				newOffset = offset - math_exp(-colliderH / gapAbove) * step
			end
			Data1.position = newOffset
			local bottomInset = -y - newOffset - originY + height
			if (Virtual1.RBP_isTarget and clampTarget) or (Virtual1.RBP_hasBossIcon and clampBoss and inPvEInstance) then
				Plate1:SetClampRectInsets(halfWidth, negHalfWidth, clampTop, bottomInset)
			else
				Plate1:SetClampRectInsets(halfWidth, negHalfWidth, hideInset, bottomInset)
			end
		end
	end
end

local function PlateOnShow(Plate)
	local Virtual = Plate.VirtualPlate
	PlatesVisible[Plate] = Virtual
	ExistsVisiblePlates = true
	RefreshFrameLevels(Virtual)
	UpdatePlateFlags(Virtual)
	UpdateRefinedPlate(Virtual)
	UpdateRefinedPlateDelayed(Virtual)
	UpdateClickbox(Virtual)
	NextUpdate = 0
end

local function PlateOnHide(Plate)
	local Virtual = Plate.VirtualPlate
	PlatesVisible[Plate] = nil
	ExistsVisiblePlates = next(PlatesVisible) ~= nil
	ResetPlateFlags(Virtual)
	ResetRefinedPlate(Virtual)
	if RBP.hasComboPoints and RBP.dbp.comboPoints_enable then
		ClearComboPlate(Virtual)
	end
	Plate.namePlateUnitToken = nil
	Virtual.namePlateUnitToken = nil
	if RBP.inCombat then
		ExecuteClickboxSecureScript()
	end
end

local MainUpdater = CreateFrame("Frame")
MainUpdater:SetScript("OnUpdate", function(self, elapsed)
	if not ExistsVisiblePlates then return end
	local dbp = RBP.dbp
	if dbp.modNonTargetAlpha and not hasAlphaOverride and RBP.hasTarget then
		UpdateNonTargetAlpha()
	end
	if dbp.stackingEnabled and not hasModernStacking then
		UpdateStacking(dbp, elapsed)
	end
	NextUpdate = NextUpdate - elapsed
	if NextUpdate <= 0 then
		NextUpdate = UpdateRate
		PlatesUpdate(dbp)
	end
	NextSecUpdate = NextSecUpdate - elapsed
	if NextSecUpdate <= 0 then
		NextSecUpdate = SecUpdateRate
		PlatesSecUpdate()
	end
end)

---------------------------------------- Settings Update Functions ----------------------------------------
function RBP:UpdateAllVirtualsScale()
	for _, Virtual in pairs(VirtualPlates) do
		UpdateLocalScale(Virtual)
		SetVirtualScale(Virtual)
		if not self.inCombat then
			UpdateClickboxOutOfCombat(Virtual)
		end
	end
end

function RBP:UpdateAllTexts()
	for _, Virtual in pairs(VirtualPlates) do
		UpdateNameText(Virtual)
		UpdateLevelText(Virtual)
		UpdateArenaIDText(Virtual)
	end
end

function RBP:UpdateAllHealthBars()
	local dbp = RBP.dbp
	for _, Virtual in pairs(VirtualPlates) do
		UpdateHealthBorder(Virtual)
		UpdateHealthText(Virtual)
		UpdateHealthBarBg(Virtual)
		if dbp.healthText_hide then
			Virtual.RBP_healthText:Hide()
		else
			Virtual.RBP_healthText:Show()
		end
		if Virtual.RBP_healthBarIsShown and dbp.healthBar_progressiveTexCrop then
			Virtual.RBP_healthBarTexCrop = true
		else
			Virtual.RBP_healthBarTexCrop = nil
		end
		UpdateHealthTextValue(Virtual.RBP_healthBar)
	end
end

function RBP:UpdateAllCastBars()
	local dbp = RBP.dbp
	for _, Virtual in pairs(VirtualPlates) do
		if Virtual.RBP_channelingFlag == 1 then
			Virtual.RBP_castBarTex:SetVertexColor(unpack(dbp.castBar_channelingColor))
		else
			Virtual.RBP_castBarTex:SetVertexColor(unpack(dbp.castBar_color))
		end
		Virtual.RBP_castBarTex:SetTexture(RBP.LSM:Fetch("statusbar", dbp.castBar_Tex))
		Virtual.RBP_castBarTexFull:SetTexture(RBP.LSM:Fetch("statusbar", dbp.castBar_Tex))
		UpdateCastBarArt(Virtual)
		UpdateCastBarBg(Virtual)
		UpdateCastText(Virtual)
		UpdateCastTimer(Virtual)
		if dbp.castText_hide then
			Virtual.RBP_castText:Hide()
		else
			Virtual.RBP_castText:Show()
		end
		if dbp.castTimerText_hide then
			Virtual.RBP_castTimerText:Hide()
		elseif Virtual.RBP_castBarIsShown and Virtual.RBP_castText:GetText() then
			Virtual.RBP_castTimerText:Show()
		else
			Virtual.RBP_castTimerText:Hide()
		end
		if dbp.castBar_showSpark then
			Virtual.RBP_castSpark:Show()
		else
			Virtual.RBP_castSpark:Hide()
		end
		if Virtual.RBP_castBarIsShown and dbp.castBar_progressiveTexCrop then
			Virtual.RBP_castBarTexCrop = true
		else
			Virtual.RBP_castBarTexCrop = nil
		end
	end
end

function RBP:UpdateAllCastBarBorders()
	for _, Virtual in pairs(VirtualPlates) do
		UpdateCastBarArt(Virtual)
	end
end

function RBP:UpdateAllIcons()
	for _, Virtual in pairs(VirtualPlates) do
		SetupBossIcon(Virtual)
		SetupRaidTargetIcon(Virtual)
		SetupEliteIcon(Virtual)
		SetupClassIcon(Virtual)
		SetupTotemIcon(Virtual)
		UpdateBarlessPlate(Virtual)
	end
	self:UpdateComboPointsSettings()
end

function RBP:UpdateAllBarlessPlates()
	for _, Virtual in pairs(VirtualPlates) do
		UpdateBarlessPlate(Virtual)
	end
end

function RBP:UpdateAllNonTargetAlpha()
	for _, Virtual in pairs(PlatesVisible) do
		UpdatePlateNonTargetAlpha(Virtual)
	end
end

function RBP:UpdateAllGlows()
	for _, Virtual in pairs(VirtualPlates) do
		UpdateTargetGlow(Virtual)
		UpdateMouseoverGlow(Virtual)
		SetupThreatGlow(Virtual)
		if Virtual.RBP_totemPlate_targetGlow then
			Virtual.RBP_totemPlate_targetGlow:SetVertexColor(unpack(RBP.dbp.targetGlow_Color))
		end
	end
end

function RBP:ResetDynamicScales()
	for _, Virtual in pairs(VirtualPlates) do
		Virtual.RBP_dynamicScale = nil
	end
end

function RBP:ResetAllRegionsAlpha()
	for _, Virtual in pairs(VirtualPlates) do
		SetAlpha(Virtual, 1)
		Virtual.RBP_regionsWrapper:SetAlpha(1)
		Virtual.RBP_regionsAlpha = nil
		if hasModernStacking and Virtual.RBP_virtualAlpha == 0 then
			Virtual.RealPlate:SetStackingEnabled(Virtual.RBP_healthBarIsShown == true and not Virtual.RBP_isBarlessPlate)
		end
		Virtual.RBP_virtualAlpha = nil
	end
end

function RBP:ResetPBFlags()
	for _, Virtual in pairs(VirtualPlates) do
		if Virtual.PB_parentFrame then
			Virtual.PB_parentFrame:SetAlpha(1)
		end
		Virtual.RBP_pbAlpha = nil
		Virtual.PB_stopIconUpdate = nil
	end
end

function RBP:UpdateWorldFrameHeight(init)
	if hasModernStacking then return end
	local dbp = RBP.dbp
	self.WorldFrameWidth = WorldFrame:GetWidth()
	if dbp.clampTarget or dbp.clampBoss then
		ExtendWorldFrameHeight(true)
	elseif not init then
		ExtendWorldFrameHeight(false)
	end
end

function RBP:UpdateAllShownPlates()
	for _, Virtual in pairs(PlatesVisible) do
		ResetRefinedPlate(Virtual)
		UpdateRefinedPlate(Virtual)
		UpdateRefinedPlateDelayed(Virtual)
		if not RBP.inCombat then
			UpdateClickboxOutOfCombat(Virtual)
		end
	end
end

function RBP:UpdateClickboxAttributes()
	if not self.inCombat then
		ClickboxAttributeUpdater()
	else
		self.delayedClickboxUpdate = true
	end
end

function RBP:UpdateCVars()
	local dbp = RBP.dbp
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("showVKeyCastbar", 1)
	if not hasModernStacking and dbp.stackingEnabled then
		SetCVar("nameplateAllowOverlap", 1)
	end
	if dbp.enableAggroColoring then
		if dbp.disableAggroOpenworld then
			SetCVar("threatWarning", 1)
		else
			SetCVar("threatWarning", 3)
		end
	end
	if hasLegacyStacking then
		SetCVar("nameplateStackFriendlyMode", 0)
		SetCVar("nameplateHitboxHeight", 0)
		SetCVar("nameplateHitboxWidth", 0)
		SetCVar("nameplateFriendlyHitboxHeight", 0)
		SetCVar("nameplateFriendlyHitboxWidth", 0)
	end
end

function RBP:ApplyStyle()
	self:UpdateAllHealthBars()
	self:UpdateAllCastBars()
	self:UpdateAllIcons()
	self:UpdateAllGlows()
	self:UpdateAllShownPlates()
end

function RBP:UpdateProfile()
	self:UpdateCVars()
	self:UpdateLDWfix()
	self:ResetDynamicScales()
	self:ResetAllRegionsAlpha()
	self:ResetPBFlags()
	self:UpdateAllVirtualsScale()
	self:UpdateAllTexts()
	self:UpdateAllBarlessPlates()
	self:UpdateAllHealthBars()
	self:UpdateAllCastBars()
	self:UpdateAllCastBarBorders()
	self:UpdateAllIcons()
	self:UpdateAllGlows()
	self:BuildBlacklistUI()
	self:UpdateAllClickboxTextures()
	self:UpdateClickboxesDriver()
	self:UpdateWorldFrameHeight()
	self:UpdateAllShownPlates()
	self:UpdateClickboxAttributes()
end

----------- Reference for Core.lua -----------
RBP.EventHandler = EventHandler
RBP.VirtualPlates = VirtualPlates
RBP.PlatesVisible = PlatesVisible
RBP.PlateOverrides = PlateOverrides
RBP.SetupRefinedPlate = SetupRefinedPlate
RBP.ForceLevelHide = ForceLevelHide
RBP.CheckLDWZoneIndoors = CheckLDWZoneIndoors
RBP.CheckDominateMind = CheckDominateMind
RBP.UpdateGroupInfo = UpdateGroupInfo
RBP.UpdateArenaInfo = UpdateArenaInfo
RBP.ExecuteClickboxSecureScript = ExecuteClickboxSecureScript
RBP.InitPlatesClickboxes = InitPlatesClickboxes
RBP.ClickboxAttributeUpdater = ClickboxAttributeUpdater
RBP.UpdateClickboxOutOfCombat = UpdateClickboxOutOfCombat
RBP.CheckNameplateSize = CheckNameplateSize
RBP.RefreshGroupVisuals = RefreshGroupVisuals
RBP.UpdateRaidIcon = UpdateRaidIcon
RBP.UpdateComboPoints = UpdateComboPoints
RBP.PlateOnShow = PlateOnShow
RBP.PlateOnHide = PlateOnHide
