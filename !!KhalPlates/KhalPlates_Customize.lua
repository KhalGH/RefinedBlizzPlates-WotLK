
local AddonFile, KP = ... -- namespace

----------------------------- API -----------------------------
local ipairs, unpack, select, math_floor, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName =
      ipairs, unpack, select, math.floor, CreateFrame, UnitCastingInfo, UnitChannelInfo, UnitName

------------------------- Core Variables -------------------------
local VirtualPlates = {} -- Storage table for Virtual nameplate frames
local RealPlates = {} -- Storage table for real nameplate frames
local texturePath = "Interface\\AddOns\\" .. AddonFile .. "\\Textures\\"
local NP_WIDTH = 156.65118520899 -- Nameplate original width (don't modify)
local NP_HEIGHT = 39.162796302247 -- Nameplate original height (don't modify)

-------------------- Customization Parameters --------------------
local globalYoffset = 22 -- Global vertical offset for nameplates
local VPscale = 1        -- Global scale for nameplates
local NPminLevel = 1     -- Minimum unit level to show its nameplate
local fontPath = "Fonts\\ARIALN.TTF" -- Font used for nameplate text
-- Name Text
local nameText_fontSize = 9
local nameText_fontFlags = nil
local nameText_anchor = "CENTER"
local nameText_Xoffset = 0.2
local nameText_Yoffset = 0.7
local nameText_width = 85 -- max text width before truncation (...)
local nameText_color = {1, 1, 1} -- white
-- Health Text
local healthText_fontSize = 8.8
local healthText_fontFlags = nil
local healthText_anchor = "RIGHT"
local healthText_Xoffset = 0
local healthText_Yoffset = 0.3
local healthText_color = {1, 1, 1} -- white
-- Cast Text
local castText_fontSize = 9
local castText_fontFlags = nil
local castText_anchor = "CENTER"
local castText_Xoffset = -3.8
local castText_Yoffset = 1.6
local castText_width = 90 -- max text width before truncation (...)
local castText_color = {1, 1, 1} -- white
-- Cast Timer Text
local castTimerText_fontSize = 8.8
local castTimerText_fontFlags = nil
local castTimerText_anchor = "RIGHT"
local castTimerText_Xoffset = -2
local castTimerText_Yoffset = 1
local castTimerText_color = {1, 1, 1} -- white
-- Target Glow
local targetGlow_alpha = 1 -- opacity
-- Mouseover Glow
local mouseoverGlow_alpha = 1 -- opacity
-- Boss Icon
local bossIcon_size = 18
local bossIcon_anchor = "RIGHT"
local bossIcon_Xoffset = 4.5
local bossIcon_Yoffset = -9
-- Raid Target Icon
local raidTargetIcon_size = 27
local raidTargetIcon_anchor = "RIGHT"
local raidTargetIcon_Xoffset = 16
local raidTargetIcon_Yoffset = -9
-- Totem Plates
local totemSize = 23 -- Size of the totem (or NPC) icon replacing the nameplate
local totemOffSet = -5 -- Vertical offset for totem icon
local totemGlowSize = 128 * totemSize / 88 -- Ratio 128:88 comes from texture pixels
-- Class Icon (in Arenas and BGs)
local showClassOnFriends = true
local showClassOnEnemies = true
local classIcon_size = 26
local classIcon_anchor = "LEFT"
local classIcon_Xoffset = -9.6
local classIcon_Yoffset = -9

---------------------------- Customization Functions ----------------------------
local function CreateHealthBorder(healthBar)
	if healthBar.healthBarBorder then return end
	healthBar.healthBarBorder = healthBar:CreateTexture(nil, "ARTWORK")
	healthBar.healthBarBorder:SetTexture(texturePath .. "HealthBar-Border")
	healthBar.healthBarBorder:SetSize(NP_WIDTH, NP_HEIGHT)
	healthBar.healthBarBorder:SetPoint("CENTER", 10.5, 9)
end

local function CreateBarBackground(Bar)
	if Bar.BackgroundTex then return end 
	Bar.BackgroundTex = Bar:CreateTexture(nil, "BACKGROUND")
	Bar.BackgroundTex:SetTexture(texturePath .. "NamePlate-Background")
	Bar.BackgroundTex:SetSize(NP_WIDTH, NP_HEIGHT)
	Bar.BackgroundTex:SetPoint("CENTER", 10.5, 9)
end

local function CreateNameText(healthBar)
	if healthBar.nameText then return end
	healthBar.nameText = healthBar:CreateFontString(nil, "OVERLAY")
	healthBar.nameText:SetFont(fontPath, nameText_fontSize, nameText_fontFlags)
	healthBar.nameText:SetPoint(nameText_anchor, nameText_Xoffset, nameText_Yoffset)
	healthBar.nameText:SetWidth(nameText_width)
	healthBar.nameText:SetTextColor(unpack(nameText_color))
	healthBar.nameText:SetShadowOffset(0.5, -0.5)
	healthBar.nameText:SetNonSpaceWrap(false)
	healthBar.nameText:SetWordWrap(false)
end

local function UpdateHealthText(healthBar)
	local min, max = healthBar:GetMinMaxValues()
	local value = healthBar:GetValue()
	if max > 0 then
		local percent = math_floor((value / max) * 100)
		if percent < 100 and percent > 0 then
			healthBar.healthText:SetText(percent .. "%")
		else
			healthBar.healthText:SetText("")
		end
	else
		healthBar.healthText:SetText("")
	end
end

local function CreateHealthText(healthBar)
	if healthBar.healthText then return end
	healthBar.healthText = healthBar:CreateFontString(nil, "OVERLAY")
	healthBar.healthText:SetFont(fontPath, healthText_fontSize, healthText_fontFlags)
	healthBar.healthText:SetPoint(healthText_anchor, healthText_Xoffset, healthText_Yoffset)
	healthBar.healthText:SetTextColor(unpack(healthText_color))
	healthBar.healthText:SetShadowOffset(0.5, -0.5)
	UpdateHealthText(healthBar)
	healthBar:HookScript("OnValueChanged", UpdateHealthText)
	healthBar:HookScript("OnShow", UpdateHealthText)
end

local function CreateTargetGlow(healthBar)
	if healthBar.targetGlow then return end
	healthBar.targetGlow = healthBar:CreateTexture(nil, "OVERLAY")	
	healthBar.targetGlow:SetTexture(texturePath .. "HealthBar-TargetGlow")
	healthBar.targetGlow:SetSize(NP_WIDTH, NP_HEIGHT)
	healthBar.targetGlow:SetAlpha(targetGlow_alpha)
	healthBar.targetGlow:SetPoint("CENTER", 0.7, 0.5)
	healthBar.targetGlow:Hide()
end

local function UpdateTargetGlow(healthBar)
	local Virtual = healthBar:GetParent()
	local RealPlate = RealPlates[Virtual]
	healthBar.targetBorderDelay = healthBar.targetBorderDelay or CreateFrame("Frame")
	healthBar.targetBorderDelay:SetScript("OnUpdate", function(self, elapsed)
		self:SetScript("OnUpdate", nil)
		if healthBar.nameText:GetText() == UnitName("target") and Virtual:GetAlpha() == 1 then
			healthBar.targetGlow:Show()
			if RealPlate.totemPlate then RealPlate.totemPlate.targetGlow:Show() end
		else
			healthBar.targetGlow:Hide()
			if RealPlate.totemPlate then RealPlate.totemPlate.targetGlow:Hide() end
		end
	end)
end

local function CreateCastText(castBar)
	if castBar.castText then return end
	castBar.castText = castBar:CreateFontString(nil, "OVERLAY")
	castBar.castText:SetFont(fontPath, castText_fontSize, castText_fontFlags)
	castBar.castText:SetPoint(castText_anchor, castText_Xoffset, castText_Yoffset)
	castBar.castText:SetWidth(castText_width)
	castBar.castText:SetTextColor(unpack(castText_color))
	castBar.castText:SetNonSpaceWrap(false)
	castBar.castText:SetWordWrap(false)
	castBar.castText:SetShadowOffset(0.5, -0.5)
	castBar.castTextDelay = castBar.castTextDelay or CreateFrame("Frame")
	local function UpdateCastText()
		castBar.castTextDelay:SetScript("OnUpdate", function(self, elapsed)
			self:SetScript("OnUpdate", nil)
			local unit = "target"
			local spellName = UnitCastingInfo(unit) or UnitChannelInfo(unit)
			castBar.castText:SetText(spellName)				
		end)
	end
	UpdateCastText()
	castBar:HookScript("OnShow", UpdateCastText)
end

local function CreateCastTimer(castBar)
	if castBar.castTimerText then return end
	castBar.castTimerText = castBar:CreateFontString(nil, "OVERLAY")
	castBar.castTimerText:SetFont(fontPath, castTimerText_fontSize, castTimerText_fontFlags)
	castBar.castTimerText:SetPoint(castTimerText_anchor, castTimerText_Xoffset, castTimerText_Yoffset)
	castBar.castTimerText:SetTextColor(unpack(castTimerText_color))
	castBar.castTimerText:SetShadowOffset(0.5, -0.5)
	castBar:HookScript("OnValueChanged", function(self, value)
		local min, max = self:GetMinMaxValues()
		if max and value then
			local remaining = max - value
			if UnitChannelInfo("target") then
				self.castTimerText:SetFormattedText("%.1f", value)
			else
				self.castTimerText:SetFormattedText("%.1f", remaining)
			end
		end
	end)
end

local function CreateClassIcon(Virtual)
	if Virtual.classIcon then return end
	Virtual.classIcon = Virtual:CreateTexture(nil, "ARTWORK")	
	Virtual.classIcon:SetSize(classIcon_size, classIcon_size)
	Virtual.classIcon:SetPoint(classIcon_anchor, classIcon_Xoffset, classIcon_Yoffset + globalYoffset)
	Virtual.classIcon:Hide()
end

local function CustomizePlate(Virtual)
	local threatGlow, healthBarBorder, castBarBorder, shieldCastBarBorder, spellIcon, healthBarHighlight, nameText, levelText, bossIcon, raidTargetIcon, eliteIcon = Virtual:GetRegions()
	Virtual.castBarBorder = castBarBorder
	Virtual.healthBarHighlight = healthBarHighlight
	Virtual.nameText = nameText
	Virtual.levelText = levelText
	Virtual.healthBar, Virtual.castBar = Virtual:GetChildren()
	Virtual.healthBar.barTex = Virtual.healthBar:GetRegions()
	Virtual.castBar.barTex = Virtual.castBar:GetRegions()
	CreateHealthBorder(Virtual.healthBar)
	CreateNameText(Virtual.healthBar)
	CreateTargetGlow(Virtual.healthBar)
	CreateHealthText(Virtual.healthBar)
	CreateBarBackground(Virtual.healthBar)
	CreateBarBackground(Virtual.castBar)
	CreateCastText(Virtual.castBar)
	CreateCastTimer(Virtual.castBar)
	CreateClassIcon(Virtual)
	healthBarBorder:Hide()
	nameText:Hide()
	threatGlow:SetTexture(nil)
	castBarBorder:SetTexture(texturePath .. "CastBar-Border")
	healthBarHighlight:SetTexture(texturePath .. "HealthBar-MouseoverGlow")
	healthBarHighlight:SetSize(NP_WIDTH, NP_HEIGHT)
	healthBarHighlight:SetAlpha(mouseoverGlow_alpha)
	bossIcon:ClearAllPoints()
	bossIcon:SetSize(bossIcon_size, bossIcon_size)
	bossIcon:SetPoint(bossIcon_anchor, bossIcon_Xoffset, bossIcon_Yoffset + globalYoffset)
	raidTargetIcon:ClearAllPoints()
	raidTargetIcon:SetSize(raidTargetIcon_size, raidTargetIcon_size)
	raidTargetIcon:SetPoint(raidTargetIcon_anchor, raidTargetIcon_Xoffset, raidTargetIcon_Yoffset + globalYoffset)
	eliteIcon:SetTexCoord(0.578125, 0, 0.578125, 0.84375, 0, 0, 0, 0.84375)
	eliteIcon:SetPoint("LEFT", 0, -11.5 + globalYoffset)
	Virtual.healthBar.barTex:SetTexture(texturePath .. "NamePlate-BarFill")
	Virtual.healthBar.barTex:SetDrawLayer("BORDER")
	Virtual.castBar.barTex:SetTexture(texturePath .. "NamePlate-BarFill")
	local function VirtualOnShow()
		castBarBorder:SetPoint("CENTER", 0, -19 + globalYoffset)
		castBarBorder:SetWidth(145)
		shieldCastBarBorder:SetWidth(145)
		healthBarHighlight:ClearAllPoints()
		healthBarHighlight:SetPoint("CENTER", 1.2, -8.7 + globalYoffset)
		levelText:Hide()
		Virtual.healthBar.nameText:SetText(nameText:GetText())
		UpdateTargetGlow(Virtual.healthBar)
	end
	VirtualOnShow()
	Virtual:HookScript("OnShow", VirtualOnShow)
end

local function SetupTotemPlate(Plate)
	if Plate.totemPlate then return end
	Plate.totemPlate = CreateFrame("Frame", nil, Plate)
	Plate.totemPlate:SetPoint("TOP", 0, totemOffSet)
	Plate.totemPlate:SetSize(totemSize, totemSize)
	Plate.totemPlate:SetScale(VPscale)
	Plate.totemPlate:Hide()
	Plate.totemPlate.icon = Plate.totemPlate:CreateTexture(nil, "ARTWORK")
	Plate.totemPlate.icon:SetAllPoints(Plate.totemPlate)
	Plate.totemPlate.targetGlow = Plate.totemPlate:CreateTexture(nil, "OVERLAY")
	Plate.totemPlate.targetGlow:SetTexture(texturePath .. "TotemPlate-TargetGlow.blp")
	Plate.totemPlate.targetGlow:SetPoint("CENTER")
	Plate.totemPlate.targetGlow:SetSize(totemGlowSize, totemGlowSize)
	Plate.totemPlate.targetGlow:SetAlpha(targetGlow_alpha)
	Plate.totemPlate.targetGlow:Hide()
	Plate.totemPlate.mouseoverGlow = Plate.totemPlate:CreateTexture(nil, "OVERLAY")
	Plate.totemPlate.mouseoverGlow:SetTexture(texturePath .. "TotemPlate-MouseoverGlow.blp")
	Plate.totemPlate.mouseoverGlow:SetPoint("CENTER")
	Plate.totemPlate.mouseoverGlow:SetSize(totemGlowSize, totemGlowSize)
	Plate.totemPlate.mouseoverGlow:SetAlpha(mouseoverGlow_alpha)
	Plate.totemPlate.mouseoverGlow:Hide()
end

----------- reference for KhalPlates.lua -----------
KP.NP_WIDTH = NP_WIDTH
KP.NP_HEIGHT = NP_HEIGHT
KP.VirtualPlates = VirtualPlates
KP.RealPlates = RealPlates
KP.texturePath = texturePath
KP.globalYoffset = globalYoffset
KP.VPscale = VPscale
KP.NPminLevel = NPminLevel
KP.nameText_color = nameText_color
KP.targetGlow_alpha = targetGlow_alpha
KP.mouseoverGlow_alpha = mouseoverGlow_alpha
KP.UpdateTargetGlow = UpdateTargetGlow
KP.showClassOnFriends = showClassOnFriends
KP.showClassOnEnemies = showClassOnEnemies
KP.CustomizePlate = CustomizePlate
KP.SetupTotemPlate = SetupTotemPlate