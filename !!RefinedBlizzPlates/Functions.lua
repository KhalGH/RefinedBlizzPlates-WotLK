
local AddonFile, RBP = ... -- namespace

----------------------------- API -----------------------------
local ipairs, unpack, tonumber, tostring, select, math_exp, math_floor, math_abs, string_format, string_char, string_sub, table_insert, SetCVar, wipe, WorldFrame, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, RAID_CLASS_COLORS, SecureHandlerWrapScript, ToggleFrame, UIPanelWindows, SetUIVisibility =
      ipairs, unpack, tonumber, tostring, select, math.exp, math.floor, math.abs, string.format, string.char, string.sub, table.insert, SetCVar, wipe, WorldFrame, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, RAID_CLASS_COLORS, SecureHandlerWrapScript, ToggleFrame, UIPanelWindows, SetUIVisibility

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

-- Hash table mapping custom color keys to class names
local ClassByKey = {
	[761122] = "DEATHKNIGHT",
	[994803] = "DRUID",
	[668244] = "HUNTER",
	[407993] = "MAGE",
	[955472] = "PALADIN",
	[999999] = "PRIEST",
	[999540] = "ROGUE",
	[004386] = "SHAMAN",
	[575078] = "WARLOCK",
	[776042] = "WARRIOR",
	[000099] = "FRIENDLY PLAYER",
}

SetCVar("ShowClassColorInNameplate", 1) -- "Class Colors in Nameplates" must be enabled to identify enemy players

local function ReactionByPlateColor(r, g, b)
	if r < 0.01 and ((g > 0.99 and b < 0.01) or (b > 0.99 and g < 0.01)) then
		return "FRIENDLY"
	else
		return "HOSTILE"
	end
end

-- Converts normalized RGB from nameplates into a custom color key and returns the class name
local function ClassByPlateColor(r, g, b)
	local key = math_floor(r * 100) * 10000 + math_floor(g * 100) * 100 + math_floor(b * 100)
	return ClassByKey[key]
end

------------------------- Customization Functions -------------------------
local function InitBarTextures(Virtual)
	Virtual.healthBarTex:SetDrawLayer("BORDER")
	Virtual.castBarBorder:SetTexture(ASSETS .. "PlateBorders\\CastBar-Border")
	Virtual.castBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.castBar_Tex))
	Virtual.castBarTex:SetDrawLayer("BORDER")
	Virtual.ogHealthBarBorder:Hide()
	Virtual.ogNameText:Hide()
end

local function SetupThreatGlow(Virtual)
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.threatGlow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
	else
		Virtual.threatGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-ThreatGlow")
	end
end

local function SetupHealthBorder(Virtual)
	if Virtual.healthBarBorder then return end
	Virtual.healthBarBorder = Virtual.healthBar:CreateTexture(nil, "ARTWORK")
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.healthBarBorder:SetTexture("Interface\\Tooltips\\Nameplate-Border")
	else
		Virtual.healthBarBorder:SetTexture(ASSETS .. "PlateBorders\\HealthBar-Border")		
	end
	Virtual.healthBarBorder:SetVertexColor(unpack(RBP.dbp.healthBar_borderTint))
	Virtual.healthBarBorder:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
	Virtual.healthBarBorder:SetPoint("CENTER", 10.5, 9)
end

local function SetupHealthBarBackground(Virtual)
	if Virtual.healthBarBackground then return end 
	Virtual.healthBarBackground = Virtual.healthBar:CreateTexture(nil, "BACKGROUND")
	Virtual.healthBarBackground:SetTexture(ASSETS .. "PlateBorders\\NamePlate-Background")
	Virtual.healthBarBackground:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
	Virtual.healthBarBackground:SetPoint("CENTER", 10.5, 9)
end

local function SetupCastBarBackground(Virtual)
	if Virtual.castBarBackground then return end 
	Virtual.castBarBackground = Virtual.castBar:CreateTexture(nil, "BACKGROUND")
	Virtual.castBarBackground:SetTexture(ASSETS .. "PlateBorders\\NamePlate-Background")
	Virtual.castBarBackground:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
	Virtual.castBarBackground:SetPoint("CENTER", 10.5, 9)
	Virtual.castBarBackground:Hide()
end

local function UpdateNameText(Virtual)
	local nameText = Virtual.nameText
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
	if Virtual.nameText then return end
	Virtual.nameText = Virtual.healthBar:CreateFontString(nil, "OVERLAY")
	Virtual.nameText:SetShadowOffset(0.5, -0.5)
	Virtual.nameText:SetNonSpaceWrap(false)
	Virtual.nameText:SetWordWrap(false)
	Virtual.nameText:Hide()
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
	Virtual.ArenaIDText:SetShadowOffset(0.5, -0.5)
	Virtual.ArenaIDText:Hide()
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

local function UpdateHealthTextValue(healthBar)
	local Plate = healthBar.RealPlate
	local Virtual = Plate.VirtualPlate
	local min, max = healthBar:GetMinMaxValues()
	local val = healthBar:GetValue()
	if max > 0 then
		local percent = math_floor((val / max) * 100)
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

