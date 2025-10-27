
local AddonFile, KP = ... -- namespace

----------------------------- API -----------------------------
local ipairs, unpack, tonumber, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, floor =
      ipairs, unpack, tonumber, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName, math.floor

------------------------- Core Variables -------------------------
local VirtualPlates = {}     -- Storage table for Virtual nameplate frames
local RealPlates = {}        -- Storage table for real nameplate frames
local PlatesVisible = {}     -- Storage table: currently active nameplates
local ClassByFriendName = {} -- Storage table: maps friendly player names (party/raid) to their class
local ASSETS = "Interface\\AddOns\\" .. AddonFile .. "\\Assets\\"
local NP_WIDTH = 156.65118520899 -- Nameplate original width (don't modify)
local NP_HEIGHT = 39.162796302247 -- Nameplate original height (don't modify)

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
	[000099] = "FRIENDLY", -- identifies friendly players
}

SetCVar("ShowClassColorInNameplate", 1) -- "Class Colors in Nameplates" must be enabled to identify enemy players

-- Converts normalized RGB from nameplates into a custom color key and returns the class name
local function ClassByPlateColor(healthBar)
	local r, g, b = healthBar:GetStatusBarColor()
	local key = floor(r * 100) * 10000 + floor(g * 100) * 100 + floor(b * 100)
	return ClassByKey[key]
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

local function SetupBarBackground(Bar)
	if Bar.BackgroundTex then return end 
	Bar.BackgroundTex = Bar:CreateTexture(nil, "BACKGROUND")
	Bar.BackgroundTex:SetTexture(ASSETS .. "PlateBorders\\NamePlate-Background")
	Bar.BackgroundTex:SetSize(KP.NP_WIDTH, KP.NP_HEIGHT)
	Bar.BackgroundTex:SetPoint("CENTER", 10.5, 9)
	Bar.BackgroundTex:Hide()
end

local function SetupNameText(healthBar)
	if healthBar.nameText then return end
	healthBar.nameText = healthBar:CreateFontString(nil, "OVERLAY")
	healthBar.nameText:SetFont(KP.LSM:Fetch("font", KP.dbp.nameText_font), KP.dbp.nameText_size, KP.dbp.nameText_outline)
	healthBar.nameText:ClearAllPoints()
	healthBar.nameText:SetPoint(KP.dbp.nameText_anchor, KP.dbp.nameText_offsetX + 0.2, KP.dbp.nameText_offsetY + 0.7)
	healthBar.nameText:SetWidth(KP.dbp.nameText_width)
	healthBar.nameText:SetJustifyH(KP.dbp.nameText_anchor)
	healthBar.nameText:SetTextColor(unpack(KP.dbp.nameText_color))
	healthBar.nameText:SetShadowOffset(0.5, -0.5)
	healthBar.nameText:SetNonSpaceWrap(false)
	healthBar.nameText:SetWordWrap(false)
	if KP.dbp.nameText_hide then
		healthBar.nameText:Hide()
	end
end

local function UpdateHealthTextValue(healthBar)
	local min, max = healthBar:GetMinMaxValues()
	local val = healthBar:GetValue()
	if max > 0 then
		local percent = floor((val / max) * 100)
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
	local RealPlate = KP.RealPlates[Virtual]
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
	healthBar.targetBorderDelay = CreateFrame("Frame")
	healthBar.targetBorderDelay:Hide()
	healthBar.targetBorderDelay:SetScript("OnUpdate", function(self)
		self:Hide()
		Virtual.Alpha = Virtual:GetAlpha()
		if Virtual.nameString == UnitName("target") and Virtual.Alpha == 1 then
			Virtual.isTarget = true
			healthBar.targetGlow:Show()
			if RealPlate.totemPlate then RealPlate.totemPlate.targetGlow:Show() end
		else
			Virtual.isTarget = false
			healthBar.targetGlow:Hide()
			if RealPlate.totemPlate then RealPlate.totemPlate.targetGlow:Hide() end
		end
	end)
end

local function UpdateTargetGlow(Virtual)
	Virtual.healthBar.targetBorderDelay:Show()
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
	castBar.castTextDelay:Hide()
	castBar.castTextDelay:SetScript("OnUpdate", function(self)
		self:Hide()
		local spellName = UnitCastingInfo("target") or UnitChannelInfo("target")
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
			Virtual.castBarBorder:Hide()
			Virtual.shieldCastBarBorder:Hide()
			Virtual.spellIcon:Hide()
			castBar.BackgroundTex:Hide()
			castBar.castText:Hide()
			castBar.castTimerText:Hide()
		end
	end)
	local function UpdateCastTextValue()
		castBar.castTextDelay:Show()
	end
	UpdateCastTextValue()
	castBar:HookScript("OnShow", UpdateCastTextValue)
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
			local remaining = max - val
			if UnitChannelInfo("target") then
				self.castTimerText:SetFormattedText("%.1f", val)
			else
				self.castTimerText:SetFormattedText("%.1f", remaining)
			end
		end
	end)
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
	SetupTargetGlow(Virtual)
	SetupHealthText(Virtual.healthBar)
	SetupBarBackground(Virtual.healthBar)
	SetupBarBackground(Virtual.castBar)
	SetupCastText(Virtual)
	SetupCastTimer(Virtual.castBar)
	SetupBossIcon(Virtual)
	SetupRaidTargetIcon(Virtual)
	SetupEliteIcon(Virtual)
	SetupClassIcon(Virtual)
	healthBarBorder:Hide()
	nameText:Hide()
	levelText:SetFont(KP.LSM:Fetch("font", KP.dbp.levelText_font), KP.dbp.levelText_size, KP.dbp.levelText_outline)
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
			if KP.dbp.levelText_hide then
				levelText:Hide()
			else
				levelText:ClearAllPoints()
				if KP.dbp.levelText_anchor == "Left" then
					levelText:SetPoint("CENTER", Virtual.healthBar, "LEFT", KP.dbp.levelText_offsetX - 10 , KP.dbp.levelText_offsetY + 0.3)
				elseif KP.dbp.levelText_anchor == "Center" then
					levelText:SetPoint("CENTER", Virtual.healthBar, "CENTER", KP.dbp.levelText_offsetX, KP.dbp.levelText_offsetY + 0.3)
				else
					levelText:SetPoint("CENTER", Virtual.healthBar, "RIGHT", KP.dbp.levelText_offsetX + 10, KP.dbp.levelText_offsetY + 0.3)
				end
			end
		else
			castBarBorder:SetPoint("CENTER", KP.dbp.globalOffsetX + 10.3, KP.dbp.globalOffsetY -19)
			castBarBorder:SetWidth(157)
			shieldCastBarBorder:SetWidth(157)
			healthBarHighlight:SetPoint("CENTER", 11.83 + KP.dbp.globalOffsetX, -8.7 + KP.dbp.globalOffsetY)
			if KP.dbp.levelText_hide then
				levelText:Hide()
			else
				levelText:ClearAllPoints()
				if KP.dbp.levelText_anchor == "Left" then
					levelText:SetPoint("CENTER", Virtual.healthBar, "LEFT", KP.dbp.levelText_offsetX - 13.5, KP.dbp.levelText_offsetY + 0.3)
				elseif KP.dbp.levelText_anchor == "Center" then
					levelText:SetPoint("CENTER", Virtual.healthBar, "CENTER", KP.dbp.levelText_offsetX + 11, KP.dbp.levelText_offsetY + 0.3)
				else
					levelText:SetPoint("CENTER", Virtual.healthBar, "RIGHT", KP.dbp.levelText_offsetX + 11.2, KP.dbp.levelText_offsetY + 0.3)
				end
			end
		end
		Virtual.healthBar.nameText:SetText(nameText:GetText())
		UpdateTargetGlow(Virtual)
	end
	VirtualOnShow()
	Virtual:HookScript("OnShow", VirtualOnShow)
