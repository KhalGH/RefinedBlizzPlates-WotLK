
local AddonFile, RBP = ... -- namespace

----------------------------- API -----------------------------
local ipairs, unpack, tonumber, tostring, select, math_exp, math_floor, math_abs, string_format, string_char, string_sub, table_insert, SetCVar, wipe, WorldFrame, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, UnitDebuff, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, RAID_CLASS_COLORS, SetMapToCurrentZone, GetCurrentMapAreaID, GetSubZoneText, SecureHandlerWrapScript, ToggleFrame, UIPanelWindows, SetUIVisibility =
      ipairs, unpack, tonumber, tostring, select, math.exp, math.floor, math.abs, string.format, string.char, string.sub, table.insert, SetCVar, wipe, WorldFrame, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, UnitDebuff, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, RAID_CLASS_COLORS, SetMapToCurrentZone, GetCurrentMapAreaID, GetSubZoneText, SecureHandlerWrapScript, ToggleFrame, UIPanelWindows, SetUIVisibility

------------------------- Core Variables -------------------------
local NP_WIDTH = 156.65118520899  -- Nameplate original width (don't modify)
local NP_HEIGHT = 39.162796302247 -- Nameplate original height (don't modify)
local VirtualPlates = {}          -- Storage table: Virtual nameplate frames
local PlatesVisible = {}          -- Storage table: currently active nameplates
local StackablePlates = {}        -- Storage table: Plates filtered for improved stacking
local ClassByFriendName = {}      -- Storage table: maps friendly player names (party/raid) to their class
local ArenaID = {}                -- Storage table: maps arena names to their ID number
local PartyID = {}                -- Storage table: maps party names to their ID number
local ASSETS = "Interface\\AddOns\\" .. AddonFile .. "\\Assets\\"

------------------------- Customization Functions -------------------------
local function InitBarTextures(Virtual)
	Virtual.healthBarTex:SetDrawLayer("BORDER")
	Virtual.castBarBorder:SetTexture(ASSETS .. "PlateRegions\\CastBar-Border")
	Virtual.shieldCastBarBorder:SetTexture(ASSETS .. "PlateRegions\\CastBar-ShieldBorder")
	Virtual.castBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.castBar_Tex))
	Virtual.castBarTex:SetDrawLayer("BORDER")
	Virtual.spellIcon:SetDrawLayer("BORDER")
	Virtual.ogHealthBarBorder:Hide()
	Virtual.ogNameText:Hide()
end

local function SetupThreatGlow(Virtual)
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.threatGlow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
	else
		Virtual.threatGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-ThreatGlow")
	end
end

local function UpdateHealthBorder(Virtual)
	if not Virtual.healthBarBorder then return end
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.healthBarBorder:SetTexture("Interface\\Tooltips\\Nameplate-Border")
	else
		Virtual.healthBarBorder:SetTexture(ASSETS .. "PlateRegions\\HealthBar-Border")		
	end
	Virtual.healthBarBorder:SetVertexColor(unpack(RBP.dbp.healthBar_borderTint))
end

local function SetupHealthBorder(Virtual)
	if Virtual.healthBarBorder then return end
	Virtual.healthBarBorder = Virtual.healthBar:CreateTexture(nil, "ARTWORK")
	Virtual.healthBarBorder:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
	Virtual.healthBarBorder:SetPoint("CENTER", 10.5, 9)
	UpdateHealthBorder(Virtual)
end

local function SetupHealthBarBackground(Virtual)
	if Virtual.healthBarBackground then return end 
	Virtual.healthBarBackground = Virtual.healthBar:CreateTexture(nil, "BACKGROUND")
	local healthBarBackground = Virtual.healthBarBackground
	healthBarBackground:SetTexture(ASSETS .. "PlateRegions\\NamePlate-Background")
	healthBarBackground:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
	healthBarBackground:SetPoint("CENTER", 10.5, 9)
end

local function UpdateCastBarBackground(Virtual)
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.castBarBackground:SetSize(158, 36)
	else
		Virtual.castBarBackground:SetSize(145, 36)
	end
end

local function SetupCastBarBackground(Virtual)
	if Virtual.castBarBackground then return end
	Virtual.castBarBackground = Virtual.castBar:CreateTexture(nil, "BACKGROUND")
	local castBarBackground = Virtual.castBarBackground
	castBarBackground:SetTexture(ASSETS .. "PlateRegions\\NamePlate-Background")
	castBarBackground:SetPoint("CENTER", 10.5, 9)
	UpdateCastBarBackground(Virtual)
end

local function UpdateNameText(Virtual)
	local nameText = Virtual.newNameText
	if not nameText then return end
	nameText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.nameText_font), RBP.dbp.nameText_size, RBP.dbp.nameText_outline)
	nameText:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		if RBP.dbp.nameText_anchor == "CENTER" then
			nameText:SetPoint(RBP.dbp.nameText_anchor, RBP.dbp.nameText_offsetX + 11.2, RBP.dbp.nameText_offsetY + 17.7)
		else
			nameText:SetPoint(RBP.dbp.nameText_anchor, RBP.dbp.nameText_offsetX + 0.2, RBP.dbp.nameText_offsetY + 0.7)
		end
	else
		nameText:SetPoint(RBP.dbp.nameText_anchor, RBP.dbp.nameText_offsetX + 0.2, RBP.dbp.nameText_offsetY + 0.7)
	end
	nameText:SetWidth(RBP.dbp.nameText_width)
	nameText:SetJustifyH(RBP.dbp.nameText_anchor)
	nameText:SetTextColor(unpack(RBP.dbp.nameText_color))
end

local function SetupNameText(Virtual)
	if Virtual.newNameText then return end
	Virtual.newNameText = Virtual.healthBar:CreateFontString(nil, "OVERLAY")
	local nameText = Virtual.newNameText
	nameText:SetShadowOffset(0.5, -0.5)
	nameText:SetNonSpaceWrap(false)
	nameText:SetWordWrap(false)
	nameText:Hide()
	UpdateNameText(Virtual)
end

local function SetupLevelText(Virtual)
	if not Virtual.levelText then return end
	local levelText = Virtual.levelText
	levelText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.levelText_font), RBP.dbp.levelText_size, RBP.dbp.levelText_outline)
	levelText:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		if RBP.dbp.levelText_anchor == "Left" then
			levelText:SetPoint("CENTER", Virtual.healthBar, "LEFT", RBP.dbp.levelText_offsetX - 13.5, RBP.dbp.levelText_offsetY + 0.3)
		elseif RBP.dbp.levelText_anchor == "Center" then
			levelText:SetPoint("CENTER", Virtual.healthBar, "CENTER", RBP.dbp.levelText_offsetX + 11, RBP.dbp.levelText_offsetY + 0.3)
		else
			levelText:SetPoint("CENTER", Virtual.healthBar, "RIGHT", RBP.dbp.levelText_offsetX + 11.2, RBP.dbp.levelText_offsetY + 0.3)
		end
	else
		if RBP.dbp.levelText_anchor == "Left" then
			levelText:SetPoint("CENTER", Virtual.healthBar, "LEFT", RBP.dbp.levelText_offsetX - 10 , RBP.dbp.levelText_offsetY + 0.3)
		elseif RBP.dbp.levelText_anchor == "Center" then
			levelText:SetPoint("CENTER", Virtual.healthBar, "CENTER", RBP.dbp.levelText_offsetX, RBP.dbp.levelText_offsetY + 0.3)
		else
			levelText:SetPoint("CENTER", Virtual.healthBar, "RIGHT", RBP.dbp.levelText_offsetX + 10, RBP.dbp.levelText_offsetY + 0.3)
		end
	end
end

local function UpdateArenaIDText(Virtual)
	local ArenaIDText = Virtual.ArenaIDText
	ArenaIDText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.ArenaIDText_font), RBP.dbp.ArenaIDText_size, RBP.dbp.ArenaIDText_outline)
	ArenaIDText:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		if RBP.dbp.ArenaIDText_anchor == "Left" then
			ArenaIDText:SetPoint("CENTER", Virtual.healthBar, "LEFT", RBP.dbp.ArenaIDText_offsetX - 8, RBP.dbp.ArenaIDText_offsetY + 0.4)
		elseif RBP.dbp.ArenaIDText_anchor == "Center" then
			ArenaIDText:SetPoint("CENTER", Virtual.healthBar, "CENTER", RBP.dbp.ArenaIDText_offsetX + 11, RBP.dbp.ArenaIDText_offsetY + 0.4)
		else
			ArenaIDText:SetPoint("CENTER", Virtual.healthBar, "RIGHT", RBP.dbp.ArenaIDText_offsetX + 12, RBP.dbp.ArenaIDText_offsetY + 0.4)
		end
	else
		if RBP.dbp.ArenaIDText_anchor == "Left" then
			ArenaIDText:SetPoint("CENTER", Virtual.healthBar, "LEFT", RBP.dbp.ArenaIDText_offsetX - 8, RBP.dbp.ArenaIDText_offsetY + 0.4)
		elseif RBP.dbp.ArenaIDText_anchor == "Center" then
			ArenaIDText:SetPoint("CENTER", Virtual.healthBar, "CENTER", RBP.dbp.ArenaIDText_offsetX, RBP.dbp.ArenaIDText_offsetY + 0.4)
		else
			ArenaIDText:SetPoint("CENTER", Virtual.healthBar, "RIGHT", RBP.dbp.ArenaIDText_offsetX + 8, RBP.dbp.ArenaIDText_offsetY + 0.4)
		end
	end
end

local function SetupArenaIDText(Virtual)
	if Virtual.ArenaIDText then return end
	Virtual.ArenaIDText = Virtual.healthBar:CreateFontString(nil, "OVERLAY")
	local ArenaIDText = Virtual.ArenaIDText
	ArenaIDText:SetShadowOffset(0.5, -0.5)
	ArenaIDText:Hide()
	UpdateArenaIDText(Virtual)
end

local function UpdateBarlessHealthText(healthText, percent)
    local r, g, b = 1, 1, 0
    if percent <= 15 then
        g = 0
    elseif percent < 60 then
        g = (percent - 15) / 45
    else
        r = 1 - (percent - 60) / 40
    end
    healthText:SetText("<" .. percent .. "%>")
    healthText:SetTextColor(r, g, b)
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

local grayColor = {0.35, 0.35, 0.35}

local function MixColor(original, grayFraction)
	return {
		original[1] * (1 - grayFraction) + grayColor[1] * grayFraction,
		original[2] * (1 - grayFraction) + grayColor[2] * grayFraction,
		original[3] * (1 - grayFraction) + grayColor[3] * grayFraction
	}
end

