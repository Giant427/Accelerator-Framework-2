local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

------------------
-- To be cloned --
------------------

local To_Be_Cloned = ReplicatedStorageFolder:WaitForChild("To-Be-Cloned")
local ModuleScript = To_Be_Cloned:WaitForChild("ModuleScript")

-------------
-- Objects --
-------------

local Objects = script.Parent
local ClientPlayerProfile = Objects:WaitForChild("ClientPlayerProfile")
local CharacterProfile = require(Objects:WaitForChild("CharacterProfile"))

--------------------
-- Player Profile --
--------------------

local PlayerProfile = {}

---------------
-- Variables --
---------------

PlayerProfile.Player = nil
PlayerProfile.ClientProfileCreated = false
PlayerProfile.Character = nil
PlayerProfile.RemoteEvent = nil

PlayerProfile.CameraCFrame = CFrame.new()

---------------------
-- Profile Objects --
---------------------

PlayerProfile.CharacterProfile = nil

---------------
-- Functions --
---------------

-- Initiate

function PlayerProfile:Initiate()
	-- Character added

	do
		self.Player.CharacterAdded:Connect(function(Character)
			self:CharacterAdded(Character)
		end)
	end

	-- Player remote event

	do
		self.RemoteEvent = Instance.new("RemoteEvent")
		self.RemoteEvent.Name = self.Player.Name
		self.RemoteEvent.Parent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder")

		self.RemoteEvent.OnServerEvent:Connect(function(Player, Request)
			if not Player == self.Player then
				self.Player:Kick("Tried to hack my game huh?")
				return
			end
			self:RemoteEventRequest(Request)
		end)
	end

	-- Character profile

	do
		local CharacterProfileInfo = {}
		CharacterProfileInfo.Player = self.Player
		CharacterProfileInfo.Character = self.Character
		CharacterProfileInfo.Enabled = true

		CharacterProfileInfo.Configurations = {
			{
				BodyPart = "Head",
				BodyJoint = "Neck",
				JointOffset = CFrame.new(),
				MultiplierVector = Vector3.new(0.5, 0, 0),
			},
			{
				BodyPart = "RightUpperArm",
				BodyJoint = "RightShoulder",
				JointOffset = CFrame.new(),
				MultiplierVector = Vector3.new(0.5, 0, 0),
			},
			{
				BodyPart = "LeftUpperArm",
				BodyJoint = "LeftShoulder",
				JointOffset = CFrame.new(),
				MultiplierVector = Vector3.new(0.5, 0, 0),
			},
			{
				BodyPart = "UpperTorso",
				BodyJoint = "Waist",
				JointOffset = CFrame.new(),
				MultiplierVector = Vector3.new(0.5, 0, 0),
			},
		}

		self.CharacterProfile = CharacterProfile:New(CharacterProfileInfo)
		self.CharacterProfile:Initiate()
	end

	-- Update body parts

	do
		RunService.Heartbeat:Connect(function()
			self.CharacterProfile:UpdateCharacter()
		end)
	end
end

-- Character added

function PlayerProfile:CharacterAdded(Character)
	self.Character = Character
	self.CharacterProfile.Character = Character
end

-- Remote event

function PlayerProfile:RemoteEventRequest(Request, arg1)
	-- Get client player profile

	if Request == "GetClientPlayerProfile" then
		if not self.ClientProfileCreated == false then
			self.Player:Kick("Tried to hack my game huh?")
			return
		end
		self.ClientProfileCreated = true

		local Profile = ClientPlayerProfile:Clone()
        Profile.Name = "ClientPlayerProfile"
		Profile.Parent = self.Player.Backpack

		self.RemoteEvent:FireClient(self.Player, "GetClientPlayerProfile")
	end

	-- Update character profile tilt part

	if Request == "CharacterProfile:UpdateBodyPosition()" then
		self.CameraCFrame = arg1
		self.CharacterProfile:UpdateBodyPosition(self.CameraCFrame)
	end
end

---------------------------
-- Player profile module --
---------------------------

local PlayerProfileModule = {}

-----------------
-- Constructor --
-----------------

function PlayerProfileModule:New(ProfileInfo)
    ProfileInfo = ProfileInfo or {}
	setmetatable(ProfileInfo, PlayerProfile)
	PlayerProfile.__index = PlayerProfile
	return ProfileInfo
end

return PlayerProfileModule