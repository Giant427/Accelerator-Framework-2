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
	self.Character = self.Player.Character

	-- On character added
	self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)

	-- Remote event
	do
		self.RemoteEvent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder"):WaitForChild(self.Player.Name)

		self.RemoteEvent.OnClientEvent:Connect(function(Request)
			self:RemoteEventRequest(Request)
		end)
	end

	-- Rjac profile
	RunService.Heartbeat:Connect(function()
		self.RemoteEvent:FireServer("RjacProfile:UpdateTiltDirection()", game.Workspace.CurrentCamera.CFrame)
	end)

	-- Movement profile
	do
		local MovementState = Instance.new("StringValue")
		MovementState.Name = "MovementState"

		local HumanoidState = Instance.new("StringValue")
		HumanoidState.Name = "HumanoidState"

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
end

-- On character added
function ClientPlayerProfile:onCharacterAdded(Character)
	self.Character = Character
end

-- On client event
function ClientPlayerProfile:onClientEvent(Request)

end

return ClientPlayerProfile