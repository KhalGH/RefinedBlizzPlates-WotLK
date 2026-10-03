-------------------------------------------------------------
--------------- Core based on "VirtualPlates" ---------------
-------------------------------------------------------------

-- Namespace
local AddonFile, RBP = ...

-- API
local select, next, pairs, ipairs, unpack, string_format, math_sqrt, GetAddOnMetadata, CreateFrame, UnitLevel, UnitDebuff, IsInInstance, SetUIVisibility, SetCVar, C_NamePlate =
      select, next, pairs, ipairs, unpack, string.format, math.sqrt, GetAddOnMetadata, CreateFrame, UnitLevel, UnitDebuff, IsInInstance, SetUIVisibility, SetCVar, C_NamePlate

-- Localized namespace definitions
local hasModernAPI = RBP.hasModernAPI
local EventHandler = RBP.EventHandler
local VirtualPlates = RBP.VirtualPlates
local PlatesVisible = RBP.PlatesVisible
local UpdateRefinedPlateDelayed = RBP.UpdateRefinedPlateDelayed
local SetupRefinedPlate = RBP.SetupRefinedPlate
local ForceLevelHide = RBP.ForceLevelHide
local CheckLDWZoneIndoors = RBP.CheckLDWZoneIndoors
local CheckDominateMind = RBP.CheckDominateMind
local UpdateGroupInfo = RBP.UpdateGroupInfo
local UpdateArenaInfo = RBP.UpdateArenaInfo
local ExecuteClickboxSecureScript = RBP.ExecuteClickboxSecureScript
local InitPlatesClickboxes = RBP.InitPlatesClickboxes
local ClickboxAttributeUpdater = RBP.ClickboxAttributeUpdater
local UpdateClickboxOutOfCombat = RBP.UpdateClickboxOutOfCombat
local UpdateClickbox = RBP.UpdateClickbox
local UpdatePlateFlags = RBP.UpdatePlateFlags
local ResetPlateFlags = RBP.ResetPlateFlags
local PlatesUpdate = RBP.PlatesUpdate 
local PlatesUpdateModern = RBP.PlatesUpdateModern
local PlatesSecUpdate = RBP.PlatesSecUpdate
local RefreshGroupVisuals = RBP.RefreshGroupVisuals
local UpdateRaidIcon = RBP.UpdateRaidIcon
local UpdateRefinedPlate = RBP.UpdateRefinedPlate
local ResetRefinedPlate = RBP.ResetRefinedPlate
local UpdateStacking = RBP.UpdateStacking

-- Local definitions
local PlateOverrides = {}	 -- Storage table: [MethodName] = override function for virtual plates
local NextUpdate = 0.05		 -- Time controller for PlatesUpdate
local UpdateRate = 0.05	     -- Minimum time between PlatesUpdate.
local NextSecUpdate = 0.2    -- Time controller for PlatesSecUpdate
local SecUpdateRate = 0.2	 -- Minimum time between PlatesSecUpdate.

-- Backup of native frame methods
local WorldFrame_GetChildren = WorldFrame.GetChildren
local GetParent = EventHandler.GetParent

-- Status Flags
local ExistsVisiblePlates = false
local nameplateSizeCheck = true
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
RBP.NP_WIDTH = 128
RBP.NP_HEIGHT = 32
RBP.NP_SCALE = 1
RBP.HB_CENTER_X = -8.5759733829502
RBP.HB_CENTER_Y = -7.5040053203105
RBP.HB_BOTTOMLEFT_X = 3.9680000548363
RBP.HB_BOTTOMLEFT_Y = 4
RBP.TG_TOP_X = -1.28
RBP.TG_TOP_Y = -8.32

local function PlateOnShow(Plate)
	local Virtual = Plate.VirtualPlate
	PlatesVisible[Plate] = Virtual
	ExistsVisiblePlates = true
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
	if RBP.inCombat then
		ExecuteClickboxSecureScript()
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