local function UpdateBarlessNameText(Plate, percent)
	local name = Plate.nameString
	local nameLen = utf8len(name)
	if nameLen > 0 then
		local chars = utf8chars(name)
		local grayLength = nameLen * (100 - percent) / 100
		local grayCountFloor = math_floor(grayLength)
		local grayFraction = grayLength - grayCountFloor
		local i_start = nameLen - grayCountFloor + 1
		local coloredText = ""
		for i = 1, nameLen do
			local charColor
			if i >= i_start then
				charColor = grayColor
			elseif i == i_start - 1 and grayFraction > 0 then
				charColor = MixColor(Plate.barlessNameTextRGB, grayFraction)
			else
				charColor = Plate.barlessNameTextRGB
			end
			coloredText = coloredText .. string_format("|cff%02x%02x%02x%s|r", math_floor(charColor[1] * 255), math_floor(charColor[2] * 255), math_floor(charColor[3] * 255), chars[i])
		end
		Plate.barlessPlate_nameText:SetText(coloredText)
	end
end

local function UpdateHealthTextValue(healthBar, value)
	local Plate = healthBar.RealPlate
	local Virtual = Plate.VirtualPlate
	local min, max = healthBar:GetMinMaxValues()
	if max > 0 then
		local val = value or healthBar:GetValue()
		local percent = val / max
		if Virtual.healthBarIsShown then
			if Virtual.healthBarTexCrop then
				Virtual.healthBarTex:SetTexCoord(0, percent, 0, 1)
			else
				Virtual.healthBarTex:SetTexCoord(0, 1, 0, 1)
			end
			if Virtual.aggroColoring then
				Virtual.aggroOverlay:SetTexCoord(0, percent, 0, 1)
			end
		end
		percent = math_floor(percent * 100)
		if percent < 100 and percent > 0 then
			Virtual.healthText:SetText(percent .. "%")
			if Plate.BarlessHealthTextIsShown then
				UpdateBarlessHealthText(Plate.barlessPlate_healthText, percent)
			end
		else
			Virtual.healthText:SetText("")
			if Plate.BarlessHealthTextIsShown then 
				Plate.barlessPlate_healthText:SetText("")
			end
		end
		if Plate.barlessNameTextGrayOut and Plate.barlessPlateIsShown then
			UpdateBarlessNameText(Plate, percent)
		end
	else
		Virtual.healthText:SetText("")
		if Plate.BarlessHealthTextIsShown then
			Plate.barlessPlate_healthText:SetText("")
		end
		if Plate.barlessNameTextGrayOut and Plate.barlessPlateIsShown then
			UpdateBarlessNameText(Plate, 0)
		end
	end
end

local function UpdateHealthText(Virtual)
	if not Virtual.healthText then return end
	local healthText = Virtual.healthText
	healthText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.healthText_font), RBP.dbp.healthText_size, RBP.dbp.healthText_outline)
	healthText:ClearAllPoints()
	healthText:SetPoint(RBP.dbp.healthText_anchor, RBP.dbp.healthText_offsetX, RBP.dbp.healthText_offsetY + 0.3)
	healthText:SetTextColor(unpack(RBP.dbp.healthText_color))
end

local function SetupHealthText(Virtual)
	if Virtual.healthText then return end
	Virtual.healthText = Virtual.healthBar:CreateFontString(nil, "OVERLAY")
	local healthText = Virtual.healthText
	healthText:SetShadowOffset(0.5, -0.5)
	UpdateHealthText(Virtual)
	local healthBar = Virtual.healthBar
	UpdateHealthTextValue(healthBar)
	healthBar:HookScript("OnValueChanged", UpdateHealthTextValue)
	healthBar:HookScript("OnShow", UpdateHealthTextValue)
	if RBP.dbp.healthText_hide then
		healthText:Hide()
	end
end

local function UpdateTargetGlow(Virtual)
	if not Virtual.targetGlow then return end
	local targetGlow = Virtual.targetGlow
	targetGlow:SetVertexColor(unpack(RBP.dbp.targetGlow_Tint))
	targetGlow:SetAlpha(RBP.dbp.targetGlow_Alpha)
	if RBP.dbp.healthBar_border == "Blizzard" then
		targetGlow:SetSize(RBP.NP_WIDTH * 1.165, RBP.NP_HEIGHT)
		targetGlow:SetPoint("CENTER", 11.33, 0.5)
		if RBP.dbp.showTargetGlowBorder then
			targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-TargetGlowBlizz")
		else
			targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MinimalistTargetGlowBlizz")
		end
	else
		targetGlow:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
		targetGlow:SetPoint("CENTER", 0.7, 0.5)
		if RBP.dbp.showTargetGlowBorder then
			targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-TargetGlow")
		else
			targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MinimalistTargetGlow")
		end
	end
end

local function SetupTargetGlow(Virtual)
	if Virtual.targetGlow then return end
	Virtual.targetGlow = Virtual.healthBar:CreateTexture(nil, "OVERLAY")
	Virtual.targetGlow:Hide()
	UpdateTargetGlow(Virtual)
end

local function UpdateMouseoverGlow(Virtual)
	local healthBarHighlight = Virtual.healthBarHighlight
	healthBarHighlight:SetVertexColor(unpack(RBP.dbp.mouseoverGlow_Tint))
	healthBarHighlight:SetAlpha(RBP.dbp.mouseoverGlow_Alpha)
	healthBarHighlight:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		healthBarHighlight:SetSize(RBP.NP_WIDTH * 1.165, RBP.NP_HEIGHT)
		healthBarHighlight:SetPoint("CENTER", 11.83 + RBP.dbp.globalOffsetX, -8.7 + RBP.dbp.globalOffsetY)
		if RBP.dbp.showMouseoverGlowBorder then
			healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MouseoverGlowBlizz")
		else
			healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MinimalistMouseoverGlowBlizz")
		end
	else
		healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MouseoverGlow")
		healthBarHighlight:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
		healthBarHighlight:SetPoint("CENTER", 1.2 + RBP.dbp.globalOffsetX, -8.7 + RBP.dbp.globalOffsetY)
		if RBP.dbp.showMouseoverGlowBorder then
			healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MouseoverGlow")
		else
			healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MinimalistMouseoverGlow")
		end
	end	
end

local function UpdateCastText(Virtual)
	if not Virtual.castText then return end
	local castText = Virtual.castText
	castText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.castText_font), RBP.dbp.castText_size, RBP.dbp.castText_outline)
	castText:SetTextColor(unpack(RBP.dbp.castText_color))
	castText:SetJustifyH(RBP.dbp.castText_anchor)
	castText:SetWidth(RBP.dbp.castText_width)
	castText:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		castText:SetPoint(RBP.dbp.castText_anchor, RBP.dbp.castText_offsetX - 8.5, RBP.dbp.castText_offsetY + 0.7)
	else
		castText:SetPoint(RBP.dbp.castText_anchor, RBP.dbp.castText_offsetX - 8.5, RBP.dbp.castText_offsetY + 1)
	end
end

local function SetupCastText(Virtual)
	if Virtual.castText then return end
	Virtual.castText = Virtual.castBar:CreateFontString(nil, "OVERLAY")
	local Plate = Virtual.RealPlate
	local castText = Virtual.castText
	castText:SetNonSpaceWrap(false)
	castText:SetWordWrap(false)
	castText:SetShadowOffset(0.5, -0.5)
	UpdateCastText(Virtual)
	castText:SetText("")
	if RBP.dbp.castText_hide then
		castText:Hide()
	end
end

local function UpdateCastTimer(Virtual)
	local castTimerText = Virtual.castTimerText
	castTimerText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.castTimerText_font), RBP.dbp.castTimerText_size, RBP.dbp.castTimerText_outline)
	castTimerText:SetTextColor(unpack(RBP.dbp.castTimerText_color))
	castTimerText:ClearAllPoints()
	castTimerText:SetPoint(RBP.dbp.castTimerText_anchor, RBP.dbp.castTimerText_offsetX - 3, RBP.dbp.castTimerText_offsetY + 1)
end

local function SetupCastTimer(Virtual)
	if Virtual.castTimerText then return end
	Virtual.castTimerText = Virtual.castBar:CreateFontString(nil, "OVERLAY")
	local castTimerText = Virtual.castTimerText
	castTimerText:SetShadowOffset(0.5, -0.5)
	castTimerText:Hide()
	UpdateCastTimer(Virtual)
end

local function UpdateCastTextString(Virtual, unit)
	if unit then
		local spellCasting = UnitCastingInfo(unit)
		local spellChanneling = UnitChannelInfo(unit)
		local spellName
		if spellChanneling then
			Virtual.castBarChanneling = true
			spellName = spellChanneling
		elseif spellCasting then
			Virtual.castBarChanneling = nil
			spellName = spellCasting
		end
		if spellName then
			Virtual.castText:SetText(spellName)
			if not RBP.dbp.castTimerText_hide then
				Virtual.castTimerText:Show()
			else
				Virtual.castTimerText:Hide()
			end
		else
			Virtual.castText:SetText("")
			Virtual.castTimerText:Hide()
		end
	else
		Virtual.castBarChanneling = nil
		Virtual.castText:SetText("")
		Virtual.castTimerText:Hide()
	end
end

local function UpdateCastBarOnShow(Virtual)
	local castBar = Virtual.castBar
	local castBarTex = Virtual.castBarTex
	local castBarBorder = Virtual.castBarBorder
	local shieldCastBarBorder = Virtual.shieldCastBarBorder
	local spellIcon = Virtual.spellIcon
	if RBP.dbp.castBar_showSpark then
		Virtual.castSpark:Hide()
		Virtual.castBarInitSpark = true
	end
	castBarTex:SetVertexColor(unpack(RBP.dbp.castBar_color))
	castBarBorder:SetVertexColor(unpack(RBP.dbp.castBar_borderTint))
	shieldCastBarBorder:SetVertexColor(unpack(RBP.dbp.castBar_protectedBorderTint))
	if castBarBorder:IsShown() then
		if RBP.dbp.healthBar_border == "Blizzard" then
			castBar:SetPoint("BOTTOMRIGHT", RBP.dbp.globalOffsetX -4.1, RBP.dbp.globalOffsetY - 12.5)
			spellIcon:SetPoint("CENTER", castBarBorder, "BOTTOMLEFT", 16.1, 10.5)
			spellIcon:SetSize(16.8, 16.8)
		else
			castBar:SetPoint("BOTTOMRIGHT", RBP.dbp.globalOffsetX -10, RBP.dbp.globalOffsetY - 12.5)
			spellIcon:SetPoint("CENTER", castBarBorder, "BOTTOMLEFT", 14.6, 10.5)
			spellIcon:SetSize(15.8, 15.8)
		end
	else
		if RBP.dbp.healthBar_border == "Blizzard" then
			castBar:SetPoint("BOTTOMRIGHT", RBP.dbp.globalOffsetX -4, RBP.dbp.globalOffsetY - 17.5)
			spellIcon:SetPoint("CENTER", castBarBorder, "BOTTOMLEFT", 16, 5.5)
			spellIcon:SetSize(16.8, 16.8)
		else
			castBar:SetPoint("BOTTOMRIGHT", RBP.dbp.globalOffsetX -8.5, RBP.dbp.globalOffsetY - 17.5)
			spellIcon:SetPoint("CENTER", castBarBorder, "BOTTOMLEFT", 13, 5.5)
			spellIcon:SetSize(16.8, 16.8)
		end
	end
end

