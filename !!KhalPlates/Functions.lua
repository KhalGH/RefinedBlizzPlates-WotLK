
local AddonFile, KP = ... -- namespace

----------------------------- API -----------------------------
local ipairs, unpack, tonumber, tostring, select, wipe, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, RAID_CLASS_COLORS, math_exp, math_floor, math_abs =
      ipairs, unpack, tonumber, tostring, select, wipe, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, UnitClass, UnitIsUnit, UnitCanAttack, GetNumArenaOpponents, GetNumPartyMembers, GetNumRaidMembers, GetRaidRosterInfo, RAID_CLASS_COLORS, math.exp, math.floor, math.abs

------------------------- Core Variables -------------------------
local NP_WIDTH = 156.65118520899  -- Nameplate original width (don't modify)
local NP_HEIGHT = 39.162796302247 -- Nameplate original height (don't modify)
local VirtualPlates = {}          -- Storage table: Virtual nameplate frames
local RealPlates = {}             -- Storage table: Real nameplate frames
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

-- Converts normalized RGB from nameplates into a custom color key and returns the class name
local function ClassByPlateColor(healthBar)
	local r, g, b = healthBar:GetStatusBarColor()
	local key = math_floor(r * 100) * 10000 + math_floor(g * 100) * 100 + math_floor(b * 100)
	return ClassByKey[key]
end

local function ReactionByPlateColor(healthBar)
	local r, g, b = healthBar:GetStatusBarColor()
	if r < 0.01 and ((g > 0.99 and b < 0.01) or (b > 0.99 and g < 0.01)) then
		return "FRIENDLY"
	else
		return "ENEMY"
	end
end

------------------------- Customization Functions -------------------------
local function SetupHealthBorder(healthBar)
	if healthBar.healthBarBorder then return end
	healthBar.healthBarBorder = healthBar:CreateTexture(nil, "ARTWORK")
	if KP.dbp.healthBar_border == "KhalPlates" then
		healthBar.healthBarBorder:SetTexture(ASSETS .. "PlateBorders\\HealthBar-Border")
	else
		healthBar.healthBarBorder:SetTexture("Interface\\Tooltips\\Nameplate-Border")
	end
	healthBar.healthBarBorder:SetVertexColor(unpack(KP.dbp.healthBar_borderTint))
	healthBar.healthBarBorder:SetSize(KP.NP_WIDTH, KP.NP_HEIGHT)
	healthBar.healthBarBorder:SetPoint("CENTER", 10.5, 9)
end

local function SetupBarBackground(Bar, hide)
	if Bar.BackgroundTex then return end 
	Bar.BackgroundTex = Bar:CreateTexture(nil, "BACKGROUND")
	Bar.BackgroundTex:SetTexture(ASSETS .. "PlateBorders\\NamePlate-Background")
	Bar.BackgroundTex:SetSize(KP.NP_WIDTH, KP.NP_HEIGHT)
	Bar.BackgroundTex:SetPoint("CENTER", 10.5, 9)
	if hide then
		Bar.BackgroundTex:Hide()
	end
end

local function UpdateNameText(nameText)
	if not nameText then return end
	nameText:SetFont(KP.LSM:Fetch("font", KP.dbp.nameText_font), KP.dbp.nameText_size, KP.dbp.nameText_outline)
	nameText:ClearAllPoints()
	if KP.dbp.healthBar_border == "KhalPlates" then
		nameText:SetPoint(KP.dbp.nameText_anchor, KP.dbp.nameText_offsetX + 0.2, KP.dbp.nameText_offsetY + 0.7)
	else
		if KP.dbp.nameText_anchor == "CENTER" then
			nameText:SetPoint(KP.dbp.nameText_anchor, KP.dbp.nameText_offsetX + 11.2, KP.dbp.nameText_offsetY + 17.7)
		else
			nameText:SetPoint(KP.dbp.nameText_anchor, KP.dbp.nameText_offsetX + 0.2, KP.dbp.nameText_offsetY + 0.7)
		end
	end
	nameText:SetWidth(KP.dbp.nameText_width)
	nameText:SetJustifyH(KP.dbp.nameText_anchor)
	nameText:SetTextColor(unpack(KP.dbp.nameText_color))
end

local function SetupNameText(healthBar)
	if healthBar.nameText then return end
	healthBar.nameText = healthBar:CreateFontString(nil, "OVERLAY")
	healthBar.nameText:SetShadowOffset(0.5, -0.5)
	healthBar.nameText:SetNonSpaceWrap(false)
	healthBar.nameText:SetWordWrap(false)
	healthBar.nameText:Hide()
	UpdateNameText(healthBar.nameText)
end

local function SetupLevelText(Virtual)
	if not Virtual.levelText then return end
	local levelText = Virtual.levelText
	local healthBar = Virtual.healthBar
	levelText:SetFont(KP.LSM:Fetch("font", KP.dbp.levelText_font), KP.dbp.levelText_size, KP.dbp.levelText_outline)
	levelText:ClearAllPoints()
	if KP.dbp.healthBar_border == "KhalPlates" then
		if KP.dbp.levelText_anchor == "Left" then
			levelText:SetPoint("CENTER", healthBar, "LEFT", KP.dbp.levelText_offsetX - 10 , KP.dbp.levelText_offsetY + 0.3)
		elseif KP.dbp.levelText_anchor == "Center" then
			levelText:SetPoint("CENTER", healthBar, "CENTER", KP.dbp.levelText_offsetX, KP.dbp.levelText_offsetY + 0.3)
		else
			levelText:SetPoint("CENTER", healthBar, "RIGHT", KP.dbp.levelText_offsetX + 10, KP.dbp.levelText_offsetY + 0.3)
		end
	else
		if KP.dbp.levelText_anchor == "Left" then
			levelText:SetPoint("CENTER", healthBar, "LEFT", KP.dbp.levelText_offsetX - 13.5, KP.dbp.levelText_offsetY + 0.3)
		elseif KP.dbp.levelText_anchor == "Center" then
			levelText:SetPoint("CENTER", healthBar, "CENTER", KP.dbp.levelText_offsetX + 11, KP.dbp.levelText_offsetY + 0.3)
		else
			levelText:SetPoint("CENTER", healthBar, "RIGHT", KP.dbp.levelText_offsetX + 11.2, KP.dbp.levelText_offsetY + 0.3)
		end
	end
end

local function UpdateArenaIDText(healthBar)
	local ArenaIDText = healthBar.ArenaIDText
	ArenaIDText:SetFont(KP.LSM:Fetch("font", KP.dbp.ArenaIDText_font), KP.dbp.ArenaIDText_size, KP.dbp.ArenaIDText_outline)
	ArenaIDText:ClearAllPoints()
	if KP.dbp.healthBar_border == "KhalPlates" then
		if KP.dbp.ArenaIDText_anchor == "Left" then
			ArenaIDText:SetPoint("CENTER", healthBar, "LEFT", KP.dbp.ArenaIDText_offsetX - 8, KP.dbp.ArenaIDText_offsetY + 0.4)
		elseif KP.dbp.ArenaIDText_anchor == "Center" then
			ArenaIDText:SetPoint("CENTER", healthBar, "CENTER", KP.dbp.ArenaIDText_offsetX, KP.dbp.ArenaIDText_offsetY + 0.4)
		else
			ArenaIDText:SetPoint("CENTER", healthBar, "RIGHT", KP.dbp.ArenaIDText_offsetX + 8, KP.dbp.ArenaIDText_offsetY + 0.4)
		end
	else
		if KP.dbp.ArenaIDText_anchor == "Left" then
			ArenaIDText:SetPoint("CENTER", healthBar, "LEFT", KP.dbp.ArenaIDText_offsetX - 8, KP.dbp.ArenaIDText_offsetY + 0.4)
		elseif KP.dbp.ArenaIDText_anchor == "Center" then
			ArenaIDText:SetPoint("CENTER", healthBar, "CENTER", KP.dbp.ArenaIDText_offsetX + 11, KP.dbp.ArenaIDText_offsetY + 0.4)
		else
			ArenaIDText:SetPoint("CENTER", healthBar, "RIGHT", KP.dbp.ArenaIDText_offsetX + 12, KP.dbp.ArenaIDText_offsetY + 0.4)
		end
	end
end

local function SetupArenaIDText(healthBar)
	if healthBar.ArenaIDText then return end
	healthBar.ArenaIDText = healthBar:CreateFontString(nil, "OVERLAY")
	healthBar.ArenaIDText:SetShadowOffset(0.5, -0.5)
	healthBar.ArenaIDText:Hide()
	UpdateArenaIDText(healthBar)
end

local function UpdateHealthTextValue(healthBar)
	local min, max = healthBar:GetMinMaxValues()
	local val = healthBar:GetValue()
	if max > 0 then
		local percent = math_floor((val / max) * 100)
		if percent < 100 and percent > 0 then
			healthBar.healthText:SetText(percent .. "%")
		else
			healthBar.healthText:SetText("")
		end
	else
		healthBar.healthText:SetText("")
	end
end

local function SetupHealthText(healthBar)
	if healthBar.healthText then return end
	healthBar.healthText = healthBar:CreateFontString(nil, "OVERLAY")
	healthBar.healthText:SetFont(KP.LSM:Fetch("font", KP.dbp.healthText_font), KP.dbp.healthText_size, KP.dbp.healthText_outline)
	healthBar.healthText:SetPoint(KP.dbp.healthText_anchor, KP.dbp.healthText_offsetX, KP.dbp.healthText_offsetY + 0.3)
	healthBar.healthText:SetTextColor(unpack(KP.dbp.healthText_color))
	healthBar.healthText:SetShadowOffset(0.5, -0.5)
	UpdateHealthTextValue(healthBar)
	healthBar:HookScript("OnValueChanged", UpdateHealthTextValue)
	healthBar:HookScript("OnShow", UpdateHealthTextValue)
	if KP.dbp.healthText_hide then
		healthText:Hide()
	end
end

local function SetupTargetGlow(Virtual)
	local healthBar = Virtual.healthBar
	if healthBar.targetGlow then return end
	local RealPlate = RealPlates[Virtual]
	healthBar.targetGlow = healthBar:CreateTexture(nil, "OVERLAY")
	healthBar.targetGlow:Hide()
	if KP.dbp.healthBar_border == "KhalPlates" then
		healthBar.targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlow")
		healthBar.targetGlow:SetSize(KP.NP_WIDTH, KP.NP_HEIGHT)
		healthBar.targetGlow:SetPoint("CENTER", 0.7, 0.5)
	else
		healthBar.targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlowBlizz")
		healthBar.targetGlow:SetSize(KP.NP_WIDTH * 1.165, KP.NP_HEIGHT)
		healthBar.targetGlow:SetPoint("CENTER", 11.33, 0.5)
	end
	healthBar.targetGlow:SetVertexColor(unpack(KP.dbp.targetGlow_Tint))
end

local function SetupTargetHandler(Virtual)
	if Virtual.targetHandler then return end
	local Plate = RealPlates[Virtual]
	Virtual.targetHandler = CreateFrame("Frame")
	Virtual.targetHandler:SetScript("OnUpdate", function(self)
		self:Hide()
		if Virtual.nameString == UnitName("target") and Virtual:GetAlpha() == 1 then
			Virtual.isTarget = true
			Virtual.healthBar.targetGlow:Show()
			if Plate.totemPlate then Plate.totemPlate.targetGlow:Show() end
		else
			Virtual.isTarget = false
			Virtual.healthBar.targetGlow:Hide()
			if Plate.totemPlate then Plate.totemPlate.targetGlow:Hide() end
		end
		if Virtual.isShown and not Plate.isFriendly and not KP.dbp.stackingEnabled then
			if (Virtual.isTarget and KP.dbp.clampTarget) or (Plate.isBoss and KP.dbp.clampBoss and KP.inPvEInstance) then
				Plate:SetClampRectInsets(80*KP.dbp.globalScale, -80*KP.dbp.globalScale, KP.dbp.upperborder, 0)
				Plate:SetClampedToScreen(true)
			else
				Plate:SetClampRectInsets(0, 0, 0, 0)
				Plate:SetClampedToScreen(false)
			end				
		end
	end)
end

local function SetupCastText(Virtual)
	local castBar = Virtual.castBar
	if castBar.castText then return end
	castBar.castText = castBar:CreateFontString(nil, "OVERLAY")
	castBar.castText:SetFont(KP.LSM:Fetch("font", KP.dbp.castText_font), KP.dbp.castText_size, KP.dbp.castText_outline)
	castBar.castText:SetWidth(KP.dbp.castText_width)
	castBar.castText:SetJustifyH(KP.dbp.castText_anchor)
	castBar.castText:SetTextColor(unpack(KP.dbp.castText_color))
	castBar.castText:SetNonSpaceWrap(false)
	castBar.castText:SetWordWrap(false)
	castBar.castText:SetShadowOffset(0.5, -0.5)
	if KP.dbp.healthBar_border == "KhalPlates" then
		castBar.castText:SetPoint(KP.dbp.castText_anchor, KP.dbp.castText_offsetX - 3.8, KP.dbp.castText_offsetY + 1.6)
	else
		castBar.castText:SetPoint(KP.dbp.castText_anchor, KP.dbp.castText_offsetX - 9.3, KP.dbp.castText_offsetY + 1.6)
	end
	castBar.castText:Hide()
	castBar.castTextDelay = castBar.castTextDelay or CreateFrame("Frame")
	castBar.castTextDelay:SetScript("OnUpdate", function(self)
		self:Hide()
		local Plate = RealPlates[Virtual]
		local unit = Plate.namePlateUnitToken or Plate.unitToken or (Virtual.isTarget and "target")
		local spellCasting, spellChanneling, spellName
		if unit then
			spellCasting = UnitCastingInfo(unit)
			spellChanneling = UnitChannelInfo(unit)
		end
		if spellCasting then
			castBar.channeling = false
			spellName = spellCasting
		elseif spellChanneling then
			castBar.channeling = true
			spellName = spellChanneling
		end
 		if spellName then
			castBar.BackgroundTex:Show()
			if not KP.dbp.castText_hide then
				castBar.castText:SetText(spellName)
				castBar.castText:Show()
			else
				castBar.castText:Hide()
			end
			if not KP.dbp.castTimerText_hide then
				castBar.castTimerText:Show()
			else
				castBar.castTimerText:Hide()
			end
		else
			castBar.BackgroundTex:Hide()
			castBar.castText:Hide()
			castBar.castTimerText:Hide()
		end
	end)
	castBar:HookScript("OnShow", function() castBar.castTextDelay:Show() end)
	castBar:HookScript("OnHide", function() castBar.channeling = false end)
end

local function SetupCastTimer(castBar)
	if castBar.castTimerText then return end
	castBar.castTimerText = castBar:CreateFontString(nil, "OVERLAY")
	castBar.castTimerText:SetFont(KP.LSM:Fetch("font", KP.dbp.castTimerText_font), KP.dbp.castTimerText_size, KP.dbp.castTimerText_outline)
	castBar.castTimerText:SetTextColor(unpack(KP.dbp.castTimerText_color))
	castBar.castTimerText:SetShadowOffset(0.5, -0.5)
	castBar.castTimerText:SetPoint(KP.dbp.castTimerText_anchor, KP.dbp.castTimerText_offsetX - 2, KP.dbp.castTimerText_offsetY + 1)
	castBar.castTimerText:Hide()
	castBar:HookScript("OnValueChanged", function(self, val)
		local min, max = self:GetMinMaxValues()
		if max and val then
			if self.channeling then
				self.castTimerText:SetFormattedText("%.1f", val)
			else
				self.castTimerText:SetFormattedText("%.1f", max - val)
			end
		end
	end)
end

local function SetupCastGlow(Virtual)
	if Virtual.castGlow then return end
	Virtual.castGlow = Virtual:CreateTexture(nil, "OVERLAY")	
	Virtual.castGlow:SetTexture(ASSETS .. "PlateBorders\\CastBar-Glow")
	Virtual.castGlow:SetTexCoord(0, 0.55, 0, 1)
	if KP.dbp.healthBar_border == "KhalPlates" then
		Virtual.castGlow:SetSize(160, 40)
		Virtual.castGlow:SetPoint("CENTER", 2.75, -27.5 + KP.dbp.globalOffsetY)
	else
		Virtual.castGlow:SetSize(173.5, 40)
		Virtual.castGlow:SetPoint("CENTER", 2.2, -27.5 + KP.dbp.globalOffsetY)
	end
	Virtual.castGlow:SetVertexColor(0.25, 0.75, 0.25)
	Virtual.castGlow:Hide()
	if KP.dbp.enableCastGlow then
		local castBar = select(2, Virtual:GetChildren())
		local castBarBorder = select(3, Virtual:GetRegions())
		local Plate = RealPlates[Virtual]
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
			if Virtual.castGlowIsShown and Virtual.isTarget then
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
	bossIcon:SetSize(KP.dbp.bossIcon_size, KP.dbp.bossIcon_size)
	bossIcon:ClearAllPoints()
	if KP.dbp.healthBar_border == "KhalPlates" then
		if KP.dbp.bossIcon_anchor == "Left" then
			bossIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT",  KP.dbp.bossIcon_offsetX - 1, KP.dbp.bossIcon_offsetY )
		elseif KP.dbp.bossIcon_anchor == "Top" then
			bossIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", KP.dbp.bossIcon_offsetX, KP.dbp.bossIcon_offsetY + 3.5)
		else
			bossIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT",  KP.dbp.bossIcon_offsetX + 1, KP.dbp.bossIcon_offsetY)
		end
	else
		if KP.dbp.bossIcon_anchor == "Left" then
			bossIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT", KP.dbp.bossIcon_offsetX, KP.dbp.bossIcon_offsetY)
		elseif KP.dbp.bossIcon_anchor == "Top" then
			bossIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", KP.dbp.bossIcon_offsetX + 11, KP.dbp.bossIcon_offsetY + 17.5)
		else
			bossIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT", KP.dbp.bossIcon_offsetX + 3, KP.dbp.bossIcon_offsetY)
		end
	end
end

local function SetupRaidTargetIcon(Virtual)
	local raidTargetIcon = Virtual.raidTargetIcon
	raidTargetIcon:SetSize(KP.dbp.raidTargetIcon_size, KP.dbp.raidTargetIcon_size)
	raidTargetIcon:ClearAllPoints()
	if KP.dbp.healthBar_border == "KhalPlates" then
		if KP.dbp.raidTargetIcon_anchor == "Left" then
			raidTargetIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT",  KP.dbp.raidTargetIcon_offsetX - 3, KP.dbp.raidTargetIcon_offsetY)
		elseif KP.dbp.raidTargetIcon_anchor == "Top" then
			raidTargetIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", KP.dbp.raidTargetIcon_offsetX, KP.dbp.raidTargetIcon_offsetY + 5)
		else
			raidTargetIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT",  KP.dbp.raidTargetIcon_offsetX + 3, KP.dbp.raidTargetIcon_offsetY)
		end
	else
		if KP.dbp.raidTargetIcon_anchor == "Left" then
			raidTargetIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT", KP.dbp.raidTargetIcon_offsetX - 3, KP.dbp.raidTargetIcon_offsetY + 1)
		elseif KP.dbp.raidTargetIcon_anchor == "Top" then
			raidTargetIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", KP.dbp.raidTargetIcon_offsetX + 11, KP.dbp.raidTargetIcon_offsetY + 21)
		else
			raidTargetIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT", KP.dbp.raidTargetIcon_offsetX + 24, KP.dbp.raidTargetIcon_offsetY + 1)
		end
	end
end

local function SetupEliteIcon(Virtual)
	local eliteIcon = Virtual.eliteIcon
	eliteIcon:SetVertexColor(unpack(KP.dbp.eliteIcon_Tint))
	eliteIcon:ClearAllPoints()
	if KP.dbp.eliteIcon_anchor == "Left" then
		eliteIcon:SetTexCoord(0.578125, 0, 0.578125, 0.84375, 0, 0, 0, 0.84375)
		eliteIcon:SetPoint("LEFT", Virtual.healthBar, "LEFT", -18, -1.5)
	else
		eliteIcon:SetTexCoord(0, 0, 0, 0.84375, 0.578125, 0, 0.578125, 0.84375)
		if KP.dbp.healthBar_border == "KhalPlates" then
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
	classIcon:SetSize(KP.dbp.classIcon_size, KP.dbp.classIcon_size)
	classIcon:ClearAllPoints()
	if KP.dbp.healthBar_border == "KhalPlates" then
		if KP.dbp.classIcon_anchor == "Left" then
			classIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT", KP.dbp.classIcon_offsetX - 0.5, KP.dbp.classIcon_offsetY)
		elseif KP.dbp.classIcon_anchor == "Top" then
			classIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", KP.dbp.classIcon_offsetX, KP.dbp.classIcon_offsetY + 3)
		else
			classIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT", KP.dbp.classIcon_offsetX + 0.5, KP.dbp.classIcon_offsetY)
		end
	else
		if KP.dbp.classIcon_anchor == "Left" then
			classIcon:SetPoint("RIGHT", Virtual.healthBar, "LEFT", KP.dbp.classIcon_offsetX - 0.5, KP.dbp.classIcon_offsetY)
		elseif KP.dbp.classIcon_anchor == "Top" then
			classIcon:SetPoint("BOTTOM", Virtual.healthBar, "TOP", KP.dbp.classIcon_offsetX + 11, KP.dbp.classIcon_offsetY + 18)
		else
			classIcon:SetPoint("LEFT", Virtual.healthBar, "RIGHT", KP.dbp.classIcon_offsetX + 22, KP.dbp.classIcon_offsetY)
		end
	end
end

local function SetupKhalPlate(Virtual)
	local threatGlow, healthBarBorder, castBarBorder, shieldCastBarBorder, spellIcon, healthBarHighlight, nameText, levelText, bossIcon, raidTargetIcon, eliteIcon = Virtual:GetRegions()
	Virtual.threatGlow = threatGlow
	Virtual.castBarBorder = castBarBorder
	Virtual.shieldCastBarBorder = shieldCastBarBorder
	Virtual.spellIcon = spellIcon
	Virtual.healthBarHighlight = healthBarHighlight
	Virtual.nameText = nameText
	Virtual.levelText = levelText
	Virtual.bossIcon = bossIcon
	Virtual.raidTargetIcon = raidTargetIcon
	Virtual.eliteIcon = eliteIcon
	Virtual.healthBar, Virtual.castBar = Virtual:GetChildren()
	Virtual.healthBar.barTex = Virtual.healthBar:GetRegions()
	Virtual.castBar.barTex = Virtual.castBar:GetRegions()
	SetupHealthBorder(Virtual.healthBar)
	SetupNameText(Virtual.healthBar)
	SetupLevelText(Virtual)
	SetupArenaIDText(Virtual.healthBar)
	SetupTargetGlow(Virtual)
	SetupTargetHandler(Virtual)
	SetupHealthText(Virtual.healthBar)
	SetupBarBackground(Virtual.healthBar)
	SetupBarBackground(Virtual.castBar, true)
	SetupCastText(Virtual)
	SetupCastTimer(Virtual.castBar)
	SetupCastGlow(Virtual)
	SetupBossIcon(Virtual)
	SetupRaidTargetIcon(Virtual)
	SetupEliteIcon(Virtual)
	SetupClassIcon(Virtual)
	healthBarBorder:Hide()
	nameText:Hide()
	castBarBorder:SetTexture(ASSETS .. "PlateBorders\\CastBar-Border")
	if KP.dbp.healthBar_border == "KhalPlates" then
		threatGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-ThreatGlow")
		healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\HealthBar-MouseoverGlow")
		healthBarHighlight:SetSize(KP.NP_WIDTH, KP.NP_HEIGHT)
	else
		threatGlow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
		healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\HealthBar-MouseoverGlowBlizz")
		healthBarHighlight:SetSize(KP.NP_WIDTH * 1.165, KP.NP_HEIGHT)
	end
	healthBarHighlight:SetVertexColor(unpack(KP.dbp.mouseoverGlow_Tint))
	Virtual.healthBar.barTex:SetDrawLayer("BORDER")
	if ClassByPlateColor(Virtual.healthBar) then
		Virtual.healthBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.healthBar_playerTex))
	else
		Virtual.healthBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.healthBar_npcTex))
	end
	Virtual.castBar.barTex:SetDrawLayer("BORDER")
	Virtual.castBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.castBar_Tex))
	local function VirtualOnShow()
		healthBarHighlight:ClearAllPoints()
		if KP.dbp.healthBar_border == "KhalPlates" then
			castBarBorder:SetPoint("CENTER", KP.dbp.globalOffsetX, KP.dbp.globalOffsetY -19)
			castBarBorder:SetWidth(145)
			shieldCastBarBorder:SetWidth(145)
			healthBarHighlight:SetPoint("CENTER", 1.2 + KP.dbp.globalOffsetX, -8.7 + KP.dbp.globalOffsetY)
		else
			castBarBorder:SetPoint("CENTER", KP.dbp.globalOffsetX + 10.3, KP.dbp.globalOffsetY -19)
			castBarBorder:SetWidth(157)
			shieldCastBarBorder:SetWidth(157)
			healthBarHighlight:SetPoint("CENTER", 11.83 + KP.dbp.globalOffsetX, -8.7 + KP.dbp.globalOffsetY)
		end
		Virtual.healthBar.nameText:SetText(nameText:GetText())
	end
	VirtualOnShow()
	Virtual:HookScript("OnShow", VirtualOnShow)