end

local function SetupTotemPlate(Plate)
	if Plate.totemPlate then return end
	Plate.totemPlate = CreateFrame("Frame", nil, Plate)
	Plate.totemPlate:SetPoint("TOP", 0, KP.dbp.totemOffset - 5)
	Plate.totemPlate:SetSize(KP.dbp.totemSize, KP.dbp.totemSize)
	Plate.totemPlate:SetScale(KP.dbp.globalScale)
	Plate.totemPlate:Hide()
	Plate.totemPlate.icon = Plate.totemPlate:CreateTexture(nil, "ARTWORK")
	Plate.totemPlate.icon:SetAllPoints(Plate.totemPlate)
	Plate.totemPlate.targetGlow = Plate.totemPlate:CreateTexture(nil, "OVERLAY")
	Plate.totemPlate.targetGlow:SetSize(128*KP.dbp.totemSize/88, 128*KP.dbp.totemSize/88)
	Plate.totemPlate.targetGlow:SetTexture(ASSETS .. "PlateBorders\\TotemPlate-TargetGlow.blp")
	Plate.totemPlate.targetGlow:SetVertexColor(unpack(KP.dbp.targetGlow_Tint))
	Plate.totemPlate.targetGlow:SetPoint("CENTER")
	Plate.totemPlate.targetGlow:Hide()