local function SetupCastSpark(Virtual)
	if Virtual.castSpark then return end
	Virtual.castSpark = Virtual.castBar:CreateTexture(nil, "ARTWORK")
	local castSpark = Virtual.castSpark
	castSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	castSpark:SetBlendMode("ADD")
	castSpark:SetPoint("CENTER", Virtual.castBarTex, "RIGHT")
	castSpark:SetSize(10, 22)
	castSpark:Hide()
end

local function UpdateCastGlow(Virtual)
	local castGlow = Virtual.castGlow
	if RBP.dbp.healthBar_border == "Blizzard" then
		castGlow:SetSize(175.5, 40)
		castGlow:SetPoint("CENTER", 1.9, RBP.dbp.globalOffsetY - 26.5)
	else
		castGlow:SetSize(160, 40)
		castGlow:SetPoint("CENTER", 2.3, RBP.dbp.globalOffsetY - 26.5)
	end
end

local function SetupCastGlow(Virtual)
	if Virtual.castGlow then return end
	Virtual.castGlow = Virtual:CreateTexture(nil, "OVERLAY")
	local castGlow = Virtual.castGlow
	castGlow:SetTexture(ASSETS .. "PlateRegions\\CastBar-Glow")
	castGlow:SetVertexColor(0.25, 0.75, 0.25)
	castGlow:SetTexCoord(0, 0.55, 0, 1)
	castGlow:Hide()
	UpdateCastGlow(Virtual)
	if RBP.dbp.enableCastGlow then
		local castBar = Virtual.castBar
		local castBarBorder = Virtual.castBarBorder
		local Plate = Virtual.RealPlate
		castBar:HookScript("OnShow", function()
			local unit = Plate.namePlateUnitToken or Plate.unitToken
			if unit and UnitIsUnit(unit.."target", "player") and not UnitIsUnit("target", unit) and castBarBorder:IsShown() then
				if UnitCanAttack("player", unit) then
					castGlow:SetVertexColor(1, 0, 0)
				else
					castGlow:SetVertexColor(0.25, 0.75, 0.25)
				end
				castGlow:Show()
				Virtual.castGlowIsShown = true
			end
		end)
		castBar:HookScript("OnValueChanged", function()
			if Virtual.castGlowIsShown and Plate.isTarget then
				castGlow:Hide()
				Virtual.castGlowIsShown = nil
			end
		end)
		castBar:HookScript("OnHide", function()
			castGlow:Hide()
			Virtual.castGlowIsShown = nil
		end)
	end
end

local function HookCastBarScripts(Virtual)
	local Plate = Virtual.RealPlate
	local castBar = Virtual.castBar
	local castBarTex = Virtual.castBarTex
	local castTimerText = Virtual.castTimerText
	local delayedCastBarOnShow = CreateFrame("Frame")
	delayedCastBarOnShow:SetScript("OnUpdate", function(self)
		self:Hide()
		local min, max = castBar:GetMinMaxValues()
		if Virtual.healthBarIsShown and max > 0 then
			Virtual.castBarIsShown = true
			local unit = Plate.namePlateUnitToken or Plate.unitToken or (Plate.isTarget and "target")
			UpdateCastTextString(Virtual, unit)
			UpdateCastBarOnShow(Virtual)
			if RBP.dbp.castBar_progressiveTexCrop then
				Virtual.castBarTexCrop = true
			end
		else
			castBar:Hide()
			Virtual.castBarBorder:Hide()
			Virtual.shieldCastBarBorder:Hide()
			Virtual.spellIcon:Hide()
			Virtual.castBarIsShown = nil
			Virtual.castBarChanneling = nil
		end
	end)
	castBar:HookScript("OnShow", function(self)
		delayedCastBarOnShow:Show()
	end)
	castBar:HookScript("OnHide", function(self)
		Virtual.castBarIsShown = nil
		Virtual.castBarChanneling = nil
		Virtual.castBarInitSpark = nil
		Virtual.castBarTexCrop = nil
	end)
	castBar:HookScript("OnValueChanged", function(self, val)
		if Virtual.castBarInitSpark then
			Virtual.castBarInitSpark = nil
			Virtual.castSpark:Show()
		end
		if Virtual.castBarIsShown then
			local min, max = self:GetMinMaxValues()
			if max > 0 then
				if Virtual.castBarTexCrop then
					castBarTex:SetTexCoord(0, val / max, 0, 1)
				else
					castBarTex:SetTexCoord(0, 1, 0, 1)
				end
				if Virtual.castBarChanneling then
					castTimerText:SetFormattedText("%.1f", val)
				else
					castTimerText:SetFormattedText("%.1f", max - val)					
				end
			end
		end
	end)
end

local function SetupBossIcon(Virtual)
	local bossIcon = Virtual.bossIcon
	bossIcon:SetSize(RBP.dbp.bossIcon_size, RBP.dbp.bossIcon_size)
	bossIcon:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		if RBP.dbp.bossIcon_anchor == "Left" then
			bossIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT", RBP.dbp.bossIcon_offsetX, RBP.dbp.bossIcon_offsetY)
		elseif RBP.dbp.bossIcon_anchor == "Top" then
			bossIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", RBP.dbp.bossIcon_offsetX + 11, RBP.dbp.bossIcon_offsetY + 17.5)
		else
			bossIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT", RBP.dbp.bossIcon_offsetX + 3, RBP.dbp.bossIcon_offsetY)
		end
	else
		if RBP.dbp.bossIcon_anchor == "Left" then
			bossIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT",  RBP.dbp.bossIcon_offsetX - 1, RBP.dbp.bossIcon_offsetY )
		elseif RBP.dbp.bossIcon_anchor == "Top" then
			bossIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", RBP.dbp.bossIcon_offsetX, RBP.dbp.bossIcon_offsetY + 3.5)
		else
			bossIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT",  RBP.dbp.bossIcon_offsetX + 1, RBP.dbp.bossIcon_offsetY)
		end
	end
end

local function SetupRaidTargetIcon(Virtual)
	local raidTargetIcon = Virtual.raidTargetIcon
	raidTargetIcon:SetSize(RBP.dbp.raidTargetIcon_size, RBP.dbp.raidTargetIcon_size)
	raidTargetIcon:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		if RBP.dbp.raidTargetIcon_anchor == "Left" then
			raidTargetIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT", RBP.dbp.raidTargetIcon_offsetX - 3, RBP.dbp.raidTargetIcon_offsetY + 1)
		elseif RBP.dbp.raidTargetIcon_anchor == "Top" then
			raidTargetIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", RBP.dbp.raidTargetIcon_offsetX + 11, RBP.dbp.raidTargetIcon_offsetY + 21)
		else
			raidTargetIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT", RBP.dbp.raidTargetIcon_offsetX + 24, RBP.dbp.raidTargetIcon_offsetY + 1)
		end
	else
		if RBP.dbp.raidTargetIcon_anchor == "Left" then
			raidTargetIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT",  RBP.dbp.raidTargetIcon_offsetX - 3, RBP.dbp.raidTargetIcon_offsetY)
		elseif RBP.dbp.raidTargetIcon_anchor == "Top" then
			raidTargetIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", RBP.dbp.raidTargetIcon_offsetX, RBP.dbp.raidTargetIcon_offsetY + 5)
		else
			raidTargetIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT",  RBP.dbp.raidTargetIcon_offsetX + 3, RBP.dbp.raidTargetIcon_offsetY)
		end
	end
end

local function SetupEliteIcon(Virtual)
	local eliteIcon = Virtual.eliteIcon
	eliteIcon:SetVertexColor(unpack(RBP.dbp.eliteIcon_Tint))
	eliteIcon:ClearAllPoints()
	if RBP.dbp.eliteIcon_style == "Modern" then
		eliteIcon:SetTexture(ASSETS .. "PlateRegions\\ModernEliteIcon")
		eliteIcon:SetSize(36 * RBP.dbp.eliteIcon_widthScale, 36 * RBP.dbp.eliteIcon_heightScale)
		if RBP.dbp.eliteIcon_anchor == "Left" then
			eliteIcon:SetTexCoord(0.9, 0.1, 0.9, 0.9, 0.1, 0.1, 0.1, 0.9)
			eliteIcon:SetPoint("LEFT", Virtual.healthBar, "LEFT", -15.5 + RBP.dbp.eliteIcon_offsetX, 0.3 + RBP.dbp.eliteIcon_offsetY)
		else
			eliteIcon:SetTexCoord(0.1, 0.1, 0.1, 0.9, 0.9, 0.1, 0.9, 0.9)
			if RBP.dbp.healthBar_border == "Blizzard" then
				eliteIcon:SetPoint("RIGHT", Virtual.healthBar, "RIGHT", 36.5 + RBP.dbp.eliteIcon_offsetX, 0.3 + RBP.dbp.eliteIcon_offsetY)
			else
				eliteIcon:SetPoint("RIGHT", Virtual.healthBar, "RIGHT", 16 + RBP.dbp.eliteIcon_offsetX, 0.3 + RBP.dbp.eliteIcon_offsetY)
			end
		end
	elseif RBP.dbp.eliteIcon_style == "Minimalist" then
		eliteIcon:SetTexture(ASSETS .. "PlateRegions\\MinimalistEliteIcon")
		eliteIcon:SetSize(16 * RBP.dbp.eliteIcon_widthScale, 16 * RBP.dbp.eliteIcon_heightScale)
		if RBP.dbp.eliteIcon_anchor == "Left" then
			eliteIcon:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1)
			eliteIcon:SetPoint("LEFT", Virtual.healthBar, "LEFT", -18 + RBP.dbp.eliteIcon_offsetX, RBP.dbp.eliteIcon_offsetY)
		else
			eliteIcon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
			if RBP.dbp.healthBar_border == "Blizzard" then
				eliteIcon:SetPoint("RIGHT", Virtual.healthBar, "RIGHT", 39.5 + RBP.dbp.eliteIcon_offsetX, RBP.dbp.eliteIcon_offsetY)
			else
				eliteIcon:SetPoint("RIGHT", Virtual.healthBar, "RIGHT", 18 + RBP.dbp.eliteIcon_offsetX, RBP.dbp.eliteIcon_offsetY)
			end
		end
	else
		eliteIcon:SetTexture("Interface\\Tooltips\\elitenameplateicon")
		eliteIcon:SetSize(46.055 * RBP.dbp.eliteIcon_widthScale, 33.680 * RBP.dbp.eliteIcon_heightScale)
		if RBP.dbp.eliteIcon_anchor == "Left" then
			eliteIcon:SetTexCoord(0.578125, 0, 0.578125, 0.84375, 0, 0, 0, 0.84375)
			eliteIcon:SetPoint("LEFT", Virtual.healthBar, "LEFT", -18 + RBP.dbp.eliteIcon_offsetX, -1.5 + RBP.dbp.eliteIcon_offsetY)
		else
			eliteIcon:SetTexCoord(0, 0, 0, 0.84375, 0.578125, 0, 0.578125, 0.84375)
			if RBP.dbp.healthBar_border == "Blizzard" then
				eliteIcon:SetPoint("RIGHT", Virtual.healthBar, "RIGHT", 39 + RBP.dbp.eliteIcon_offsetX, -1 + RBP.dbp.eliteIcon_offsetY)				
			else
				eliteIcon:SetPoint("RIGHT", Virtual.healthBar, "RIGHT", 18 + RBP.dbp.eliteIcon_offsetX, -1.5 + RBP.dbp.eliteIcon_offsetY)
			end
		end
	end