end

local function SetupTotemIcon(Plate)
	if not Plate.totemPlate then return end
	Plate.totemPlate:SetPoint("TOP", 0, KP.dbp.totemOffset - 5)
	Plate.totemPlate:SetSize(KP.dbp.totemSize, KP.dbp.totemSize)
	Plate.totemPlate.targetGlow:SetSize(128*KP.dbp.totemSize/88, 128*KP.dbp.totemSize/88)
end

local function SetupTotemPlate(Plate)
	if Plate.totemPlate then return end
	Plate.totemPlate = CreateFrame("Frame", nil, Plate)
	Plate.totemPlate:Hide()
	Plate.totemPlate.icon = Plate.totemPlate:CreateTexture(nil, "ARTWORK")
	Plate.totemPlate.icon:SetAllPoints(Plate.totemPlate)
	Plate.totemPlate.targetGlow = Plate.totemPlate:CreateTexture(nil, "OVERLAY")
	Plate.totemPlate.targetGlow:SetTexture(ASSETS .. "PlateBorders\\TotemPlate-TargetGlow.blp")
	Plate.totemPlate.targetGlow:SetVertexColor(unpack(KP.dbp.targetGlow_Tint))
	Plate.totemPlate.targetGlow:SetPoint("CENTER")
	Plate.totemPlate.targetGlow:Hide()
	SetupTotemIcon(Plate)
