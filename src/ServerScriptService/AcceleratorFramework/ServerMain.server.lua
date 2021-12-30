local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Accelerator framework folder in ReplicatedStorage
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

-- Player specific remote events go here

local RemoteEventsFolder = ReplicatedStorageFolder:FindFirstChild("RemoteEventsFolder")

if not RemoteEventsFolder then
    -- Remote events fodler doesnt exist, time to make one
    RemoteEventsFolder = Instance.new("Folder")
    RemoteEventsFolder.Name = "RemoteEventsFolder"
    RemoteEventsFolder.Parent = ReplicatedStorageFolder
end

-- A unified module for creating objects/classes
local ObjectCreator = require(script.Parent:WaitForChild("ObjectCreator"))

-- Player specific server profile's go here
local PlayersFolder = script.Parent:FindFirstChild("PlayersFolder")

if not PlayersFolder then
    -- Players fodler doesnt exist, time to make one
    PlayersFolder = Instance.new("Folder")
    PlayersFolder.Name = "PlayersFolder"
    PlayersFolder.Parent = script.Parent
end

-- Player added
local function onPlayerAdded(Player)
    local Profile = ObjectCreator:CreatePlayerProfile(Player)
    Profile.Parent = PlayersFolder
    Profile = require(Profile)
    Profile:Initiate()
end

Players.PlayerAdded:Connect(onPlayerAdded)