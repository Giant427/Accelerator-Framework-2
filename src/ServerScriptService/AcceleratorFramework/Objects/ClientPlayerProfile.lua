local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Movement handler for character movement abilities: Crouch, Prone, Sprint, Slide
local MovementHandler = game.ReplicatedStorage:WaitForChild("MovementHandler"):WaitForChild("MovementHandler")

-- Accelerator framework folder in ReplicatedStorage
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

---------------------------
-- Client player profile --
---------------------------

local ClientPlayerProfile = {}

-- Properties
ClientPlayerProfile.Player = nil
ClientPlayerProfile.Character = nil
ClientPlayerProfile.RemoteEvent = nil

-- Movement handler
ClientPlayerProfile.MovementProfile = nil

-- Functions

-- Starter function to assemble the whole profile for functionality
function ClientPlayerProfile:Initiate()
	-- Saftey measures incase character has already loaded
	self.Character = self.Player.Character
	self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)

	-- Remote event
	self.RemoteEvent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder"):WaitForChild(self.Player.Name)
	self.RemoteEvent.OnClientEvent:Connect(function(Request)
		self:RemoteEventRequest(Request)
	end)

	RunService.Heartbeat:Connect(function()
		self.RemoteEvent:FireServer("RjacProfile:UpdateTiltDirection()", game.Workspace.CurrentCamera.CFrame)
	end)

	-- Movement profile
	local MovementState = Instance.new("StringValue")
	MovementState.Name = "MovementState"
	local HumanoidState = Instance.new("StringValue")
	HumanoidState.Name = "HumanoidState"

	-- Creating MovementProfile
	self.MovementProfile = MovementHandler:Clone()
	self.MovementProfile.Parent = script

	MovementState.Parent = self.MovementProfile
	HumanoidState.Parent = self.MovementProfile

	self.MovementProfile = require(self.MovementProfile)

	self.MovementProfile.Player = self.Player
	self.MovementProfile.MovementState = MovementState
	self.MovementProfile.HumanoidState = HumanoidState

	self.MovementProfile:Initiate()
end

-- On character added
function ClientPlayerProfile:onCharacterAdded(Character)
	self.Character = Character
end

-- On client event
function ClientPlayerProfile:onClientEvent(Request)

end

return ClientPlayerProfile