end

---------------------------------------- Settings Update Functions ----------------------------------------
function KP:UpdateAllVirtualsScale()
	for Plate, Virtual in pairs(VirtualPlates) do
		Virtual:SetScale(KP.dbp.globalScale)
		if Plate.totemPlate then
			Plate.totemPlate:SetScale(KP.dbp.globalScale)
		end
		if not KP.inCombat then
			if Virtual:IsShown() then
				if KP.dbp.healthBar_border == "KhalPlates" then
					Plate:SetSize(NP_WIDTH * KP.dbp.globalScale * 0.9, NP_HEIGHT * KP.dbp.globalScale * 0.7)
				else
					Plate:SetSize(NP_WIDTH * KP.dbp.globalScale, NP_HEIGHT * KP.dbp.globalScale)
				end
			else
				Plate:SetSize(0.01, 0.01)
			end
		end
	end
end

function KP:MoveAllVisiblePlates(diffX, diffY)
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

function KP:UpdateLevelFilter()
	for _, Virtual in pairs(PlatesVisible) do
		local name = Virtual.nameString
		local totemTex = KP.TotemTexs[name]
		if totemTex then
			Virtual:Hide()
		else
			local level = tonumber(Virtual.levelText:GetText())
			if level and level < KP.dbp.levelFilter then
				Virtual:Hide()
			else
				Virtual:Show()
			end
		end
	end
end

function KP:UpdateAllHealthBars()
	for _, Virtual in pairs(VirtualPlates) do
		local healthBar = Virtual.healthBar
		local healthBarBorder = healthBar.healthBarBorder
		local healthText = healthBar.healthText
		if KP.dbp.healthBar_border == "KhalPlates" then
			healthBarBorder:SetTexture(ASSETS .. "PlateBorders\\HealthBar-Border")
		else
			healthBarBorder:SetTexture("Interface\\Tooltips\\Nameplate-Border")
		end
		healthBarBorder:SetVertexColor(unpack(KP.dbp.healthBar_borderTint))
		if Virtual.classKey then
			healthBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.healthBar_playerTex))
		else
			healthBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.healthBar_npcTex))
		end
		if KP.dbp.healthText_hide then
			healthText:Hide()
		else
			healthText:Show()
			healthText:SetFont(KP.LSM:Fetch("font", KP.dbp.healthText_font), KP.dbp.healthText_size, KP.dbp.healthText_outline)
			healthText:ClearAllPoints()
			healthText:SetPoint(KP.dbp.healthText_anchor, KP.dbp.healthText_offsetX, KP.dbp.healthText_offsetY + 0.3)
			healthText:SetTextColor(unpack(KP.dbp.healthText_color))
		end
	end
