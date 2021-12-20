local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

------------------
-- To be cloned --
------------------

local To_Be_Cloned = ReplicatedStorageFolder:WaitForChild("To-Be-Cloned")
local ModuleScript = To_Be_Cloned:WaitForChild("ModuleScript")

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
	-- Character added

	self.Player.CharacterAdded:Connect(function(Character)
		self:CharacterAdded(Character)
	end)

	-- Player remote event

	self.RemoteEvent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder"):WaitForChild(self.Player.Name)

    self.RemoteEvent.OnClientEvent:Connect(function(Request)
		self:RemoteEventRequest(Request)
	end)

	-- Character profile

	task.spawn(function()
		while task.wait(0.01) do
			self.RemoteEvent:FireServer("CharacterProfile:UpdateBodyPosition()", game.Workspace.CurrentCamera.CFrame)
		end
	end)
end

-- Character added

function ClientPlayerProfile:CharacterAdded(Character)
	self.Character = Character
    print(Character.Name)
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

return ClientPlayerProfileModule