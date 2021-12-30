local Players = game:GetService("Players")

-- Local player
local LocalPlayer = Players.LocalPlayer

-- Setup client profile
local function SetupClientProfile()
    local ClientProfile = script.Parent.Parent.Parent:WaitForChild("Backpack").ClientPlayerProfile
    ClientProfile.Parent = script.Parent
    ClientProfile = require(ClientProfile)
    ClientProfile.Player = LocalPlayer
    ClientProfile:Initiate()
end

SetupClientProfile()