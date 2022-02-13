local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ClientProfile = require(script.Parent:WaitForChild("ClientProfile"))
local ClientPlayerProfile = require(script.Parent:WaitForChild("ClientPlayerProfile"))
local ProfileInfo = {}
ProfileInfo.Player = LocalPlayer
local Profile = ClientPlayerProfile:New(ProfileInfo)
ClientProfile.Profile = Profile
ClientProfile.Profile:Initiate()