--- Adds and skins a new nameplate.
-- @ param Plate  Newly found default nameplate to be hooked.
local function PlateAdd(Plate)
	local Virtual = CreateFrame("Frame", nil, Plate)
	Plate.VirtualPlate = Virtual
	Virtual.RealPlate = Plate
	VirtualPlates[Plate] = Virtual
	
	if nameplateSizeCheck then
		nameplateSizeCheck = false
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

	Virtual:Hide() -- Gets explicitly shown on plate show
	Virtual:SetPoint("TOP")
	Virtual:SetSize(RBP.NP_WIDTH, RBP.NP_HEIGHT)
	ReparentChildren(Plate, Plate:GetChildren())
	ReparentRegions(Plate, Plate:GetRegions())
	Virtual:SetScale(RBP.dbp.globalScale or 1)
	Virtual:EnableDrawLayer("HIGHLIGHT") -- Allows the highlight to show without enabling mouse events

	Plate:SetScript("OnShow", PlateOnShow)
	Plate:SetScript("OnHide", PlateOnHide)

	-- Hook methods
	for Key, Value in pairs(PlateOverrides) do
		Virtual[Key] = Value
	end

	SetupRefinedPlate(Virtual)

	if not hasModernAPI and Plate:IsVisible() then
		PlateOnShow(Plate)
	end

	-- Force recalculation of effective depth for all child frames
	local WFDepth = WorldFrame:GetDepth()
	WorldFrame:SetDepth(WFDepth + 1)
	WorldFrame:SetDepth(WFDepth)
end

local function IsNamePlate(frame)
	local _, r2 = frame:GetRegions()
	return r2 and r2:GetObjectType() == "Texture" and r2:GetTexture() == "Interface\\Tooltips\\Nameplate-Border"
end

local ChildCount, NewChildCount = 0
local function WorldFrameOnUpdate(self, elapsed)
	NewChildCount = self:GetNumChildren()
	if ChildCount ~= NewChildCount then
		for i = ChildCount + 1, NewChildCount do
			local child = select(i, WorldFrame_GetChildren(self))
			if not VirtualPlates[child] and IsNamePlate(child) then
				PlateAdd(child)
			end
		end
		ChildCount = NewChildCount
	end
	if not ExistsVisiblePlates then return end
	if RBP.dbp.stackingEnabled then
		UpdateStacking(elapsed)
	end
	NextUpdate = NextUpdate - elapsed
	if NextUpdate <= 0 then
		NextUpdate = UpdateRate
		if hasModernAPI then
			PlatesUpdateModern()
		else
			PlatesUpdate()
		end
	end
	NextSecUpdate = NextSecUpdate - elapsed
	if NextSecUpdate <= 0 then
		NextSecUpdate = SecUpdateRate
		PlatesSecUpdate()
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

WorldFrame:HookScript("OnUpdate", WorldFrameOnUpdate) -- First OnUpdate handler to run

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
	function PlateOverrides:HookScript(Script, Handler, ...)
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
	RBP.dbp = self.db.profile
	self:UpdateProfile()
end