end

local function SetupClassIcon(Virtual)
	if not Virtual.classIcon then
		Virtual.classIcon = Virtual.healthBar:CreateTexture(nil, "ARTWORK")
		Virtual.classIcon:Hide()
	end
	local classIcon = Virtual.classIcon
	classIcon:SetSize(RBP.dbp.classIcon_size, RBP.dbp.classIcon_size)
	classIcon:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		if RBP.dbp.classIcon_anchor == "Left" then
			classIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT", RBP.dbp.classIcon_offsetX - 0.5, RBP.dbp.classIcon_offsetY)
		elseif RBP.dbp.classIcon_anchor == "Top" then
			classIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", RBP.dbp.classIcon_offsetX + 11, RBP.dbp.classIcon_offsetY + 18)
		else
			classIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT", RBP.dbp.classIcon_offsetX + 22, RBP.dbp.classIcon_offsetY)
		end
	else
		if RBP.dbp.classIcon_anchor == "Left" then
			classIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT", RBP.dbp.classIcon_offsetX - 0.5, RBP.dbp.classIcon_offsetY)
		elseif RBP.dbp.classIcon_anchor == "Top" then
			classIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", RBP.dbp.classIcon_offsetX, RBP.dbp.classIcon_offsetY + 3)
		else
			classIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT", RBP.dbp.classIcon_offsetX + 0.5, RBP.dbp.classIcon_offsetY)
		end
	end
end

local function SetupCastBorder(Virtual)
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.castBar:SetSize(129, 11)
		Virtual.castBarBorder:SetPoint("CENTER", RBP.dbp.globalOffsetX + 9.9, RBP.dbp.globalOffsetY -18)
		Virtual.castBarBorder:SetWidth(159)
		Virtual.shieldCastBarBorder:SetPoint("CENTER", Virtual.castBarBorder, 0.7, -14)
		Virtual.shieldCastBarBorder:SetWidth(155)
	else
		Virtual.castBar:SetSize(119, 11)
		Virtual.castBarBorder:SetPoint("CENTER", RBP.dbp.globalOffsetX - 0.5, RBP.dbp.globalOffsetY -18)
		Virtual.castBarBorder:SetWidth(145)
		Virtual.shieldCastBarBorder:SetPoint("CENTER", Virtual.castBarBorder, 0.7, -14)
		Virtual.shieldCastBarBorder:SetWidth(145)
	end
end

local function SetupTotemIcon(Plate)
	if not Plate.totemPlate then return end
	Plate.totemPlate:SetPoint("TOP", Plate, 0, RBP.dbp.totemOffset - 3)
	Plate.totemPlate:SetSize(RBP.dbp.totemSize, RBP.dbp.totemSize)
	Plate.totemPlate_targetGlow:SetSize(128*RBP.dbp.totemSize/88, 128*RBP.dbp.totemSize/88)
end

local function SetupTotemPlate(Plate)
	if Plate.totemPlate then return end
	Plate.totemPlate = CreateFrame("Frame", nil, WorldFrame)
	local totemPlate = Plate.totemPlate
	totemPlate:Hide()
	Plate.totemPlate_icon = totemPlate:CreateTexture(nil, "BORDER")
	Plate.totemPlate_icon:SetAllPoints(totemPlate)
	Plate.totemPlate_targetGlow = totemPlate:CreateTexture(nil, "OVERLAY")
	local totemPlate_targetGlow = Plate.totemPlate_targetGlow
	totemPlate_targetGlow:SetTexture(ASSETS .. "PlateRegions\\TotemPlate-TargetGlow")
	totemPlate_targetGlow:SetVertexColor(unpack(RBP.dbp.targetGlow_Tint))
	totemPlate_targetGlow:SetPoint("CENTER")
	totemPlate_targetGlow:Hide()
	Plate.totemPlate_border = totemPlate:CreateTexture(nil, "ARTWORK")
	local totemPlate_border = Plate.totemPlate_border
	totemPlate_border:SetTexture(ASSETS .. "PlateRegions\\TotemPlate-Border")
	totemPlate_border:SetVertexColor(1, 0, 0)
	totemPlate_border:SetAllPoints(totemPlate)
	totemPlate_border:Hide()
	SetupTotemIcon(Plate)
end

local function UpdateBarlessPlate(Plate)
	if not Plate.barlessPlate then return end
	local barlessPlate_nameText = Plate.barlessPlate_nameText
	local barlessPlate_healthText = Plate.barlessPlate_healthText
	local barlessPlate_classIcon = Plate.barlessPlate_classIcon
	local barlessPlate_raidTargetIcon = Plate.barlessPlate_raidTargetIcon
	if Plate.classKey then
		barlessPlate_nameText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.barlessPlate_textFont), RBP.dbp.barlessPlate_textSize, RBP.dbp.barlessPlate_textOutline)
		barlessPlate_nameText:SetPoint("TOP", 0, RBP.dbp.barlessPlate_offset)
		barlessPlate_healthText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.barlessPlate_textFont), RBP.dbp.barlessPlate_healthTextSize, RBP.dbp.barlessPlate_textOutline)
		barlessPlate_classIcon:SetSize(RBP.dbp.barlessPlate_classIconSize, RBP.dbp.barlessPlate_classIconSize)
		barlessPlate_classIcon:ClearAllPoints()
		if RBP.dbp.barlessPlate_classIconAnchor == "Left" then
			barlessPlate_classIcon:SetPoint("RIGHT", barlessPlate_nameText, "LEFT", RBP.dbp.barlessPlate_classIconOffsetX, RBP.dbp.barlessPlate_classIconOffsetY)
		elseif RBP.dbp.barlessPlate_classIconAnchor == "Right" then
			barlessPlate_classIcon:SetPoint("LEFT", barlessPlate_nameText, "RIGHT", RBP.dbp.barlessPlate_classIconOffsetX, RBP.dbp.barlessPlate_classIconOffsetY)
		elseif RBP.dbp.barlessPlate_classIconAnchor == "Bottom" then
			barlessPlate_classIcon:SetPoint("TOP", barlessPlate_nameText, "BOTTOM", RBP.dbp.barlessPlate_classIconOffsetX, RBP.dbp.barlessPlate_classIconOffsetY)
		else
			barlessPlate_classIcon:SetPoint("BOTTOM", barlessPlate_nameText, "TOP", RBP.dbp.barlessPlate_classIconOffsetX, RBP.dbp.barlessPlate_classIconOffsetY)
		end
	else
		barlessPlate_nameText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.barlessPlate_NPCtextFont), RBP.dbp.barlessPlate_NPCtextSize, RBP.dbp.barlessPlate_NPCtextOutline)
		barlessPlate_nameText:SetPoint("TOP", 0, RBP.dbp.barlessPlate_NPCoffset)
		barlessPlate_healthText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.barlessPlate_NPCtextFont), RBP.dbp.barlessPlate_healthTextSize, RBP.dbp.barlessPlate_NPCtextOutline)
	end
	barlessPlate_healthText:ClearAllPoints()
	if RBP.dbp.barlessPlate_healthTextAnchor == "Left" then
		barlessPlate_healthText:SetPoint("RIGHT", barlessPlate_nameText, "LEFT", RBP.dbp.barlessPlate_healthTextOffsetX, RBP.dbp.barlessPlate_healthTextOffsetY)
	elseif RBP.dbp.barlessPlate_healthTextAnchor == "Right" then
		barlessPlate_healthText:SetPoint("LEFT", barlessPlate_nameText, "RIGHT", RBP.dbp.barlessPlate_healthTextOffsetX, RBP.dbp.barlessPlate_healthTextOffsetY)
	elseif RBP.dbp.barlessPlate_healthTextAnchor == "Bottom" then
		barlessPlate_healthText:SetPoint("TOP", barlessPlate_nameText, "BOTTOM", RBP.dbp.barlessPlate_healthTextOffsetX, RBP.dbp.barlessPlate_healthTextOffsetY)
	else
		barlessPlate_healthText:SetPoint("BOTTOM", barlessPlate_nameText, "TOP", RBP.dbp.barlessPlate_healthTextOffsetX, RBP.dbp.barlessPlate_healthTextOffsetY)
	end	
	barlessPlate_raidTargetIcon:SetSize(RBP.dbp.barlessPlate_raidTargetIconSize, RBP.dbp.barlessPlate_raidTargetIconSize)
	barlessPlate_raidTargetIcon:ClearAllPoints()
	if RBP.dbp.barlessPlate_raidTargetIconAnchor == "Left" then
		barlessPlate_raidTargetIcon:SetPoint("RIGHT", barlessPlate_nameText, "LEFT", RBP.dbp.barlessPlate_raidTargetIconOffsetX, RBP.dbp.barlessPlate_raidTargetIconOffsetY)
	elseif RBP.dbp.barlessPlate_raidTargetIconAnchor == "Right" then
		barlessPlate_raidTargetIcon:SetPoint("LEFT", barlessPlate_nameText, "RIGHT", RBP.dbp.barlessPlate_raidTargetIconOffsetX, RBP.dbp.barlessPlate_raidTargetIconOffsetY)
	elseif RBP.dbp.barlessPlate_raidTargetIconAnchor == "Bottom" then
		barlessPlate_raidTargetIcon:SetPoint("TOP", barlessPlate_nameText, "BOTTOM", RBP.dbp.barlessPlate_raidTargetIconOffsetX, RBP.dbp.barlessPlate_raidTargetIconOffsetY)
	else
		barlessPlate_raidTargetIcon:SetPoint("BOTTOM", barlessPlate_nameText, "TOP", RBP.dbp.barlessPlate_raidTargetIconOffsetX, RBP.dbp.barlessPlate_raidTargetIconOffsetY)
	end
end

local function SetupBarlessPlate(Plate)
	if Plate.barlessPlate then return end
	Plate.barlessPlate = CreateFrame("Frame", nil, WorldFrame)
	local barlessPlate = Plate.barlessPlate
	barlessPlate:SetSize(1, 1)
	barlessPlate:SetPoint("TOP", Plate)
	barlessPlate:Hide()
	Plate.barlessPlate_nameText = barlessPlate:CreateFontString(nil, "OVERLAY")
	Plate.barlessPlate_nameText:SetShadowOffset(0.5, -0.5)
	Plate.barlessPlate_healthText = barlessPlate:CreateFontString(nil, "OVERLAY")
	Plate.barlessPlate_healthText:SetShadowOffset(0.5, -0.5)
	Plate.barlessPlate_healthText:Hide()
	Plate.barlessPlate_raidTargetIcon = barlessPlate:CreateTexture(nil, "BORDER")
	Plate.barlessPlate_raidTargetIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	Plate.barlessPlate_raidTargetIcon:Hide()
	Plate.barlessPlate_classIcon = barlessPlate:CreateTexture(nil, "ARTWORK")
	Plate.barlessPlate_classIcon:Hide()
	UpdateBarlessPlate(Plate)