end

local function SetupClassPlateIcon(Plate)
	if not Plate.classPlate then return end
	Plate.classPlate:SetPoint("TOP", Plate, "TOP", 0, KP.dbp.classPlate_offset)
	Plate.classPlate:SetSize(KP.dbp.classPlate_iconSize, KP.dbp.classPlate_iconSize)
	Plate.classPlate.icon:SetSize(KP.dbp.classPlate_iconSize, KP.dbp.classPlate_iconSize)
	Plate.classPlate.nameText:SetFont(KP.LSM:Fetch("font", KP.dbp.classPlate_textFont), KP.dbp.classPlate_textSize, KP.dbp.classPlate_textOutline)
end

local function SetupClassPlate(Plate)
	if Plate.classPlate then return end
	Plate.classPlate = CreateFrame("Frame", nil, WorldFrame)
	Plate.classPlate:Hide()
	Plate.classPlate.nameText = Plate.classPlate:CreateFontString(nil, "OVERLAY")
	Plate.classPlate.nameText:SetPoint("TOP")
	Plate.classPlate.nameText:SetShadowOffset(0.5, -0.5)
	Plate.classPlate.icon = Plate.classPlate:CreateTexture(nil, "ARTWORK")
	Plate.classPlate.icon:SetPoint("BOTTOM", Plate.classPlate, "TOP")
	SetupClassPlateIcon(Plate)