end

function KP:UpdateAllNameTexts()
	for _, Virtual in pairs(VirtualPlates) do
		local nameText = Virtual.healthBar.nameText
		if KP.dbp.nameText_hide then
			nameText:Hide()
		else
			nameText:Show()
			nameText:SetFont(KP.LSM:Fetch("font", KP.dbp.nameText_font), KP.dbp.nameText_size, KP.dbp.nameText_outline)
			nameText:ClearAllPoints()
			nameText:SetPoint(KP.dbp.nameText_anchor, KP.dbp.nameText_offsetX + 0.2, KP.dbp.nameText_offsetY + 0.7)
			nameText:SetWidth(KP.dbp.nameText_width)
			nameText:SetJustifyH(KP.dbp.nameText_anchor)
			nameText:SetTextColor(unpack(KP.dbp.nameText_color))
		end
	end
end

function KP:UpdateAllLevelTexts()
	for _, Virtual in pairs(VirtualPlates) do
		local levelText = Virtual.levelText
		if KP.dbp.levelText_hide then
			levelText:Hide()
		else
			levelText:SetFont(KP.LSM:Fetch("font", KP.dbp.levelText_font), KP.dbp.levelText_size, KP.dbp.levelText_outline)
			levelText:ClearAllPoints()
			if KP.dbp.healthBar_border == "KhalPlates" then
				if KP.dbp.levelText_anchor == "Left" then
					levelText:SetPoint("CENTER", Virtual.healthBar, "LEFT", KP.dbp.levelText_offsetX - 10, KP.dbp.levelText_offsetY + 0.3)
				elseif KP.dbp.levelText_anchor == "Center" then
					levelText:SetPoint("CENTER", Virtual.healthBar, "CENTER", KP.dbp.levelText_offsetX, KP.dbp.levelText_offsetY + 0.3)
				else
					levelText:SetPoint("CENTER", Virtual.healthBar, "RIGHT", KP.dbp.levelText_offsetX + 10, KP.dbp.levelText_offsetY + 0.3)
				end
			else
				if KP.dbp.levelText_anchor == "Left" then
					levelText:SetPoint("CENTER", Virtual.healthBar, "LEFT", KP.dbp.levelText_offsetX - 13.5, KP.dbp.levelText_offsetY + 0.3)
				elseif KP.dbp.levelText_anchor == "Center" then
					levelText:SetPoint("CENTER", Virtual.healthBar, "CENTER", KP.dbp.levelText_offsetX + 11, KP.dbp.levelText_offsetY + 0.3)
				else
					levelText:SetPoint("CENTER", Virtual.healthBar, "RIGHT", KP.dbp.levelText_offsetX + 11.2, KP.dbp.levelText_offsetY + 0.3)
				end
			end
			levelText:Show()
		end
	end
end

function KP:UpdateAllCastBarBorders()
	for _, Virtual in pairs(VirtualPlates) do
		local castBarBorder = Virtual.castBarBorder
		local shieldCastBarBorder = Virtual.shieldCastBarBorder
		if KP.dbp.healthBar_border == "KhalPlates" then
			castBarBorder:SetPoint("CENTER", KP.dbp.globalOffsetX, KP.dbp.globalOffsetY -19)
			castBarBorder:SetWidth(145)
			shieldCastBarBorder:SetWidth(145)
		else
			castBarBorder:SetPoint("CENTER", KP.dbp.globalOffsetX + 10.5, KP.dbp.globalOffsetY -19)
			castBarBorder:SetWidth(157)
			shieldCastBarBorder:SetWidth(157)
		end
	end
end