local function SetupHealthText(Virtual)
	if Virtual.healthText then return end
	Virtual.healthText = Virtual.healthBar:CreateFontString(nil, "OVERLAY")
	Virtual.healthText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.healthText_font), RBP.dbp.healthText_size, RBP.dbp.healthText_outline)
	Virtual.healthText:SetPoint(RBP.dbp.healthText_anchor, RBP.dbp.healthText_offsetX, RBP.dbp.healthText_offsetY + 0.3)
	Virtual.healthText:SetTextColor(unpack(RBP.dbp.healthText_color))
	Virtual.healthText:SetShadowOffset(0.5, -0.5)
	UpdateHealthTextValue(Virtual.healthBar)
	Virtual.healthBar:HookScript("OnValueChanged", UpdateHealthTextValue)
	Virtual.healthBar:HookScript("OnShow", UpdateHealthTextValue)
	if RBP.dbp.healthText_hide then
		Virtual.healthText:Hide()
	end
end

local function SetupTargetGlow(Virtual)
	if Virtual.targetGlow then return end
	Virtual.targetGlow = Virtual.healthBar:CreateTexture(nil, "OVERLAY")
	Virtual.targetGlow:Hide()
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlowBlizz")
		Virtual.targetGlow:SetSize(RBP.NP_WIDTH * 1.165, RBP.NP_HEIGHT)
		Virtual.targetGlow:SetPoint("CENTER", 11.33, 0.5)
	else
		Virtual.targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlow")
		Virtual.targetGlow:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
		Virtual.targetGlow:SetPoint("CENTER", 0.7, 0.5)
	end
	Virtual.targetGlow:SetVertexColor(unpack(RBP.dbp.targetGlow_Tint))
end

local function UpdateMouseoverGlow(Virtual)
	local healthBarHighlight = Virtual.healthBarHighlight
	healthBarHighlight:SetVertexColor(unpack(RBP.dbp.mouseoverGlow_Tint))
	healthBarHighlight:ClearAllPoints()
	if RBP.dbp.healthBar_border == "Blizzard" then
		healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\HealthBar-MouseoverGlowBlizz")
		healthBarHighlight:SetSize(RBP.NP_WIDTH * 1.165, RBP.NP_HEIGHT)
		healthBarHighlight:SetPoint("CENTER", 11.83 + RBP.dbp.globalOffsetX, -8.7 + RBP.dbp.globalOffsetY)
	else
		healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\HealthBar-MouseoverGlow")
		healthBarHighlight:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
		healthBarHighlight:SetPoint("CENTER", 1.2 + RBP.dbp.globalOffsetX, -8.7 + RBP.dbp.globalOffsetY)
	end	
end

local function SetupCastText(Virtual)
	if Virtual.castText then return end
	local castBar = Virtual.castBar
	Virtual.castText = castBar:CreateFontString(nil, "OVERLAY")
	Virtual.castText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.castText_font), RBP.dbp.castText_size, RBP.dbp.castText_outline)
	Virtual.castText:SetWidth(RBP.dbp.castText_width)
	Virtual.castText:SetJustifyH(RBP.dbp.castText_anchor)
	Virtual.castText:SetTextColor(unpack(RBP.dbp.castText_color))
	Virtual.castText:SetNonSpaceWrap(false)
	Virtual.castText:SetWordWrap(false)
	Virtual.castText:SetShadowOffset(0.5, -0.5)
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.castText:SetPoint(RBP.dbp.castText_anchor, RBP.dbp.castText_offsetX - 9.3, RBP.dbp.castText_offsetY + 1.6)
	else
		Virtual.castText:SetPoint(RBP.dbp.castText_anchor, RBP.dbp.castText_offsetX - 3.8, RBP.dbp.castText_offsetY + 1.6)
	end
	Virtual.castText:Hide()
	castBar.castTextDelay = castBar.castTextDelay or CreateFrame("Frame")
	castBar.castTextDelay:SetScript("OnUpdate", function(self)
		self:Hide()
		local Plate = Virtual.RealPlate
		if not Plate.barlessPlateIsShown and not Plate.totemPlateIsShown then
			local unit = Plate.namePlateUnitToken or Plate.unitToken or (Plate.isTarget and "target")
			local spellCasting, spellChanneling, spellName
			if unit then
				spellCasting = UnitCastingInfo(unit)
				spellChanneling = UnitChannelInfo(unit)
			end
			if spellChanneling then
				castBar.channeling = true
				spellName = spellChanneling
			elseif spellCasting then
				spellName = spellCasting
			end
			if spellName then
				Virtual.castBarBackground:Show()
				if not RBP.dbp.castText_hide then
					Virtual.castText:SetText(spellName)
					Virtual.castText:Show()
				else
					Virtual.castText:Hide()
				end
				if not RBP.dbp.castTimerText_hide then
					Virtual.castTimerText:Show()
				else
					Virtual.castTimerText:Hide()
				end
			else
				Virtual.castBarBackground:Hide()
				Virtual.castText:Hide()
				Virtual.castTimerText:Hide()
			end
			castBar.isShown = true
		else
			Virtual.castBar:Hide()
			Virtual.castBarBorder:Hide()
			Virtual.shieldCastBarBorder:Hide()
			Virtual.spellIcon:Hide()
			castBar.isShown = nil
		end
	end)
	castBar:HookScript("OnShow", function(self)
		self.castTextDelay:Show()
	end)
	castBar:HookScript("OnHide", function(self)
		self.channeling = nil
		self.isShown = nil
	end)
end