end

---------------------------------------- Settings Update Functions ----------------------------------------
function KP:UpdateAllVirtualsScale()
	for Plate, Virtual in pairs(VirtualPlates) do
		Virtual:SetScale(self.dbp.globalScale)
		if not self.inCombat then
			if Virtual:IsShown() then
				if self.dbp.healthBar_border == "KhalPlates" then
					Plate:SetSize(NP_WIDTH * self.dbp.globalScale * 0.9, NP_HEIGHT * self.dbp.globalScale * 0.7)
				else
					Plate:SetSize(NP_WIDTH * self.dbp.globalScale, NP_HEIGHT * self.dbp.globalScale)
				end
			else
				Plate:SetSize(0.01, 0.01)
			end
		end
	end
end

function KP:MoveAllShownPlates(diffX, diffY)
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

function KP:UpdateAllTexts()
	for Plate, Virtual in pairs(VirtualPlates) do
		local healthBar = Virtual.healthBar
		UpdateNameText(healthBar.nameText)
		SetupLevelText(Virtual)
		UpdateArenaIDText(healthBar)
	end
end

function KP:UpdateAllHealthBars()
	for Plate, Virtual in pairs(VirtualPlates) do
		local healthBar = Virtual.healthBar
		local healthBarBorder = healthBar.healthBarBorder
		local healthText = healthBar.healthText
		if self.dbp.healthBar_border == "KhalPlates" then
			healthBarBorder:SetTexture(ASSETS .. "PlateBorders\\HealthBar-Border")
		else
			healthBarBorder:SetTexture("Interface\\Tooltips\\Nameplate-Border")
		end
		healthBarBorder:SetVertexColor(unpack(self.dbp.healthBar_borderTint))
		if Plate.classKey then
			healthBar.barTex:SetTexture(self.LSM:Fetch("statusbar", self.dbp.healthBar_playerTex))
		else
			healthBar.barTex:SetTexture(self.LSM:Fetch("statusbar", self.dbp.healthBar_npcTex))
		end
		if self.dbp.healthText_hide then
			healthText:Hide()
		else
			healthText:Show()
			healthText:SetFont(self.LSM:Fetch("font", self.dbp.healthText_font), self.dbp.healthText_size, self.dbp.healthText_outline)
			healthText:ClearAllPoints()
			healthText:SetPoint(self.dbp.healthText_anchor, self.dbp.healthText_offsetX, self.dbp.healthText_offsetY + 0.3)
			healthText:SetTextColor(unpack(self.dbp.healthText_color))
		end
	end
