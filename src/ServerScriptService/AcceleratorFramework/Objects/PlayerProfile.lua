local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local GunResourcesHandler = require(ReplicatedStorageFolder:WaitForChild("Modules"):WaitForChild("GunResourcesHandler"))
local ObjectCreator = require(game.ServerScriptService.AcceleratorFramework:WaitForChild("ObjectCreator"))

local PlayerProfile = {}

-- Properties
PlayerProfile.Player = nil
PlayerProfile.Character = nil
PlayerProfile.RemoteEvent = nil
PlayerProfile.CameraCFrame = CFrame.new()
PlayerProfile.RjacProfile = nil
PlayerProfile.Inventory = {}
PlayerProfile.Enabled = false
PlayerProfile.onCharacterAddedConnection = nil
PlayerProfile.onServerEventConnection = nil

-- Starter function to assemble the whole profile for functionality
function PlayerProfile:Initiate()
	self.Character = self.Player.Character
	self.onCharacterAddedConnection = self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)
	-- Remote event
	self.RemoteEvent = Instance.new("RemoteEvent")
	self.RemoteEvent.Name = self.Player.UserId
	self.RemoteEvent.Parent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder")
	self.onServerEventConnection = self.RemoteEvent.OnServerEvent:Connect(function(Player, Request, arg1)
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
		if not self.Enabled then return end
		self.RjacProfile:UpdateCharacter()
	end)
	for _,v in pairs(RjacConfigurations) do
		self.RjacProfile:AddBodyJoint(v.BodyPart, v.BodyJoint, v.MultiplierVector)
	end
	-- Enable
	self.Enabled = true
	self.RjacProfile.Enabled = true
end

-- On character added
function PlayerProfile:onCharacterAdded(Character)
	self.Character = Character
	self.RjacProfile.Character = Character
end

-- Remote event
function PlayerProfile:onServerEvent(Player, Request, arg1)
	if not self.Enabled then return end
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
	-- Destroy class
	if Request == ":Destroy()" then
		self:Destroy()
	end
end

-- Add gun to inventory
function PlayerProfile:AddGun(GunName)
	local Metadata = GunResourcesHandler:GetResource(GunName, "Metadata")
	Metadata.Player = self.Player
	self.RemoteEvent:FireClient(self.Player, ":AddGun(GunName)", GunName)
	local GunProfileServer = ObjectCreator:CreateGunProfileServer(Metadata)
	self.Inventory[#self.Inventory + 1] = GunProfileServer
end

-- Destructor
function PlayerProfile:Destroy()
	self.RemoteEvent:FireClient(self.Player, ":Destroy()")
   	self.RjacProfile:Destroy()
	self.RemoteEvent:Destroy()
	self.onCharacterAddedConnection:Disconnect()
	self.onServerEventConnection:Disconnect()
	for i,_ in pairs(self) do
		self[i] = nil
	end
	for i,_ in pairs(getmetatable(self)) do
		getmetatable(self)[i] = nil
	end
	for i,v in pairs(require(game.ServerScriptService.AcceleratorFramework.PlayerProfiles)) do
		if v.Player == self.Player then
			require(game.ServerScriptService.AcceleratorFramework.PlayerProfiles)[i] = nil
		end
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