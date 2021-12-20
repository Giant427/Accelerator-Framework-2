local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

------------------
-- To be cloned --
------------------

local To_Be_Cloned = ReplicatedStorageFolder:WaitForChild("To-Be-Cloned")
local ModuleScript = To_Be_Cloned:WaitForChild("ModuleScript")

--------------------------------------
-- Setting up client player profile --
--------------------------------------

local ClientProfile

-- Remote event

local RemoteEvent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder"):WaitForChild(LocalPlayer.Name)

RemoteEvent.OnClientEvent:Connect(function(Request)
    -- Get client player profile

	if Request == "GetClientPlayerProfile" then
        local ClientPlayerProfile = require(script.Parent.Parent.Parent.Backpack:WaitForChild("ClientPlayerProfile"))

        local ClientProfileInfo = {}
        ClientProfileInfo.Player = LocalPlayer

        ClientProfile = ClientPlayerProfile:New(ClientProfileInfo)
        ClientPlayerProfile:GetScript():Destroy()

        ClientProfile:Initiate()
	end
end)

-- Get client player profile

RemoteEvent:FireServer("GetClientPlayerProfile")