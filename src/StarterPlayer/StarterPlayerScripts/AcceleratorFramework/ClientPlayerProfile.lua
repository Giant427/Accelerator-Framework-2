local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local MovementHandler = require(game.ReplicatedStorage:WaitForChild("MovementHandler"):WaitForChild("MovementHandler"))

local ClientPlayerProfile = {}

-- Properties
ClientPlayerProfile.Player = nil
ClientPlayerProfile.Character = nil
ClientPlayerProfile.RemoteEvent = nil
ClientPlayerProfile.MovementProfile = nil
ClientPlayerProfile.ViewmodelProfile = nil
ClientPlayerProfile.Enabled = false
ClientPlayerProfile.onCharacterAddedConnection = nil
ClientPlayerProfile.onClientEventConnection = nil

-- Starter function to assemble the whole profile for functionality
function ClientPlayerProfile:Initiate()
	-- Saftey measures incase character has already loaded
	self.Character = self.Player.Character
	self.onCharacterAddedConnection = self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)
	-- Remote event
	self.RemoteEvent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder"):WaitForChild(self.Player.Name)
	self.onServerEventConnection = self.RemoteEvent.OnClientEvent:Connect(function(Request)
		if not self.Enabled then return end
		self:onClientEvent(Request)
	end)
	task.spawn(function()
		while task.wait(0.01) and self.Enabled do
			self.RemoteEvent:FireServer("RjacProfile:UpdateTiltDirection()", game.Workspace.CurrentCamera.CFrame)
		end
	end)
	-- Movement handler
	local MovementState = Instance.new("StringValue")
	local HumanoidState = Instance.new("StringValue")
	MovementState.Name = "MovementState"
	HumanoidState.Name = "HumanoidState"
	MovementState.Parent = self.Player.PlayerScripts.AcceleratorFramework.ClientProfile
	HumanoidState.Parent = self.Player.PlayerScripts.AcceleratorFramework.ClientProfile
	local MovementProfileInfo = {}
	MovementProfileInfo.Player = self.Player
	MovementProfileInfo.MovementState = MovementState
	MovementProfileInfo.HumanoidState = HumanoidState
	self.MovementProfile = MovementHandler:New(MovementProfileInfo)
	self.MovementProfile:Initiate()
	-- Viewmodel profile
	local ProfileInfo = {}
	ProfileInfo.Player = self.Player
	self.ViewmodelProfile = require(script.Parent.ViewmodelProfile):New(ProfileInfo)
	self.ViewmodelProfile:Initiate()
	-- Enable
	self.Enabled = true
	self.MovementProfile.Enabled = true
	self.ViewmodelProfile.Enabled = true
	-- Script clean up
	--[[
		Destroying ClientMain just completely disables everything in the Profile :(
		self.Player.PlayerScripts.AcceleratorFramework.ClientMain:Destroy()
	]]
	self.Player.PlayerScripts.AcceleratorFramework.ClientPlayerProfile:Destroy()
	self.Player.PlayerScripts.AcceleratorFramework.ViewmodelProfile:Destroy()
end

-- On character added
function ClientPlayerProfile:onCharacterAdded(Character)
	self.Character = Character
end

-- On client event
function ClientPlayerProfile:onClientEvent(Request)
	-- Destroy class
	if Request == ":Destroy()" then
		self:Destroy()
	end
end

-- Destructor
function ClientPlayerProfile:Destroy()
	local Player = self.Player
	self.Enabled = false
	self.ViewmodelProfile:Destroy()
	self.MovementProfile:Destroy()
	self.Player.PlayerScripts.AcceleratorFramework.ClientProfile.MovementState:Destroy()
	self.Player.PlayerScripts.AcceleratorFramework.ClientProfile.HumanoidState:Destroy()
	self.onCharacterAddedConnection:Disconnect()
	self.onServerEventConnection:Disconnect()
	for i,_ in pairs(self) do
		self[i] = nil
	end
	for i,_ in pairs(getmetatable(self)) do
		getmetatable(self)[i] = nil
	end
	require(Player.PlayerScripts.AcceleratorFramework.ClientProfile)["Profile"] = nil
end

-- Constructor
local ClientPlayerProfileModule = {}
function ClientPlayerProfileModule:New(ProfileInfo)
	ProfileInfo = ProfileInfo or {}
	setmetatable(ProfileInfo, ClientPlayerProfile)
	ClientPlayerProfile.__index = ClientPlayerProfile
	return ProfileInfo
end

return ClientPlayerProfileModule