function RBP:Initialize()
	self.db = LibStub("AceDB-3.0"):New("KhalPlatesDB", self.default, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")
	
	RBP.dbp = self.db.profile -- Replace default profile with AceDB profile

	RBP:BuildBlacklistUI()
	RBP:UpdateNonTargetAlphaDriver()
	RBP:OverrideNameplateSize()
	ClickboxAttributeUpdater()
	SetUIVisibility(true)

	local config = LibStub("AceConfig-3.0")
	local dialog = LibStub("AceConfigDialog-3.0")
	config:RegisterOptionsTable("RefinedBlizzPlates", self.MainOptionTable)
	dialog:AddToBlizOptions("RefinedBlizzPlates", "RefinedBlizzPlates")
	config:RegisterOptionsTable("RefinedBlizzPlates_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
	dialog:AddToBlizOptions("RefinedBlizzPlates_Profiles", "Profiles", "RefinedBlizzPlates")
	config:RegisterOptionsTable("RefinedBlizzPlates_About", self.AboutTable)
	dialog:AddToBlizOptions("RefinedBlizzPlates_About", "About", "RefinedBlizzPlates")

    SLASH_RBP1 = "/rbp"
    SlashCmdList["RBP"] = function()
		InterfaceOptionsFrame_OpenToCategory("RefinedBlizzPlates")
		InterfaceOptionsFrame_OpenToCategory("RefinedBlizzPlates")
    end	
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
	RBP:UpdateCVars()
	self:UnregisterEvent(event)
	self[event] = nil
end

function EventHandler:PLAYER_REGEN_ENABLED()
	RBP.inCombat = false
	if RBP.delayedClickboxUpdate then
		RBP.delayedClickboxUpdate = false
		ClickboxAttributeUpdater()
	end
    if hasModernAPI and RBP.dbp.depthScaling then
        for _, Virtual in pairs(PlatesVisible) do
        	UpdateClickboxOutOfCombat(Virtual)
        end
    end
end

function EventHandler:PLAYER_REGEN_DISABLED()
	RBP.inCombat = true
	InitPlatesClickboxes()
	ExecuteClickboxSecureScript()
end

function EventHandler:PLAYER_TARGET_CHANGED()
	RBP.hasTarget = UnitExists("target") == 1
	RBP.GlobalDelayedUpdater:Show()
end

function EventHandler:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()
	RBP.inInstance = inInstance == 1
	RBP.inOpenWorld = not inInstance
	RBP.inPvEInstance = instanceType == "party" or instanceType == "raid"
	RBP.inPvPInstance = instanceType == "pvp" or instanceType == "arena"
	RBP.inBG = instanceType == "pvp"
	RBP.inArena = instanceType == "arena"
	UpdateGroupInfo()
	if instanceType == "arena" then
		UpdateArenaInfo()
	end
	if RBP.dbp.LDWfix and instanceType == "raid" then
		RBP:CheckLDWZone()
	end
end

function EventHandler:PARTY_MEMBERS_CHANGED()
	UpdateGroupInfo()
	RefreshGroupVisuals()
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
	if RBP.inICC then
		CheckLDWZoneIndoors()
	end
end

function EventHandler:UNIT_AURA(event, unit)
	if RBP.inLDWZone and unit == "player" then
		CheckDominateMind()
	end
end

function EventHandler:RAID_TARGET_UPDATE()
	for _, Virtual in pairs(PlatesVisible) do
		UpdateRaidIcon(Virtual)
	end
end

function EventHandler:NAME_PLATE_CREATED(event, Plate)
	if not VirtualPlates[Plate] then
		PlateAdd(Plate)
	end
end

function EventHandler:NAME_PLATE_UNIT_ADDED(event, nameplateID)
	local Plate = C_NamePlate.GetNamePlateForUnit(nameplateID)
	if not Plate then return end
	if not Plate.namePlateUnitToken then
		Plate.namePlateUnitToken = nameplateID
		Plate.VirtualPlate.namePlateUnitToken = nameplateID
		if Plate:IsVisible() then
			PlateOnShow(Plate)
		end
	else
		Plate.namePlateUnitToken = nameplateID
		Plate.VirtualPlate.namePlateUnitToken = nameplateID
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
EventHandler:RegisterEvent("PLAYER_PVP_RANK_CHANGED")
EventHandler:RegisterEvent("PLAYER_LEVEL_UP")
EventHandler:RegisterEvent("ARENA_OPPONENT_UPDATE")
EventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")
EventHandler:RegisterEvent("UNIT_AURA")
EventHandler:RegisterEvent("RAID_TARGET_UPDATE")
if hasModernAPI then
	EventHandler:RegisterEvent("NAME_PLATE_CREATED")
	EventHandler:RegisterEvent("NAME_PLATE_UNIT_ADDED")
end