end

function KP:UpdateAllCastBars()
	for _, Virtual in pairs(VirtualPlates) do
		local castBar = Virtual.castBar
		castBar.barTex:SetTexture(self.LSM:Fetch("statusbar", self.dbp.castBar_Tex))
		if not self.dbp.castText_hide then
			local castText = castBar.castText
			castText:SetFont(self.LSM:Fetch("font", self.dbp.castText_font), self.dbp.castText_size, self.dbp.castText_outline)
			castText:SetTextColor(unpack(self.dbp.castText_color))
			castText:SetJustifyH(self.dbp.castText_anchor)
			castText:SetWidth(self.dbp.castText_width)
			castText:ClearAllPoints()
			if self.dbp.healthBar_border == "KhalPlates" then
				castText:SetPoint(self.dbp.castText_anchor, self.dbp.castText_offsetX - 3.8, self.dbp.castText_offsetY + 1.6)
			else
				castText:SetPoint(self.dbp.castText_anchor, self.dbp.castText_offsetX - 9.3, self.dbp.castText_offsetY + 1.6)
			end
			if castBar:IsShown() then
				castText:Show()
			end
		else
			castBar.castText:Hide()
		end
		if not self.dbp.castTimerText_hide then
			local castTimerText = castBar.castTimerText
			castTimerText:SetFont(self.LSM:Fetch("font", self.dbp.castTimerText_font), self.dbp.castTimerText_size, self.dbp.castTimerText_outline)
			castTimerText:SetTextColor(unpack(self.dbp.castTimerText_color))
			castTimerText:ClearAllPoints()
			castTimerText:SetPoint(self.dbp.castTimerText_anchor, self.dbp.castTimerText_offsetX - 2, self.dbp.castTimerText_offsetY + 1)
			if castBar:IsShown() then
				castTimerText:Show()
			end
		else
			castBar.castTimerText:Hide()
		end
	end
