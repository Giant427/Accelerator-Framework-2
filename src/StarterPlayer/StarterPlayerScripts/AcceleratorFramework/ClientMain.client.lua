local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ClientProfile = script.Parent:WaitForChild("ClientProfile")

-- Setup client profile
local function SetupClientProfile()
    local ClientPlayerProfile = script.Parent:WaitForChild("ClientPlayerProfile")
    local ProfileInfo = {}
    ProfileInfo.Player = LocalPlayer
    ClientProfile = require(ClientPlayerProfile):New(ProfileInfo)
    ClientPlayerProfile:Destroy()
    ClientProfile:Initiate()
end

SetupClientProfile()