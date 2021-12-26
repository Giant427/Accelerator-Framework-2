local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

---------------------------
-- Client player profile --
---------------------------

local ClientPlayerProfile = {}

---------------
-- Variables --
---------------

ClientPlayerProfile.Player = nil
ClientPlayerProfile.Character = nil
ClientPlayerProfile.RemoteEvent = nil

---------------
-- Functions --
---------------

-- Initiate

function ClientPlayerProfile:Initiate()
	self.Character = self.Player.Character

	-- Character added

	self.Player.CharacterAdded:Connect(function(Character)
		self:CharacterAdded(Character)
	end)

	-- Player remote event

	self.RemoteEvent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder"):WaitForChild(self.Player.Name)

    self.RemoteEvent.OnClientEvent:Connect(function(Request)
		self:RemoteEventRequest(Request)
	end)

	-- Rjac profile

	RunService.Heartbeat:Connect(function()
		self.RemoteEvent:FireServer("RjacProfile:UpdateDirection()", game.Workspace.CurrentCamera.CFrame)
	end)
end

-- Character added

function ClientPlayerProfile:CharacterAdded(Character)
	self.Character = Character
end

-- Remote event

function ClientPlayerProfile:RemoteEventRequest(Request, arg1)
end

----------------------------------
-- Client player profile module --
----------------------------------

local ClientPlayerProfileModule = {}

-- Get script

function ClientPlayerProfileModule:GetScript()
	return script
end

-----------------
-- Constructor --
-----------------

function ClientPlayerProfileModule:New(ProfileInfo)
    ProfileInfo = ProfileInfo or {}
	setmetatable(ProfileInfo, ClientPlayerProfile)
	ClientPlayerProfile.__index = ClientPlayerProfile
	return ProfileInfo
end

return ClientPlayerProfile