local function SetupCastTimer(Virtual)
	if Virtual.castTimerText then return end
	local castBar = Virtual.castBar
	Virtual.castTimerText = castBar:CreateFontString(nil, "OVERLAY")
	Virtual.castTimerText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.castTimerText_font), RBP.dbp.castTimerText_size, RBP.dbp.castTimerText_outline)
	Virtual.castTimerText:SetTextColor(unpack(RBP.dbp.castTimerText_color))
	Virtual.castTimerText:SetShadowOffset(0.5, -0.5)
	Virtual.castTimerText:SetPoint(RBP.dbp.castTimerText_anchor, RBP.dbp.castTimerText_offsetX - 2, RBP.dbp.castTimerText_offsetY + 1)
	Virtual.castTimerText:Hide()
	castBar:HookScript("OnValueChanged", function(self, val)
		if self.isShown then
			local min, max = self:GetMinMaxValues()
			if max and val then
				if self.channeling then
					Virtual.castTimerText:SetFormattedText("%.1f", val)
				else
					Virtual.castTimerText:SetFormattedText("%.1f", max - val)
				end
			end
		end
	end)
end

local function SetupCastGlow(Virtual)
	if Virtual.castGlow then return end
	Virtual.castGlow = Virtual:CreateTexture(nil, "OVERLAY")	
	Virtual.castGlow:SetTexture(ASSETS .. "PlateBorders\\CastBar-Glow")
	Virtual.castGlow:SetTexCoord(0, 0.55, 0, 1)
	if RBP.dbp.healthBar_border == "Blizzard" then
		Virtual.castGlow:SetSize(173.5, 40)
		Virtual.castGlow:SetPoint("CENTER", 2.2, -27.5 + RBP.dbp.globalOffsetY)
	else
		Virtual.castGlow:SetSize(160, 40)
		Virtual.castGlow:SetPoint("CENTER", 2.75, -27.5 + RBP.dbp.globalOffsetY)
	end
	Virtual.castGlow:SetVertexColor(0.25, 0.75, 0.25)
	Virtual.castGlow:Hide()
	if RBP.dbp.enableCastGlow then
		local castBar = Virtual.castBar
		local castBarBorder = Virtual.castBarBorder
		local Plate = Virtual.RealPlate
		castBar:HookScript("OnShow", function()
			local unit = Plate.unitToken
			if unit and UnitIsUnit(unit.."target", "player") and not UnitIsUnit("target", unit) and castBarBorder:IsShown() then
				if UnitCanAttack("player", unit) then
					Virtual.castGlow:SetVertexColor(1, 0, 0)
				else
					Virtual.castGlow:SetVertexColor(0.25, 0.75, 0.25)
				end
				Virtual.castGlow:Show()
				Virtual.castGlowIsShown = true
			end
		end)
		castBar:HookScript("OnValueChanged", function()
			if Virtual.castGlowIsShown and Plate.isTarget then
				Virtual.castGlow:Hide()
				Virtual.castGlowIsShown = false
			end
		end)
		castBar:HookScript("OnHide", function()
			Virtual.castGlow:Hide()
			Virtual.castGlowIsShown = false
		end)
	end
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
	if RBP.dbp.eliteIcon_anchor == "Left" then
		eliteIcon:SetTexCoord(0.578125, 0, 0.578125, 0.84375, 0, 0, 0, 0.84375)
		eliteIcon:SetPoint("LEFT", Virtual.healthBar, "LEFT", -18, -1.5)
	else
		eliteIcon:SetTexCoord(0, 0, 0, 0.84375, 0.578125, 0, 0.578125, 0.84375)
		if RBP.dbp.healthBar_border == "Blizzard" then
			eliteIcon:SetPoint("RIGHT", Virtual.healthBar, "RIGHT", 18, -1.5)
		else
			eliteIcon:SetPoint("RIGHT", Virtual.healthBar, "RIGHT", 39, -1)
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
		Virtual.castBarBorder:SetPoint("CENTER", RBP.dbp.globalOffsetX + 10.3, RBP.dbp.globalOffsetY -19)
		Virtual.castBarBorder:SetWidth(157)
		Virtual.shieldCastBarBorder:SetWidth(157)
	else
		Virtual.castBarBorder:SetPoint("CENTER", RBP.dbp.globalOffsetX, RBP.dbp.globalOffsetY -19)
		Virtual.castBarBorder:SetWidth(145)
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
	Plate.totemPlate:Hide()
	Plate.totemPlate_icon = Plate.totemPlate:CreateTexture(nil, "BORDER")
	Plate.totemPlate_icon:SetAllPoints(Plate.totemPlate)
	Plate.totemPlate_targetGlow = Plate.totemPlate:CreateTexture(nil, "OVERLAY")
	Plate.totemPlate_targetGlow:SetTexture(ASSETS .. "PlateBorders\\TotemPlate-TargetGlow")
	Plate.totemPlate_targetGlow:SetVertexColor(unpack(RBP.dbp.targetGlow_Tint))
	Plate.totemPlate_targetGlow:SetPoint("CENTER")
	Plate.totemPlate_targetGlow:Hide()
	Plate.totemPlate_border = Plate.totemPlate:CreateTexture(nil, "ARTWORK")
	Plate.totemPlate_border:SetTexture(ASSETS .. "PlateBorders\\TotemPlate-Border")
	Plate.totemPlate_border:SetVertexColor(1, 0, 0)
	Plate.totemPlate_border:SetAllPoints(Plate.totemPlate)
	Plate.totemPlate_border:Hide()
	SetupTotemIcon(Plate)
end