end

local function CheckBarlessPlate(Plate)
	if Plate.isFriendly and ((RBP.inBG and RBP.dbp.barlessPlate_showInBG) or (RBP.inArena and RBP.dbp.barlessPlate_showInArena) or (RBP.inPvEInstance and RBP.dbp.barlessPlate_showInPvE)) then
		if not Plate.barlessPlate then
			SetupBarlessPlate(Plate)
		end
		Plate.isBarlessPlate = true
		return true
	end
end

local function BarlessPlateHandler(Plate)
	local Virtual = Plate.VirtualPlate
	Virtual.threatGlow:SetTexture(nil)
	local barlessPlate = Plate.barlessPlate
	if not Plate.isTarget then
		local barlessNameText = Plate.barlessPlate_nameText
		barlessNameText:SetTextColor(unpack(Plate.barlessNameTextRGB))
		barlessNameText:SetText(Plate.nameString)
		local healthBarHighlight = Virtual.healthBarHighlight
		healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\BarlessPlate-MouseoverGlow")
		healthBarHighlight:ClearAllPoints()
		healthBarHighlight:SetPoint("CENTER", barlessNameText, 0, -1.3)
		healthBarHighlight:SetSize(barlessNameText:GetWidth() + 30, barlessNameText:GetHeight() + 20)
		if (Plate.classKey and RBP.dbp.barlessPlate_showHealthText) or (not Plate.classKey and RBP.dbp.barlessPlate_showNPCHealthText) then
			Plate.barlessPlate_healthText:Show()
			Plate.BarlessHealthTextIsShown = true	
		end
		if Plate.hasRaidIcon and RBP.dbp.barlessPlate_showRaidTarget then
			Plate.barlessPlate_raidTargetIcon:SetTexCoord(Virtual.raidTargetIcon:GetTexCoord())
			Plate.barlessPlate_raidTargetIcon:Show()
		end
		if Plate.classKey and RBP.dbp.barlessPlate_showClassIcon then
			Plate.barlessPlate_classIcon:SetTexture(ASSETS .. "Classes\\" .. (ClassByFriendName[Plate.nameString] or ""))
			Plate.barlessPlate_classIcon:Show()
		end
		UpdateBarlessPlate(Plate)
		barlessPlate:Show()
		Plate.barlessPlateIsShown = true
		UpdateHealthTextValue(Virtual.healthBar)
		Virtual.healthBar:Hide()
		Virtual.healthBarIsShown = nil
		Virtual.castBar:Hide()
		Virtual.castBarIsShown = nil
		Virtual.castBarBorder:Hide()
		Virtual.shieldCastBarBorder:Hide()
		Virtual.spellIcon:Hide()
		Virtual.levelText:Hide()
		Virtual.bossIcon:Hide()
		Virtual.raidTargetIcon:Hide()
		Virtual.eliteIcon:Hide()
		if Virtual.BGHframe then
			if RBP.dbp.barlessPlate_BGHiconAnchor == "Left" then
				Virtual.BGHframe:ModifyIcon(true, barlessPlate, RBP.dbp.barlessPlate_BGHiconSize, "RIGHT", barlessNameText, "LEFT", RBP.dbp.barlessPlate_BGHiconOffsetX, RBP.dbp.barlessPlate_BGHiconOffsetY)
			elseif RBP.dbp.barlessPlate_BGHiconAnchor == "Right" then
				Virtual.BGHframe:ModifyIcon(true, barlessPlate, RBP.dbp.barlessPlate_BGHiconSize, "LEFT", barlessNameText, "RIGHT", RBP.dbp.barlessPlate_BGHiconOffsetX, RBP.dbp.barlessPlate_BGHiconOffsetY)
			elseif RBP.dbp.barlessPlate_BGHiconAnchor == "Bottom" then
				Virtual.BGHframe:ModifyIcon(true, barlessPlate, RBP.dbp.barlessPlate_BGHiconSize, "TOP", barlessNameText, "BOTTOM", RBP.dbp.barlessPlate_BGHiconOffsetX, RBP.dbp.barlessPlate_BGHiconOffsetY)
			else
				Virtual.BGHframe:ModifyIcon(true, barlessPlate, RBP.dbp.barlessPlate_BGHiconSize, "BOTTOM", barlessNameText, "TOP", RBP.dbp.barlessPlate_BGHiconOffsetX, RBP.dbp.barlessPlate_BGHiconOffsetY)
			end
		elseif Plate.firstProcessing then
			if RBP.dbp.barlessPlate_BGHiconAnchor == "Left" then
				Virtual.shouldModifyBGH = {true, barlessPlate, RBP.dbp.barlessPlate_BGHiconSize, "RIGHT", barlessNameText, "LEFT", RBP.dbp.barlessPlate_BGHiconOffsetX, RBP.dbp.barlessPlate_BGHiconOffsetY}
			elseif RBP.dbp.barlessPlate_BGHiconAnchor == "Right" then
				Virtual.shouldModifyBGH = {true, barlessPlate, RBP.dbp.barlessPlate_BGHiconSize, "LEFT", barlessNameText, "RIGHT", RBP.dbp.barlessPlate_BGHiconOffsetX, RBP.dbp.barlessPlate_BGHiconOffsetY}
			elseif RBP.dbp.barlessPlate_BGHiconAnchor == "Bottom" then
				Virtual.shouldModifyBGH = {true, barlessPlate, RBP.dbp.barlessPlate_BGHiconSize, "TOP", barlessNameText, "BOTTOM", RBP.dbp.barlessPlate_BGHiconOffsetX, RBP.dbp.barlessPlate_BGHiconOffsetY}
			else
				Virtual.shouldModifyBGH = {true, barlessPlate, RBP.dbp.barlessPlate_BGHiconSize, "BOTTOM", barlessNameText, "TOP", RBP.dbp.barlessPlate_BGHiconOffsetX, RBP.dbp.barlessPlate_BGHiconOffsetY}
			end
		end
	else
		Virtual.healthBar:Show()
		Virtual.healthBarIsShown = true
		UpdateMouseoverGlow(Virtual)
		if Plate.hasBossIcon then
			Virtual.bossIcon:Show()
		elseif not RBP.dbp.levelText_hide and not (RBP.inArena and RBP.dbp.PartyIDText_show and RBP.dbp.PartyIDText_HideLevel) then
			SetupLevelText(Virtual)
			Virtual.levelText:Show()
		end
		if Plate.hasRaidIcon then
			Virtual.raidTargetIcon:Show()
		end
		if Plate.hasEliteIcon then
			Virtual.eliteIcon:Show()
		end
		barlessPlate:Hide()
		Plate.barlessPlate_healthText:Hide()
		Plate.barlessPlate_raidTargetIcon:Hide()
		Plate.barlessPlate_classIcon:Hide()
		Plate.barlessPlateIsShown = nil
		Plate.BarlessHealthTextIsShown = nil
		if Virtual.BGHframe then
			Virtual.BGHframe:ModifyIcon()
		end
	end
end

local function SetupTargetHandler(Plate)
	if Plate.targetHandler then return end
	local Virtual = Plate.VirtualPlate
	Plate.targetHandler = CreateFrame("Frame")
	Plate.targetHandler:SetScript("OnUpdate", function(self)
		self:Hide()
		if Plate.nameString == UnitName("target") and Virtual:GetAlpha() == 1 then
			Plate.isTarget = true
			Virtual.targetGlow:Show()		
			if Plate.isFriendly then
				Virtual:SetScale(RBP.dbp.globalScale * RBP.dbp.friendlyScale * RBP.dbp.targetScale)
			else
				Virtual:SetScale(RBP.dbp.globalScale * RBP.dbp.targetScale)
			end
			if Plate.totemPlate_targetGlow then 
				Plate.totemPlate_targetGlow:Show()
			end
			if Virtual.castBarIsShown and not Virtual.castText:GetText() then
				UpdateCastTextString(Virtual, "target")
			end
		else
			Plate.isTarget = false
			Virtual.targetGlow:Hide()
			if Plate.isFriendly then
				Virtual:SetScale(RBP.dbp.globalScale * RBP.dbp.friendlyScale)
			else
				Virtual:SetScale(RBP.dbp.globalScale)
			end
			if Plate.totemPlate_targetGlow then Plate.totemPlate_targetGlow:Hide() end
		end
		if Virtual.isShown then
			if Plate.isBarlessPlate then	
				BarlessPlateHandler(Plate)
			end
			if not Plate.isFriendly and not RBP.dbp.stackingEnabled then
				if (Plate.isTarget and RBP.dbp.clampTarget) or (Plate.hasBossIcon and RBP.dbp.clampBoss and RBP.inPvEInstance) then
					Plate:SetClampedToScreen(true)
					Plate:SetClampRectInsets(80*RBP.dbp.globalScale, -80*RBP.dbp.globalScale, RBP.dbp.upperborder, 0)
				else
					Plate:SetClampedToScreen(false)
					Plate:SetClampRectInsets(0, 0, 0, 0)
				end				
			end
		end
		Plate.firstProcessing = nil
	end)
end

local function UpdateTarget(Plate)
	Plate.targetHandler:Show()
end

local function SetupClickboxTexture(Plate)
	Plate.clickboxTexture = Plate:CreateTexture(nil, "OVERLAY")
	Plate.clickboxTexture:SetTexture(0.8,0.1,0.1,0.5)
	Plate.clickboxTexture:SetAllPoints(Plate)
	if not RBP.dbp.showClickbox then
		Plate.clickboxTexture:Hide()
	end
end

local function SetupAggroOverlay(Virtual)
	if Virtual.aggroOverlay then return end
	Virtual.aggroOverlay = Virtual.healthBar:CreateTexture(nil, "BORDER")
	local aggroOverlay = Virtual.aggroOverlay
	aggroOverlay:SetAllPoints(Virtual.healthBarTex)
	aggroOverlay:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
    aggroOverlay:Hide()
end

local function GetAggroStatus(threatGlow)
	if not threatGlow:IsVisible() then return 0 end
	local r, g, b = threatGlow:GetVertexColor()
	if b > 0.5 then return 0 end
	if g < 0.5 then return 3 end
	if g < 0.9 then return 2 end
	return 1
end

local function UpdateAggroOverlay(Virtual)
	local aggroOverlay = Virtual.aggroOverlay
	local aggroStatus = GetAggroStatus(Virtual.threatGlow)
	if aggroStatus > 0 then
		if aggroStatus == 3 then
			aggroOverlay:SetVertexColor(unpack(RBP.dbp.aggroColor))
		elseif aggroStatus == 2 then
			aggroOverlay:SetVertexColor(unpack(RBP.dbp.losingAggroColor))
		elseif aggroStatus == 1 then
			aggroOverlay:SetVertexColor(unpack(RBP.dbp.gainingAggroColor))
		end
		aggroOverlay:Show()
		Virtual.healthBarTex:SetTexture(nil)
	else
		aggroOverlay:Hide()
		Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
	end
end

