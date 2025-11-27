-------------------------------------------------------------
--------------- Core based on "VirtualPlates" ---------------
-------------------------------------------------------------

-- Namespace
local AddonFile, RBP = ...

-- API
local select, next, pairs, ipairs, unpack, string_format, GetAddOnMetadata, sort, wipe, CreateFrame, UnitName, UnitLevel, UnitDebuff, IsInInstance, SetMapToCurrentZone, GetCurrentMapAreaID, GetSubZoneText, SetUIVisibility, SetCVar =
      select, next, pairs, ipairs, unpack, string.format, GetAddOnMetadata, sort, wipe, CreateFrame, UnitName, UnitLevel, UnitDebuff, IsInInstance, SetMapToCurrentZone, GetCurrentMapAreaID, GetSubZoneText, SetUIVisibility, SetCVar

-- Localized namespace definitions
local NP_WIDTH = RBP.NP_WIDTH
local NP_HEIGHT = RBP.NP_HEIGHT
local VirtualPlates = RBP.VirtualPlates
local PlatesVisible = RBP.PlatesVisible
local ReactionByPlateColor = RBP.ReactionByPlateColor
local UpdateTarget = RBP.UpdateTarget
local SetupRefinedPlate = RBP.SetupRefinedPlate
local ForceLevelHide = RBP.ForceLevelHide
local CheckDominateMind = RBP.CheckDominateMind
local UpdateGroupInfo = RBP.UpdateGroupInfo
local UpdateArenaInfo = RBP.UpdateArenaInfo
local UpdateClassColorNames = RBP.UpdateClassColorNames
local ExecuteHitboxSecureScript = RBP.ExecuteHitboxSecureScript
local InitPlatesHitboxes = RBP.InitPlatesHitboxes
local HitboxAttributeUpdater = RBP.HitboxAttributeUpdater
local UpdateHitboxInCombat = RBP.UpdateHitboxInCombat
local UpdateHitboxOutOfCombat = RBP.UpdateHitboxOutOfCombat
local UpdateRefinedPlate = RBP.UpdateRefinedPlate
local ResetRefinedPlate = RBP.ResetRefinedPlate
local DelayedUpdateAllShownPlates = RBP.DelayedUpdateAllShownPlates
local UpdateStacking = RBP.UpdateStacking

-- Local definitions
local EventHandler = CreateFrame("Frame", nil, WorldFrame) -- Main addon frame (event handler + access to native frame methods)
local PlateOverrides = {}	 -- Storage table: [MethodName] = override function for virtual plates
local PlateLevels = 3 	     -- Frame level difference between plates so one plate's children don't overlap the next closest plate
local NextUpdate = 0.05		 -- Time controller for PlatesUpdate
local UpdateRate = 0.05	     -- Minimum time between plates are updated.

-- Backup of native frame methods
local WorldFrame_GetChildren = WorldFrame.GetChildren
local SetFrameLevel = EventHandler.SetFrameLevel
local GetParent = EventHandler.GetParent

-- Status Flags
local ExistsVisiblePlates = false
RBP.inCombat = false
RBP.inInstance = false
RBP.inPvEInstance = false
RBP.inPvPInstance = false
RBP.inBG = false
RBP.inArena = false
RBP.inICC = false
RBP.inLDWZone = false
RBP.playerLevel = UnitLevel("player")

