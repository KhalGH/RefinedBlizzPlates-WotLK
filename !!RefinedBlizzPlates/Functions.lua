
local AddonFile, RBP = ... -- namespace
local L = RBP.L
local hasModernAPI = RBP.hasModernAPI

----------------------------- API -----------------------------
local pairs, ipairs, unpack, tonumber, tostring, select, math_exp, math_floor, math_abs, string_format, string_char, string_sub, table_insert, SetCVar, sort, wipe, WorldFrame, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, UnitDebuff, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, RAID_CLASS_COLORS, SetMapToCurrentZone, GetCurrentMapAreaID, GetSubZoneText, SecureHandlerWrapScript, ToggleFrame, UIPanelWindows, SetUIVisibility =
      pairs, ipairs, unpack, tonumber, tostring, select, math.exp, math.floor, math.abs, string.format, string.char, string.sub, table.insert, SetCVar, sort, wipe, WorldFrame, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, UnitDebuff, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, RAID_CLASS_COLORS, SetMapToCurrentZone, GetCurrentMapAreaID, GetSubZoneText, SecureHandlerWrapScript, ToggleFrame, UIPanelWindows, SetUIVisibility

------------------------- Core Variables -------------------------
local VirtualPlates = {}      	-- Storage table: Virtual nameplate frames
local PlatesVisible = {}      	-- Storage table: currently active nameplates
local ClassByFriendName = {}  	-- Storage table: maps friendly player names (party/raid) to their class
local ArenaID = {}            	-- Storage table: maps arena names to their ID number
local PartyID = {}           	-- Storage table: maps party names to their ID number
local StackablePlates = {}    	-- Storage table: Plates filtered for improved stacking
local StackableList = {}		-- Storage table: StackablePlates entries packed in a dense array for fast iteration
local StackableCount = 0		-- Number of entries in StackableList
local PlateLevels = 3			-- Frame level difference between plates so one plate's children don't overlap the next closest plate
local ASSETS = "Interface\\AddOns\\" .. AddonFile .. "\\Assets\\"
local EventHandler = CreateFrame("Frame", nil, WorldFrame)
local SetFrameLevel = EventHandler.SetFrameLevel	-- Backup of native frame methods
local SetScale = EventHandler.SetScale 				-- Backup of native frame methods
local SetAlpha = EventHandler.SetAlpha 				-- Backup of native frame methods

------------------------- Customization Functions -------------------------
local function InitBarTextures(Virtual)
	Virtual.RBP_healthBar:SetFrameLevel(Virtual:GetFrameLevel())
	Virtual.RBP_castBarBorder:SetTexture(ASSETS .. "PlateRegions\\CastBar-Border")
	Virtual.RBP_shieldCastBarBorder:SetTexture(ASSETS .. "PlateRegions\\CastBar-ShieldBorder")
	Virtual.RBP_spellIcon:SetDrawLayer("BORDER")
	Virtual.RBP_ogHealthBarTex:SetTexture(nil)
	Virtual.RBP_ogHealthBarBorder:SetPoint("TOPLEFT", Virtual)
	Virtual.RBP_ogHealthBarBorder:SetPoint("BOTTOMRIGHT", Virtual)
	Virtual.RBP_ogHealthBarBorder:Hide()
	Virtual.RBP_ogNameText:SetPoint("BOTTOM", Virtual, "CENTER")
	Virtual.RBP_ogNameText:Hide()
	Virtual.RBP_ogCastBarTex:SetTexture(nil)
end