end

function KP:UpdateAllIcons()
	for Plate, Virtual in pairs(VirtualPlates) do
		SetupBossIcon(Virtual)
		SetupRaidTargetIcon(Virtual)
		SetupEliteIcon(Virtual)
		SetupClassIcon(Virtual)
		SetupTotemIcon(Plate)
		SetupClassPlateIcon(Plate)
	end
end

function KP:UpdateAllGlows()
	for Plate, Virtual in pairs(VirtualPlates) do
		local targetGlow = Virtual.healthBar.targetGlow
		local targetGlowTotem = Plate.totemPlate and Plate.totemPlate.targetGlow
		local healthBarHighlight = Virtual.healthBarHighlight
		local threatGlow = Virtual.threatGlow
		local castGlow = Virtual.castGlow
		targetGlow:SetVertexColor(unpack(self.dbp.targetGlow_Tint))
		healthBarHighlight:SetVertexColor(unpack(self.dbp.mouseoverGlow_Tint))
		healthBarHighlight:ClearAllPoints()
		if self.dbp.healthBar_border == "KhalPlates" then
			targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlow")
			targetGlow:SetSize(self.NP_WIDTH, self.NP_HEIGHT)
			targetGlow:SetPoint("CENTER", 0.7, 0.5)
			healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\HealthBar-MouseoverGlow")
			healthBarHighlight:SetSize(self.NP_WIDTH, self.NP_HEIGHT)
			healthBarHighlight:SetPoint("CENTER", 1.2 + self.dbp.globalOffsetX, -8.7 + self.dbp.globalOffsetY)
			threatGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-ThreatGlow")
			castGlow:SetSize(160, 40)
			castGlow:SetPoint("CENTER", 2.75, -27.5 + KP.dbp.globalOffsetY)
		else
			targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlowBlizz")
			targetGlow:SetSize(self.NP_WIDTH * 1.165, self.NP_HEIGHT)
			targetGlow:SetPoint("CENTER", 11.33, 0.5)
			healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\HealthBar-MouseoverGlowBlizz")
			healthBarHighlight:SetSize(self.NP_WIDTH * 1.165, self.NP_HEIGHT)
			healthBarHighlight:SetPoint("CENTER", 11.83 + self.dbp.globalOffsetX, -8.7 + self.dbp.globalOffsetY)
			threatGlow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
			castGlow:SetSize(173.5, 40)
			castGlow:SetPoint("CENTER", 2.2, -27.5 + KP.dbp.globalOffsetY)
		end
		if targetGlowTotem then
			targetGlowTotem:SetVertexColor(unpack(self.dbp.targetGlow_Tint))
		end
	end
end

function KP:UpdateAllCastBarBorders()
	for _, Virtual in pairs(VirtualPlates) do
		local castBarBorder = Virtual.castBarBorder
		local shieldCastBarBorder = Virtual.shieldCastBarBorder
		if self.dbp.healthBar_border == "KhalPlates" then
			castBarBorder:SetPoint("CENTER", self.dbp.globalOffsetX, self.dbp.globalOffsetY -19)
			castBarBorder:SetWidth(145)
			shieldCastBarBorder:SetWidth(145)
		else
			castBarBorder:SetPoint("CENTER", self.dbp.globalOffsetX + 10.5, self.dbp.globalOffsetY -19)
			castBarBorder:SetWidth(157)
			shieldCastBarBorder:SetWidth(157)
		end
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

local function UpdateClassColorNames()
	for Plate, Virtual in pairs(PlatesVisible) do
		local class = Plate.classKey
		local classColor
		if class then
			if class == "FRIENDLY PLAYER" and ClassByFriendName[name] then
				classColor = RAID_CLASS_COLORS[ClassByFriendName[name]]
			elseif class ~= "FRIENDLY PLAYER" then
				classColor = RAID_CLASS_COLORS[class]
			end
		end
		Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = unpack(KP.dbp.nameText_color)
		if classColor and ((class == "FRIENDLY PLAYER" and KP.dbp.nameText_classColorFriends) or (class ~= "FRIENDLY PLAYER" and KP.dbp.nameText_classColorEnemies)) then
			Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = classColor.r, classColor.g, classColor.b
		end
		Virtual.healthBar.nameText:SetTextColor(Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB)
		Virtual.nameTextIsYellow = false
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

