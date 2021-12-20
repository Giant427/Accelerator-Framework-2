local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")

--------------------------
-- Remote events folder --
--------------------------

local RemoteEventsFolder = Instance.new("Folder")
RemoteEventsFolder.Name = "RemoteEventsFolder"
RemoteEventsFolder.Parent = ReplicatedStorageFolder

------------------
-- To be cloned --
------------------

local To_Be_Cloned = ReplicatedStorageFolder:WaitForChild("To-Be-Cloned")
local ModuleScript = To_Be_Cloned:WaitForChild("ModuleScript")

-------------
-- Objects --
-------------

local Objects = script.Parent:WaitForChild("Objects")
local PlayerProfile = require(Objects:WaitForChild("PlayerProfile"))

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
    local ProfileInfo = {}
    ProfileInfo.Player = Player

    local ProfileObject = PlayerProfile:New(ProfileInfo)

    local Profile = ModuleScript:Clone()
    Profile.Name = Player.Name
    Profile.Parent = PlayerFolder

    Profile = require(Profile)
    Profile = ProfileObject

    Profile:Initiate()
end

Players.PlayerAdded:Connect(PlayerAdded)