local function SetupThreatGlow(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_threatGlow:SetPoint("TOP", Virtual, RBP.TG_TOP_X + dbp.globalOffsetX, RBP.TG_TOP_Y + dbp.globalOffsetY)
	if dbp.healthBar_border == "Blizzard" then
		Virtual.RBP_threatGlow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
	else
		Virtual.RBP_threatGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-ThreatGlow")
	end
end

local function UpdateHealthBorder(Virtual)
	if not Virtual.RBP_healthBarBorder then return end
	local dbp = RBP.dbp
	Virtual.RBP_healthBarBorder:SetPoint("CENTER", -RBP.HB_CENTER_X, -RBP.HB_CENTER_Y)
	if dbp.healthBar_border == "Blizzard" then
		Virtual.RBP_healthBarBorder:SetTexture("Interface\\Tooltips\\Nameplate-Border")
	else
		Virtual.RBP_healthBarBorder:SetTexture(ASSETS .. "PlateRegions\\HealthBar-Border")		
	end
	Virtual.RBP_healthBarBorder:SetVertexColor(unpack(dbp.healthBar_borderTint))
end

local function SetupHealthBorder(Virtual)
	if Virtual.RBP_healthBarBorder then return end
	Virtual.RBP_healthBarBorder = Virtual.RBP_healthBar:CreateTexture(nil, "ARTWORK")
	Virtual.RBP_healthBarBorder:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
	UpdateHealthBorder(Virtual)
end

local function UpdateNameText(Virtual)
	if not Virtual.RBP_nameText then return end
	local dbp = RBP.dbp
	Virtual.RBP_nameText:SetFont(RBP.LSM:Fetch("font", dbp.nameText_font), dbp.nameText_size * RBP.NP_SCALE, dbp.nameText_outline)
	Virtual.RBP_nameText:ClearAllPoints()
	if dbp.healthBar_border == "Blizzard" then
		if dbp.nameText_anchor == "CENTER" then
			Virtual.RBP_nameText:SetPoint(dbp.nameText_anchor, dbp.nameText_offsetX - RBP.HB_CENTER_X, dbp.nameText_offsetY - RBP.HB_CENTER_Y + dbp.nameText_size * RBP.NP_SCALE * 0.5)
		else
			Virtual.RBP_nameText:SetPoint(dbp.nameText_anchor, dbp.nameText_offsetX, dbp.nameText_offsetY - RBP.HB_CENTER_Y + dbp.nameText_size * RBP.NP_SCALE * 0.5)
		end
	else
		Virtual.RBP_nameText:SetPoint(dbp.nameText_anchor, dbp.nameText_offsetX, dbp.nameText_offsetY + 0.57 * RBP.NP_SCALE)
	end
	Virtual.RBP_nameText:SetWidth(dbp.nameText_width)
	Virtual.RBP_nameText:SetJustifyH(dbp.nameText_anchor)
	Virtual.RBP_nameText:SetTextColor(unpack(dbp.nameText_color), Virtual.RBP_regionsAlpha or 1)
end

local function SetupNameText(Virtual)
	if Virtual.RBP_nameText then return end
	Virtual.RBP_nameText = Virtual.RBP_healthBar:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_nameText:SetShadowOffset(0.5, -0.5)
	Virtual.RBP_nameText:SetNonSpaceWrap(false)
	Virtual.RBP_nameText:SetWordWrap(false)
	Virtual.RBP_nameText:Hide()
	UpdateNameText(Virtual)
end

local function UpdateLevelText(Virtual)
	if not Virtual.RBP_levelText then return end
	local dbp = RBP.dbp
	Virtual.RBP_levelText:SetFont(RBP.LSM:Fetch("font", dbp.levelText_font), dbp.levelText_size * RBP.NP_SCALE, dbp.levelText_outline)
	Virtual.RBP_levelText:ClearAllPoints()
	if dbp.healthBar_border == "Blizzard" then
		if dbp.levelText_anchor == "Left" then
			Virtual.RBP_levelText:SetPoint("CENTER", Virtual.RBP_healthBar, "LEFT", dbp.levelText_offsetX - 11.03 * RBP.NP_SCALE, dbp.levelText_offsetY + 0.57 * RBP.NP_SCALE)
		elseif dbp.levelText_anchor == "Center" then
			Virtual.RBP_levelText:SetPoint("CENTER", Virtual.RBP_healthBar, "CENTER", dbp.levelText_offsetX, dbp.levelText_offsetY + 0.57 * RBP.NP_SCALE)
		else
			Virtual.RBP_levelText:SetPoint("CENTER", Virtual.RBP_healthBar, "RIGHT", dbp.levelText_offsetX + 9.15 * RBP.NP_SCALE, dbp.levelText_offsetY + 0.57 * RBP.NP_SCALE)
		end
	else
		if dbp.levelText_anchor == "Left" then
			Virtual.RBP_levelText:SetPoint("CENTER", Virtual.RBP_healthBar, "LEFT", dbp.levelText_offsetX - 8.17 * RBP.NP_SCALE, dbp.levelText_offsetY + 0.57 * RBP.NP_SCALE)
		elseif dbp.levelText_anchor == "Center" then
			Virtual.RBP_levelText:SetPoint("CENTER", Virtual.RBP_healthBar, "CENTER", dbp.levelText_offsetX, dbp.levelText_offsetY + 0.57 * RBP.NP_SCALE)
		else
			Virtual.RBP_levelText:SetPoint("CENTER", Virtual.RBP_healthBar, "RIGHT", dbp.levelText_offsetX + 8.17 * RBP.NP_SCALE, dbp.levelText_offsetY + 0.57 * RBP.NP_SCALE)
		end
	end
end

local function UpdateArenaIDText(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_ArenaIDText:SetFont(RBP.LSM:Fetch("font", dbp.ArenaIDText_font), dbp.ArenaIDText_size * RBP.NP_SCALE, dbp.ArenaIDText_outline)
	Virtual.RBP_ArenaIDText:ClearAllPoints()
	if dbp.healthBar_border == "Blizzard" then
		if dbp.ArenaIDText_anchor == "Left" then
			Virtual.RBP_ArenaIDText:SetPoint("CENTER", Virtual.RBP_healthBar, "LEFT", dbp.ArenaIDText_offsetX - 6.54 * RBP.NP_SCALE, dbp.ArenaIDText_offsetY + 0.33 * RBP.NP_SCALE)
		elseif dbp.ArenaIDText_anchor == "Center" then
			Virtual.RBP_ArenaIDText:SetPoint("CENTER", Virtual.RBP_healthBar, "CENTER", dbp.ArenaIDText_offsetX - RBP.HB_CENTER_X, dbp.ArenaIDText_offsetY + 0.33 * RBP.NP_SCALE)
		else
			Virtual.RBP_ArenaIDText:SetPoint("CENTER", Virtual.RBP_healthBar, "RIGHT", dbp.ArenaIDText_offsetX + 9.81 * RBP.NP_SCALE, dbp.ArenaIDText_offsetY + 0.66 * RBP.NP_SCALE)
		end
	else
		if dbp.ArenaIDText_anchor == "Left" then
			Virtual.RBP_ArenaIDText:SetPoint("CENTER", Virtual.RBP_healthBar, "LEFT", dbp.ArenaIDText_offsetX - 6.54 * RBP.NP_SCALE, dbp.ArenaIDText_offsetY + 0.33 * RBP.NP_SCALE)
		elseif dbp.ArenaIDText_anchor == "Center" then
			Virtual.RBP_ArenaIDText:SetPoint("CENTER", Virtual.RBP_healthBar, "CENTER", dbp.ArenaIDText_offsetX, dbp.ArenaIDText_offsetY + 0.33 * RBP.NP_SCALE)
		else
			Virtual.RBP_ArenaIDText:SetPoint("CENTER", Virtual.RBP_healthBar, "RIGHT", dbp.ArenaIDText_offsetX + 6.54 * RBP.NP_SCALE, dbp.ArenaIDText_offsetY + 0.33 * RBP.NP_SCALE)
		end
	end
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

local grayColor = {0.35, 0.35, 0.35}

local function MixColor(original, grayFraction)
	return {
		original[1] * (1 - grayFraction) + grayColor[1] * grayFraction,
		original[2] * (1 - grayFraction) + grayColor[2] * grayFraction,
		original[3] * (1 - grayFraction) + grayColor[3] * grayFraction
	}
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
		local coloredText = ""
		for i = 1, nameLen do
			local charColor
			if i >= i_start then
				charColor = grayColor
			elseif i == i_start - 1 and grayFraction > 0 then
				charColor = MixColor(Virtual.RBP_barlessNameTextRGB, grayFraction)
			else
				charColor = Virtual.RBP_barlessNameTextRGB
			end
			coloredText = coloredText .. string_format("|cff%02x%02x%02x%s|r", math_floor(charColor[1] * 255), math_floor(charColor[2] * 255), math_floor(charColor[3] * 255), chars[i])
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
	Virtual.RBP_healthText:SetPoint(dbp.healthText_anchor, dbp.healthText_offsetX, dbp.healthText_offsetY + 0.57 * RBP.NP_SCALE)
	Virtual.RBP_healthText:SetTextColor(unpack(dbp.healthText_color))
end

local function SetupHealthText(Virtual)
	if Virtual.RBP_healthText then return end
	Virtual.RBP_healthText = Virtual.RBP_healthBar:CreateFontString(nil, "OVERLAY")
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
	Virtual.RBP_healthBarBg:SetAllPoints()
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
	if dbp.showTargetGlowBorder then
		if dbp.healthBar_border == "Blizzard" then
			if dbp.targetGlow_Gradient then
				Virtual.RBP_targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-TargetGlowBlizz-Gradient")
			else
				Virtual.RBP_targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-TargetGlowBlizz")
			end
		else
			if dbp.targetGlow_Gradient then
				Virtual.RBP_targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-TargetGlow-Gradient")
			else
				Virtual.RBP_targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-TargetGlow")
			end
		end
	else
		Virtual.RBP_targetGlow:SetTexture(ASSETS .. "PlateRegions\\HealthBar-TargetGlowMinimalist")
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
	Virtual.RBP_healthBarHighlight:SetPoint("CENTER", dbp.globalOffsetX, dbp.globalOffsetY)
	if dbp.showMouseoverGlowBorder then
		if dbp.healthBar_border == "Blizzard" then
			Virtual.RBP_healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MouseoverGlowBlizz")
		else
			Virtual.RBP_healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MouseoverGlow")
		end
	else
		Virtual.RBP_healthBarHighlight:SetTexture(ASSETS .. "PlateRegions\\HealthBar-MouseoverGlowMinimalist")
	end
end

local function UpdateCastText(Virtual)
	if not Virtual.RBP_castText then return end
	local dbp = RBP.dbp
	Virtual.RBP_castText:SetFont(RBP.LSM:Fetch("font", dbp.castText_font), dbp.castText_size * RBP.NP_SCALE, dbp.castText_outline)
	Virtual.RBP_castText:SetTextColor(unpack(dbp.castText_color))
	Virtual.RBP_castText:SetJustifyH(dbp.castText_anchor)
	Virtual.RBP_castText:SetWidth(dbp.castText_width)
	Virtual.RBP_castText:ClearAllPoints()
	if dbp.healthBar_border == "Blizzard" then
		Virtual.RBP_castText:SetPoint(dbp.castText_anchor, Virtual.RBP_castBar, dbp.castText_offsetX - 7 * RBP.NP_SCALE, dbp.castText_offsetY + 0.57 * RBP.NP_SCALE)
	else
		Virtual.RBP_castText:SetPoint(dbp.castText_anchor, Virtual.RBP_castBar, dbp.castText_offsetX - 7 * RBP.NP_SCALE, dbp.castText_offsetY + 0.82 * RBP.NP_SCALE)
	end
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
	Virtual.RBP_castBarBg:SetAllPoints()
	UpdateCastBarBg(Virtual)
end

local function SetupCastText(Virtual)
	if Virtual.RBP_castText then return end
	Virtual.RBP_castText = Virtual:CreateFontString(nil, "OVERLAY")
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
	if dbp.healthBar_border == "Blizzard" then
		Virtual.RBP_castTimerText:SetPoint(dbp.castTimerText_anchor, dbp.castTimerText_offsetX - 2.5 * RBP.NP_SCALE, dbp.castTimerText_offsetY + 0.57 * RBP.NP_SCALE)
	else
		Virtual.RBP_castTimerText:SetPoint(dbp.castTimerText_anchor, dbp.castTimerText_offsetX - 2.5 * RBP.NP_SCALE, dbp.castTimerText_offsetY + 0.82 * RBP.NP_SCALE)
	end
end

local function SetupCastTimer(Virtual)
	if Virtual.RBP_castTimerText then return end
	Virtual.RBP_castTimerText = Virtual.RBP_castBar:CreateFontString(nil, "OVERLAY")
	Virtual.RBP_castTimerText:SetShadowOffset(0.5, -0.5)
	Virtual.RBP_castTimerText:Hide()
	UpdateCastTimer(Virtual)
end

local function UpdateCastTextString(Virtual, unit)
	if unit then
		local spellCasting = UnitCastingInfo(unit)
		local spellChanneling = UnitChannelInfo(unit)
		local spellName
		if spellChanneling then
			Virtual.RBP_channelingFlag = 1
			spellName = spellChanneling
		elseif spellCasting then
			Virtual.RBP_channelingFlag = 0
			spellName = spellCasting
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

local function UpdateCastBarBorder(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_castBarBorder:SetVertexColor(unpack(dbp.castBar_borderTint))
	Virtual.RBP_castBar:SetPoint("BOTTOMRIGHT", Virtual.RBP_castBarBorder, - 3.8 * RBP.NP_SCALE, 4.5 * RBP.NP_SCALE)
	if dbp.healthBar_border == "Blizzard" then
		Virtual.RBP_spellIcon:SetPoint("CENTER", Virtual.RBP_castBarBorder, "BOTTOMLEFT", 13.16 * RBP.NP_SCALE, 8.58 * RBP.NP_SCALE)
		Virtual.RBP_spellIcon:SetSize(13.73 * RBP.NP_SCALE, 13.73 * RBP.NP_SCALE)
	else
		Virtual.RBP_spellIcon:SetPoint("CENTER", Virtual.RBP_castBarBorder, "BOTTOMLEFT", 11.93 * RBP.NP_SCALE, 8.58 * RBP.NP_SCALE)
		Virtual.RBP_spellIcon:SetSize(12.91 * RBP.NP_SCALE, 12.91 * RBP.NP_SCALE)
	end
end

local function UpdateShieldCastBarBorder(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_shieldCastBarBorder:SetVertexColor(unpack(dbp.castBar_protectedBorderTint))
	Virtual.RBP_castBar:SetPoint("BOTTOMRIGHT", Virtual.RBP_castBarBorder, - 3 * RBP.NP_SCALE, 0.5 * RBP.NP_SCALE)
	if dbp.healthBar_border == "Blizzard" then
		Virtual.RBP_spellIcon:SetPoint("CENTER", Virtual.RBP_castBarBorder, "BOTTOMLEFT", 11.8 * RBP.NP_SCALE, 4.5 * RBP.NP_SCALE)
		Virtual.RBP_spellIcon:SetSize(13.73 * RBP.NP_SCALE, 13.73 * RBP.NP_SCALE)
	else
		Virtual.RBP_spellIcon:SetPoint("CENTER", Virtual.RBP_castBarBorder, "BOTTOMLEFT", 10.6 * RBP.NP_SCALE, 4.5 * RBP.NP_SCALE)
		Virtual.RBP_spellIcon:SetSize(13.73 * RBP.NP_SCALE, 13.73 * RBP.NP_SCALE)
	end
end

local function UpdateCastBarOnShow(Virtual)
	local dbp = RBP.dbp
	if dbp.castBar_showSpark then
		Virtual.RBP_castSpark:Hide()
		Virtual.RBP_castBarInitSpark = true
	end
	if Virtual.RBP_channelingFlag == 1 then
		Virtual.RBP_castBarTex:SetVertexColor(unpack(dbp.castBar_channelingColor))
	else
		Virtual.RBP_castBarTex:SetVertexColor(unpack(dbp.castBar_color))
	end
	if Virtual.RBP_shieldCastBarBorderIsShown then
		UpdateShieldCastBarBorder(Virtual)
	else
		UpdateCastBarBorder(Virtual)
	end
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
	Virtual.RBP_castGlow:SetTexture(ASSETS .. "PlateRegions\\CastBar-Glow")
	Virtual.RBP_castGlow:SetVertexColor(0.25, 0.75, 0.25)
	Virtual.RBP_castGlow:SetPoint("CENTER", Virtual.RBP_castBarBorder)
	Virtual.RBP_castGlow:SetSize(RBP.NP_WIDTH * 1.852, RBP.NP_HEIGHT * 2)
	Virtual.RBP_castGlow:Hide()
	if RBP.dbp.enableCastGlow then
		Virtual.RBP_castBar:HookScript("OnShow", function()
			local unit = Virtual.namePlateUnitToken or Virtual.RBP_unitToken
			if unit and UnitIsUnit(unit.."target", "player") and not UnitIsUnit("target", unit) and Virtual.RBP_castBarBorder:IsShown() then
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
	local firstCastVal, secondCastVal, currCastVal, maxCastVal, lastOVC, channelingCompleted, castingFailed, alpha, lastTimerTenths, texCropped
	local delayedCastBarOnShow = CreateFrame("Frame")
	delayedCastBarOnShow:SetScript("OnUpdate", function(self)
		self:Hide()
		local max = select(2, castBar:GetMinMaxValues())
		maxCastVal = max and max > 0 and max or nil
		if Virtual.RBP_healthBarIsShown and maxCastVal then
			Virtual.RBP_castBarIsShown = true
			local unit = Virtual.namePlateUnitToken or Virtual.RBP_unitToken or (Virtual.RBP_isTarget and "target")
			UpdateCastTextString(Virtual, unit)
			UpdateCastBarOnShow(Virtual)
			if RBP.dbp.castBar_progressiveTexCrop then
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
			if Virtual.RBP_shieldCastBarBorderIsShown then
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
		if maxCastVal and Virtual.RBP_healthBarIsShown and not castBar:IsShown() and Virtual.RBP_isTarget == (RBP.hasTarget and Plate:GetAlpha() == 1) then
			if Virtual.RBP_shieldCastBarBorderIsShown then
				shieldCastBarBorder:Show()
				UpdateShieldCastBarBorder(Virtual)
			else
				castBarBorder:Show()
				UpdateCastBarBorder(Virtual)
			end
			spellIcon:Show()
			castBarTexFull:Show()
			castBarRegionsFadeOut:Show()
		else
			castText:SetAlpha(1)
			castText:SetText("")			
		end
	end)
	castBar:HookScript("OnShow", function(self)
		castText:SetAlpha(1)
		castText:SetText("")
		lastTimerTenths = nil
		if castBarRegionsFadeOut:IsShown() then
			castBarRegionsFadeOut:Hide()
			castBarRegionsFadeOut.elapsed = 0
			maxCastVal = nil
			channelingCompleted = nil
			castingFailed = nil
			castBarTexFull:Hide()
			castBarTexFull:SetAlpha(1)
		end
		Virtual.RBP_shieldCastBarBorderIsShown = shieldCastBarBorder:IsShown()
		delayedCastBarOnShow:Show()
	end)
	castBar:HookScript("OnHide", function(self)
		Virtual.RBP_castBarIsShown = nil
		Virtual.RBP_castBarInitSpark = nil
		Virtual.RBP_castBarTexCrop = nil
		Virtual.RBP_channelingFlag = nil
		firstCastVal = nil
		secondCastVal = nil
		currCastVal = nil
		lastOVC = nil
		if RBP.dbp.castBar_forcedFading then
			delayedCastBarOnHide:Show()
		else
			maxCastVal = nil
			castText:SetAlpha(1)
			castText:SetText("")
		end
	end)
	castBar:HookScript("OnValueChanged", function(self, val)
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
				if lastTimerTenths ~= tenths then
					lastTimerTenths = tenths
					castTimerText:SetFormattedText("%.1f", t)
				end
			end
		end
	end)
end

local function SetupBossIcon(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_bossIcon:SetSize(dbp.bossIcon_size * RBP.NP_SCALE, dbp.bossIcon_size * RBP.NP_SCALE)
	Virtual.RBP_bossIcon:ClearAllPoints()
	if dbp.healthBar_border == "Blizzard" then
		if dbp.bossIcon_anchor == "Left" then
			Virtual.RBP_bossIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "LEFT", dbp.bossIcon_offsetX - 0.8 * RBP.NP_SCALE, dbp.bossIcon_offsetY)
		elseif dbp.bossIcon_anchor == "Top" then
			Virtual.RBP_bossIcon:SetPoint("BOTTOM", Virtual.RBP_healthBar, "TOP", dbp.bossIcon_offsetX - RBP.HB_CENTER_X, dbp.bossIcon_offsetY + 14 * RBP.NP_SCALE)
		else
			Virtual.RBP_bossIcon:SetPoint("CENTER", Virtual.RBP_healthBar, dbp.bossIcon_offsetX + 61.1 * RBP.NP_SCALE, dbp.bossIcon_offsetY + 0.5 * RBP.NP_SCALE)
		end
	else
		if dbp.bossIcon_anchor == "Left" then
			Virtual.RBP_bossIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "LEFT",  dbp.bossIcon_offsetX - 0.8 * RBP.NP_SCALE, dbp.bossIcon_offsetY)
		elseif dbp.bossIcon_anchor == "Top" then
			Virtual.RBP_bossIcon:SetPoint("BOTTOM", Virtual.RBP_healthBar, "TOP", dbp.bossIcon_offsetX, dbp.bossIcon_offsetY + 2.9 * RBP.NP_SCALE)
		else
			Virtual.RBP_bossIcon:SetPoint("LEFT", Virtual.RBP_healthBar, "RIGHT",  dbp.bossIcon_offsetX + 0.8 * RBP.NP_SCALE, dbp.bossIcon_offsetY)
		end
	end
end

local function SetupRaidTargetIcon(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_raidTargetIcon:SetSize(dbp.raidTargetIcon_size * RBP.NP_SCALE, dbp.raidTargetIcon_size * RBP.NP_SCALE)
	Virtual.RBP_raidTargetIcon:ClearAllPoints()
	if dbp.healthBar_border == "Blizzard" then
		if dbp.raidTargetIcon_anchor == "Left" then
			Virtual.RBP_raidTargetIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "LEFT", dbp.raidTargetIcon_offsetX - 2.5 * RBP.NP_SCALE, dbp.raidTargetIcon_offsetY + 0.8 * RBP.NP_SCALE)
		elseif dbp.raidTargetIcon_anchor == "Top" then
			Virtual.RBP_raidTargetIcon:SetPoint("BOTTOM", Virtual.RBP_healthBar, "TOP", dbp.raidTargetIcon_offsetX + 9 * RBP.NP_SCALE, dbp.raidTargetIcon_offsetY + 17.2 * RBP.NP_SCALE)
		else
			Virtual.RBP_raidTargetIcon:SetPoint("LEFT", Virtual.RBP_healthBar, "RIGHT", dbp.raidTargetIcon_offsetX + 19.6 * RBP.NP_SCALE, dbp.raidTargetIcon_offsetY + 0.8 * RBP.NP_SCALE)
		end
	else
		if dbp.raidTargetIcon_anchor == "Left" then
			Virtual.RBP_raidTargetIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "LEFT",  dbp.raidTargetIcon_offsetX - 2.5 * RBP.NP_SCALE, dbp.raidTargetIcon_offsetY + 0.8 * RBP.NP_SCALE)
		elseif dbp.raidTargetIcon_anchor == "Top" then
			Virtual.RBP_raidTargetIcon:SetPoint("BOTTOM", Virtual.RBP_healthBar, "TOP", dbp.raidTargetIcon_offsetX, dbp.raidTargetIcon_offsetY + 4.1 * RBP.NP_SCALE)
		else
			Virtual.RBP_raidTargetIcon:SetPoint("LEFT", Virtual.RBP_healthBar, "RIGHT",  dbp.raidTargetIcon_offsetX + 2.5 * RBP.NP_SCALE, dbp.raidTargetIcon_offsetY + 0.8 * RBP.NP_SCALE)
		end
	end
end

local function SetupEliteIcon(Virtual)
	local dbp = RBP.dbp
	Virtual.RBP_eliteIcon:SetVertexColor(unpack(dbp.eliteIcon_Tint))
	Virtual.RBP_eliteIcon:ClearAllPoints()
	if dbp.eliteIcon_style == "Modern" then
		Virtual.RBP_eliteIcon:SetTexture(ASSETS .. "PlateRegions\\ModernEliteIcon")
		Virtual.RBP_eliteIcon:SetSize(29.416 * dbp.eliteIcon_widthScale * RBP.NP_SCALE, 29.416 * dbp.eliteIcon_heightScale * RBP.NP_SCALE)
		if dbp.eliteIcon_anchor == "Left" then
			Virtual.RBP_eliteIcon:SetTexCoord(0.9, 0.1, 0.9, 0.9, 0.1, 0.1, 0.1, 0.9)
			Virtual.RBP_eliteIcon:SetPoint("LEFT", Virtual.RBP_healthBar, "LEFT", dbp.eliteIcon_offsetX - 12.665 * RBP.NP_SCALE, dbp.eliteIcon_offsetY + 0.245 * RBP.NP_SCALE)
		else
			Virtual.RBP_eliteIcon:SetTexCoord(0.1, 0.1, 0.1, 0.9, 0.9, 0.1, 0.9, 0.9)
			if dbp.healthBar_border == "Blizzard" then
				Virtual.RBP_eliteIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "RIGHT", dbp.eliteIcon_offsetX + 29.824 * RBP.NP_SCALE, dbp.eliteIcon_offsetY + 0.245 * RBP.NP_SCALE)
			else
				Virtual.RBP_eliteIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "RIGHT", dbp.eliteIcon_offsetX + 12.665 * RBP.NP_SCALE, dbp.eliteIcon_offsetY + 0.245 * RBP.NP_SCALE)
			end
		end
	elseif dbp.eliteIcon_style == "Minimalist" then
		Virtual.RBP_eliteIcon:SetTexture(ASSETS .. "PlateRegions\\MinimalistEliteIcon")
		Virtual.RBP_eliteIcon:SetSize(13.074 * dbp.eliteIcon_widthScale * RBP.NP_SCALE, 13.074 * dbp.eliteIcon_heightScale * RBP.NP_SCALE)
		if dbp.eliteIcon_anchor == "Left" then
			Virtual.RBP_eliteIcon:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1)
			Virtual.RBP_eliteIcon:SetPoint("LEFT", Virtual.RBP_healthBar, "LEFT", dbp.eliteIcon_offsetX - 14.708 * RBP.NP_SCALE, dbp.eliteIcon_offsetY)
		else
			Virtual.RBP_eliteIcon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
			if dbp.healthBar_border == "Blizzard" then
				Virtual.RBP_eliteIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "RIGHT", dbp.eliteIcon_offsetX + 32.276 * RBP.NP_SCALE, dbp.eliteIcon_offsetY)
			else
				Virtual.RBP_eliteIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "RIGHT", dbp.eliteIcon_offsetX + 14.708 * RBP.NP_SCALE, dbp.eliteIcon_offsetY)
			end
		end
	else
		Virtual.RBP_eliteIcon:SetTexture("Interface\\Tooltips\\elitenameplateicon")
		Virtual.RBP_eliteIcon:SetSize(37.63 * dbp.eliteIcon_widthScale * RBP.NP_SCALE, 27.52 * dbp.eliteIcon_heightScale * RBP.NP_SCALE)
		if dbp.eliteIcon_anchor == "Left" then
			Virtual.RBP_eliteIcon:SetTexCoord(0.578125, 0, 0.578125, 0.84375, 0, 0, 0, 0.84375)
			Virtual.RBP_eliteIcon:SetPoint("LEFT", Virtual.RBP_healthBar, "LEFT", dbp.eliteIcon_offsetX - RBP.NP_SCALE * 14.708, dbp.eliteIcon_offsetY - RBP.NP_SCALE * 1.226)
		else
			Virtual.RBP_eliteIcon:SetTexCoord(0, 0, 0, 0.84375, 0.578125, 0, 0.578125, 0.84375)
			if dbp.healthBar_border == "Blizzard" then
				Virtual.RBP_eliteIcon:SetPoint("CENTER", Virtual.RBP_healthBar, dbp.eliteIcon_offsetX - RBP.HB_CENTER_X + RBP.NP_WIDTH * 0.438, dbp.eliteIcon_offsetY - RBP.HB_CENTER_Y - 0.256 * RBP.NP_HEIGHT)
			else
				Virtual.RBP_eliteIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "RIGHT", dbp.eliteIcon_offsetX + RBP.NP_SCALE * 14.708, dbp.eliteIcon_offsetY - RBP.NP_SCALE * 1.226)
			end
		end
	end
