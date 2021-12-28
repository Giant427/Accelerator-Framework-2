local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

-------------
-- Objects --
-------------

local ObjectCreator = require(game.ServerScriptService.AcceleratorFramework:WaitForChild("ObjectCreator"))

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

PlayerProfile.RjacProfile = nil

---------------
-- Functions --
---------------

-- Initiate

function PlayerProfile:Initiate()
	self.Character = self.Player.Character

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

		self.RemoteEvent.OnServerEvent:Connect(function(Player, Request, arg1)
			if not Player == self.Player then
				self.Player:Kick("Tried to hack my game huh?")
				return
			end

			self:RemoteEventRequest(Request, arg1)
		end)
	end

	-- Rjac profile

	do
		local Configurations = {
			{
				BodyPart = "Head",
				BodyJoint = "Neck",
				MultiplierVector = Vector3.new(0.8, 0.8, 0),
			},
			{
				BodyPart = "RightUpperArm",
				BodyJoint = "RightShoulder",
				MultiplierVector = Vector3.new(0.8, 0, 0),
			},
			{
				BodyPart = "LeftUpperArm",
				BodyJoint = "LeftShoulder",
				MultiplierVector = Vector3.new(0.8, 0, 0),
			},
			{
				BodyPart = "UpperTorso",
				BodyJoint = "Waist",
				MultiplierVector = Vector3.new(0.2, 0.2, 0),
			},
		}

		-- Create profile and complete setup

		self.RjacProfile = ObjectCreator:CreateRjacProfile(self.Player)
		self.RjacProfile.Parent = script
		self.RjacProfile = require(self.RjacProfile)
		self.RjacProfile:Initiate()
		self.RjacProfile.Enabled = true

		-- Update body parts

		do
			RunService.Heartbeat:Connect(function()
				self.RjacProfile:UpdateCharacter()
			end)
		end

		-- Body joints configurations

		for _,v in pairs(Configurations) do
			self.RjacProfile:AddBodyJoint(v.BodyPart, v.BodyJoint, v.MultiplierVector)
		end
	end
end

-- Character added

function PlayerProfile:CharacterAdded(Character)
	self.Character = Character
	self.RjacProfile.Character = Character
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

		local Profile = ObjectCreator:CreateClientPlayerProfile(self.Player)
		Profile.Parent = self.Player.Backpack

		self.RemoteEvent:FireClient(self.Player, "GetClientPlayerProfile")
	end

	-- Update character profile tilt part

	if Request == "RjacProfile:UpdateDirection()" then
		self.CameraCFrame = arg1
		self.RjacProfile:UpdateDirection(arg1)
	end
end

return PlayerProfile