local function UpdateBarlessPlate(Plate)
	if not Plate.barlessPlate then return end
	if Plate.classKey then
		Plate.barlessPlate_nameText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.barlessPlate_textFont), RBP.dbp.barlessPlate_textSize, RBP.dbp.barlessPlate_textOutline)
		Plate.barlessPlate_nameText:SetPoint("TOP", 0, RBP.dbp.barlessPlate_offset)
		Plate.barlessPlate_healthText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.barlessPlate_textFont), RBP.dbp.barlessPlate_healthTextSize, RBP.dbp.barlessPlate_textOutline)
		Plate.barlessPlate_classIcon:SetSize(RBP.dbp.barlessPlate_classIconSize, RBP.dbp.barlessPlate_classIconSize)
		Plate.barlessPlate_classIcon:ClearAllPoints()
		if RBP.dbp.barlessPlate_classIconAnchor == "Left" then
			Plate.barlessPlate_classIcon:SetPoint("RIGHT", Plate.barlessPlate_nameText, "LEFT", RBP.dbp.barlessPlate_classIconOffsetX, RBP.dbp.barlessPlate_classIconOffsetY)
		elseif RBP.dbp.barlessPlate_classIconAnchor == "Right" then
			Plate.barlessPlate_classIcon:SetPoint("LEFT", Plate.barlessPlate_nameText, "RIGHT", RBP.dbp.barlessPlate_classIconOffsetX, RBP.dbp.barlessPlate_classIconOffsetY)
		elseif RBP.dbp.barlessPlate_classIconAnchor == "Bottom" then
			Plate.barlessPlate_classIcon:SetPoint("TOP", Plate.barlessPlate_nameText, "BOTTOM", RBP.dbp.barlessPlate_classIconOffsetX, RBP.dbp.barlessPlate_classIconOffsetY)
		else
			Plate.barlessPlate_classIcon:SetPoint("BOTTOM", Plate.barlessPlate_nameText, "TOP", RBP.dbp.barlessPlate_classIconOffsetX, RBP.dbp.barlessPlate_classIconOffsetY)
		end
	else
		Plate.barlessPlate_nameText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.barlessPlate_NPCtextFont), RBP.dbp.barlessPlate_NPCtextSize, RBP.dbp.barlessPlate_NPCtextOutline)
		Plate.barlessPlate_nameText:SetPoint("TOP", 0, RBP.dbp.barlessPlate_NPCoffset)
		Plate.barlessPlate_healthText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.barlessPlate_NPCtextFont), RBP.dbp.barlessPlate_healthTextSize, RBP.dbp.barlessPlate_NPCtextOutline)
	end
	Plate.barlessPlate_healthText:ClearAllPoints()
	if RBP.dbp.barlessPlate_healthTextAnchor == "Left" then
		Plate.barlessPlate_healthText:SetPoint("RIGHT", Plate.barlessPlate_nameText, "LEFT", RBP.dbp.barlessPlate_healthTextOffsetX, RBP.dbp.barlessPlate_healthTextOffsetY)
	elseif RBP.dbp.barlessPlate_healthTextAnchor == "Right" then
		Plate.barlessPlate_healthText:SetPoint("LEFT", Plate.barlessPlate_nameText, "RIGHT", RBP.dbp.barlessPlate_healthTextOffsetX, RBP.dbp.barlessPlate_healthTextOffsetY)
	elseif RBP.dbp.barlessPlate_healthTextAnchor == "Bottom" then
		Plate.barlessPlate_healthText:SetPoint("TOP", Plate.barlessPlate_nameText, "BOTTOM", RBP.dbp.barlessPlate_healthTextOffsetX, RBP.dbp.barlessPlate_healthTextOffsetY)
	else
		Plate.barlessPlate_healthText:SetPoint("BOTTOM", Plate.barlessPlate_nameText, "TOP", RBP.dbp.barlessPlate_healthTextOffsetX, RBP.dbp.barlessPlate_healthTextOffsetY)
	end	
	Plate.barlessPlate_raidTargetIcon:SetSize(RBP.dbp.barlessPlate_raidTargetIconSize, RBP.dbp.barlessPlate_raidTargetIconSize)
	Plate.barlessPlate_raidTargetIcon:ClearAllPoints()
	if RBP.dbp.barlessPlate_raidTargetIconAnchor == "Left" then
		Plate.barlessPlate_raidTargetIcon:SetPoint("RIGHT", Plate.barlessPlate_nameText, "LEFT", RBP.dbp.barlessPlate_raidTargetIconOffsetX, RBP.dbp.barlessPlate_raidTargetIconOffsetY)
	elseif RBP.dbp.barlessPlate_raidTargetIconAnchor == "Right" then
		Plate.barlessPlate_raidTargetIcon:SetPoint("LEFT", Plate.barlessPlate_nameText, "RIGHT", RBP.dbp.barlessPlate_raidTargetIconOffsetX, RBP.dbp.barlessPlate_raidTargetIconOffsetY)
	elseif RBP.dbp.barlessPlate_raidTargetIconAnchor == "Bottom" then
		Plate.barlessPlate_raidTargetIcon:SetPoint("TOP", Plate.barlessPlate_nameText, "BOTTOM", RBP.dbp.barlessPlate_raidTargetIconOffsetX, RBP.dbp.barlessPlate_raidTargetIconOffsetY)
	else
		Plate.barlessPlate_raidTargetIcon:SetPoint("BOTTOM", Plate.barlessPlate_nameText, "TOP", RBP.dbp.barlessPlate_raidTargetIconOffsetX, RBP.dbp.barlessPlate_raidTargetIconOffsetY)
	end
end