end

local function SetupClassIcon(Virtual)
	local dbp = RBP.dbp
	if not Virtual.RBP_classIcon then
		Virtual.RBP_classIcon = Virtual.RBP_healthBar:CreateTexture(nil, "ARTWORK")
		Virtual.RBP_classIcon:Hide()
	end
	Virtual.RBP_classIcon:SetSize(dbp.classIcon_size * RBP.NP_SCALE, dbp.classIcon_size * RBP.NP_SCALE)
	Virtual.RBP_classIcon:ClearAllPoints()
	if dbp.healthBar_border == "Blizzard" then
		if dbp.classIcon_anchor == "Left" then
			Virtual.RBP_classIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "LEFT", dbp.classIcon_offsetX - 0.4 * RBP.NP_SCALE, dbp.classIcon_offsetY)
		elseif dbp.classIcon_anchor == "Top" then
			Virtual.RBP_classIcon:SetPoint("BOTTOM", Virtual.RBP_healthBar, "TOP", dbp.classIcon_offsetX + 9 * RBP.NP_SCALE, dbp.classIcon_offsetY + 15 * RBP.NP_SCALE)
		else
			Virtual.RBP_classIcon:SetPoint("LEFT", Virtual.RBP_healthBar, "RIGHT", dbp.classIcon_offsetX + 18 * RBP.NP_SCALE, dbp.classIcon_offsetY)
		end
	else
		if dbp.classIcon_anchor == "Left" then
			Virtual.RBP_classIcon:SetPoint("RIGHT", Virtual.RBP_healthBar, "LEFT", dbp.classIcon_offsetX - 0.4 * RBP.NP_SCALE, dbp.classIcon_offsetY)
		elseif dbp.classIcon_anchor == "Top" then
			Virtual.RBP_classIcon:SetPoint("BOTTOM", Virtual.RBP_healthBar, "TOP", dbp.classIcon_offsetX, dbp.classIcon_offsetY + 2.5 * RBP.NP_SCALE)
		else
			Virtual.RBP_classIcon:SetPoint("LEFT", Virtual.RBP_healthBar, "RIGHT", dbp.classIcon_offsetX + 0.4 * RBP.NP_SCALE, dbp.classIcon_offsetY)
		end
	end