-- Plate handling and updating	
do
	local SortOrder, Depths = {}, {}

	local function PlateOnShow(Plate)
		local Virtual = Plate.VirtualPlate
		PlatesVisible[Plate] = Virtual
		ExistsVisiblePlates = true
		NextUpdate = 0 -- sorts instantly
		--- If an anchor ataches to the original plate (by WoW), re-anchor to the Virtual.
		for Index, Region in ipairs(Plate) do
			for Point = 1, Region:GetNumPoints() do
				local point, relativeTo, relativePoint, xOfs, yOfs = Region:GetPoint(Point)
				if relativeTo == Plate then
					Region:SetPoint(point, Virtual, relativePoint, xOfs + RBP.dbp.globalOffsetX + 11, yOfs + RBP.dbp.globalOffsetY)
				end
			end
		end
		Plate.hasRaidIcon = Virtual.raidTargetIcon:IsShown() and true
		Plate.hasEliteIcon = Virtual.eliteIcon:IsShown() and true
		Plate.isFriendly = ReactionByPlateColor(Virtual.healthBar) == "FRIENDLY"
		UpdateRefinedPlate(Plate)
		UpdateTarget(Plate)
		if RBP.inCombat then
			UpdateHitboxInCombat(Plate)
		else
			UpdateHitboxOutOfCombat(Plate)
		end
	end

	local function PlateOnHide(Plate)
		PlatesVisible[Plate] = nil
		ExistsVisiblePlates = next(PlatesVisible) ~= nil
		Plate.hasRaidIcon = nil
		Plate.hasEliteIcon = nil
		Plate.isFriendly = nil
		ResetRefinedPlate(Plate)
		if RBP.inCombat then
			ExecuteHitboxSecureScript()
		end
	end

	--- Update all visible nameplates
	local mouseoverName, Depth, healthBarHighlight, nameText, Virtual, BGHframe
	local function PlatesUpdate()
		if not ExistsVisiblePlates then return end
		mouseoverName = UnitName("mouseover")
		for Plate, Virtual in pairs(PlatesVisible) do
			Depth = Virtual:GetEffectiveDepth()
			if Depth > 0 then
				SortOrder[#SortOrder + 1] = Plate
				if Virtual.isTarget then
					Depths[Plate] = -1
				else
					Depths[Plate] = Depth
				end
				if Virtual.isShown then
					----------------------- Improved mouseover highlight -----------------------
					healthBarHighlight = Virtual.healthBarHighlight
					nameText = Virtual.healthBar.nameText
					if healthBarHighlight:IsShown() then
						if Virtual.nameString ~= mouseoverName then
							healthBarHighlight:Hide()
						elseif not Virtual.nameTextIsYellow then
							nameText:SetTextColor(1, 1, 0)
							Virtual.nameTextIsYellow  = true
						end
					elseif Virtual.nameTextIsYellow then
						nameText:SetTextColor(Virtual.nameColorR, Virtual.nameColorG, Virtual.nameColorB)
						Virtual.nameTextIsYellow = false
					end
				end
			end
		end
		------- FrameLevels update based on sorting so regions don't overlap -------
		if #SortOrder > 0 then
			sort(SortOrder, function(a, b) return Depths[a] > Depths[b] end)
			for Index, Plate in ipairs(SortOrder) do
				Virtual = PlatesVisible[Plate]
				SetFrameLevel(Virtual, Index * PlateLevels)
				SetFrameLevel(Virtual.healthBar, Index * PlateLevels)
				if Plate.totemPlateIsShown then
					SetFrameLevel(Plate.totemPlate, Index * PlateLevels)
				end
				if Plate.barlessPlateIsShown then
					SetFrameLevel(Plate.barlessPlate, Index * PlateLevels + 1)
				end
				BGHframe = Virtual.BGHframe
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
		local Virtual = Plate.VirtualPlate
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
		local Virtual = Plate.VirtualPlate
		for Index = 1, select("#", ...) do
			local Region = select(Index, ...)
			Region:SetParent(Virtual)
			Plate[#Plate + 1] = Region
		end
	end

	-- Creates a semi-transparent hitbox texture for debugging
	local function SetupHitboxTexture(Plate)
		Plate.hitBox = Plate:CreateTexture(nil, "OVERLAY")
		Plate.hitBox:SetTexture(1,0,0,0.5)
		Plate.hitBox:SetAllPoints(Plate)
	end

	--- Adds and skins a new nameplate.
	-- @ param Plate  Newly found default nameplate to be hooked.
	local function PlateAdd(Plate)
		local Virtual = CreateFrame("Frame", nil, Plate)
		Plate.VirtualPlate = Virtual
		Virtual.RealPlate = Plate
		VirtualPlates[Plate] = Virtual
	
		Virtual:Hide() -- Gets explicitly shown on plate show
		Virtual:SetPoint("TOP")
		Virtual:SetSize(NP_WIDTH, NP_HEIGHT)

		ReparentChildren(Plate, Plate:GetChildren())
		ReparentRegions(Plate, Plate:GetRegions())
		Virtual:SetScale(RBP.dbp.globalScale)
		Virtual:EnableDrawLayer("HIGHLIGHT") -- Allows the highlight to show without enabling mouse events

		Plate:SetScript("OnShow", PlateOnShow)
		Plate:SetScript("OnHide", PlateOnHide)

		-- Hook methods
		for Key, Value in pairs(PlateOverrides) do
			Virtual[Key] = Value
		end

		SetupRefinedPlate(Virtual)
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

	function RBP:WorldFrameOnUpdate(elapsed)
		UpdateStacking()
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
			Children[Index] = Frame.VirtualPlate or Frame
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

WorldFrame:HookScript("OnUpdate", RBP.WorldFrameOnUpdate) -- First OnUpdate handler to run

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
		self.OnUpdate(self.VirtualPlate, ...)
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

function RBP:OnProfileChanged(...)
	self.dbp = self.db.profile
	self:MoveAllShownPlates(self.dbp.globalOffsetX - self.globalOffsetX, self.dbp.globalOffsetY - self.globalOffsetY)
	self:UpdateProfile()
	self.globalOffsetX = self.dbp.globalOffsetX
	self.globalOffsetY = self.dbp.globalOffsetY
end

function RBP:Initialize()
	self.db = LibStub("AceDB-3.0"):New("KhalPlatesDB", self.default, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")

	self.dbp = self.db.profile -- Replace default profile with AceDB profile
	self.globalOffsetX = self.dbp.globalOffsetX
	self.globalOffsetY = self.dbp.globalOffsetY

	RBP:BuildBlacklistUI()

	HitboxAttributeUpdater()

	if self.dbp.stackingEnabled then
		SetCVar("nameplateAllowOverlap", 1)
	end

	SetUIVisibility(true)
	if self.dbp.LDWfix then
		EventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")
		EventHandler:RegisterEvent("UNIT_AURA")
	end

	local config = LibStub("AceConfig-3.0")
	local dialog = LibStub("AceConfigDialog-3.0")
	config:RegisterOptionsTable("RefinedBlizzPlates", self.MainOptionTable)
	dialog:AddToBlizOptions("RefinedBlizzPlates", "RefinedBlizzPlates")
	config:RegisterOptionsTable("RefinedBlizzPlates_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
	dialog:AddToBlizOptions("RefinedBlizzPlates_Profiles", "Profiles", "RefinedBlizzPlates")
	config:RegisterOptionsTable("RefinedBlizzPlates_About", self.AboutTable)
	dialog:AddToBlizOptions("RefinedBlizzPlates_About", "About", "RefinedBlizzPlates")
end

--- Initializes settings once loaded.
function EventHandler:ADDON_LOADED(event, Addon)
	if Addon == AddonFile then
		RBP:Initialize()
		print(string_format(" |cffCCCC88RefinedBlizzPlates|r v%s by |cffc41f3bKhal|r", GetAddOnMetadata(AddonFile, "Version")))
		self:UnregisterEvent(event)
		self[event] = nil
	end
end

function EventHandler:PLAYER_LOGIN(event)
	RBP:UpdateTotemDesc()
	RBP:UpdateWorldFrameHeight(true)
	SetCVar("showVKeyCastbar", 1)
	self:UnregisterEvent(event)
	self[event] = nil
end

function EventHandler:PLAYER_REGEN_ENABLED()
	RBP.inCombat = false
	if RBP.delayedHitboxUpdate then
		RBP.delayedHitboxUpdate = false
		HitboxAttributeUpdater()
	end
end

function EventHandler:PLAYER_REGEN_DISABLED()
	RBP.inCombat = true
	InitPlatesHitboxes()
	ExecuteHitboxSecureScript()
end

function EventHandler:PLAYER_TARGET_CHANGED()
	for Plate in pairs(PlatesVisible) do
		UpdateTarget(Plate)
	end
end

function EventHandler:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()
	RBP.inInstance = inInstance == 1
	RBP.inPvEInstance = instanceType == "party" or instanceType == "raid"
	RBP.inPvPInstance = instanceType == "pvp" or instanceType == "arena"
	RBP.inBG = instanceType == "pvp"
	RBP.inArena = instanceType == "arena"
	UpdateGroupInfo()
	if instanceType == "arena" then
		UpdateArenaInfo()
	end
	RBP.inICC = false
	RBP.inLDWZone = false
	if instanceType == "raid" and RBP.dbp.LDWfix then
		SetMapToCurrentZone()
		if GetCurrentMapAreaID() == 605 then
			RBP.inICC = true
			if GetSubZoneText() == RBP.LDWZoneText then
				RBP.inLDWZone = true
			end
		end
	end
    if RBP.DominateMind then
        RBP.DominateMind = nil
		SetUIVisibility(true)
    end
end

function EventHandler:PARTY_MEMBERS_CHANGED()
	UpdateGroupInfo()
	UpdateClassColorNames()
end

function EventHandler:UNIT_FACTION(event, unit)
	if unit == "player" and not RBP.inInstance then
		DelayedUpdateAllShownPlates()
	end
end

function EventHandler:PLAYER_PVP_RANK_CHANGED()
	if RBP.dbp.levelText_hide then
		ForceLevelHide()
	end
end

function EventHandler:PLAYER_LEVEL_UP(event, newLevel)
	RBP.playerLevel = newLevel
	if RBP.dbp.levelText_hide then
		ForceLevelHide()
	end
end

function EventHandler:ARENA_OPPONENT_UPDATE(event, unitToken, updateReason)
	if updateReason == "seen" and unitToken:match("^arena(%d+)$") then
		UpdateArenaInfo()
	end
end

function EventHandler:ZONE_CHANGED_INDOORS()
	if RBP.inICC and GetSubZoneText() == RBP.LDWZoneText then
		RBP.inLDWZone = true
	else
		RBP.inLDWZone = false
	end
    if RBP.DominateMind then
        RBP.DominateMind = nil
        SetUIVisibility(true)
    end
end

function EventHandler:UNIT_AURA(event, unit)
	if unit == "player" and RBP.inLDWZone then
		CheckDominateMind()
	end
end

function EventHandler:RAID_TARGET_UPDATE()
	RBP:UpdateAllShownPlates(true)
end

function EventHandler:NAME_PLATE_UNIT_ADDED(event, token)
	local Plate = C_NamePlate.GetNamePlateForUnit(token)
	if Plate and not Plate.namePlateUnitToken then
		Plate.namePlateUnitToken = token
	end
end

--- Global event handler.
function EventHandler:OnEvent(event, ...)
	if self[event] then
		return self[event](self, event, ...)
	end
end

EventHandler:SetScript("OnEvent", EventHandler.OnEvent)
EventHandler:RegisterEvent("ADDON_LOADED")
EventHandler:RegisterEvent("PLAYER_LOGIN")
EventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
EventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
EventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
EventHandler:RegisterEvent("PARTY_MEMBERS_CHANGED")
EventHandler:RegisterEvent("UNIT_FACTION")
EventHandler:RegisterEvent("PLAYER_PVP_RANK_CHANGED")
EventHandler:RegisterEvent("PLAYER_LEVEL_UP")
EventHandler:RegisterEvent("ARENA_OPPONENT_UPDATE")
EventHandler:RegisterEvent("RAID_TARGET_UPDATE")
if C_NamePlate then
	EventHandler:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end
RBP.EventHandler = EventHandler