local function SetupRefinedPlate(Virtual)
	local Plate = Virtual.RealPlate
	Plate.firstProcessing = true
	Virtual.threatGlow, Virtual.ogHealthBarBorder, Virtual.castBarBorder, Virtual.shieldCastBarBorder, Virtual.spellIcon, Virtual.healthBarHighlight, Virtual.ogNameText, Virtual.levelText, Virtual.bossIcon, Virtual.raidTargetIcon, Virtual.eliteIcon = Virtual:GetRegions()
	Virtual.healthBar, Virtual.castBar = Virtual:GetChildren()
	Virtual.healthBarTex = Virtual.healthBar:GetRegions()
	Virtual.castBarTex = Virtual.castBar:GetRegions()
	Virtual.healthBar.RealPlate = Plate
	InitBarTextures(Virtual)
	SetupThreatGlow(Virtual)
	SetupHealthBorder(Virtual)
	SetupNameText(Virtual)
	SetupLevelText(Virtual)
	SetupArenaIDText(Virtual)
	SetupTargetGlow(Virtual)
	SetupHealthText(Virtual)
	SetupHealthBarBackground(Virtual)
	SetupCastBarBackground(Virtual)
	SetupCastText(Virtual)
	SetupCastTimer(Virtual)
	SetupCastSpark(Virtual)
	SetupCastGlow(Virtual)
	HookCastBarScripts(Virtual)
	SetupBossIcon(Virtual)
	SetupRaidTargetIcon(Virtual)
	SetupEliteIcon(Virtual)
	SetupClassIcon(Virtual)
	SetupCastBorder(Virtual)
	SetupTargetHandler(Plate)
	SetupClickboxTexture(Plate)
end

local firstChecked
local ForceLevelHideHandler = CreateFrame("Frame")
ForceLevelHideHandler:Hide()
ForceLevelHideHandler:SetScript("OnUpdate", function(self)
	firstChecked = false
	for _, Virtual in pairs(PlatesVisible) do
		if not firstChecked then
			firstChecked = true
			if not Virtual.levelText:IsShown() then
				break
			else
				self:Hide()
			end
		end
		Virtual.levelText:Hide()
	end
	if not firstChecked then
		self:Hide()
	end
end)
local function ForceLevelHide()
	ForceLevelHideHandler:Show()
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
	for i = 1 , GetNumPartyMembers() do
		local partyID = "party" .. i
		local name = UnitName(partyID)
		local _, class = UnitClass(partyID)
		name = name:match("([^%-]+).*") -- remove realm suffix
		if name and class then
			PartyID[name] = tostring(i)
			ClassByFriendName[name] = class
		end
	end
	for i = 1 , GetNumRaidMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
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

local function UpdateClassColorNames()
	local class, name
	for Plate, Virtual in pairs(PlatesVisible) do
		class = Plate.classKey
		name = Plate.nameString
		local classColor
		if class then
			if class == "FRIENDLY_PLAYER" and ClassByFriendName[name] then
				classColor = RAID_CLASS_COLORS[ClassByFriendName[name]]
				Plate.classColor = classColor
			elseif class ~= "FRIENDLY_PLAYER" then
				classColor = RAID_CLASS_COLORS[class]
				Plate.classColor = classColor
			end
		end
		Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = unpack(RBP.dbp.nameText_color)
		if classColor and ((class == "FRIENDLY_PLAYER" and RBP.dbp.nameText_classColorFriends) or (class ~= "FRIENDLY_PLAYER" and RBP.dbp.nameText_classColorEnemies)) then
			Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = classColor.r, classColor.g, classColor.b
		end
		Virtual.newNameText:SetTextColor(Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB)
		Virtual.nameTextIsYellow = false
	end
end

