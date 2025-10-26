-------------------------------------------------------------
---------- Core based on "VirtualPlates" by Saiket ----------
-------------------------------------------------------------

-- Namespace
local AddonFile, KP = ...

-- API
local tonumber, select, sort, wipe, pairs, ipairs, unpack, CreateFrame, UnitName, UnitExists, IsInInstance, GetNumRaidMembers, GetRaidRosterInfo =
      tonumber, select, sort, wipe, pairs, ipairs, unpack, CreateFrame, UnitName, UnitExists, IsInInstance, GetNumRaidMembers, GetRaidRosterInfo

-- Localized namespace definitions
local VirtualPlates = KP.VirtualPlates
local RealPlates = KP.RealPlates
local PlatesVisible = KP.PlatesVisible
local ClassByFriendName = KP.ClassByFriendName
local NP_WIDTH = KP.NP_WIDTH
local NP_HEIGHT = KP.NP_HEIGHT
local ASSETS = KP.ASSETS
local UpdateTargetGlow = KP.UpdateTargetGlow
local ClassByPlateColor = KP.ClassByPlateColor
local SetupKhalPlate = KP.SetupKhalPlate
local SetupTotemPlate = KP.SetupTotemPlate
local TotemTexs = KP.TotemTexs

-- Local definitions
local EventHandler = CreateFrame("Frame", nil, WorldFrame) -- Main addon frame (event handler + access to native frame methods)
local PlateOverrides = {}	 -- Storage table: [MethodName] = override function for virtual plates
local PlateLevels = 3 	     -- Frame level difference between plates so one plate's children don't overlap the next closest plate
local NextUpdate = 0.05		 -- Time controller for PlatesUpdate
local UpdateRate = 0.05	     -- Minimum time between plates are updated.

-- Backup of native frame methods
local WorldFrame_GetChildren = WorldFrame.GetChildren
local SetFrameLevel = EventHandler.SetFrameLevel

-- Internal State
KP.inCombat = false
KP.inPvPInstance = false

