
-- Namespace
local AddOnName, KP = ...

-- API
local math_floor, tonumber, select, sort, wipe, pairs, ipairs, unpack, tremove, tinsert, CreateFrame, UnitName, UnitExists, IsInInstance, GetNumRaidMembers, GetRaidRosterInfo =
      math.floor, tonumber, select, sort, wipe, pairs, ipairs, unpack, tremove, tinsert, CreateFrame, UnitName, UnitExists, IsInInstance, GetNumRaidMembers, GetRaidRosterInfo

-- Localized namespace definitions
local NP_WIDTH = KP.NP_WIDTH
local NP_HEIGHT = KP.NP_HEIGHT
local VPscale = KP.VPscale
local VirtualPlates = KP.VirtualPlates
local RealPlates = KP.RealPlates
local texturePath = KP.texturePath
local TotemTexs = KP.TotemTexs
local globalYoffset = KP.globalYoffset
local NPminLevel = KP.NPminLevel
local nameText_colorR, nameText_colorG, nameText_colorB = unpack(KP.nameText_color)
local UpdateTargetGlow = KP.UpdateTargetGlow
local showClassOnFriends = KP.showClassOnFriends
local showClassOnEnemies = KP.showClassOnEnemies
local CustomizePlate = KP.CustomizePlate
local SetupTotemPlate = KP.SetupTotemPlate

-- Local definitions
local PlatesVisible = {}	-- Storage table: currently active nameplates
local PlateOverrides = {}	-- Storage table: [MethodName] = override function for virtual plates
local NextUpdate = 0		-- Time controller for PlatesUpdate
local KPframe = CreateFrame("Frame", nil, WorldFrame) -- Main addon frame (event handler + access to native frame methods)
local NPwidth = NP_WIDTH * VPscale * 0.9
local NPheight = NP_HEIGHT * VPscale * 0.7
local InCombat = false
local inPvPInstance = false
local ClassByFriendName = {}

-- Sensitive Settings
local PlateLevels = 3 	-- Frame level difference between plates so one plate's children don't overlap the next closest plate
local UpdateRate = 0.05	-- Minimum time between plates are updated.

-- Backup of native frame methods
local WorldFrame_GetChildren = WorldFrame.GetChildren
local SetFrameLevel = KPframe.SetFrameLevel