local function SetupBarlessPlate(Plate)
	if Plate.barlessPlate then return end
	Plate.barlessPlate = CreateFrame("Frame", nil, WorldFrame)
	Plate.barlessPlate:SetSize(1, 1)
	Plate.barlessPlate:SetPoint("TOP", Plate)
	Plate.barlessPlate:Hide()
	Plate.barlessPlate_nameText = Plate.barlessPlate:CreateFontString(nil, "OVERLAY")
	Plate.barlessPlate_nameText:SetShadowOffset(0.5, -0.5)
	Plate.barlessPlate_healthText = Plate.barlessPlate:CreateFontString(nil, "OVERLAY")
	Plate.barlessPlate_healthText:SetShadowOffset(0.5, -0.5)
	Plate.barlessPlate_healthText:Hide()
	Plate.barlessPlate_raidTargetIcon = Plate.barlessPlate:CreateTexture(nil, "BORDER")
	Plate.barlessPlate_raidTargetIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	Plate.barlessPlate_raidTargetIcon:Hide()
	Plate.barlessPlate_classIcon = Plate.barlessPlate:CreateTexture(nil, "ARTWORK")
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
	local barlessPlate = Plate.barlessPlate
	if not Plate.isTarget then
		local barlessNameText = Plate.barlessPlate_nameText
		barlessNameText:SetTextColor(unpack(Plate.barlessNameTextRGB))
		barlessNameText:SetText(Plate.nameString)
		local healthBarHighlight = Virtual.healthBarHighlight
		healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\BarlessPlate-MouseoverGlow")
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
		Virtual.castBar:Hide()
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
			Virtual:SetScale(RBP.dbp.globalScale * RBP.dbp.targetScale)
			if Plate.totemPlate_targetGlow then Plate.totemPlate_targetGlow:Show() end
		else
			Plate.isTarget = false
			Virtual.targetGlow:Hide()
			Virtual:SetScale(RBP.dbp.globalScale)
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

local function SetupAggroOverlay(Virtual)
	if Virtual.aggroOverlay then return end
	Virtual.aggroOverlay = Virtual.healthBar:CreateTexture(nil, "BORDER")
	Virtual.aggroOverlay:SetAllPoints(Virtual.healthBarTex)
	Virtual.aggroOverlay:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
    Virtual.aggroOverlay:Hide()
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
	if aggroStatus == 3 then
		aggroOverlay:SetVertexColor(unpack(RBP.dbp.aggroColor))
	elseif aggroStatus == 2 then
		aggroOverlay:SetVertexColor(unpack(RBP.dbp.losingAggroColor))
	elseif aggroStatus == 1 then
		aggroOverlay:SetVertexColor(unpack(RBP.dbp.gainingAggroColor))
	elseif aggroStatus == 0 then
		aggroOverlay:SetVertexColor(unpack(RBP.dbp.noAggroColor))
	end
	aggroOverlay:Show()
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
	SetupCastGlow(Virtual)
	SetupBossIcon(Virtual)
	SetupRaidTargetIcon(Virtual)
	SetupEliteIcon(Virtual)
	SetupClassIcon(Virtual)
	SetupCastBorder(Virtual)
	SetupTargetHandler(Plate)
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

local delayedSUIV = CreateFrame("Frame")
delayedSUIV:Hide()
delayedSUIV:SetScript("OnUpdate", function(self, elapsed)
    self.timeLeft = self.timeLeft - elapsed
    if self.timeLeft <= 0 then
        self:Hide()
		SetUIVisibility(true)
        RBP:UpdateAllShownPlates(false, true)
    end
end)
local function DelayedSetUIVisibility()
    delayedSUIV.timeLeft = 0.2
    delayedSUIV:Show()
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
		DelayedSetUIVisibility()
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
			if class == "FRIENDLY PLAYER" and ClassByFriendName[name] then
				classColor = RAID_CLASS_COLORS[ClassByFriendName[name]]
				Plate.classColor = classColor
			elseif class ~= "FRIENDLY PLAYER" then
				classColor = RAID_CLASS_COLORS[class]
				Plate.classColor = classColor
			end
		end
		Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = unpack(RBP.dbp.nameText_color)
		if classColor and ((class == "FRIENDLY PLAYER" and RBP.dbp.nameText_classColorFriends) or (class ~= "FRIENDLY PLAYER" and RBP.dbp.nameText_classColorEnemies)) then
			Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = classColor.r, classColor.g, classColor.b
		end
		Virtual.nameText:SetTextColor(Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB)
		Virtual.nameTextIsYellow = false
	end
end