function KP:UpdateAllCastBars()
	for _, Virtual in pairs(VirtualPlates) do
		local castBar = Virtual.castBar
		castBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.castBar_Tex))
		if not KP.dbp.castText_hide then
			local castText = castBar.castText
			castText:SetFont(KP.LSM:Fetch("font", KP.dbp.castText_font), KP.dbp.castText_size, KP.dbp.castText_outline)
			castText:SetTextColor(unpack(KP.dbp.castText_color))
			castText:SetJustifyH(KP.dbp.castText_anchor)
			castText:SetWidth(KP.dbp.castText_width)
			castText:ClearAllPoints()
			if KP.dbp.healthBar_border == "KhalPlates" then
				castText:SetPoint(KP.dbp.castText_anchor, KP.dbp.castText_offsetX - 3.8, KP.dbp.castText_offsetY + 1.6)
			else
				castText:SetPoint(KP.dbp.castText_anchor, KP.dbp.castText_offsetX - 9.3, KP.dbp.castText_offsetY + 1.6)
			end
			if castBar:IsShown() then
				castText:Show()
			end
		else
			castBar.castText:Hide()
		end
		if not KP.dbp.castTimerText_hide then
			local castTimerText = castBar.castTimerText
			castTimerText:SetFont(KP.LSM:Fetch("font", KP.dbp.castTimerText_font), KP.dbp.castTimerText_size, KP.dbp.castTimerText_outline)
			castTimerText:SetTextColor(unpack(KP.dbp.castTimerText_color))
			castTimerText:ClearAllPoints()
			castTimerText:SetPoint(KP.dbp.castTimerText_anchor, KP.dbp.castTimerText_offsetX - 2, KP.dbp.castTimerText_offsetY + 1)
			if castBar:IsShown() then
				castTimerText:Show()
			end
		else
			castBar.castTimerText:Hide()
		end
	end
end

function KP:UpdateAllGlows()
	for Plate, Virtual in pairs(VirtualPlates) do
		local targetGlow = Virtual.healthBar.targetGlow
		local targetGlowTotem = Plate.totemPlate and Plate.totemPlate.targetGlow
		local healthBarHighlight = Virtual.healthBarHighlight
		local threatGlow = Virtual.threatGlow
		targetGlow:SetVertexColor(unpack(KP.dbp.targetGlow_Tint))
		healthBarHighlight:SetVertexColor(unpack(KP.dbp.mouseoverGlow_Tint))
		healthBarHighlight:ClearAllPoints()
		if KP.dbp.healthBar_border == "KhalPlates" then
			targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlow")
			targetGlow:SetSize(KP.NP_WIDTH, KP.NP_HEIGHT)
			targetGlow:SetPoint("CENTER", 0.7, 0.5)
			healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\HealthBar-MouseoverGlow")
			healthBarHighlight:SetSize(KP.NP_WIDTH, KP.NP_HEIGHT)
			healthBarHighlight:SetPoint("CENTER", 1.2 + KP.dbp.globalOffsetX, -8.7 + KP.dbp.globalOffsetY)
			threatGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-ThreatGlow")
		else
			targetGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-TargetGlowBlizz")
			targetGlow:SetSize(KP.NP_WIDTH * 1.165, KP.NP_HEIGHT)
			targetGlow:SetPoint("CENTER", 11.33, 0.5)
			healthBarHighlight:SetTexture(ASSETS .. "PlateBorders\\HealthBar-MouseoverGlowBlizz")
			healthBarHighlight:SetSize(KP.NP_WIDTH * 1.165, KP.NP_HEIGHT)
			healthBarHighlight:SetPoint("CENTER", 11.83 + KP.dbp.globalOffsetX, -8.7 + KP.dbp.globalOffsetY)
			threatGlow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
		end
		if targetGlowTotem then
			targetGlowTotem:SetVertexColor(unpack(KP.dbp.targetGlow_Tint))
		end
	end