end

local function SetupCastBorder(Virtual)
	local dbp = RBP.dbp
	if dbp.healthBar_border == "Blizzard" then
		Virtual.RBP_castBar:SetSize(105.41 * RBP.NP_SCALE, 8.99 * RBP.NP_SCALE)
		Virtual.RBP_castBarBorder:SetPoint("CENTER", dbp.globalOffsetX - 0.831 * RBP.NP_SCALE, dbp.globalOffsetY - 14.7 * RBP.NP_SCALE)
		Virtual.RBP_castBarBorder:SetSize(RBP.NP_WIDTH * 1.017, RBP.NP_HEIGHT)
		Virtual.RBP_shieldCastBarBorder:SetPoint("CENTER", Virtual.RBP_castBarBorder, 0.572 * RBP.NP_SCALE, - 11.439 * RBP.NP_SCALE)
		Virtual.RBP_shieldCastBarBorder:SetSize(RBP.NP_WIDTH * 1.017, RBP.NP_HEIGHT)
		Virtual.RBP_castGlow:SetSize(RBP.NP_WIDTH * 2.034, RBP.NP_HEIGHT * 2)
	else
		Virtual.RBP_castBar:SetSize(96.01 * RBP.NP_SCALE, 8.99 * RBP.NP_SCALE)
		Virtual.RBP_castBarBorder:SetPoint("CENTER", dbp.globalOffsetX - 9.397 * RBP.NP_SCALE, dbp.globalOffsetY - 14.7 * RBP.NP_SCALE)
		Virtual.RBP_castBarBorder:SetSize(RBP.NP_WIDTH * 0.926, RBP.NP_HEIGHT)
		Virtual.RBP_shieldCastBarBorder:SetPoint("CENTER", Virtual.RBP_castBarBorder, 0.572 * RBP.NP_SCALE, - 11.439 * RBP.NP_SCALE)
		Virtual.RBP_shieldCastBarBorder:SetSize(RBP.NP_WIDTH * 0.926, RBP.NP_HEIGHT)
		Virtual.RBP_castGlow:SetSize(RBP.NP_WIDTH * 1.852, RBP.NP_HEIGHT * 2)
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

