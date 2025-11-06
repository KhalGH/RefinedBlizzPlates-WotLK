-------------------------------------------------------------
--------------- Core based on "VirtualPlates" ---------------
-------------------------------------------------------------

-- Namespace
local AddonFile, KP = ...

-- API
local select, sort, wipe, pairs, ipairs, unpack, CreateFrame, UnitName, IsInInstance, ToggleFrame, UIPanelWindows =
      select, sort, wipe, pairs, ipairs, unpack, CreateFrame, UnitName, IsInInstance, ToggleFrame, UIPanelWindows

-- Localized namespace definitions
local NP_WIDTH = KP.NP_WIDTH
local NP_HEIGHT = KP.NP_HEIGHT
local VirtualPlates = KP.VirtualPlates
local RealPlates = KP.RealPlates
local PlatesVisible = KP.PlatesVisible
local ClassByFriendName = KP.ClassByFriendName
local ArenaID = KP.ArenaID
local PartyID = KP.PartyID
local ASSETS = KP.ASSETS
local UpdatePlateVisibility = KP.UpdatePlateVisibility
local ResetPlateFlags = KP.ResetPlateFlags
local UpdateHitboxOutOfCombat = KP.UpdateHitboxOutOfCombat
local UpdateTargetGlow = KP.UpdateTargetGlow
local SetupLevelText = KP.SetupLevelText
local ClassByPlateColor = KP.ClassByPlateColor
local ReactionByPlateColor = KP.ReactionByPlateColor
local UpdateGroupInfo = KP.UpdateGroupInfo
local UpdateClassColorNames = KP.UpdateClassColorNames
local UpdateArenaInfo = KP.UpdateArenaInfo
local SetupKhalPlate = KP.SetupKhalPlate
local SetupTotemPlate = KP.SetupTotemPlate
local SetupClassPlate = KP.SetupClassPlate

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
KP.inCombat = false
KP.inInstance = false
KP.inPvEInstance = false
KP.inPvPInstance = false
KP.inBG = false
KP.inArena = false

