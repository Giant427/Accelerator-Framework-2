local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

--------------------------
-- Remote events folder --
--------------------------

local RemoteEventsFolder = Instance.new("Folder")
RemoteEventsFolder.Name = "RemoteEventsFolder"
RemoteEventsFolder.Parent = ReplicatedStorageFolder

-------------
-- Objects --
-------------

local ObjectCreator = require(script.Parent:WaitForChild("ObjectCreator"))

-------------
-- Players --
-------------

local PlayerFolder = script.Parent:FindFirstChild("PlayerFolder")

if not PlayerFolder then
    PlayerFolder = Instance.new("Folder")
    PlayerFolder.Name = "PlayerFolder"
    PlayerFolder.Parent = script.Parent
end

-- Player added

local function PlayerAdded(Player)
    local Profile = ObjectCreator:CreatePlayerProfile(Player)
    Profile.Parent = PlayerFolder
    Profile = require(Profile)
    Profile:Initiate()
end

Players.PlayerAdded:Connect(PlayerAdded)