-- SecureHandlers System: Manages nameplate clickbox resizing while in combat
local TriggerFrames = {}
local ResizeClickbox = CreateFrame("Frame", "ResizeClickboxSecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
ResizeClickbox:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(ResizeClickbox, "OnShow", ResizeClickbox,
	[[
	local WorldFrame = self:GetFrameRef("WorldFrame")
	local normalWidth = self:GetAttribute("normalWidth")
	local normalHeight = self:GetAttribute("normalHeight")
	local totemWidth = self:GetAttribute("totemWidth")
	local totemHeight = self:GetAttribute("totemHeight")
	local barlessWidth = self:GetAttribute("barlessWidth")
	local barlessHeight = self:GetAttribute("barlessHeight")
	local friendlyWidth = self:GetAttribute("friendlyWidth")
	local friendlyHeight = self:GetAttribute("friendlyHeight")
	Plates = Plates or table.new()
	for plate, shown in pairs(Plates) do
		if shown and not plate:IsShown() then
			Plates[plate] = nil
		end
	end
	for i, nameplate in pairs(newtable(WorldFrame:GetChildren())) do
		if nameplate:IsShown() and nameplate:IsProtected() and not Plates[nameplate] then
			Plates[nameplate] = true
			if WorldFrame:GetID() == 0 then
				nameplate:SetWidth(normalWidth)
				nameplate:SetHeight(normalHeight)
			elseif WorldFrame:GetID() == 1 then
				nameplate:SetWidth(0.01)
				nameplate:SetHeight(0.01)
			elseif WorldFrame:GetID() == 2 then
				nameplate:SetWidth(totemWidth)
				nameplate:SetHeight(totemHeight)
			elseif WorldFrame:GetID() == 3 then
				nameplate:SetWidth(barlessWidth)
				nameplate:SetHeight(barlessHeight)
			elseif WorldFrame:GetID() == 4 then
				nameplate:SetWidth(friendlyWidth)
				nameplate:SetHeight(friendlyHeight)
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
	RBP.ResizeClickbox:SetAttribute("normalWidth", NP_WIDTH * RBP.dbp.globalScale * RBP.dbp.clickboxWidthFactor)
	RBP.ResizeClickbox:SetAttribute("normalHeight", NP_HEIGHT * RBP.dbp.globalScale * RBP.dbp.clickboxHeightFactor)
	RBP.ResizeClickbox:SetAttribute("friendlyWidth", NP_WIDTH * RBP.dbp.globalScale * RBP.dbp.friendlyScale * RBP.dbp.clickboxWidthFactor)
	RBP.ResizeClickbox:SetAttribute("friendlyHeight", NP_HEIGHT * RBP.dbp.globalScale * RBP.dbp.friendlyScale * RBP.dbp.clickboxHeightFactor)
	RBP.ResizeClickbox:SetAttribute("totemWidth", RBP.dbp.totemSize * 1.2)
	RBP.ResizeClickbox:SetAttribute("totemHeight", RBP.dbp.totemSize * 1.2)
	RBP.ResizeClickbox:SetAttribute("barlessWidth", RBP.dbp.barlessPlate_textSize * 2 + 50)
	RBP.ResizeClickbox:SetAttribute("barlessHeight", RBP.dbp.barlessPlate_textSize + 5)
end

local function UpdateClickboxInCombat(Plate)
	if not Plate.VirtualPlate.isShown or (Plate.isFriendly and RBP.dbp.friendlyClickthrough and RBP.inInstance) then
		SetNullClickbox()
	elseif Plate.totemPlateIsShown then
		SetTotemClickbox()
	elseif Plate.isBarlessPlate then
		SetBarlessClickbox()
	elseif Plate.VirtualPlate.isShown and Plate.isFriendly then
		SetFriendlyClickbox()
	else
		SetNormalClickbox()
	end
	ExecuteClickboxSecureScript()
end

local function UpdateClickboxOutOfCombat(Plate)
	if not Plate.VirtualPlate.isShown or (Plate.isFriendly and RBP.dbp.friendlyClickthrough and RBP.inInstance) then
		Plate:SetSize(0.01, 0.01)
	elseif Plate.totemPlateIsShown then
		Plate:SetSize(RBP.dbp.totemSize * 1.2, RBP.dbp.totemSize * 1.2)
	elseif Plate.isBarlessPlate then
		Plate:SetSize(2*RBP.dbp.barlessPlate_textSize + 50, RBP.dbp.barlessPlate_textSize + 5)
	elseif Plate.VirtualPlate.isShown and Plate.isFriendly then
		Plate:SetSize(NP_WIDTH * RBP.dbp.globalScale * RBP.dbp.friendlyScale * RBP.dbp.clickboxWidthFactor, NP_HEIGHT * RBP.dbp.globalScale * RBP.dbp.friendlyScale * RBP.dbp.clickboxHeightFactor)
	else
		Plate:SetSize(NP_WIDTH * RBP.dbp.globalScale * RBP.dbp.clickboxWidthFactor, NP_HEIGHT * RBP.dbp.globalScale * RBP.dbp.clickboxHeightFactor)
	end
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

local ClassByPlateColor = {
	[78]  = "DEATHKNIGHT",
	[104] = "DRUID",
	[75]  = "HUNTER",
	[49]  = "MAGE",
	[101] = "PALADIN",
	[110] = "PRIEST",
	[109] = "ROGUE",
	[5]   = "SHAMAN",
	[63]  = "WARLOCK",
	[84]  = "WARRIOR",
	[0]   = "FRIENDLY_PLAYER",
}

local function UpdatePlateReactionFlags(Plate, r, g, b, reaction)
	Plate.reaction = reaction
	Plate.isFriendly = reaction == 5
	Plate.classKey = ClassByPlateColor[math_floor(r * 100 + g * 10 + b)]
	Plate.healthBarColor = {r, g, b}
end

local function UpdatePlateFlags(Plate)
	local Virtual = Plate.VirtualPlate
	local r, g, b = Virtual.healthBar:GetStatusBarColor()
	local reaction = ReactionByPlateColor(r, g, b)
	UpdatePlateReactionFlags(Plate, r, g, b, reaction)
	Plate.hasRaidIcon = Virtual.raidTargetIcon:IsShown() and true
	Plate.hasEliteIcon = Virtual.eliteIcon:IsShown() and true
	Plate.hasBossIcon = Virtual.bossIcon:IsShown() and true
	Plate.levelNumber = tonumber(Virtual.levelText:GetText())
	Plate.nameString = Virtual.ogNameText:GetText()
	Virtual.newNameText:SetText(Plate.nameString)
end

local function ResetPlateFlags(Plate)
	local Virtual = Plate.VirtualPlate
	Plate.reaction = nil
	Plate.isFriendly = nil
	Plate.classKey = nil
	Plate.healthBarColor = nil
	Plate.hasRaidIcon = nil
	Plate.hasEliteIcon = nil
	Plate.hasBossIcon = nil
	Plate.levelNumber = nil
	Plate.nameString = nil
end

local function UpdateRefinedPlate(Plate)
	local Virtual = Plate.VirtualPlate
	local name = Plate.nameString
	local level = Plate.levelNumber
	if not level or level >= RBP.dbp.levelFilter or Plate.hasBossIcon then
		local totemKey = RBP.Totems[name]
		local totemCheck = RBP.dbp.TotemsCheck[totemKey]
		local blacklisted = RBP.dbp.Blacklist[name]
		if totemCheck or blacklisted then
			------------------------ TotemPlates Handling ------------------------
			local iconTexture = (totemCheck == 1 and ASSETS .. "Icons\\" .. totemKey) or (blacklisted ~= "" and blacklisted)
			if iconTexture and iconTexture ~= "" then
				if not Plate.totemPlate then
					SetupTotemPlate(Plate) -- Setup TotemPlate on the fly
				end
				Plate.totemPlate:Show()
				Plate.totemPlateIsShown = true
				Plate.totemPlate_icon:SetTexture(iconTexture)
				local healthBarHighlight = Virtual.healthBarHighlight
				healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\TotemPlate-MouseoverGlow")
				healthBarHighlight:ClearAllPoints()
				healthBarHighlight:SetPoint("CENTER", Plate.totemPlate)
				healthBarHighlight:SetSize(128*RBP.dbp.totemSize/88, 128*RBP.dbp.totemSize/88)
				if RBP.dbp.showTotemBorder then
					Plate.totemPlate_border:Show()
					if Plate.isFriendly then
						Plate.totemPlate_border:SetVertexColor(0, 1, 0)
					else
						Plate.totemPlate_border:SetVertexColor(1, 0, 0)
					end
				end
				Virtual:Show()
				Virtual.isShown = true
				Virtual.healthBar:Hide()
				Virtual.healthBarIsShown = nil
				Virtual.castBar:Hide()
				Virtual.castBarIsShown = nil
				Virtual.castBarBorder:Hide()
				Virtual.shieldCastBarBorder:Hide()
				Virtual.spellIcon:Hide()
				Virtual.levelText:Hide()
				Virtual.bossIcon:Hide()
				Virtual.raidTargetIcon:Hide()	
			end		
		else
			Virtual:Show()
			Virtual.isShown = true
			Virtual.healthBar:Show()
			Virtual.healthBarIsShown = true
			SetupCastBorder(Virtual)
			UpdateMouseoverGlow(Virtual)
			SetupThreatGlow(Virtual)
			if RBP.dbp.healthBar_progressiveTexCrop then
				Virtual.healthBarTexCrop = true				
			end
			local levelText = Virtual.levelText
			if Virtual.bossIcon:IsShown() then
				levelText:Hide()
			else
				SetupLevelText(Virtual)
				levelText:Show()
			end
			if RBP.dbp.levelText_hide then
				levelText:Hide()
			end
			local nameText = Virtual.newNameText
			if RBP.dbp.nameText_hide then
				nameText:Hide()
			else
				nameText:Show()	
			end
			local class = Plate.classKey
			local classColor	
			if class then
				if class == "FRIENDLY_PLAYER" then
					classColor = ClassByFriendName[name] and RAID_CLASS_COLORS[ClassByFriendName[name]]
					Plate.classColor = classColor
					Virtual.bossIcon:Hide()
				else
					classColor = RAID_CLASS_COLORS[class]
					Plate.classColor = classColor
					if not Virtual.bossIcon:IsShown() and level and level - RBP.playerLevel >= 10 then
						Virtual.bossIcon:Show()
						levelText:Hide()
					end
				end
				------------------------ Show Arena IDs ------------------------
				if RBP.inArena then
					local ArenaIDText = Virtual.ArenaIDText
					if class == "FRIENDLY_PLAYER" then
						local partyID = PartyID[name]
						if not partyID then
							UpdateGroupInfo()
							partyID = PartyID[name]
						end
						if partyID then
							Plate.unitToken = "party" .. partyID
							if RBP.dbp.PartyIDText_show then
								ArenaIDText:SetTextColor(unpack(RBP.dbp.PartyIDText_color))
								ArenaIDText:SetText(partyID)
								ArenaIDText:Show()
								if RBP.dbp.PartyIDText_HideLevel then
									levelText:Hide()
								end
								if RBP.dbp.PartyIDText_HideName then
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
							Plate.unitToken = "arena" .. arenaID
							if RBP.dbp.ArenaIDText_show then
								ArenaIDText:SetTextColor(unpack(RBP.dbp.ArenaIDText_color))
								ArenaIDText:SetText(arenaID)
								ArenaIDText:Show()
								if RBP.dbp.ArenaIDText_HideLevel then
									levelText:Hide()
								end
								if RBP.dbp.ArenaIDText_HideName then
									nameText:Hide()
								end
							end
						end
					end
				end
				--------------- Show class icons in instances --------------
				if RBP.inInstance then
					if class == "FRIENDLY_PLAYER" and RBP.dbp.showClassOnFriends then
						Virtual.classIcon:SetTexture(ASSETS .. "Classes\\" .. (ClassByFriendName[name] or ""))
						Virtual.classIcon:Show()
					elseif class ~= "FRIENDLY_PLAYER" and RBP.dbp.showClassOnEnemies then
						Virtual.classIcon:SetTexture(ASSETS .. "Classes\\" .. class)
						Virtual.classIcon:Show()
					end
				end
				Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_playerTex))
			else
				if RBP.dbp.enableAggroColoring and not RBP.inPvPInstance and (RBP.inPvEInstance or not RBP.dbp.disableAggroOpenworld) then
					if not Virtual.aggroOverlay then
						SetupAggroOverlay(Virtual)
					end
					UpdateAggroOverlay(Virtual)
					Virtual.threatGlow:SetTexture(nil)
					Virtual.aggroColoring = true
				else
					Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
				end
			end
			if classColor and ((class == "FRIENDLY_PLAYER" and RBP.dbp.nameText_classColorFriends) or (class ~= "FRIENDLY_PLAYER" and RBP.dbp.nameText_classColorEnemies)) then
				Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = classColor.r, classColor.g, classColor.b
			else
				Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = unpack(RBP.dbp.nameText_color)
			end
			nameText:SetTextColor(Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB)
			Virtual.nameTextIsYellow = false
			----------------- BarlessPlate Check -----------------
			if CheckBarlessPlate(Plate) then
				if class then
					if classColor and RBP.dbp.barlessPlate_classColors then
						Plate.barlessNameTextRGB = {classColor.r, classColor.g, classColor.b}
					else
						Plate.barlessNameTextRGB = RBP.dbp.barlessPlate_textColor
					end
					if RBP.dbp.barlessPlate_nameColorByHP then
						Plate.barlessNameTextGrayOut = true
					end
				else
					Plate.barlessNameTextRGB = RBP.dbp.barlessPlate_NPCtextColor
					if RBP.dbp.barlessPlate_NPCnameColorByHP then
						Plate.barlessNameTextGrayOut = true
					end					
				end
			end
			----------------- Init Enhanced Plate Stacking -----------------
			if not Plate.isFriendly then
				if RBP.dbp.stackingEnabled and not StackablePlates[Plate] then
					StackablePlates[Plate] = {xpos = 0, ypos = 0, position = 0}
				elseif Plate.hasBossIcon and RBP.dbp.clampBoss and RBP.inPvEInstance then
					Plate:SetClampedToScreen(true)
					Plate:SetClampRectInsets(80*RBP.dbp.globalScale, -80*RBP.dbp.globalScale, RBP.dbp.upperborder, 0)
				end
			end
		end	
	end
end

local function ResetRefinedPlate(Plate)
	local Virtual = Plate.VirtualPlate
	Virtual:Hide()
	Virtual:SetScale(RBP.dbp.globalScale)
	Virtual.classIcon:Hide()
	Virtual.ArenaIDText:Hide()
	Virtual.isShown = nil
	Virtual.nameTextIsYellow = nil
	Virtual.aggroColoring = nil
	Virtual.healthBarTexCrop = nil
	Plate.classColor = nil
	Plate.unitToken = nil
	Plate.totemPlateIsShown = nil
	if Plate.totemPlate then 
		Plate.totemPlate:Hide()
		Plate.totemPlate_border:Hide()
	end
	if Plate.barlessPlate then
		Plate.barlessPlate:Hide()
		Plate.barlessPlate_healthText:Hide()
		Plate.barlessPlate_raidTargetIcon:Hide()
		Plate.barlessPlate_classIcon:Hide()
	end
	Plate.isBarlessPlate = nil
	Plate.barlessPlateIsShown = nil
	Plate.BarlessHealthTextIsShown = nil
	Plate.barlessNameTextRGB = nil
	Plate.barlessNameTextGrayOut = nil
	if Virtual.aggroOverlay then
		Virtual.aggroOverlay:Hide()
	end
	StackablePlates[Plate] = nil
	Plate:SetClampedToScreen(false)
	Plate:SetClampRectInsets(0, 0, 0, 0)
	if Virtual.BGHframe then
		Virtual.BGHframe:ModifyIcon()
	else
		Virtual.shouldModifyBGH = nil
	end
end

local function PlatesSecUpdate()
	local r, g, b, reaction
	for Plate, Virtual in pairs(PlatesVisible) do
		r, g, b = Virtual.healthBar:GetStatusBarColor()
		reaction = ReactionByPlateColor(r, g, b)
		if reaction ~= Plate.reaction then
			UpdatePlateReactionFlags(Plate, r, g, b, reaction)
			ResetRefinedPlate(Plate)
			UpdateRefinedPlate(Plate)
			UpdateTarget(Plate)
			if not RBP.inCombat then
				UpdateClickboxOutOfCombat(Plate)
			end
		end
		if Virtual.aggroColoring then
			UpdateAggroOverlay(Virtual)
		end
	end
end

-- Enlarging of WorldFrame, so that nameplates are displayed even if they have slightly left the screen or are very high up, as is the case with large bosses.
RBP.ScreenWidth = GetScreenWidth() * UIParent:GetEffectiveScale()
RBP.ScreenHeight = 768
local function ExtendWorldFrameHeight(shouldExtend)
	local heightScale = shouldExtend and 50 or 1
	WorldFrame:ClearAllPoints()
	WorldFrame:SetPoint("BOTTOM")
	WorldFrame:SetWidth(RBP.ScreenWidth)
	WorldFrame:SetHeight(RBP.ScreenHeight*heightScale)
end

-- Retail-like Nameplate Stacking
-- All visible enemy nameplates are iterated and the minimum distance to the next nameplate is determined.
-- If there is no other nameplate in the immediate vicinity of the original position, the position is reset (to prevent the nameplates from rising higher and higher).
-- Depending on whether the position is to be reset or the nameplate is above or below the closest one different functions are used for a smooth movement.
local ySpeed = 3
local delta = ySpeed
local resetSpeedFactor = 1
local raiseSpeedFactor = 1
local lowerSpeedFactor = 0.8
local function UpdateStacking()
	if RBP.dbp.stackingInInstance and not RBP.inInstance then return end
    local xspace = RBP.dbp.xspace * RBP.dbp.globalScale
    local yspace = RBP.dbp.yspace * RBP.dbp.globalScale
    for Plate1, Plate1_StackData in pairs(StackablePlates) do
        local width, height = Plate1:GetSize()
		local x, y = select(4, Plate1:GetPoint(1))
		local Virtual1 = Plate1.VirtualPlate
		StackablePlates[Plate1].xpos = x
		StackablePlates[Plate1].ypos = y
        if RBP.dbp.FreezeMouseover and Virtual1.healthBarHighlight:IsShown() then  -- Freeze Mouseover Nameplate
            local x, y =  Plate1:GetCenter() -- This Coordinates are the "real" values for the center point
            local newposition = y - Plate1_StackData.ypos - RBP.dbp.originpos + height/2
            Plate1_StackData.position = newposition
            Plate1_StackData.xpos = x
            Plate1:SetClampedToScreen(true)
            Plate1:SetClampRectInsets(-2*RBP.ScreenWidth, RBP.ScreenWidth - x - width/2, RBP.ScreenHeight - y - height/2, -2*RBP.ScreenHeight)
        else
            local min = 1000
            local reset = true
            for Plate2, Plate2_StackData in pairs(StackablePlates) do
                if Plate1 ~= Plate2 then
                    local xdiff = Plate1_StackData.xpos - Plate2_StackData.xpos
                    local ydiff = Plate1_StackData.ypos + Plate1_StackData.position - Plate2_StackData.ypos - Plate2_StackData.position
                    local ydiff_origin = Plate1_StackData.ypos - Plate2_StackData.ypos - Plate2_StackData.position
                    if math_abs(xdiff) < xspace then -- only consider nameplates in xspace
                        if ydiff >= 0 and math_abs(ydiff) < min then -- find minimal distance from other Plate2 below Plate1 
                            min = math_abs(ydiff)
                        end
                        if math_abs(ydiff_origin) < yspace then
                            reset = false  -- no reset if nameplate near origin position
                        end
                    end
                end
            end
            local oldposition = Plate1_StackData.position
            local newposition = oldposition
            if oldposition >= delta and reset then
                newposition = oldposition - math_exp(-10/oldposition)*ySpeed*resetSpeedFactor
            elseif min < yspace then
                newposition = oldposition + math_exp(-min/yspace)*ySpeed*raiseSpeedFactor
            elseif (oldposition >= delta and min > yspace + delta) then
                newposition = oldposition - math_exp(-yspace/min)*ySpeed*lowerSpeedFactor
            end
            Plate1_StackData.position = newposition
            Plate1:SetClampedToScreen(true)
			if (Plate1.isTarget and RBP.dbp.clampTarget) or (Plate1.hasBossIcon and RBP.dbp.clampBoss and RBP.inPvEInstance) then
				Plate1:SetClampRectInsets(0.5*width, -0.5*width, RBP.dbp.upperborder, - Plate1_StackData.ypos - newposition - RBP.dbp.originpos + height)
			else
				Plate1:SetClampRectInsets(0.5*width, -0.5*width, -height, - Plate1_StackData.ypos - newposition - RBP.dbp.originpos + height)
			end
        end
    end
end

---------------------------------------- Settings Update Functions ----------------------------------------
function RBP:UpdateAllVirtualsScale()
	for Plate, Virtual in pairs(VirtualPlates) do
		if Plate.isTarget then
			if Plate.isFriendly then
				Virtual:SetScale(RBP.dbp.globalScale * RBP.dbp.friendlyScale * RBP.dbp.targetScale)
			else
				Virtual:SetScale(RBP.dbp.globalScale * RBP.dbp.targetScale)
			end
		else
			if Plate.isFriendly then
				Virtual:SetScale(RBP.dbp.globalScale * RBP.dbp.friendlyScale)
			else
				Virtual:SetScale(RBP.dbp.globalScale)
			end
		end
		if not self.inCombat then
			UpdateClickboxOutOfCombat(Plate)
		end
	end
end

function RBP:MoveAllShownPlates(diffX, diffY)
	for Plate, Virtual in pairs(PlatesVisible) do
		for _, Region in ipairs(Plate) do
			for i = 1, Region:GetNumPoints() do
				local point, relFrame, relPoint, xOfs, yOfs = Region:GetPoint(i)
                if relFrame == Virtual then
                    Region:SetPoint(point, Virtual, relPoint, xOfs + diffX, yOfs + diffY)
                end
			end
		end
	end
end

function RBP:UpdateAllTexts()
	for Plate, Virtual in pairs(VirtualPlates) do
		UpdateNameText(Virtual)
		SetupLevelText(Virtual)
		UpdateArenaIDText(Virtual)
	end
end

function RBP:UpdateAllHealthBars()
	for Plate, Virtual in pairs(VirtualPlates) do
		UpdateHealthBorder(Virtual)
		UpdateHealthText(Virtual)
		if Plate.classKey then
			Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_playerTex))
		else
			Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
		end
		if Virtual.aggroOverlay then
			Virtual.aggroOverlay:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
		end
		if RBP.dbp.healthText_hide then
			Virtual.healthText:Hide()
		else
			Virtual.healthText:Show()
		end
		if Virtual.healthBarIsShown and RBP.dbp.healthBar_progressiveTexCrop then
			Virtual.healthBarTexCrop = true
			local min, max = Virtual.healthBar:GetMinMaxValues()
			if max > 0 then
				local val = Virtual.healthBar:GetValue()
				Virtual.healthBarTex:SetTexCoord(0, val / max, 0, 1)
			else
				Virtual.healthBarTex:SetTexCoord(0, 1, 0, 1)
			end
		else
			Virtual.healthBarTexCrop = nil
			Virtual.healthBarTex:SetTexCoord(0, 1, 0, 1)
		end
	end