local function UpdatePlateVisibility(Plate, Virtual)
	-------- Sets the healthBar texture and text colors based on unit type --------
	local healthBar = Virtual.healthBar
	local name = Virtual.nameText:GetText()
	Virtual.nameString = name
	------------------------ TotemPlates Handling ------------------------
	local totemKey = KP.Totems[name]
	local totemCheck = KP.dbp.TotemsCheck[totemKey]
	local blacklisted = KP.dbp.Blacklist[name]
	if totemCheck or blacklisted then
		if not Plate.totemPlate then
			SetupTotemPlate(Plate) -- Setup TotemPlate on the fly
		end
		Virtual:Hide()
		local iconTexture = (totemCheck == 1 and ASSETS .. "Icons\\" .. totemKey) or (blacklisted ~= "" and blacklisted)
		if iconTexture then
			Plate.totemPlate:Show()
			Plate.totemPlate.icon:SetTexture(iconTexture)
			Plate.totemPlateIsShown = true
		end
	else
		--------------- Nameplate Level Filter --------------
		local level = tonumber(Virtual.levelText:GetText())
		if level and level < KP.dbp.levelFilter then
			Virtual:Hide() -- Hide low level nameplates
		else
			local levelText = Virtual.levelText
			if Virtual.bossIcon:IsShown() then
				Plate.isBoss = true
				levelText:Hide()
			else
				SetupLevelText(Virtual)
				levelText:Show()
			end
			if KP.dbp.levelText_hide then
				levelText:Hide()
			end
			local nameText = healthBar.nameText
			if KP.dbp.nameText_hide then
				nameText:Hide()
			else
				nameText:Show()	
			end
			Plate.isFriendly = ReactionByPlateColor(healthBar) == "FRIENDLY"
			local class = ClassByPlateColor(healthBar)
			local classColor	
			if class then
				Plate.classKey = class
				local classPlateCheck
				if class == "FRIENDLY PLAYER" then
					classColor = ClassByFriendName[name] and RAID_CLASS_COLORS[ClassByFriendName[name]]
					---------------------- Special Class Name/Icon ----------------------
					if (KP.inBG and KP.dbp.classPlate_showNameInBG) 
					or (KP.inArena and KP.dbp.classPlate_showNameInArena) 
					or (KP.inPvEInstance and KP.dbp.classPlate_showNameInPvE) then
						if not Plate.classPlate then
							SetupClassPlate(Plate)
						end
						Plate.classPlate.nameText:SetText(name)
						if classColor and KP.dbp.classPlate_classColors then
							Plate.classPlate.nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
						else
							Plate.classPlate.nameText:SetTextColor(unpack(KP.dbp.classPlate_textColor))
						end
						Plate.classPlate.nameText:Show()
						classPlateCheck = true
					end
					if (KP.inBG and KP.dbp.classPlate_showIconInBG) 
					or (KP.inArena and KP.dbp.classPlate_showIconInArena) 
					or (KP.inPvEInstance and KP.dbp.classPlate_showIconInPvE) then
						if not Plate.classPlate then
							SetupClassPlate(Plate)
						end
						Plate.classPlate.icon:SetTexture(ASSETS .. "Classes\\" .. (ClassByFriendName[name] or ""))
						Plate.classPlate.icon:Show()
						classPlateCheck = true
					end
				else
					classColor = RAID_CLASS_COLORS[class]
				end
				if classPlateCheck then
					Virtual:Hide()
					Plate.classPlate:Show()
					Plate.classPlateIsShown = true
				else
					------------------------ Show Arena IDs ------------------------
					if KP.inArena then
						local ArenaIDText = healthBar.ArenaIDText
						if class == "FRIENDLY PLAYER" then
							local partyID = PartyID[name]
							if not partyID then
								UpdateGroupInfo()
								partyID = PartyID[name]
							end
							if partyID then
								Plate.unitToken = "party" .. partyID
								if KP.dbp.PartyIDText_show then
									ArenaIDText:SetTextColor(unpack(KP.dbp.PartyIDText_color))
									ArenaIDText:SetText(partyID)
									ArenaIDText:Show()
									if KP.dbp.PartyIDText_HideLevel then
										levelText:Hide()
									end
									if KP.dbp.PartyIDText_HideName then
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
								if KP.dbp.ArenaIDText_show then
									ArenaIDText:SetTextColor(unpack(KP.dbp.ArenaIDText_color))
									ArenaIDText:SetText(arenaID)
									ArenaIDText:Show()
									if KP.dbp.ArenaIDText_HideLevel then
										levelText:Hide()
									end
									if KP.dbp.ArenaIDText_HideName then
										nameText:Hide()
									end
								end
							end
						end
					end
					--------------- Show class icons in PvP instances --------------
					if KP.inPvPInstance then
						if class == "FRIENDLY PLAYER" and KP.dbp.showClassOnFriends then
							Virtual.classIcon:SetTexture(ASSETS .. "Classes\\" .. (ClassByFriendName[name] or ""))
							Virtual.classIcon:Show()
						elseif class ~= "FRIENDLY PLAYER" and KP.dbp.showClassOnEnemies then
							Virtual.classIcon:SetTexture(ASSETS .. "Classes\\" .. class)
							Virtual.classIcon:Show()
						end
					end
					healthBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.healthBar_playerTex))
					Virtual.isShown = true
				end
			else
				healthBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.healthBar_npcTex))
				Virtual.isShown = true
			end
			if Virtual.isShown then
				if classColor and ((class == "FRIENDLY PLAYER" and KP.dbp.nameText_classColorFriends) or (class ~= "FRIENDLY PLAYER" and KP.dbp.nameText_classColorEnemies)) then
					Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = classColor.r, classColor.g, classColor.b
				else
					Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = unpack(KP.dbp.nameText_color)
				end
				nameText:SetTextColor(Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB)
				Virtual.nameTextIsYellow = false
				----------------- Init Enhanced Plate Stacking -----------------
				if not Plate.isFriendly then
					if KP.dbp.stackingEnabled then
						KP.StackablePlates[Plate] = {xpos = 0, ypos = 0, position = 0}
					elseif Plate.isBoss and KP.dbp.clampBoss and KP.inPvEInstance then
						Plate:SetClampedToScreen(true)
						Plate:SetClampRectInsets(80*KP.dbp.globalScale, -80*KP.dbp.globalScale, KP.dbp.upperborder, 0)
					end
				end
			end
		end	
	end
	Virtual.targetHandler:Show()
end

local function ResetPlateFlags(Plate, Virtual)
	Virtual.classIcon:Hide()
	Virtual.healthBar.ArenaIDText:Hide()
	Virtual.isShown = nil
	Virtual.nameString = nil
	Virtual.nameTextIsYellow = nil
	Plate.isBoss = nil
	Plate.isFriendly = nil
	Plate.classKey = nil
	Plate.totemPlateIsShown = nil
	Plate.classPlateIsShown = nil
	Plate.unitToken = nil
	if Plate.totemPlate then Plate.totemPlate:Hide() end
	if Plate.classPlate then 
		Plate.classPlate:Hide()
		Plate.classPlate.nameText:Hide()
		Plate.classPlate.icon:Hide()
	end
	KP.StackablePlates[Plate] = nil
	Plate:SetClampedToScreen(false)
	Plate:SetClampRectInsets(0, 0, 0, 0)
end

local function UpdateHitboxOutOfCombat(Plate, Virtual)
	if not Virtual:IsShown() or (Plate.isFriendly and KP.dbp.friendlyClickthrough and KP.inInstance) then
		Plate:SetSize(0.01, 0.01)
	else
		if KP.dbp.healthBar_border == "KhalPlates" then
			Plate:SetSize(NP_WIDTH * KP.dbp.globalScale * 0.9, NP_HEIGHT * KP.dbp.globalScale * 0.7)
		else
			Plate:SetSize(NP_WIDTH * KP.dbp.globalScale, NP_HEIGHT * KP.dbp.globalScale)
		end
	end