-- Main plate handling and updating	
do
	local SortOrder, Depths = {}, {}

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

	-- Converts normalized RGB from nameplates into a custom color key and returns the class name
	local function ClassByPlateColor(Virtual)
		local r, g, b = Virtual.healthBar:GetStatusBarColor()
		local key = math_floor(r * 100) * 10000 + math_floor(g * 100) * 100 + math_floor(b * 100)
		return ClassByKey[key]
	end

	--- If an anchor ataches to the original plate (by WoW), re-anchor to the Virtual.
	local function ResetPoint(Plate, Region, Point, RelFrame, ...)
		if RelFrame == Plate then
			local point, xOfs, yOfs = ...
			Region:SetPoint(Point, VirtualPlates[Plate], point, xOfs + 11, yOfs + globalYoffset)
		end
	end

	--- Re-anchors regions when a plate is shown.
	-- WoW re-anchors most regions when it shows a nameplate, so restore those anchors to the Virtual frame.
	local function PlateOnShow(Plate)
		NextUpdate = 0 -- Resize instantly
		local Virtual = VirtualPlates[Plate]
		PlatesVisible[Plate] = Virtual
		Virtual:Show()
		-- Reposition all regions
		for Index, Region in ipairs(Plate) do
			for Point = 1, Region:GetNumPoints() do
				ResetPoint(Plate, Region, Region:GetPoint(Point))
			end
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
				Plate.totemPlate.icon:SetTexture(texturePath .. "Totems\\" .. totemTex)
			end
		else
			if Plate.totemPlate then Plate.totemPlate:Hide() end
			--------------- Nameplate Level Filter --------------
			local level = tonumber(Virtual.levelText:GetText())
			if level and level < NPminLevel then
				Virtual:Hide() -- Hide low level nameplates
			elseif inPvPInstance then
				--------------- Show class icons in PvP instances --------------
				local class = ClassByPlateColor(Virtual)
				if class == "FRIENDLY" and showClassOnFriends then
					class = ClassByFriendName[name] or ""
					Virtual.classIcon:SetTexture(texturePath .. "Classes\\" .. class)
					Virtual.classIcon:Show()
				elseif class and showClassOnEnemies then
					Virtual.classIcon:SetTexture(texturePath .. "Classes\\" .. class)
					Virtual.classIcon:Show()
				end
			end	
		end
		if not InCombat then
			if Virtual:IsShown() then
				Plate:SetSize(NPwidth, NPheight)
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

	--- Sorts, scales, and fades all nameplates based on distance or depth.
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
				local nameText = Virtual.healthBar.nameText
				local healthBarHighlight = Virtual.healthBarHighlight
				if healthBarHighlight:IsShown() then
					nameText:SetTextColor(1, 1, 0) -- yellow
					if nameText:GetText() ~= mouseoverName then
						healthBarHighlight:Hide()
					end
				else
					nameText:SetTextColor(nameText_colorR, nameText_colorG, nameText_colorB)
				end
			end
		end
		-------------- FrameLevels update based on sorting --------------
		if #SortOrder > 0 then
			sort(SortOrder, SortFunc)
			for Index, Plate in ipairs(SortOrder) do
				local Virtual = PlatesVisible[Plate]
				SetFrameLevel(Virtual, Index * PlateLevels)
				local TotemPlate = Plate.totemPlate
				local totemTex = TotemTexs[Virtual.nameText:GetText()]
				if TotemPlate and totemTex and totemTex ~= "" then
					SetFrameLevel(TotemPlate, Index * PlateLevels)
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
		Virtual:SetScale(VPscale)

		ReparentChildren(Plate, Plate:GetChildren())
		ReparentRegions(Plate, Plate:GetRegions())
		Virtual:EnableDrawLayer("HIGHLIGHT") -- Allows the highlight to show without enabling mouse events

		Plate:SetScript("OnShow", PlateOnShow)
		Plate:SetScript("OnHide", PlateOnHide)

		-- Hook methods
		for Key, Value in pairs(PlateOverrides) do
			Virtual[Key] = Value
		end

		CustomizePlate(Virtual)

		if Plate:IsVisible() then
			PlateOnShow(Plate)
		end

		-- Force recalculation of effective depth for all child frames
		local Depth = WorldFrame:GetDepth()
		WorldFrame:SetDepth(Depth + 1)
		WorldFrame:SetDepth(Depth)
	end

	local function IsNamePlate(frame)
		if frame:GetName() then return false end
		local region = select(2, frame:GetRegions())
		return region and region:GetTexture() == "Interface\\Tooltips\\Nameplate-Border"
	end

	local ChildCount, NewChildCount = 0
	WorldFrame:HookScript("OnUpdate", function()
		NewChildCount = WorldFrame:GetNumChildren()
		if ChildCount ~= NewChildCount then
			local WFchildren = { WorldFrame_GetChildren(WorldFrame) }
			for i = ChildCount + 1, NewChildCount do
				local child = WFchildren[i]
				if not VirtualPlates[child] and IsNamePlate(child) then
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

--- Initializes settings once loaded.
function KPframe:ADDON_LOADED(Event, AddOn)
	if AddOn == AddOnName then
		self:UnregisterEvent(Event)
		self[Event] = nil
	end
end

function KPframe:PLAYER_REGEN_ENABLED()
	InCombat = false
	for Plate, Virtual in pairs(PlatesVisible) do
		if Virtual:IsShown() then
			Plate:SetSize(NPwidth, NPheight)
		else
			Plate:SetSize(0.01, 0.01)
		end
	end 
end

function KPframe:PLAYER_REGEN_DISABLED()
	InCombat = true
end

function KPframe:PLAYER_TARGET_CHANGED()
	for _, Virtual in pairs(PlatesVisible) do
		UpdateTargetGlow(Virtual.healthBar)
	end
end

local function UpdateClassByFriendName()
	ClassByFriendName = {}
	for i = 1 , GetNumRaidMembers() do
		local name, _, _, _, _, class = GetRaidRosterInfo(i)
		if name and class then
			name = name:match("([^%-]+).*") -- remove realm suffix
			ClassByFriendName[name] = class
		end
	end
end

function KPframe:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		inPvPInstance = true
		UpdateClassByFriendName()
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	elseif inPvPInstance then
		inPvPInstance = false
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		ClassByFriendName = {}
	end
end

function KPframe:PARTY_MEMBERS_CHANGED()
	if inPvPInstance then 
		UpdateClassByFriendName() 
	end
end

--- Global event handler.
function KPframe:OnEvent(Event, ...)
	if self[Event] then
		return self[Event](self, Event, ...)
	end
end

WorldFrame:HookScript("OnUpdate", KP.WorldFrameOnUpdate) -- First OnUpdate handler to run
KPframe:SetScript("OnEvent", KPframe.OnEvent)
KPframe:RegisterEvent("ADDON_LOADED")
KPframe:RegisterEvent("PLAYER_REGEN_DISABLED")
KPframe:RegisterEvent("PLAYER_REGEN_ENABLED")
KPframe:RegisterEvent("PLAYER_TARGET_CHANGED")
KPframe:RegisterEvent("PLAYER_ENTERING_WORLD")
KPframe:RegisterEvent("PARTY_MEMBERS_CHANGED")

local GetParent = KPframe.GetParent;
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

	local SetScript = KPframe.SetScript
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

	local GetScript = KPframe.GetScript
	--- Redirects calls to GetScript for the OnUpdate handler to the original plate's script.
	function PlateOverrides:GetScript(Script, ...)
		if type(Script) == "string" and Script:lower() == "onupdate" then
			return GetParent(self).OnUpdate
		else
			return GetScript(self, Script, ...)
		end
	end

	local HookScript = KPframe.HookScript
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