-- SecureHandlers System: Manages nameplate hitbox resizing while in combat
local TriggerFrames = {}
local ResizeHitBox = CreateFrame("Frame", "ResizeHitboxSecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
ResizeHitBox:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(ResizeHitBox, "OnShow", ResizeHitBox,
	[[
	local WorldFrame = self:GetFrameRef("WorldFrame")
	local normalWidth = self:GetAttribute("normalWidth")
	local normalHeight = self:GetAttribute("normalHeight")
	local totemWidth = self:GetAttribute("totemWidth")
	local totemHeight = self:GetAttribute("totemHeight")
	local barlessWidth = self:GetAttribute("barlessWidth")
	local barlessHeight = self:GetAttribute("barlessHeight")
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
			end
		end
	end
	]]
)
TriggerFrames["ResizeHitboxSecureHandler"] = ResizeHitBox
RBP.ResizeHitBox = ResizeHitBox
local function ExecuteHitboxSecureScript()
    ToggleFrame(ResizeHitBox)
	ToggleFrame(ResizeHitBox)
end
local SetWorldFrameID0 = CreateFrame("Frame", "SetWorldFrameID0SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID0:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID0, "OnShow", SetWorldFrameID0, [[self:GetFrameRef("WorldFrame"):SetID(0)]])
TriggerFrames["SetWorldFrameID0SecureHandler"] = SetWorldFrameID0
local function SetNormalHitbox()
	if WorldFrame:GetID() ~= 0 then
		ToggleFrame(SetWorldFrameID0)
		ToggleFrame(SetWorldFrameID0)
	end
end
local SetWorldFrameID1 = CreateFrame("Frame", "SetWorldFrameID1SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID1:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID1, "OnShow", SetWorldFrameID1, [[self:GetFrameRef("WorldFrame"):SetID(1)]])
TriggerFrames["SetWorldFrameID1SecureHandler"] = SetWorldFrameID1
local function SetNullHitbox()
	if WorldFrame:GetID() ~= 1 then
		ToggleFrame(SetWorldFrameID1)
		ToggleFrame(SetWorldFrameID1)
	end
end
local SetWorldFrameID2 = CreateFrame("Frame", "SetWorldFrameID2SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID2:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID2, "OnShow", SetWorldFrameID2, [[self:GetFrameRef("WorldFrame"):SetID(2)]])
TriggerFrames["SetWorldFrameID2SecureHandler"] = SetWorldFrameID2
local function SetTotemHitbox()
	if WorldFrame:GetID() ~= 2 then
		ToggleFrame(SetWorldFrameID2)
		ToggleFrame(SetWorldFrameID2)
	end
end
local SetWorldFrameID3 = CreateFrame("Frame", "SetWorldFrameID3SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID3:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID3, "OnShow", SetWorldFrameID3, [[self:GetFrameRef("WorldFrame"):SetID(3)]])
TriggerFrames["SetWorldFrameID3SecureHandler"] = SetWorldFrameID3
local function SetBarlessHitbox()
	if WorldFrame:GetID() ~= 3 then
		ToggleFrame(SetWorldFrameID3)
		ToggleFrame(SetWorldFrameID3)
	end
end
local SetWorldFrameID5 = CreateFrame("Frame", "SetWorldFrameID5SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID5:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID5, "OnShow", SetWorldFrameID5, [[self:GetFrameRef("WorldFrame"):SetID(5)]])
TriggerFrames["SetWorldFrameID5SecureHandler"] = SetWorldFrameID5
local function InitPlatesHitboxes()
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

local function HitboxAttributeUpdater()
	if RBP.dbp.healthBar_border == "Blizzard" then
		RBP.ResizeHitBox:SetAttribute("normalWidth", NP_WIDTH * RBP.dbp.globalScale)
		RBP.ResizeHitBox:SetAttribute("normalHeight", NP_HEIGHT * RBP.dbp.globalScale)
	else
		RBP.ResizeHitBox:SetAttribute("normalWidth", NP_WIDTH * RBP.dbp.globalScale * 0.9)
		RBP.ResizeHitBox:SetAttribute("normalHeight", NP_HEIGHT * RBP.dbp.globalScale * 0.7)
	end
	RBP.ResizeHitBox:SetAttribute("totemWidth", RBP.dbp.totemSize * 1.2)
	RBP.ResizeHitBox:SetAttribute("totemHeight", RBP.dbp.totemSize * 1.2)
	RBP.ResizeHitBox:SetAttribute("barlessWidth", 2*RBP.dbp.barlessPlate_textSize + 50)
	RBP.ResizeHitBox:SetAttribute("barlessHeight", RBP.dbp.barlessPlate_textSize + 5)
end

local function UpdateHitboxInCombat(Plate)
	if not Plate.VirtualPlate.isShown or (Plate.isFriendly and RBP.dbp.friendlyClickthrough and RBP.inInstance) then
		SetNullHitbox()
	elseif Plate.totemPlateIsShown then
		SetTotemHitbox()
	elseif Plate.isBarlessPlate then
		SetBarlessHitbox()
	else
		SetNormalHitbox()
	end
	ExecuteHitboxSecureScript()
end

local function UpdateHitboxOutOfCombat(Plate)
	if not Plate.VirtualPlate.isShown or (Plate.isFriendly and RBP.dbp.friendlyClickthrough and RBP.inInstance) then
		Plate:SetSize(0.01, 0.01)
	elseif Plate.totemPlateIsShown then
		Plate:SetSize(RBP.dbp.totemSize * 1.2, RBP.dbp.totemSize * 1.2)
	elseif Plate.isBarlessPlate then
		Plate:SetSize(2*RBP.dbp.barlessPlate_textSize + 50, RBP.dbp.barlessPlate_textSize + 5)
	else
		if RBP.dbp.healthBar_border == "Blizzard" then
			Plate:SetSize(NP_WIDTH * RBP.dbp.globalScale, NP_HEIGHT * RBP.dbp.globalScale)
		else
			Plate:SetSize(NP_WIDTH * RBP.dbp.globalScale * 0.9, NP_HEIGHT * RBP.dbp.globalScale * 0.7)
		end
	end
end

local function UpdatePlateFlags(Plate)
	local Virtual = Plate.VirtualPlate
	Plate.hasRaidIcon = Virtual.raidTargetIcon:IsShown() and true
	Plate.hasEliteIcon = Virtual.eliteIcon:IsShown() and true
	Plate.hasBossIcon = Virtual.bossIcon:IsShown() and true
	Virtual.healthBarColor = {Virtual.healthBar:GetStatusBarColor()}
	Plate.isFriendly = ReactionByPlateColor(unpack(Virtual.healthBarColor)) == "FRIENDLY"
	Plate.classKey = ClassByPlateColor(unpack(Virtual.healthBarColor))
	Plate.levelNumber = tonumber(Virtual.levelText:GetText())
	Plate.nameString = Virtual.ogNameText:GetText()
	Virtual.nameText:SetText(Plate.nameString)
end

local function ResetPlateFlags(Plate)
	local Virtual = Plate.VirtualPlate
	Plate.hasRaidIcon = nil
	Plate.hasEliteIcon = nil
	Plate.hasBossIcon = nil
	Virtual.healthBarColor = nil
	Plate.isFriendly = nil
	Plate.classKey = nil
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
				healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\TotemPlate-MouseoverGlow")
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
				Virtual.castBar:Hide()
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
			SetupCastBorder(Virtual)
			UpdateMouseoverGlow(Virtual)
			SetupThreatGlow(Virtual)
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
			local healthBar = Virtual.healthBar
			local nameText = Virtual.nameText
			if RBP.dbp.nameText_hide then
				nameText:Hide()
			else
				nameText:Show()	
			end
			local class = Plate.classKey
			local classColor	
			if class then
				if class == "FRIENDLY PLAYER" then
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
					if class == "FRIENDLY PLAYER" then
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
					if class == "FRIENDLY PLAYER" and RBP.dbp.showClassOnFriends then
						Virtual.classIcon:SetTexture(ASSETS .. "Classes\\" .. (ClassByFriendName[name] or ""))
						Virtual.classIcon:Show()
					elseif class ~= "FRIENDLY PLAYER" and RBP.dbp.showClassOnEnemies then
						Virtual.classIcon:SetTexture(ASSETS .. "Classes\\" .. class)
						Virtual.classIcon:Show()
					end
				end
				Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_playerTex))
			else
				if RBP.dbp.enableAggroColoring and not Plate.isFriendly and RBP.inPvEInstance then
					if not Virtual.aggroOverlay then
						SetupAggroOverlay(Virtual)
					end
					Virtual.threatGlow:SetTexture(nil)
					Virtual.healthBarTex:SetTexture(nil)
					UpdateAggroOverlay(Virtual)
					Virtual.aggroColoring = true
				else
					Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
				end
			end
			if classColor and ((class == "FRIENDLY PLAYER" and RBP.dbp.nameText_classColorFriends) or (class ~= "FRIENDLY PLAYER" and RBP.dbp.nameText_classColorEnemies)) then
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
	Virtual.healthBar:Show()
	Virtual.ArenaIDText:Hide()
	Virtual.isShown = nil
	Virtual.nameTextIsYellow = nil
	Virtual.aggroColoring = nil
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

local DelayedUpdateAllShownPlatesHandler = CreateFrame("Frame")
DelayedUpdateAllShownPlatesHandler:Hide()
DelayedUpdateAllShownPlatesHandler:SetScript("OnUpdate", function(self)
	self:Hide()
	RBP:UpdateAllShownPlates(false, true)
end)
local function DelayedUpdateAllShownPlates()
	DelayedUpdateAllShownPlatesHandler:Show()
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
	if not RBP.dbp.stackingEnabled then return end
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
			Virtual:SetScale(RBP.dbp.globalScale * RBP.dbp.targetScale)
		else
			Virtual:SetScale(RBP.dbp.globalScale)
		end
		if not self.inCombat then
			UpdateHitboxOutOfCombat(Plate)
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
		local healthBar = Virtual.healthBar
		local healthBarBorder = Virtual.healthBarBorder
		local healthText = Virtual.healthText
		if RBP.dbp.healthBar_border == "Blizzard" then
			healthBarBorder:SetTexture("Interface\\Tooltips\\Nameplate-Border")
		else
			healthBarBorder:SetTexture(ASSETS .. "PlateBorders\\HealthBar-Border")
		end
		healthBarBorder:SetVertexColor(unpack(RBP.dbp.healthBar_borderTint))
		if Plate.classKey then
			Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_playerTex))
		else
			Virtual.healthBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
		end
		if Virtual.aggroOverlay then
			Virtual.aggroOverlay:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.healthBar_npcTex))
		end
		if RBP.dbp.healthText_hide then
			healthText:Hide()
		else
			healthText:Show()
			healthText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.healthText_font), RBP.dbp.healthText_size, RBP.dbp.healthText_outline)
			healthText:ClearAllPoints()
			healthText:SetPoint(RBP.dbp.healthText_anchor, RBP.dbp.healthText_offsetX, RBP.dbp.healthText_offsetY + 0.3)
			healthText:SetTextColor(unpack(RBP.dbp.healthText_color))
		end
	end