-- Plate handling and updating	
do
	local SortOrder, Depths = {}, {}

	--- If an anchor ataches to the original plate (by WoW), re-anchor to the Virtual.
	local function ResetPoint(Plate, Region, Point, RelFrame, ...)
		if RelFrame == Plate then
			local point, xOfs, yOfs = ...
			Region:SetPoint(Point, VirtualPlates[Plate], point, xOfs + KP.dbp.globalOffsetX + 11, yOfs + KP.dbp.globalOffsetY)
		end
	end

	--- Re-anchors regions when a plate is shown.
	-- WoW re-anchors most regions when it shows a nameplate, so restore those anchors to the Virtual frame.
	local function PlateOnShow(Plate)
		local Virtual = VirtualPlates[Plate]
		PlatesVisible[Plate] = Virtual
		Virtual:Show()
		NextUpdate = 0 -- sorts instantly

		-- Reposition all regions
		for Index, Region in ipairs(Plate) do
			for Point = 1, Region:GetNumPoints() do
				ResetPoint(Plate, Region, Region:GetPoint(Point))
			end
		end

		-- Sets the texture based on player or NPC nameplate
		local healthBar = Virtual.healthBar
		local class = ClassByPlateColor(healthBar)
		if class then
			healthBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.healthBar_playerTex))
		else
			healthBar.barTex:SetTexture(KP.LSM:Fetch("statusbar", KP.dbp.healthBar_npcTex))
		end

		------------------------ TotemPlates Handling ------------------------
		local name = Virtual.nameText:GetText()
		local totemTex = TotemTexs[name]
		if totemTex then
			if not Plate.totemPlate then
				SetupTotemPlate(Plate) -- Setup TotemPlate on the fly
			end
			Virtual:Hide()
			if totemTex ~= "" then
				Plate.totemPlate:Show()
				Plate.totemPlate.icon:SetTexture(ASSETS .. "Totems\\" .. totemTex)
			end
		else
			if Plate.totemPlate then Plate.totemPlate:Hide() end
			--------------- Nameplate Level Filter --------------
			local level = tonumber(Virtual.levelText:GetText())
			if level and level < KP.dbp.levelFilter then
				Virtual:Hide() -- Hide low level nameplates
			elseif class and KP.inPvPInstance then
				--------------- Show class icons in PvP instances --------------
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

	--- Removes the plate from the visible list when hidden.
	local function PlateOnHide(Plate)
		PlatesVisible[Plate] = nil
		local Virtual = VirtualPlates[Plate]
		Virtual.classIcon:Hide()
		Virtual:Hide(); -- Explicitly hide so IsShown returns false.
		if Plate.totemPlate then Plate.totemPlate:Hide() end
	end

	--- Subroutine for table.sort to depth-sort plate virtuals.
	local function SortFunc(PlateA, PlateB)
		return Depths[PlateA] > Depths[PlateB]
	end

	--- Update all visible nameplates
	local function PlatesUpdate()
		local targetExists = UnitExists("target")
		local mouseoverName = UnitName("mouseover")
		for Plate, Virtual in pairs(PlatesVisible) do
			local Depth = Virtual:GetEffectiveDepth()
			if Depth > 0 then
				SortOrder[#SortOrder + 1] = Plate
				if targetExists and Virtual:GetAlpha() == 1 then
					Depths[Plate] = -1
				else
					Depths[Plate] = Depth
				end
				----------------------- Improved mouseover highlight -----------------------
				local healthBarHighlight = Virtual.healthBarHighlight
				local nameText = Virtual.healthBar.nameText
				if healthBarHighlight:IsShown() then
					nameText:SetTextColor(1, 1, 0) -- yellow
					if nameText:GetText() ~= mouseoverName then
						healthBarHighlight:Hide()
					end
				else
					nameText:SetTextColor(unpack(KP.dbp.nameText_color))
				end
			end
		end
		------- FrameLevels update based on sorting so regions don't overlap -------
		if #SortOrder > 0 then
			sort(SortOrder, SortFunc)
			for Index, Plate in ipairs(SortOrder) do
				local Virtual = PlatesVisible[Plate]
				SetFrameLevel(Virtual, Index * PlateLevels)
				SetFrameLevel(Virtual.healthBar, Index * PlateLevels)
				local TotemPlate = Plate.totemPlate
				local totemTex = TotemTexs[Virtual.nameText:GetText()]
				if TotemPlate and totemTex and totemTex ~= "" then
					SetFrameLevel(TotemPlate, Index * PlateLevels)
				end
				local BGHframe = Virtual.BGHframe
				if BGHframe then
					SetFrameLevel(BGHframe, Index * PlateLevels + 1) 
				end
			end
			wipe(SortOrder)
		end
	end

	--- Parents all plate children to the Virtual, and saves references to them in the plate.
	-- @ param Plate  Original nameplate children are being removed from.
	-- @ param ...  Children of Plate to be reparented.
	local function ReparentChildren(Plate, ...)
		local Virtual = VirtualPlates[Plate]
		for Index = 1, select("#", ...) do
			local Child = select(Index, ...)
			if Child ~= Virtual then
				local LevelOffset = Child:GetFrameLevel() - Plate:GetFrameLevel()
				Child:SetParent(Virtual)
				Child:SetFrameLevel( Virtual:GetFrameLevel() + LevelOffset) -- Maintain relative frame levels
				Plate[#Plate + 1] = Child;
			end
		end
	end

	--- Parents all plate regions to the Virtual, similar to ReparentChildren.
	-- @ see ReparentChildren
	local function ReparentRegions(Plate, ...)
		local Virtual = VirtualPlates[Plate]
		for Index = 1, select("#", ...) do
			local Region = select(Index, ...)
			Region:SetParent(Virtual)
			Plate[#Plate + 1] = Region
		end
	end

	-- Creates a semi-transparent hitbox texture for debugging
	local function SetupHitboxTexture(Plate)
		Plate.hitBox = Plate:CreateTexture(nil, "BACKGROUND")
		Plate.hitBox:SetTexture(0,0,0,0.5)
		Plate.hitBox:SetAllPoints(Plate)
	end

	--- Adds and skins a new nameplate.
	-- @ param Plate  Newly found default nameplate to be hooked.
	local function PlateAdd(Plate)
		local Virtual = CreateFrame("Frame", nil, Plate)

		VirtualPlates[Plate] = Virtual
		RealPlates[Virtual] = Plate
		Plate.VirtualPlate = Plate.VirtualPlate or Virtual
		Virtual.RealPlate = Virtual.RealPlate or Plate
	
		Virtual:Hide() -- Gets explicitly shown on plate show
		Virtual:SetPoint("TOP")
		Virtual:SetSize(NP_WIDTH, NP_HEIGHT)
		Virtual:SetScale(KP.dbp.globalScale)

		ReparentChildren(Plate, Plate:GetChildren())
		ReparentRegions(Plate, Plate:GetRegions())
		Virtual:EnableDrawLayer("HIGHLIGHT") -- Allows the highlight to show without enabling mouse events

		Plate:SetScript("OnShow", PlateOnShow)
		Plate:SetScript("OnHide", PlateOnHide)

		-- Hook methods
		for Key, Value in pairs(PlateOverrides) do
			Virtual[Key] = Value
		end

		SetupKhalPlate(Virtual)
		--SetupHitboxTexture(Plate)

		if Plate:IsVisible() then
			PlateOnShow(Plate)
		end

		-- Force recalculation of effective depth for all child frames
		local Depth = WorldFrame:GetDepth()
		WorldFrame:SetDepth(Depth + 1)
		WorldFrame:SetDepth(Depth)
	end

	local function IsNamePlate(frame)
		local _, r2 = frame:GetRegions()
		return r2 and r2:GetObjectType() == "Texture" and r2:GetTexture() == "Interface\\Tooltips\\Nameplate-Border"
	end

	local ChildCount, NewChildCount = 0
	WorldFrame:HookScript("OnUpdate", function(self)
		NewChildCount = self:GetNumChildren()
		if ChildCount ~= NewChildCount then
			for i = ChildCount + 1, NewChildCount do
				local child = select(i, WorldFrame_GetChildren(self))
				if IsNamePlate(child) then
					PlateAdd(child)
				end
			end
			ChildCount = NewChildCount
		end
	end)

	function KP:WorldFrameOnUpdate(elapsed)
		NextUpdate = NextUpdate - elapsed
		if NextUpdate <= 0 then
			NextUpdate = UpdateRate
			return PlatesUpdate()
		end
	end
end

do
	local Children = {}
	--- Filters the results of WorldFrame:GetChildren to replace plates with their virtuals.
	local function ReplaceChildren(...)
		local Count = select("#", ...)
		for Index = 1, Count do
			local Frame = select(Index, ...)
			Children[Index] = VirtualPlates[Frame] or Frame
		end
		for Index = Count + 1, #Children do -- Remove any extras from the last call
			Children[Index] = nil
		end
		return unpack(Children)
	end
	--- Returns Virtual frames in place of real nameplates.
	-- @ return The results of WorldFrame:GetChildren with any reference to a plate replaced with its virtuals.
	function WorldFrame:GetChildren(...)
		return ReplaceChildren(WorldFrame_GetChildren(self, ...))
	end
end

function KP:OnProfileChanged(...)
	self.dbp = self.db.profile
	self:MoveAllVisiblePlates(self.dbp.globalOffsetX - self.globalOffsetX, self.dbp.globalOffsetY - self.globalOffsetY)
	self:UpdateProfile()
	self.globalOffsetX = self.dbp.globalOffsetX
	self.globalOffsetY = self.dbp.globalOffsetY
end

function KP:Initialize()
	self.db = LibStub("AceDB-3.0"):New("KhalPlatesDB", self.default, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")
	
	self.dbp = self.db.profile -- Replace default profile with AceDB profile

	self.globalOffsetX = self.dbp.globalOffsetX
	self.globalOffsetY = self.dbp.globalOffsetY

	local config = LibStub("AceConfig-3.0")
	local dialog = LibStub("AceConfigDialog-3.0")
	config:RegisterOptionsTable("KhalPlates", self.MainOptionTable)
	dialog:AddToBlizOptions("KhalPlates", "KhalPlates")
	config:RegisterOptionsTable("KhalPlates_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
	dialog:AddToBlizOptions("KhalPlates_Profiles", "Profiles", "KhalPlates")
	config:RegisterOptionsTable("KhalPlates_About", self.AboutTable)
	dialog:AddToBlizOptions("KhalPlates_About", "About", "KhalPlates")
end

--- Initializes settings once loaded.
function EventHandler:ADDON_LOADED(event, Addon)
	if Addon == AddonFile then
		KP:Initialize()
		self:UnregisterEvent(event)
		self[event] = nil
	end
end

function EventHandler:PLAYER_REGEN_ENABLED()
	KP.inCombat = false
	for Plate, Virtual in pairs(PlatesVisible) do
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

function EventHandler:PLAYER_REGEN_DISABLED()
	KP.inCombat = true
end

function EventHandler:PLAYER_TARGET_CHANGED()
	for _, Virtual in pairs(PlatesVisible) do
		UpdateTargetGlow(Virtual)
	end
end

local function UpdateClassByFriendName()
	wipe(ClassByFriendName)
	for i = 1 , GetNumRaidMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		if name and class then
			name = name:match("([^%-]+).*") -- remove realm suffix
			ClassByFriendName[name] = class
		end
	end
end

function EventHandler:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		KP.inPvPInstance = true
		UpdateClassByFriendName()
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	elseif KP.inPvPInstance then
		KP.inPvPInstance = false
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		wipe(ClassByFriendName)
	end
end

function EventHandler:PARTY_MEMBERS_CHANGED()
	if KP.inPvPInstance then 
		UpdateClassByFriendName() 
	end
end

local firstChecked
local ForceLevelHide = CreateFrame("Frame")
ForceLevelHide:Hide()
ForceLevelHide:SetScript("OnUpdate", function(self)
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

function EventHandler:PLAYER_PVP_RANK_CHANGED()
	if KP.dbp.levelText_hide then
		ForceLevelHide:Show()
	end
end

--- Global event handler.
function EventHandler:OnEvent(event, ...)
	if self[event] then
		return self[event](self, event, ...)
	end
end

WorldFrame:HookScript("OnUpdate", KP.WorldFrameOnUpdate) -- First OnUpdate handler to run
EventHandler:SetScript("OnEvent", EventHandler.OnEvent)
EventHandler:RegisterEvent("ADDON_LOADED")
EventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
EventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
EventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
EventHandler:RegisterEvent("PARTY_MEMBERS_CHANGED")
EventHandler:RegisterEvent("PLAYER_PVP_RANK_CHANGED")

local GetParent = EventHandler.GetParent
do
	--- Add method overrides to be applied to plates' Virtuals.
	local function AddPlateOverride(MethodName)
		PlateOverrides[MethodName] = function(self, ...)
			local Plate = GetParent(self)
			return Plate[MethodName]( Plate, ... )
		end
	end
	AddPlateOverride("GetParent")
	AddPlateOverride("SetAlpha")
	AddPlateOverride("GetAlpha")
	AddPlateOverride("GetEffectiveAlpha")
end

-- Method overrides to use plates' OnUpdate script handlers instead of their Virtuals' to preserve handler execution order
do
	--- Wrapper for plate OnUpdate scripts to replace their self parameter with the plate's Virtual.
	local function OnUpdateOverride(self, ...)
		self.OnUpdate(VirtualPlates[self], ...)
	end
	local type = type

	local SetScript = EventHandler.SetScript
	--- Redirects all SetScript calls for the OnUpdate handler to the original plate.
	function PlateOverrides:SetScript(Script, Handler, ...)
		if type(Script) == "string" and Script:lower() == "onupdate" then
			local Plate = GetParent(self)
			Plate.OnUpdate = Handler
			return Plate:SetScript(Script, Handler and OnUpdateOverride or nil, ...)
		else
			return SetScript(self, Script, Handler, ...)
		end
	end

	local GetScript = EventHandler.GetScript
	--- Redirects calls to GetScript for the OnUpdate handler to the original plate's script.
	function PlateOverrides:GetScript(Script, ...)
		if type(Script) == "string" and Script:lower() == "onupdate" then
			return GetParent(self).OnUpdate
		else
			return GetScript(self, Script, ...)
		end
	end

	local HookScript = EventHandler.HookScript
	--- Redirects all HookScript calls for the OnUpdate handler to the original plate.
	-- Also passes the virtual to the hook script instead of the plate.
	function PlateOverrides:HookScript (Script, Handler, ...)
		if type(Script) == "string" and Script:lower() == "onupdate" then
			local Plate = GetParent(self)
			if Plate.OnUpdate then
				-- Hook old OnUpdate handler
				local Backup = Plate.OnUpdate;
				function Plate:OnUpdate(...)
					Backup(self, ...) -- Technically we should return Backup's results to match HookScript's hook behavior,
					return Handler(self, ...) -- but the overhead isn't worth it when these results get discarded.
				end
			else
				Plate.OnUpdate = Handler
			end
			return Plate:SetScript(Script, OnUpdateOverride, ...)
		else
			return HookScript(self, Script, Handler, ...)
		end
	end
end