end

function KP:UpdateAllThreatGlows()
	for _, Virtual in pairs(VirtualPlates) do
		if KP.dbp.healthBar_border == "KhalPlates" then
			Virtual.threatGlow:SetTexture(ASSETS .. "PlateBorders\\HealthBar-ThreatGlow")
		else
			Virtual.threatGlow:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash")
		end
	end
end

function KP:UpdateAllIcons()
	for _, Virtual in pairs(VirtualPlates) do
		SetupBossIcon(Virtual)
		SetupRaidTargetIcon(Virtual)
		SetupEliteIcon(Virtual)
		SetupClassIcon(Virtual)
	end
end

function KP:UpdateAllTotemPlates()
	for Plate in pairs(VirtualPlates) do
		local totemPlate = Plate.totemPlate
		if totemPlate then
			totemPlate:SetPoint("TOP", 0, KP.dbp.totemOffset - 5)
			totemPlate:SetSize(KP.dbp.totemSize, KP.dbp.totemSize)
			totemPlate.targetGlow:SetSize(128*KP.dbp.totemSize/88, 128*KP.dbp.totemSize/88)
		end
	end
end

function KP:UpdateClassIconsShown()
	for Plate, Virtual in pairs(PlatesVisible) do
		local name =  Virtual.nameString
		Virtual.classIcon:Hide()
		if not KP.TotemTexs[name] and KP.inPvPInstance then
			local class = Virtual.classKey
			if class then
				if class == "FRIENDLY" and KP.dbp.showClassOnFriends then
					class = ClassByFriendName[name] or ""
					Virtual.classIcon:SetTexture(ASSETS .. "Classes\\" .. class)
					Virtual.classIcon:Show()
				elseif class ~= "FRIENDLY" and KP.dbp.showClassOnEnemies then
					Virtual.classIcon:SetTexture(ASSETS .. "Classes\\" .. class)
					Virtual.classIcon:Show()
				end
			end
		end
	end
end

function KP:UpdateClassColorNames()
	for _, Virtual in pairs(PlatesVisible) do
		local class = Virtual.classKey
		local classColor
		if class then
			if class == "FRIENDLY" and ClassByFriendName[Virtual.nameString] and KP.dbp.nameText_classColorFriends then
				classColor = RAID_CLASS_COLORS[ClassByFriendName[Virtual.nameString]]
			elseif class ~= "FRIENDLY" and KP.dbp.nameText_classColorEnemies then
				classColor = RAID_CLASS_COLORS[class]
			end
		end
		Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = unpack(KP.dbp.nameText_color)
		if classColor then
			Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB = classColor.r, classColor.g, classColor.b
		end
		Virtual.healthBar.nameText:SetTextColor(Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB)
		Virtual.nameTextIsYellow = false
	end
end

function KP:UpdateProfile()
	self:UpdateAllVirtualsScale()
	self:UpdateLevelFilter()
	self:UpdateAllHealthBars()
	self:UpdateAllNameTexts()
	self:UpdateAllLevelTexts()
	self:UpdateAllCastBarBorders()
	self:UpdateAllCastBars()
	self:UpdateAllGlows()
	self:UpdateAllIcons()
	self:UpdateAllTotemPlates()
	self:UpdateClassIconsShown()
	self:UpdateClassColorNames()
end

----------- Reference for Core.lua -----------
KP.VirtualPlates = VirtualPlates
KP.RealPlates = RealPlates
KP.PlatesVisible = PlatesVisible
KP.ClassByFriendName = ClassByFriendName
KP.NP_WIDTH = NP_WIDTH
KP.NP_HEIGHT = NP_HEIGHT
KP.ASSETS = ASSETS
KP.UpdateTargetGlow = UpdateTargetGlow
KP.ClassByPlateColor = ClassByPlateColor
KP.SetupKhalPlate = SetupKhalPlate
KP.SetupTotemPlate = SetupTotemPlate