end

function RBP:UpdateAllCastBars()
	for _, Virtual in pairs(VirtualPlates) do
		Virtual.castBarTex:SetTexture(RBP.LSM:Fetch("statusbar", RBP.dbp.castBar_Tex))
		if not RBP.dbp.castText_hide then
			local castText = Virtual.castText
			castText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.castText_font), RBP.dbp.castText_size, RBP.dbp.castText_outline)
			castText:SetTextColor(unpack(RBP.dbp.castText_color))
			castText:SetJustifyH(RBP.dbp.castText_anchor)
			castText:SetWidth(RBP.dbp.castText_width)
			castText:ClearAllPoints()
			if RBP.dbp.healthBar_border == "Blizzard" then
				castText:SetPoint(RBP.dbp.castText_anchor, RBP.dbp.castText_offsetX - 9.3, RBP.dbp.castText_offsetY + 1.6)
			else
				castText:SetPoint(RBP.dbp.castText_anchor, RBP.dbp.castText_offsetX - 3.8, RBP.dbp.castText_offsetY + 1.6)
			end
			if Virtual.castBar:IsShown() then
				castText:Show()
			end
		else
			Virtual.castText:Hide()
		end
		if not RBP.dbp.castTimerText_hide then
			local castTimerText = Virtual.castTimerText
			castTimerText:SetFont(RBP.LSM:Fetch("font", RBP.dbp.castTimerText_font), RBP.dbp.castTimerText_size, RBP.dbp.castTimerText_outline)
			castTimerText:SetTextColor(unpack(RBP.dbp.castTimerText_color))
			castTimerText:ClearAllPoints()
			castTimerText:SetPoint(RBP.dbp.castTimerText_anchor, RBP.dbp.castTimerText_offsetX - 2, RBP.dbp.castTimerText_offsetY + 1)
			if Virtual.castBar:IsShown() then
				castTimerText:Show()
			end
		else
			Virtual.castTimerText:Hide()
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
		local targetGlow = Virtual.targetGlow
		local threatGlow = Virtual.threatGlow
		local castGlow = Virtual.castGlow
		targetGlow:SetVertexColor(unpack(RBP.dbp.targetGlow_Tint))
		if RBP.dbp.healthBar_border == "Blizzard" then
			targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlowBlizz")
			targetGlow:SetSize(self.NP_WIDTH * 1.165, self.NP_HEIGHT)
			targetGlow:SetPoint("CENTER", 11.33, 0.5)
			threatGlow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
			castGlow:SetSize(173.5, 40)
			castGlow:SetPoint("CENTER", 2.2, -27.5 + RBP.dbp.globalOffsetY)
		else
			targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlow")
			targetGlow:SetSize(self.NP_WIDTH, self.NP_HEIGHT)
			targetGlow:SetPoint("CENTER", 0.7, 0.5)
			threatGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-ThreatGlow")
			castGlow:SetSize(160, 40)
			castGlow:SetPoint("CENTER", 2.75, -27.5 + RBP.dbp.globalOffsetY)
		end
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

