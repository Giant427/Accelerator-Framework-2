local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Accelerator framework folder in ReplicatedStorage
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

-- A unified module for creating objects/classes
local ObjectCreator = require(game.ServerScriptService.AcceleratorFramework:WaitForChild("ObjectCreator"))

-------------------
-- PlayerProfile --
-------------------

local PlayerProfile = {}

-- Properties
PlayerProfile.Player = nil
PlayerProfile.Character = nil
PlayerProfile.RemoteEvent = nil
PlayerProfile.CameraCFrame = CFrame.new()

-- Profile objects
PlayerProfile.RjacProfile = nil

-- Functions

-- Starter function to assemble the whole profile for functionality
function PlayerProfile:Initiate()
	self.Character = self.Player.Character

	-- On character added
	self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)

	-- Player remote on server event
	do
		self.RemoteEvent = Instance.new("RemoteEvent")
		self.RemoteEvent.Name = self.Player.Name
		self.RemoteEvent.Parent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder")

		self.RemoteEvent.OnServerEvent:Connect(function(Player, Request, arg1)
			self:onServerEvent(Player, Request, arg1)
		end)
	end

	-- Rjac profile
	do
		-- Configurations for rotations
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
		RunService.Heartbeat:Connect(function()
			self.RjacProfile:UpdateCharacter()
		end)

		-- Add body joints to rotation loop
		for _,v in pairs(Configurations) do
			self.RjacProfile:AddBodyJoint(v.BodyPart, v.BodyJoint, v.MultiplierVector)
		end
	end

	-- Client player profile
	local ClientProfile = ObjectCreator:CreateClientPlayerProfile(self.Player)
	ClientProfile.Parent = self.Player.Backpack
end

-- On character added
function PlayerProfile:onCharacterAdded(Character)
	self.Character = Character
	self.RjacProfile.Character = Character
end

-- Remote event
function PlayerProfile:onServerEvent(Player, Request, arg1)
	-- Other players should not be able to control the profile
	if not Player == self.Player then
		self.Player:Kick("Tried to hack my game huh?")
		return
	end

	-- Update rjac profile tilt direction
	if Request == "RjacProfile:UpdateTiltDirection()" then
		self.CameraCFrame = arg1
		self.RjacProfile:UpdateTiltDirection(arg1)
	end
end

return PlayerProfile