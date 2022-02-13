local Players = game:GetService("Players")
local ObjectCreator = require(script.Parent:WaitForChild("ObjectCreator"))

-- Player specific server profile's go here
local PlayerProfiles = require(script.Parent:FindFirstChild("PlayerProfiles"))

-- On player added
local function onPlayerAdded(Player)
    PlayerProfiles[Player.Name] = ObjectCreator:CreatePlayerProfile(Player)
    local Profile = PlayerProfiles[Player.Name]
    Profile:Initiate()
end

Players.PlayerAdded:Connect(onPlayerAdded)