local function UpdateBarlessPlate(Virtual)
	if not Virtual.RBP_barlessPlate then return end
	local dbp = RBP.dbp
	local barlessPlate_nameText = Virtual.RBP_barlessPlate_nameText
	local barlessPlate_healthText = Virtual.RBP_barlessPlate_healthText
	local barlessPlate_classIcon = Virtual.RBP_barlessPlate_classIcon
	local barlessPlate_raidTargetIcon = Virtual.RBP_barlessPlate_raidTargetIcon
	local barlessPlate_targetGlow = Virtual.RBP_barlessPlate_targetGlow
	local healthBarHighlight = Virtual.RBP_healthBarHighlight
	if Virtual.RBP_classKey then
		local classColor = Virtual.RBP_classColor
		if classColor and dbp.barlessPlate_classColors then
			Virtual.RBP_barlessNameTextRGB = {classColor.r, classColor.g, classColor.b}
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
	Virtual.RBP_barlessPlate:SetFrameLevel(Virtual:GetFrameLevel()+1)
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
	if hasModernAPI then
		if dbp.barlessPlate_classColors and Virtual.RBP_classKey and Virtual.namePlateUnitToken then
			local _, unitClass = UnitClass(Virtual.namePlateUnitToken)
			local unitClassColor = RAID_CLASS_COLORS[unitClass]
			if unitClassColor then
				Virtual.RBP_barlessNameTextRGB = {unitClassColor.r, unitClassColor.g, unitClassColor.b}
				Virtual.RBP_barlessPlate_nameText:SetTextColor(unitClassColor.r, unitClassColor.g, unitClassColor.b)
			end
		end
	end
	if Virtual.RBP_isTarget and dbp.barlessPlate_excludeTarget then
		Virtual.RBP_healthBar:Show()
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

local function DelayedUpdate(Virtual)
	local Plate = Virtual.RealPlate
	local dbp = RBP.dbp
	Virtual.RBP_isTarget = RBP.hasTarget and Plate:GetAlpha() == 1
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
	if Virtual.RBP_isShown and not Virtual.RBP_isFriendly and not dbp.stackingEnabled then
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
	Virtual.RBP_firstProcessing = nil
end

local function SetupDelayedUpdater(Virtual)
	if Virtual.RBP_delayedUpdater then return end
	Virtual.RBP_delayedUpdater = CreateFrame("Frame")
	Virtual.RBP_delayedUpdater:Hide()
	Virtual.RBP_delayedUpdater:SetScript("OnUpdate", function(self)
		self:Hide()
		DelayedUpdate(Virtual)
	end)
end

local function UpdateRefinedPlateDelayed(Virtual)
	Virtual.RBP_delayedUpdater:Show()
end

RBP.GlobalDelayedUpdater = CreateFrame("Frame")
RBP.GlobalDelayedUpdater:Hide()
RBP.GlobalDelayedUpdater:SetScript("OnUpdate", function(self)
	self:Hide()
	for _, Virtual in pairs(PlatesVisible) do
		DelayedUpdate(Virtual)
	end
end)

local function UpdateNonTargetAlpha()
	if not RBP.hasTarget then return end
	for Plate in pairs(PlatesVisible) do
		if Plate:GetAlpha() ~= 1 then
			Plate:SetAlpha(RBP.dbp.nonTargetAlpha)
		end
	end
end

local NonTargetAlphaDriver = CreateFrame("Frame")
function RBP:UpdateNonTargetAlphaDriver()
	if RBP.dbp.modNonTargetAlpha then
		NonTargetAlphaDriver:SetScript("OnUpdate", UpdateNonTargetAlpha)
	else
		NonTargetAlphaDriver:SetScript("OnUpdate", nil)
	end
end

local function SetupClickboxTexture(Plate)
	Plate.clickboxTexture = Plate:CreateTexture(nil, "OVERLAY")
	Plate.clickboxTexture:SetTexture(0.8,0.1,0.1,0.5)
	Plate.clickboxTexture:SetAllPoints(Plate)
	if not RBP.dbp.showClickbox then
		Plate.clickboxTexture:Hide()
	end
end

local function SetupRefinedPlate(Virtual)
	Virtual.RBP_threatGlow, Virtual.RBP_ogHealthBarBorder, Virtual.RBP_castBarBorder, Virtual.RBP_shieldCastBarBorder, Virtual.RBP_spellIcon, Virtual.RBP_healthBarHighlight, Virtual.RBP_ogNameText, Virtual.RBP_levelText, Virtual.RBP_bossIcon, Virtual.RBP_raidTargetIcon, Virtual.RBP_eliteIcon = Virtual:GetRegions()
	Virtual.RBP_healthBar, Virtual.RBP_castBar = Virtual:GetChildren()
	Virtual.RBP_ogHealthBarTex = Virtual.RBP_healthBar:GetRegions()
	Virtual.RBP_ogCastBarTex = Virtual.RBP_castBar:GetRegions()
	Virtual.RBP_healthBar.VirtualPlate = Virtual
	Virtual.RBP_firstProcessing = true
	InitBarTextures(Virtual)
	SetupThreatGlow(Virtual)
	SetupHealthBorder(Virtual)
	SetupNameText(Virtual)
	UpdateLevelText(Virtual)
	SetupArenaIDText(Virtual)
	SetupTargetGlow(Virtual)
	SetupHealthText(Virtual)
	SetupHealthBarTex(Virtual)
	SetupHealthBarBg(Virtual)
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
	SetupCastBorder(Virtual)
	SetupDelayedUpdater(Virtual)
	SetupClickboxTexture(Virtual.RealPlate)
