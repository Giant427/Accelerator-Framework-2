local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local ObjectCreator = require(game.ServerScriptService.AcceleratorFramework:WaitForChild("ObjectCreator"))

local PlayerProfile = {}

-- Properties
PlayerProfile.Player = nil
PlayerProfile.Character = nil
PlayerProfile.RemoteEvent = nil
PlayerProfile.CameraCFrame = CFrame.new()
PlayerProfile.RjacProfile = nil

-- Starter function to assemble the whole profile for functionality
function PlayerProfile:Initiate()
	self.Character = self.Player.Character
	self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)
	-- Remote event
	self.RemoteEvent = Instance.new("RemoteEvent")
	self.RemoteEvent.Name = self.Player.Name
	self.RemoteEvent.Parent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder")
	self.RemoteEvent.OnServerEvent:Connect(function(Player, Request, arg1)
		self:onServerEvent(Player, Request, arg1)
	end)
	-- Rjac
	local RjacConfigurations = {
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
	self.RjacProfile = ObjectCreator:CreateRjacProfile(self.Player)
	self.RjacProfile:Initiate()
	self.RjacProfile.Enabled = true
	RunService.Heartbeat:Connect(function()
		self.RjacProfile:UpdateCharacter()
	end)
	for _,v in pairs(RjacConfigurations) do
		self.RjacProfile:AddBodyJoint(v.BodyPart, v.BodyJoint, v.MultiplierVector)
	end
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

-- Constructor
local PlayerProfileModule = {}
function PlayerProfileModule:New(ProfileInfo)
	ProfileInfo = ProfileInfo or {}
	setmetatable(ProfileInfo, PlayerProfile)
	PlayerProfile.__index = PlayerProfile
	return ProfileInfo
end

return PlayerProfileModule