function RBP:UpdateWorldFrameHeight(init)
	self.ScreenWidth = GetScreenWidth() * UIParent:GetEffectiveScale()
	if RBP.dbp.clampTarget or RBP.dbp.clampBoss then
		ExtendWorldFrameHeight(true)
	elseif not init then
		ExtendWorldFrameHeight(false)
	end
end

function RBP:UpdateAllShownPlates(updateRaidIcon, updateReaction)
	for Plate, Virtual in pairs(PlatesVisible) do
		if updateRaidIcon then
			Plate.hasRaidIcon = Virtual.raidTargetIcon:IsShown() and true
		end
		if updateReaction then
			Plate.isFriendly = ReactionByPlateColor(unpack(Virtual.healthBarColor)) == "FRIENDLY"
			Plate.classKey = ClassByPlateColor(unpack(Virtual.healthBarColor))
		end
		ResetRefinedPlate(Plate)
		UpdateRefinedPlate(Plate)
		UpdateTarget(Plate)
		if not self.inCombat then
			UpdateHitboxOutOfCombat(Plate)
		end
	end
end

function RBP:UpdateHitboxAttributes()
	if not self.inCombat then
		HitboxAttributeUpdater()
	else
		self.delayedHitboxUpdate = true
	end
end

function RBP:UpdateProfile()
	if RBP.dbp.stackingEnabled then SetCVar("nameplateAllowOverlap", 1) end
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
	self:UpdateHitboxAttributes()
end

----------- Reference for Core.lua -----------
RBP.NP_WIDTH = NP_WIDTH
RBP.NP_HEIGHT = NP_HEIGHT
RBP.VirtualPlates = VirtualPlates
RBP.PlatesVisible = PlatesVisible
RBP.UpdateTarget = UpdateTarget
RBP.SetupRefinedPlate = SetupRefinedPlate
RBP.ForceLevelHide = ForceLevelHide
RBP.CheckDominateMind = CheckDominateMind
RBP.UpdateGroupInfo = UpdateGroupInfo
RBP.UpdateArenaInfo = UpdateArenaInfo
RBP.UpdateClassColorNames = UpdateClassColorNames
RBP.ExecuteHitboxSecureScript = ExecuteHitboxSecureScript
RBP.InitPlatesHitboxes = InitPlatesHitboxes
RBP.HitboxAttributeUpdater = HitboxAttributeUpdater
RBP.UpdateHitboxInCombat = UpdateHitboxInCombat
RBP.UpdateHitboxOutOfCombat = UpdateHitboxOutOfCombat
RBP.UpdatePlateFlags = UpdatePlateFlags
RBP.ResetPlateFlags = ResetPlateFlags
RBP.UpdateRefinedPlate = UpdateRefinedPlate
RBP.ResetRefinedPlate = ResetRefinedPlate
RBP.DelayedUpdateAllShownPlates = DelayedUpdateAllShownPlates
RBP.UpdateStacking = UpdateStacking
RBP.UpdateAggroOverlay = UpdateAggroOverlay