end

function KP:UpdateAllShownPlates()
	for Plate, Virtual in pairs(PlatesVisible) do
		Virtual:Show()
		ResetPlateFlags(Plate, Virtual)
		UpdatePlateVisibility(Plate, Virtual)
		if not self.inCombat then
			UpdateHitboxOutOfCombat(Plate, Virtual)
		end
	end
end

function KP:UpdateHitboxAttributes()
	if not self.inCombat then
		if self.dbp.healthBar_border == "KhalPlates" then
			self.ResizeHitBox:SetAttribute("width", NP_WIDTH * self.dbp.globalScale * 0.9)
			self.ResizeHitBox:SetAttribute("height", NP_HEIGHT * self.dbp.globalScale * 0.7)
		else
			self.ResizeHitBox:SetAttribute("width", NP_WIDTH * self.dbp.globalScale)
			self.ResizeHitBox:SetAttribute("height", NP_HEIGHT * self.dbp.globalScale)
		end
	else
		self.delayedHitboxUpdate = true
	end
end

-- Enlarging of WorldFrame, so that nameplates are displayed even if they have slightly left the screen or are very high up, as is the case with large bosses.
KP.ScreenWidth = GetScreenWidth() * UIParent:GetEffectiveScale()
KP.ScreenHeight = 768
local function ExtendWorldFrameHeight(shouldExtend)
	local heightScale = shouldExtend and 50 or 1
	WorldFrame:ClearAllPoints()
	WorldFrame:SetPoint("BOTTOM")
	WorldFrame:SetWidth(KP.ScreenWidth)
	WorldFrame:SetHeight(KP.ScreenHeight*heightScale)
end
function KP:UpdateWorldFrameHeight(init)
	self.ScreenWidth = GetScreenWidth() * UIParent:GetEffectiveScale()
	if self.dbp.clampTarget or self.dbp.clampBoss then
		ExtendWorldFrameHeight(true)
	elseif not init then
		ExtendWorldFrameHeight(false)
	end
end

-- Retail-like Nameplate Stacking
-- All visible enemy nameplates are iterated and the minimum distance to the next nameplate is determined.
-- If there is no other nameplate in the immediate vicinity of the original position, the position is reset (to prevent the nameplates from rising higher and higher).
-- Depending on whether the position is to be reset or the nameplate is above or below the closest one different functions are used for a smooth movement.
local ySpeed = 3.5
local delta = ySpeed
local resetSpeedFactor = 1
local raiseSpeedFactor = 1
local lowerSpeedFactor = 0.8
local function UpdateStacking()
	if not KP.dbp.stackingEnabled then return end
	if KP.dbp.stackingInInstance and not KP.inInstance then return end
    local xspace = KP.dbp.xspace * KP.dbp.globalScale
    local yspace = KP.dbp.yspace * KP.dbp.globalScale
    for Plate1, Plate1_StackData in pairs(KP.StackablePlates) do
        local width, height = Plate1:GetSize()
		local x, y = select(4, Plate1:GetPoint(1))
		local Virtual1 = VirtualPlates[Plate1]
		KP.StackablePlates[Plate1].xpos = x
		KP.StackablePlates[Plate1].ypos = y
        if KP.dbp.FreezeMouseover and Virtual1.healthBarHighlight:IsShown() then  -- Freeze Mouseover Nameplate
            local x, y =  Plate1:GetCenter() -- This Coordinates are the "real" values for the center point
            local newposition = y - Plate1_StackData.ypos - KP.dbp.originpos + height/2
            Plate1_StackData.position = newposition
            Plate1_StackData.xpos = x
            Plate1:SetClampedToScreen(true)
            Plate1:SetClampRectInsets(-2*KP.ScreenWidth, KP.ScreenWidth - x - width/2, KP.ScreenHeight - y - height/2, -2*KP.ScreenHeight)
        else
            local min = 1000
            local reset = true
            for Plate2, Plate2_StackData in pairs(KP.StackablePlates) do
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
			if (Virtual1.isTarget and KP.dbp.clampTarget) or (Plate1.isBoss and KP.dbp.clampBoss and KP.inPvEInstance) then
				Plate1:SetClampRectInsets(0.5*width, -0.5*width, KP.dbp.upperborder, - Plate1_StackData.ypos - newposition - KP.dbp.originpos + height)
			else
				Plate1:SetClampRectInsets(0.5*width, -0.5*width, -height, - Plate1_StackData.ypos - newposition - KP.dbp.originpos + height)
			end
        end
    end
end

function KP:UpdateProfile()
	self:UpdateAllVirtualsScale()
	self:UpdateAllTexts()
	self:UpdateAllHealthBars()
	self:UpdateAllCastBars()
	self:UpdateAllIcons()
	self:UpdateAllGlows()
	self:UpdateAllCastBarBorders()
	self:BuildBlacklistUI()
	self:UpdateWorldFrameHeight()
	if self.dbp.stackingEnabled then SetCVar("nameplateAllowOverlap", 1) end
	self:UpdateAllShownPlates()
	self:UpdateHitboxAttributes()
end

----------- Reference for Core.lua -----------
KP.NP_WIDTH = NP_WIDTH
KP.NP_HEIGHT = NP_HEIGHT
KP.VirtualPlates = VirtualPlates
KP.RealPlates = RealPlates
KP.PlatesVisible = PlatesVisible
KP.StackablePlates = StackablePlates
KP.ClassByFriendName = ClassByFriendName
KP.ArenaID = ArenaID
KP.PartyID = PartyID
KP.ASSETS = ASSETS
KP.UpdatePlateVisibility = UpdatePlateVisibility
KP.ResetPlateFlags = ResetPlateFlags
KP.UpdateHitboxOutOfCombat = UpdateHitboxOutOfCombat
KP.SetupLevelText = SetupLevelText
KP.ClassByPlateColor = ClassByPlateColor
KP.ReactionByPlateColor = ReactionByPlateColor
KP.UpdateGroupInfo = UpdateGroupInfo
KP.UpdateClassColorNames = UpdateClassColorNames
KP.UpdateArenaInfo = UpdateArenaInfo
KP.SetupKhalPlate = SetupKhalPlate
KP.SetupTotemPlate = SetupTotemPlate
KP.SetupClassPlate = SetupClassPlate
KP.UpdateStacking = UpdateStacking