end

local firstChecked
local ForceLevelHideHandler = CreateFrame("Frame")
ForceLevelHideHandler:Hide()
ForceLevelHideHandler:SetScript("OnUpdate", function(self)
	firstChecked = false
	for _, Virtual in pairs(PlatesVisible) do
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
		name = name:match("([^%-]+).*") -- remove realm suffix
		if name and class then
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

local NAMEPLATE_CLASS_COLORS = {
    ["DEATHKNIGHT"] = {0.768625762313600, 0.117646798491480, 0.227450475096700},
    ["DRUID"]       = {0.999997803010050, 0.486273437738420, 0.039215601980686},
    ["HUNTER"]      = {0.666665202006700, 0.827449142932890, 0.447057843208310},
    ["MAGE"]        = {0.407842241227630, 0.799998223781590, 0.937252819538120},
    ["PALADIN"]     = {0.956860642880200, 0.549018383026120, 0.729410171508790},
    ["PRIEST"]      = {0.999997803010050, 0.999997794628140, 0.999997794628140},
    ["ROGUE"]       = {0.999997803010050, 0.956860661506650, 0.407842248678210},
    ["SHAMAN"]      = {0.000000000000000, 0.439214706420900, 0.866664767265320},
    ["WARLOCK"]     = {0.576469321735200, 0.509802818298340, 0.788233578205110},
    ["WARRIOR"]     = {0.776468882337210, 0.607841789722440, 0.427450031042100},
}

local function UpdateClassColor(Virtual)
	local class = Virtual.RBP_classKey
	local dbp = RBP.dbp
	Virtual.RBP_friendColor = nil
	Virtual.RBP_classColor = nil
	if class then
		if class == "FRIENDLY_PLAYER" then
			local friendClass = ClassByFriendName[Virtual.RBP_nameString]
			if friendClass then
				Virtual.RBP_classColor = RAID_CLASS_COLORS[friendClass]
				if dbp.healthBar_friendClassColor then
					Virtual.RBP_friendColor = NAMEPLATE_CLASS_COLORS[friendClass]
				else
					Virtual.RBP_friendColor = dbp.healthBar_friendColor
				end
			end
		else
			Virtual.RBP_classColor = RAID_CLASS_COLORS[class]
		end
	end
	local classColor = Virtual.RBP_classColor
	if classColor and ((class == "FRIENDLY_PLAYER" and dbp.nameText_classColorFriends) or (class ~= "FRIENDLY_PLAYER" and dbp.nameText_classColorEnemies)) then
		Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB = classColor.r, classColor.g, classColor.b
	else
		Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB = unpack(dbp.nameText_color)
	end
	Virtual.RBP_nameText:SetTextColor(Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB, Virtual.RBP_regionsAlpha or 1)
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
	if Virtual.RBP_lowHp then
		Virtual.RBP_healthBarTex:SetVertexColor(unpack(RBP.dbp.lowHpColor_color))
	elseif Virtual.RBP_aggroColoring then
		local aggroStatus = GetAggroStatus(Virtual.RBP_threatGlow)
		if aggroStatus > 0 then
			if aggroStatus == 3 then
				Virtual.RBP_healthBarTex:SetVertexColor(unpack(RBP.dbp.aggroColor))
			elseif aggroStatus == 2 then
				Virtual.RBP_healthBarTex:SetVertexColor(unpack(RBP.dbp.losingAggroColor))
			elseif aggroStatus == 1 then
				Virtual.RBP_healthBarTex:SetVertexColor(unpack(RBP.dbp.gainingAggroColor))
			end
		else
			Virtual.RBP_healthBarTex:SetVertexColor(unpack(Virtual.RBP_healthBarColor))		
		end
	else
		if Virtual.RBP_classKey == "FRIENDLY_PLAYER" and Virtual.RBP_friendColor then
			Virtual.RBP_healthBarTex:SetVertexColor(unpack(Virtual.RBP_friendColor))
		else
			Virtual.RBP_healthBarTex:SetVertexColor(unpack(Virtual.RBP_healthBarColor))
		end
	end
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
	if not Virtual.RBP_isShown or (Virtual.RBP_isFriendly and dbp.friendlyClickthrough and RBP.inInstance) or (Virtual.RBP_isBarlessPlate and Virtual.RBP_barlessHideNameText) then
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
	Virtual.RBP_healthBarColor = {r, g, b}
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
	Virtual.RBP_isTarget = nil
	Virtual.RBP_reaction = nil
	Virtual.RBP_isFriendly = nil
	Virtual.RBP_classKey = nil
	Virtual.RBP_healthBarColor = nil
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

local function SetRegionsAlpha(Virtual, alpha)
	Virtual.RBP_healthBarBorder:SetAlpha(alpha)
	Virtual.RBP_nameText:SetAlpha(alpha)
	Virtual.RBP_healthText:SetAlpha(alpha)
	Virtual.RBP_castBarBorder:SetAlpha(alpha)
	Virtual.RBP_castTimerText:SetAlpha(alpha)
	Virtual.RBP_castText:SetAlpha(alpha)
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
	Virtual.RBP_healthBar:SetPoint("BOTTOMLEFT", Virtual, RBP.HB_BOTTOMLEFT_X + dbp.globalOffsetX, RBP.HB_BOTTOMLEFT_Y + dbp.globalOffsetY)
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
			Virtual.RBP_healthBarIsShown = true
			SetupCastBorder(Virtual)
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
				--------------- Show class icons in instances --------------
				if RBP.inInstance then
					if class == "FRIENDLY_PLAYER" and dbp.showClassOnFriends then
						Virtual.RBP_classIcon:SetTexture(ASSETS .. "Classes\\" .. (ClassByFriendName[name] or ""))
						Virtual.RBP_classIcon:Show()
					elseif class ~= "FRIENDLY_PLAYER" and dbp.showClassOnEnemies then
						Virtual.RBP_classIcon:SetTexture(ASSETS .. "Classes\\" .. class)
						Virtual.RBP_classIcon:Show()
					end
				end
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
			if not Virtual.RBP_isFriendly then
				local Plate = Virtual.RealPlate
				if dbp.stackingEnabled then
					AddStackablePlate(Plate)
				elseif Virtual.RBP_hasBossIcon and dbp.clampBoss and RBP.inPvEInstance then
					Plate:SetClampedToScreen(true)
					Plate:SetClampRectInsets(80 * dbp.globalScale, -80 * dbp.globalScale, dbp.upperborder, 0)
				end
			end

		end	
	end
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
	SetAlpha(Virtual, 1)
    SetRegionsAlpha(Virtual, 1)
    if Virtual.PB_parentFrame then
        Virtual.PB_parentFrame:SetAlpha(1)
    end
    Virtual.PB_stopIconUpdate = nil
	Virtual.RBP_classIcon:Hide()
	Virtual.RBP_ArenaIDText:Hide()
	Virtual.RBP_isShown = nil
	Virtual.RBP_nameTextIsYellow = nil
	Virtual.RBP_healthBarTexCrop = nil
	Virtual.RBP_raidIconIndex = nil
	Virtual.RBP_lowHpColoring = nil
	Virtual.RBP_aggroColoring = nil
	Virtual.RBP_lowHp = nil
	Virtual.RBP_classColor = nil
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
	RemoveStackablePlate(Plate)
	Plate:SetClampedToScreen(false)
	Plate:SetClampRectInsets(0, 0, 0, 0)
	Virtual.RBP_castText:SetText("")
	if Virtual.BGHframe then
		Virtual.BGHframe:ModifyIcon()
	else
		Virtual.shouldModifyBGH = nil
	end
end

local SortOrder, Depths = {}, {}
local function PlatesUpdate()
	local mouseoverName = UnitName("mouseover")
	local Depth
	for _, Virtual in pairs(PlatesVisible) do
		Depth = Virtual:GetEffectiveDepth()
		if Depth > 0 then
			SortOrder[#SortOrder + 1] = Virtual
			if Virtual.RBP_isTarget then
				Depths[Virtual] = -1
			else
				Depths[Virtual] = Depth
			end
			if Virtual.RBP_isShown then
				----------------------- Improved mouseover highlight -----------------------
				if Virtual.RBP_healthBarHighlight:IsShown() then
					if Virtual.RBP_nameString ~= mouseoverName then
						Virtual.RBP_healthBarHighlight:Hide()
					elseif not Virtual.RBP_nameTextIsYellow then
						Virtual.RBP_nameText:SetTextColor(1, 1, 0, Virtual.RBP_regionsAlpha or 1)
						Virtual.RBP_nameTextIsYellow  = true
						if Virtual.RBP_castBarIsShown and not Virtual.RBP_castText:GetText() then
							UpdateCastTextString(Virtual, "mouseover")
						end
					end
				elseif Virtual.RBP_nameTextIsYellow then
					Virtual.RBP_nameText:SetTextColor(Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB, Virtual.RBP_regionsAlpha or 1)
					Virtual.RBP_nameTextIsYellow = false
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

local PlatesUpdateModern
do
	--- Update all visible nameplates
	local depthScaling, depthFading, modifyPerspective, fadePlateBuffs, fadeNPCs, depthPivot
	local minScaleFactor, depthFadeStart, depthFadeRange, depthScaleEnd, depthFadeEnd, depthHideEnd
	local dynamicScale, alpha, virtualAlpha, regionsAlpha, pbAlpha
	function PlatesUpdateModern()
		local dbp = RBP.dbp
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
		for _, Virtual in pairs(PlatesVisible) do
			if Virtual.RBP_isShown then
				Depth = Virtual:GetEffectiveDepth()
				if Depth > 0 then
					if modifyPerspective then
						-------------------- Modified perspective based on camera depth --------------------
						if Virtual.RBP_isTarget then
							if depthFading then
								if Virtual.RBP_regionsAlpha ~= 1 then
									Virtual.RBP_regionsAlpha = 1
									SetRegionsAlpha(Virtual, 1)
								end
								if Virtual.RBP_virtualAlpha ~= 1 then
									Virtual.RBP_virtualAlpha = 1
									SetAlpha(Virtual, 1)
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
									SetRegionsAlpha(Virtual, regionsAlpha)
								end
								if Virtual.RBP_virtualAlpha ~= virtualAlpha then
									Virtual.RBP_virtualAlpha = virtualAlpha
									SetAlpha(Virtual, virtualAlpha)
								end
								if fadePlateBuffs and Virtual.PB_parentFrame and Virtual.RBP_pbAlpha ~= pbAlpha then
									Virtual.RBP_pbAlpha = pbAlpha
									Virtual.PB_parentFrame:SetAlpha(pbAlpha)
									Virtual.PB_stopIconUpdate = pbAlpha == 0 or nil
								end
							end
							if depthScaling then
								if virtualAlpha == 0 then
									Virtual.RBP_dynamicScale = minScaleFactor
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
					----------------------- Improved mouseover highlight -----------------------
					if Virtual.RBP_healthBarHighlight:IsShown() then
						if Virtual.RBP_nameString ~= mouseoverName then
							Virtual.RBP_healthBarHighlight:Hide()
						elseif not Virtual.RBP_nameTextIsYellow then
							Virtual.RBP_nameText:SetTextColor(1, 1, 0, Virtual.RBP_regionsAlpha or 1)
							Virtual.RBP_nameTextIsYellow  = true
							if Virtual.RBP_castBarIsShown and not Virtual.RBP_castText:GetText() then
								UpdateCastTextString(Virtual, "mouseover")
							end
						end
					elseif Virtual.RBP_nameTextIsYellow then
						Virtual.RBP_nameText:SetTextColor(Virtual.RBP_nameColorR, Virtual.RBP_nameColorG, Virtual.RBP_nameColorB, Virtual.RBP_regionsAlpha or 1)
						Virtual.RBP_nameTextIsYellow = false
					end
				end
			end
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

-- Retail-like Nameplate Stacking
-- All visible enemy nameplates are iterated and the minimum distance to the next nameplate is determined.
-- If there is no other nameplate in the immediate vicinity of the original position, the position is reset (to prevent the nameplates from rising higher and higher).
-- Depending on whether the position is to be reset or the nameplate is above or below the closest one different functions are used for a smooth movement.
local delta = 3
local resetSpeedFactor = 1
local raiseSpeedFactor = 1
local lowerSpeedFactor = 1
local function UpdateStacking(elapsed)
	if RBP.dbp.stackingInInstance and not RBP.inInstance then return end
	if StackableCount == 0 then return end
	local dt = elapsed or 0.016
	if dt > 0.05 then dt = 0.05 end
	local dbp = RBP.dbp
	local step = dbp.yspeed * dt
	local globalScale = dbp.globalScale
	local colliderW = dbp.xspace * globalScale
	local colliderH = dbp.yspace * globalScale
	local originY = dbp.originpos
	local clampTop = dbp.upperborder
	local freeze = dbp.FreezeMouseover
	local clampTarget = dbp.clampTarget
	local clampBoss = dbp.clampBoss
	local inPvEInstance = RBP.inPvEInstance
	local worldWidth = RBP.WorldFrameWidth
	local negWorldWidth = -2 * worldWidth
	local plateWidth = RBP.NP_WIDTH * globalScale * dbp.clickboxWidthFactor
	local plateHeight = RBP.NP_HEIGHT * globalScale * dbp.clickboxHeightFactor
	local halfWidth = plateWidth * 0.5
	local negHalfWidth = -halfWidth
	local negPlateHeight = -plateHeight
	local halfPlateHeight = plateHeight * 0.5
	local hasCollisions = StackableCount > 1
	for i = 1, StackableCount do
		local Data1 = StackableList[i]
		local Plate1 = Data1.Plate
		local Virtual1 = Plate1.VirtualPlate
		local _, _, _, x, y = Plate1:GetPoint(1)
		Data1.xpos = x
		Data1.ypos = y
		Plate1:SetClampedToScreen(true)
		if freeze and Virtual1.RBP_healthBarHighlight:IsShown() then -- Freeze Mouseover Nameplate
			local cx, cy = Plate1:GetCenter() -- actual visual center (GetPoint returns the anchor)
			Data1.position = cy - y - originY + halfPlateHeight
			Data1.xpos = cx
			Plate1:SetClampRectInsets(negWorldWidth, worldWidth - cx - halfWidth, 768 - cy - halfPlateHeight, -1536)
		else
			local gapAbove = 1000
			local isolated = true
			local offset = Data1.position or 0
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
			if offset >= delta and isolated then
				newOffset = offset - math_exp(-10 / offset) * step * resetSpeedFactor
			elseif gapAbove < colliderH then
				newOffset = offset + math_exp(-gapAbove / colliderH) * step * raiseSpeedFactor
			elseif offset >= delta and gapAbove > colliderH + delta then
				newOffset = offset - math_exp(-colliderH / gapAbove) * step * lowerSpeedFactor
			end
			Data1.position = newOffset
			local bottomInset = -y - newOffset - originY + plateHeight
			if (Virtual1.RBP_isTarget and clampTarget) or (Virtual1.RBP_hasBossIcon and clampBoss and inPvEInstance) then
				Plate1:SetClampRectInsets(halfWidth, negHalfWidth, clampTop, bottomInset)
			else
				Plate1:SetClampRectInsets(halfWidth, negHalfWidth, negPlateHeight, bottomInset)
			end
		end
	end
end

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
		Virtual.RBP_castBarBorder:SetVertexColor(unpack(dbp.castBar_borderTint))
		Virtual.RBP_shieldCastBarBorder:SetVertexColor(unpack(dbp.castBar_protectedBorderTint))
		Virtual.RBP_castBarTex:SetTexture(RBP.LSM:Fetch("statusbar", dbp.castBar_Tex))
		Virtual.RBP_castBarTexFull:SetTexture(RBP.LSM:Fetch("statusbar", dbp.castBar_Tex))
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
		elseif Virtual.RBP_castText:GetText() then
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

function RBP:UpdateAllIcons()
	for _, Virtual in pairs(VirtualPlates) do
		SetupBossIcon(Virtual)
		SetupRaidTargetIcon(Virtual)
		SetupEliteIcon(Virtual)
		SetupClassIcon(Virtual)
		SetupTotemIcon(Virtual)
		UpdateBarlessPlate(Virtual)
	end
end

function RBP:UpdateAllBarlessPlates()
	for _, Virtual in pairs(VirtualPlates) do
		UpdateBarlessPlate(Virtual)
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

function RBP:UpdateAllCastBarBorders()
	for _, Virtual in pairs(VirtualPlates) do
		SetupCastBorder(Virtual)
	end
end

function RBP:ResetDynamicScales()
	for _, Virtual in pairs(VirtualPlates) do
		Virtual.RBP_dynamicScale = nil
	end
end

function RBP:ResetAllRegionsAlpha()
	for _, Virtual in pairs(VirtualPlates) do
		SetRegionsAlpha(Virtual, 1)
		SetAlpha(Virtual, 1)
		Virtual.RBP_regionsAlpha = nil
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
	if dbp.stackingEnabled then
		SetCVar("nameplateAllowOverlap", 1)
	end
	if dbp.enableAggroColoring then
		if dbp.disableAggroOpenworld then
			SetCVar("threatWarning", 1)
		else
			SetCVar("threatWarning", 3)
		end
	end
end

function RBP:ApplyPreset()
	local dbp = RBP.dbp
	if dbp.healthBar_border == "Blizzard" then
		dbp.globalOffsetX = 0
		dbp.globalOffsetY = 0
		dbp.nameText_font = RBP.BlizzFontKey
		dbp.nameText_size = 13
		dbp.nameText_width = 250
		dbp.levelText_hide = false
		dbp.levelText_font = RBP.BlizzFontKey
		dbp.levelText_size = 11.5
		dbp.ArenaIDText_font = RBP.BlizzFontKey
		dbp.ArenaIDText_size = 10.5
		dbp.healthText_font = RBP.BlizzFontKey
		dbp.healthText_anchor = "CENTER"
		dbp.healthText_offsetX = 10.5
		dbp.castText_font = RBP.BlizzFontKey
		dbp.castText_size = 8
		dbp.castTimerText_font = RBP.BlizzFontKey
		dbp.castTimerText_size = 7.8
		dbp.healthBar_friendlyPlayerTex = "Blizzard Nameplates"
		dbp.healthBar_hostilePlayerTex = "Blizzard Nameplates"
		dbp.healthBar_npcTex = "Blizzard Nameplates"
		dbp.castBar_Tex = "Blizzard Nameplates"
		dbp.eliteIcon_anchor = "Right"
		dbp.raidTargetIcon_size = 29
		dbp.raidTargetIcon_anchor = "Top"
		dbp.classIcon_size = 29
		dbp.classIcon_anchor = "Top"
	else
		dbp.globalOffsetX = 10.5
		dbp.globalOffsetY = 21
		dbp.nameText_font = RBP.RefinedFontKey
		dbp.nameText_size = 7.5
		dbp.nameText_width = 85
		dbp.levelText_hide = true
		dbp.levelText_font = RBP.RefinedFontKey
		dbp.levelText_size = 10.5				
		dbp.healthText_font = RBP.RefinedFontKey
		dbp.ArenaIDText_font = RBP.RefinedFontKey
		dbp.ArenaIDText_size = 10
		dbp.healthText_anchor = "RIGHT"
		dbp.healthText_offsetX = 0
		dbp.castText_font = RBP.RefinedFontKey
		dbp.castText_size = 7.5
		dbp.castTimerText_font = RBP.RefinedFontKey
		dbp.castTimerText_size = 7.2
		dbp.healthBar_friendlyPlayerTex = "KhalBar"
		dbp.healthBar_hostilePlayerTex = "KhalBar"
		dbp.healthBar_npcTex = "KhalBar"
		dbp.castBar_Tex = "KhalBar"
		dbp.eliteIcon_anchor = "Left"
		dbp.raidTargetIcon_size = 22
		dbp.raidTargetIcon_anchor = "Right"
		dbp.classIcon_size = 21
		dbp.classIcon_anchor = "Left"
	end
	dbp.nameText_anchor = "CENTER"
	dbp.nameText_offsetX = 0
	dbp.nameText_offsetY = 0
	dbp.levelText_outline = ""
	dbp.levelText_anchor = "Right"
	dbp.levelText_offsetX = 0
	dbp.levelText_offsetY = 0
	dbp.ArenaIDText_anchor = "Right"
	dbp.ArenaIDText_offsetX = 0
	dbp.ArenaIDText_offsetY = 0
	dbp.healthText_offsetY = 0
	dbp.ArenaIDText_HideLevel = true
	dbp.castText_anchor = "CENTER"
	dbp.castText_outline = ""
	dbp.castText_width = 90
	dbp.castText_offsetX = 0
	dbp.castText_offsetY = 0
	dbp.castTimerText_outline = ""
	dbp.castTimerText_anchor = "RIGHT"
	dbp.castTimerText_offsetX = 0
	dbp.castTimerText_offsetY = 0
	dbp.bossIcon_anchor = "Right"
	dbp.bossIcon_size = 13
	dbp.bossIcon_offsetX = 0
	dbp.bossIcon_offsetY = 0
	dbp.eliteIcon_style = "Default"
	dbp.eliteIcon_widthScale = 1
	dbp.eliteIcon_heightScale = 1
	dbp.eliteIcon_offsetX = 0
	dbp.eliteIcon_offsetY = 0
	dbp.raidTargetIcon_offsetX = 0
	dbp.raidTargetIcon_offsetY = 0
	dbp.classIcon_offsetX = 0
	dbp.classIcon_offsetY = 0
	self:UpdateAllTexts()
	self:UpdateAllHealthBars()
	self:UpdateAllCastBars()
	self:UpdateAllIcons()
	self:UpdateAllBarlessPlates()
	self:UpdateAllGlows()
	self:UpdateAllCastBarBorders()
	self:UpdateAllShownPlates()
	self:UpdateClickboxAttributes()
end

function RBP:UpdateProfile()
	self:UpdateCVars()
	self:UpdateLDWfix()
	self:ResetDynamicScales()
	self:ResetAllRegionsAlpha()
	self:ResetPBFlags()
	self:UpdateAllVirtualsScale()
	self:UpdateAllTexts()
	self:UpdateAllHealthBars()
	self:UpdateAllCastBars()
	self:UpdateAllIcons()
	self:UpdateAllBarlessPlates()
	self:UpdateAllGlows()
	self:UpdateAllCastBarBorders()
	self:BuildBlacklistUI()
	self:UpdateAllClickboxTextures()
	self:UpdateWorldFrameHeight()
	self:UpdateAllShownPlates()
	self:UpdateNonTargetAlphaDriver()
	self:UpdateClickboxAttributes()
end

----------- Reference for Core.lua -----------
RBP.EventHandler = EventHandler
RBP.VirtualPlates = VirtualPlates
RBP.PlatesVisible = PlatesVisible
RBP.UpdateRefinedPlateDelayed = UpdateRefinedPlateDelayed
RBP.SetupRefinedPlate = SetupRefinedPlate
RBP.ForceLevelHide = ForceLevelHide
RBP.CheckLDWZoneIndoors = CheckLDWZoneIndoors
RBP.CheckDominateMind = CheckDominateMind
RBP.UpdateGroupInfo = UpdateGroupInfo
RBP.UpdateArenaInfo = UpdateArenaInfo
RBP.UpdateClassColor = UpdateClassColor
RBP.UpdateHealthBarColor = UpdateHealthBarColor
RBP.ExecuteClickboxSecureScript = ExecuteClickboxSecureScript
RBP.InitPlatesClickboxes = InitPlatesClickboxes
RBP.ClickboxAttributeUpdater = ClickboxAttributeUpdater
RBP.UpdateClickboxOutOfCombat = UpdateClickboxOutOfCombat
RBP.UpdateClickbox = UpdateClickbox
RBP.UpdatePlateFlags = UpdatePlateFlags
RBP.ResetPlateFlags = ResetPlateFlags
RBP.PlatesUpdate = PlatesUpdate
RBP.PlatesUpdateModern = PlatesUpdateModern
RBP.PlatesSecUpdate = PlatesSecUpdate
RBP.RefreshGroupVisuals = RefreshGroupVisuals
RBP.UpdateRaidIcon = UpdateRaidIcon
RBP.UpdateRefinedPlate = UpdateRefinedPlate
RBP.ResetRefinedPlate = ResetRefinedPlate
RBP.UpdateStacking = UpdateStacking
RBP.SetRegionsAlpha = SetRegionsAlpha
RBP.UpdateBarlessPlate = UpdateBarlessPlate
