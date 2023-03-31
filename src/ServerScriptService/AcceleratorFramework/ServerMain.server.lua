local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local ServerStorageFolder = ServerStorage:WaitForChild("AcceleratorFramework")
local WorkspaceFolder = game.Workspace:WaitForChild("AcceleratorFramework")
local ServerScriptServiceFolder = game:GetService("ServerScriptService"):WaitForChild("AcceleratorFramework")

local CharacterUpdateHandler = require(WorkspaceFolder:WaitForChild("CharacterUpdateHandler"))
local PlayerDataHandler = require(ServerStorageFolder:WaitForChild("PlayerDataHandler"))
local ServerModule = require(ServerScriptServiceFolder:WaitForChild("ServerModule"))

-- Collision group
-- Create groups
PhysicsService:CreateCollisionGroup("BulletShells")
PhysicsService:CreateCollisionGroup("GunModels")
PhysicsService:CreateCollisionGroup("Viewmodel")
PhysicsService:CreateCollisionGroup("PlayerCharacter")

-- Set collisions
PhysicsService:CollisionGroupSetCollidable("Default", "Viewmodel", false)
PhysicsService:CollisionGroupSetCollidable("Default", "GunModels", false)
PhysicsService:CollisionGroupSetCollidable("PlayerCharacter", "BulletShells", false)
PhysicsService:CollisionGroupSetCollidable("PlayerCharacter", "Viewmodel", false)
PhysicsService:CollisionGroupSetCollidable("GunModels", "PlayerCharacter", false)
PhysicsService:CollisionGroupSetCollidable("GunModels", "Viewmodel", false)
PhysicsService:CollisionGroupSetCollidable("BulletShells", "Viewmodel", false)
PhysicsService:CollisionGroupSetCollidable("BulletShells", "GunModels", false)

-- Tilting character joints according to camera
local CharacterUpdateComms = ReplicatedStorageFolder:WaitForChild("Comms"):WaitForChild("CharacterUpdate")

local function CharacterUpdateRemote(player,request,cframe)
    if request == "Update" then
        PlayerDataHandler:UpdatePlayerAim(player,cframe)
        CharacterUpdateHandler:UpdateTPart(player,cframe)
    end
end

local function CharacterUpdateValues()
    for _,player in pairs(game.Players:GetPlayers()) do
        CharacterUpdateHandler:Update(player)
    end
end

CharacterUpdateComms.OnServerEvent:Connect(CharacterUpdateRemote)
game:GetService("RunService").Heartbeat:Connect(CharacterUpdateValues)

-- Character added
local function CharacterAdded(Character)
    for _,v in pairs(Character:GetDescendants()) do
        if v:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(v, "PlayerCharacter")
        end
    end
end

-- Player added
local function PlayerAdded(player)
    CharacterUpdateHandler:Add(player)
    PlayerDataHandler:AddPlayerData(player)
    ServerModule:AddPlayerInventory(player)
    ServerModule:AddGun(player, "M4A1")

    player.CharacterAdded:Connect(CharacterAdded)
end

game.Players.PlayerAdded:Connect(PlayerAdded)

-- Player removed
local function PlayerRemoved(player)
    CharacterUpdateHandler:Remove(player)
    PlayerDataHandler:RemovePlayerData(player)
    ServerModule:RemovePlayerInventory(player)
end

game.Players.PlayerRemoving:Connect(PlayerRemoved)