-- SecureHandlers System: Manages nameplate hitbox resizing while in combat
local TriggerFrames = {}
local ResizeHitBox = CreateFrame("Frame", "ResizeHitboxSecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
ResizeHitBox:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(ResizeHitBox, "OnShow", ResizeHitBox,
	[[
	local WorldFrame = self:GetFrameRef("WorldFrame");
	local height = self:GetAttribute("height")
	local width = self:GetAttribute("width")
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
				nameplate:SetWidth(width)
				nameplate:SetHeight(height)
			elseif WorldFrame:GetID() == 1 then
				nameplate:SetWidth(0.01)
				nameplate:SetHeight(0.01)
			end
		end
	end
	]]
)
TriggerFrames["ResizeHitboxSecureHandler"] = ResizeHitBox
KP.ResizeHitBox = ResizeHitBox
local function ExecuteHitboxSecureScript()
    ToggleFrame(ResizeHitBox)
	ToggleFrame(ResizeHitBox)
end
local SetWorldFrameID5 = CreateFrame("Frame", "SetWorldFrameID5SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID5:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID5, "OnShow", SetWorldFrameID5, [[local WorldFrame = self:GetFrameRef("WorldFrame"); WorldFrame:SetID(5)]])
TriggerFrames["SetWorldFrameID5SecureHandler"] = SetWorldFrameID5
local function InitPlatesHitboxes()
	if WorldFrame:GetID() ~= 5 then
		ToggleFrame(SetWorldFrameID5)
		ToggleFrame(SetWorldFrameID5)
	end
end
local SetWorldFrameID1 = CreateFrame("Frame", "SetWorldFrameID1SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID1:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID1, "OnShow", SetWorldFrameID1, [[local WorldFrame = self:GetFrameRef("WorldFrame"); WorldFrame:SetID(1)]])
TriggerFrames["SetWorldFrameID1SecureHandler"] = SetWorldFrameID1
local function NullifyPlateHitbox()
	if WorldFrame:GetID() ~= 1 then
		ToggleFrame(SetWorldFrameID1)
		ToggleFrame(SetWorldFrameID1)
	end
end
local SetWorldFrameID0 = CreateFrame("Frame", "SetWorldFrameID0SecureHandler", UIParent, "SecureHandlerShowHideTemplate") 
SetWorldFrameID0:SetFrameRef("WorldFrame", WorldFrame)
SecureHandlerWrapScript(SetWorldFrameID0, "OnShow", SetWorldFrameID0, [[local WorldFrame = self:GetFrameRef("WorldFrame"); WorldFrame:SetID(0)]])
TriggerFrames["SetWorldFrameID0SecureHandler"] = SetWorldFrameID0
local function NormalizePlateHitbox()
	if WorldFrame:GetID() ~= 0 then
		ToggleFrame(SetWorldFrameID0)
		ToggleFrame(SetWorldFrameID0)
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
		UpdatePlateVisibility(Plate, Virtual) -- Updates textures, texts, icons, filters
 		if KP.inCombat then
			if not Virtual.isShown or (Plate.isFriendly and KP.dbp.friendlyClickthrough and KP.inInstance) then
				NullifyPlateHitbox()
			else
				NormalizePlateHitbox()
			end
			ExecuteHitboxSecureScript()
		else
			UpdateHitboxOutOfCombat(Plate, Virtual)
		end
	end

	--- Removes the plate from the visible list when hidden.
	local function PlateOnHide(Plate)
		PlatesVisible[Plate] = nil
		local Virtual = VirtualPlates[Plate]
		Virtual:Hide() -- Explicitly hide so IsShown returns false.
		ResetPlateFlags(Plate, Virtual)
		if KP.inCombat then
			ExecuteHitboxSecureScript()
		end
	end

	--- Subroutine for table.sort to depth-sort plate virtuals.
	local function SortFunc(PlateA, PlateB)
		return Depths[PlateA] > Depths[PlateB]
	end

	--- Update all visible nameplates
	local mouseoverName, Depth, healthBarHighlight, nameText, Virtual, BGHframe
	local function PlatesUpdate()
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
			sort(SortOrder, SortFunc)
			for Index, Plate in ipairs(SortOrder) do
				Virtual = PlatesVisible[Plate]
				SetFrameLevel(Virtual, Index * PlateLevels)
				SetFrameLevel(Virtual.healthBar, Index * PlateLevels)
				if Plate.totemPlateIsShown then
					SetFrameLevel(Plate.totemPlate, Index * PlateLevels)
				end
				if Plate.classPlateIsShown then
					SetFrameLevel(Plate.classPlate, Index * PlateLevels)
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

		ReparentChildren(Plate, Plate:GetChildren())
		ReparentRegions(Plate, Plate:GetRegions())
		Virtual:SetScale(KP.dbp.globalScale)
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

WorldFrame:HookScript("OnUpdate", KP.WorldFrameOnUpdate) -- First OnUpdate handler to run

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

function KP:OnProfileChanged(...)
	self.dbp = self.db.profile
	self:MoveAllShownPlates(self.dbp.globalOffsetX - self.globalOffsetX, self.dbp.globalOffsetY - self.globalOffsetY)
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

	KP:BuildBlacklistUI()

	if self.dbp.healthBar_border == "KhalPlates" then
		ResizeHitBox:SetAttribute("width", NP_WIDTH * self.dbp.globalScale * 0.9)
		ResizeHitBox:SetAttribute("height", NP_HEIGHT * self.dbp.globalScale * 0.7)
	else
		ResizeHitBox:SetAttribute("width", NP_WIDTH * self.dbp.globalScale)
		ResizeHitBox:SetAttribute("height", NP_HEIGHT * self.dbp.globalScale)
	end

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

function EventHandler:PLAYER_LOGIN(event)
	KP:UpdateTotemDesc()
	self:UnregisterEvent(event)
	self[event] = nil
end

function EventHandler:PLAYER_REGEN_ENABLED()
	KP.inCombat = false
	if KP.delayedHitboxUpdate then
		KP.delayedHitboxUpdate = false
		if KP.dbp.healthBar_border == "KhalPlates" then
			ResizeHitBox:SetAttribute("width", NP_WIDTH * KP.dbp.globalScale * 0.9)
			ResizeHitBox:SetAttribute("height", NP_HEIGHT * KP.dbp.globalScale * 0.7)
		else
			ResizeHitBox:SetAttribute("width", NP_WIDTH * KP.dbp.globalScale)
			ResizeHitBox:SetAttribute("height", NP_HEIGHT * KP.dbp.globalScale)
		end
	end
end

function EventHandler:PLAYER_REGEN_DISABLED()
	KP.inCombat = true
	InitPlatesHitboxes()
	ExecuteHitboxSecureScript()
end

function EventHandler:PLAYER_TARGET_CHANGED()
	for _, Virtual in pairs(PlatesVisible) do
		UpdateTargetGlow(Virtual)
	end
end


function EventHandler:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()
	KP.inInstance = inInstance == 1
	KP.inPvEInstance = instanceType == "party" or instanceType == "raid"
	KP.inPvPInstance = instanceType == "pvp" or instanceType == "arena"
	KP.inBG = instanceType == "pvp"
	KP.inArena = instanceType == "arena"
	UpdateGroupInfo()
	if KP.inArena then
		UpdateArenaInfo()
	end
end

function EventHandler:PARTY_MEMBERS_CHANGED()
	UpdateGroupInfo()
	UpdateClassColorNames()
end

local DelayedUpdateClassColorNames = CreateFrame("Frame")
DelayedUpdateClassColorNames:Hide()
DelayedUpdateClassColorNames:SetScript("OnUpdate", function(self)
	self:Hide()
	UpdateClassColorNames()
end)

function EventHandler:UNIT_FACTION(event, unit)
	if unit == "player" then
		DelayedUpdateClassColorNames:Show()
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

function EventHandler:ARENA_OPPONENT_UPDATE(event, unitToken, updateReason)
	if updateReason == "seen" and unitToken:match("^arena(%d+)$") then
		UpdateArenaInfo()
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
EventHandler:RegisterEvent("ARENA_OPPONENT_UPDATE")