end

function RBP:UpdateAllCastBars()
	for _, Virtual in pairs(VirtualPlates) do
		Virtual.castBarTex:SetVertexColor(unpack(RBP.dbp.castBar_color))
		Virtual.castBarBorder:SetVertexColor(unpack(RBP.dbp.castBar_borderTint))
		Virtual.shieldCastBarBorder:SetVertexColor(unpack(RBP.dbp.castBar_protectedBorderTint))
		Virtual.castBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.castBar_Tex))
		UpdateCastBarBackground(Virtual)
		UpdateCastText(Virtual)
		UpdateCastTimer(Virtual)
		if RBP.dbp.castText_hide then
			Virtual.castText:Hide()
		else
			Virtual.castText:Show()
		end
		if RBP.dbp.castTimerText_hide then
			Virtual.castTimerText:Hide()
		elseif Virtual.castText:GetText() then
			Virtual.castTimerText:Show()
		else
			Virtual.castTimerText:Hide()
		end
		if RBP.dbp.castBar_showSpark then
			Virtual.castSpark:Show()
		else
			Virtual.castSpark:Hide()
		end
		if Virtual.castBarIsShown and RBP.dbp.castBar_progressiveTexCrop then
			Virtual.castBarTexCrop = true
		else
			Virtual.castBarTexCrop = nil
		end
	end
end

function RBP:UpdateAllIcons()
	for Plate, Virtual in pairs(VirtualPlates) do
		SetupBossIcon(Virtual)
		SetupRaidTargetIcon(Virtual)
		SetupEliteIcon(Virtual)
		SetupClassIcon(Virtual)
		SetupTotemIcon(Plate)
		UpdateBarlessPlate(Plate)
	end
end

function RBP:UpdateAllBarlessPlates()
	for Plate in pairs(VirtualPlates) do
		UpdateBarlessPlate(Plate)
	end
end

function RBP:UpdateAllGlows()
	for Plate, Virtual in pairs(VirtualPlates) do
		UpdateTargetGlow(Virtual)
		SetupThreatGlow(Virtual)
		UpdateCastGlow(Virtual)
		if Plate.totemPlate_targetGlow then
			Plate.totemPlate_targetGlow:SetVertexColor(unpack(RBP.dbp.targetGlow_Tint))
		end
	end
end

function RBP:UpdateAllCastBarBorders()
	for _, Virtual in pairs(VirtualPlates) do
		SetupCastBorder(Virtual)
	end
end

function RBP:UpdateAllClickboxTextures()
	for Plate in pairs(VirtualPlates) do
		if RBP.dbp.showClickbox then
			Plate.clickboxTexture:Show()
		else
			Plate.clickboxTexture:Hide()			
		end
	end
end

function RBP:UpdateWorldFrameHeight(init)
	self.ScreenWidth = GetScreenWidth() * UIParent:GetEffectiveScale()
	if RBP.dbp.clampTarget or RBP.dbp.clampBoss then
		ExtendWorldFrameHeight(true)
	elseif not init then
		ExtendWorldFrameHeight(false)
	end
end

function RBP:UpdateAllShownPlates(updateRaidIcon)
	for Plate, Virtual in pairs(PlatesVisible) do
		if updateRaidIcon then
			Plate.hasRaidIcon = Virtual.raidTargetIcon:IsShown() and true
		end
		ResetRefinedPlate(Plate)
		UpdateRefinedPlate(Plate)
		UpdateTarget(Plate)
		if not RBP.inCombat then
			UpdateClickboxOutOfCombat(Plate)
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
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("showVKeyCastbar", 1)
	if RBP.dbp.stackingEnabled then
		SetCVar("nameplateAllowOverlap", 1)
	end
	if RBP.dbp.enableAggroColoring then
		if RBP.dbp.disableAggroOpenworld then
			SetCVar("threatWarning", 1)
		else
			SetCVar("threatWarning", 3)
		end
	end
end

function RBP:UpdateProfile()
	self:UpdateCVars()
	self:UpdateAllVirtualsScale()
	self:UpdateAllTexts()
	self:UpdateAllHealthBars()
	self:UpdateAllCastBars()
	self:UpdateAllIcons()
	self:UpdateAllBarlessPlates()
	self:UpdateAllGlows()
	self:UpdateAllCastBarBorders()
	self:BuildBlacklistUI()
	self:UpdateWorldFrameHeight()
	self:UpdateAllShownPlates()
	self:UpdateClickboxAttributes()
end

----------- Reference for Core.lua -----------
RBP.NP_WIDTH = NP_WIDTH
RBP.NP_HEIGHT = NP_HEIGHT
RBP.VirtualPlates = VirtualPlates
RBP.PlatesVisible = PlatesVisible
RBP.UpdateTarget = UpdateTarget
RBP.UpdateCastTextString = UpdateCastTextString
RBP.SetupRefinedPlate = SetupRefinedPlate
RBP.ForceLevelHide = ForceLevelHide
RBP.CheckLDWZoneIndoors = CheckLDWZoneIndoors
RBP.CheckDominateMind = CheckDominateMind
RBP.UpdateGroupInfo = UpdateGroupInfo
RBP.UpdateArenaInfo = UpdateArenaInfo
RBP.UpdateClassColorNames = UpdateClassColorNames
RBP.ExecuteClickboxSecureScript = ExecuteClickboxSecureScript
RBP.InitPlatesClickboxes = InitPlatesClickboxes
RBP.ClickboxAttributeUpdater = ClickboxAttributeUpdater
RBP.UpdateClickboxInCombat = UpdateClickboxInCombat
RBP.UpdateClickboxOutOfCombat = UpdateClickboxOutOfCombat
RBP.UpdatePlateFlags = UpdatePlateFlags
RBP.ResetPlateFlags = ResetPlateFlags
RBP.UpdateRefinedPlate = UpdateRefinedPlate
RBP.ResetRefinedPlate = ResetRefinedPlate
RBP.UpdateStacking = UpdateStacking
RBP.PlatesSecUpdate = PlatesSecUpdate