local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

-- Setup client profile

local function SetupClientProfile()
    local ClientProfile = script.Parent.Parent.Parent.Backpack:WaitForChild("ClientPlayerProfile")
    ClientProfile.Parent = script.Parent
    ClientProfile = require(ClientProfile)
    ClientProfile.Player = LocalPlayer
    ClientProfile:Initiate()
end

-- Remote event

local RemoteEvent = ReplicatedStorageFolder:WaitForChild("RemoteEventsFolder"):WaitForChild(LocalPlayer.Name)

RemoteEvent.OnClientEvent:Connect(function(Request)
    -- Get client player profile

	if Request == "GetClientPlayerProfile" then
        SetupClientProfile()
	end
end)

-- Get client player profile

RemoteEvent:FireServer("GetClientPlayerProfile")