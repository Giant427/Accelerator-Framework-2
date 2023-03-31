local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local ServerScriptServiceFolder = game:GetService("ServerScriptService"):WaitForChild("AcceleratorFramework")

local Server_Client_Comms = ReplicatedStorageFolder:WaitForChild("Comms"):WaitForChild("Server-Client")
local GunObject = ServerScriptServiceFolder:WaitForChild("Gun_Server")

local PlayerInventoriesFolder = Instance.new("Folder")
PlayerInventoriesFolder.Name = "PlayerInventories"
PlayerInventoriesFolder.Parent = ServerScriptServiceFolder

local ServerModule = {}

-- Add a player inventory
function ServerModule:AddPlayerInventory(player)
    local PlayerFolder = Instance.new("Folder")
    PlayerFolder.Name = player.Name
    PlayerFolder.Parent = PlayerInventoriesFolder

    local InventoryFolder = Instance.new("Folder")
    InventoryFolder.Name = "Inventory"
    InventoryFolder.Parent = PlayerFolder

    local EquippedFolder = Instance.new("ObjectValue")
    EquippedFolder.Name = "Equipped"
    EquippedFolder.Parent = PlayerFolder

    return PlayerFolder
end

-- Remove a player inventory
function ServerModule:RemovePlayerInventory(player)
    local PlayerFolder = PlayerInventoriesFolder:FindFirstChild(player.Name)

    if PlayerFolder then
        PlayerFolder:Destroy()
    end
end

-- Get a player inventory
function ServerModule:GetPlayerInventory(player)
    local PlayerFolder = PlayerInventoriesFolder:FindFirstChild(player.Name)

    return PlayerFolder
end

-- Add gun to player inventory
function ServerModule:AddGun(player,GUN_NAME)
    local PlayerFolder = self:GetPlayerInventory(player)
    local Inventory = PlayerFolder:FindFirstChild("Inventory")

    local Object = GunObject:Clone()
    Object.Name = GUN_NAME

    local Slot = Instance.new("Folder")
    Slot.Name = #Inventory:GetChildren() + 1
    Slot.Parent = Inventory

    Object.Parent = Slot

    Object = require(Object)
    Object.Player = player
    Object.GunName = GUN_NAME

    Object:InitiateProcessing()

    self:ReorderInventory(player,1)

    Server_Client_Comms:FireClient(player,"AddGun",GUN_NAME)

    return self:GetGun(player,Slot.Name)
end

-- Get a gun from player inventory
function ServerModule:GetGun(player,SLOT_NUMBER)
    local PlayerFolder = self:GetPlayerInventory(player)
    local Inventory = PlayerFolder:FindFirstChild("Inventory")
    local Slot = Inventory:FindFirstChild(SLOT_NUMBER)

    if not Slot then
        return
    end

    local Gun = Slot:FindFirstChildOfClass("ModuleScript")

    return Gun
end

-- Remove gun from player inventory
function ServerModule:RemoveGun(player,SLOT_NUMBER)
    local PlayerFolder = self:GetPlayerInventory(player)

    local Equipped = PlayerFolder:FindFirstChild("Equipped").Value

    if Equipped then
        if Equipped.Parent.Name == SLOT_NUMBER then
            Equipped.Parent:Destroy()
        end
    end

    local DeletingGun = PlayerFolder:FindFirstChild("Inventory"):FindFirstChild(SLOT_NUMBER)

    if DeletingGun then
        DeletingGun:Destroy()
    end

    self:ReorderInventory(player,SLOT_NUMBER)
end

-- Get equipped gun
function ServerModule:GetEquippedGun(player)
    local PlayerFolder = self:GetPlayerInventory(player)

    local Equipped = PlayerFolder:FindFirstChild("Equipped")

    return Equipped
end

-- Reorder inventory
function ServerModule:ReorderInventory(player,STARTING_INDEX)
    local PlayerInventory = self:GetPlayerInventory(player)
    local InventoryFolder = PlayerInventory:WaitForChild("Inventory")

    for i = STARTING_INDEX,#InventoryFolder:GetChildren(),1 do
        InventoryFolder:GetChildren()[i].Name = i
    end
end

-- Equip a gun
function ServerModule:EquipGun(player,gun_object)
    local PlayerFolder = self:GetPlayerInventory(player)
    local Equipped = PlayerFolder:FindFirstChild("Equipped")

    if Equipped.Value then
        require(Equipped.Value):Unequip()
    end

    Equipped.Value = gun_object
end

-- Unequip a gun
function ServerModule:UnequipGun(player)
    local PlayerFolder = self:GetPlayerInventory(player)
    local Equipped = PlayerFolder:FindFirstChild("Equipped")

    Equipped.Value = nil
end

-- Replicating sound effects
function ServerModule:PlaySfx(Player,GUN_NAME,GUN_COMPONENT,NAME)
    Server_Client_Comms:FireAllClients("PlaySfx",Player,GUN_NAME,GUN_COMPONENT,NAME)
end

-- Replicating visual effects
function ServerModule:PlayVfx(Player,GUN_NAME,GUN_COMPONENT,NAME)
    Server_Client_Comms:FireAllClients("PlayVfx",Player,GUN_NAME,GUN_COMPONENT,NAME)
end

-- Replicating bullets shell ejections
function ServerModule:EjectShell(Player,GUN_NAME)
    Server_Client_Comms:FireAllClients("EjectShell",Player,GUN_NAME)
end

-- Replicating bullet shooting
function ServerModule:ReplicateRaycast(Player, GUN_NAME, FILTER_INSTANCES)
    Server_Client_Comms:FireAllClients("ReplicateRaycast", Player, GUN_NAME, FILTER_INSTANCES)
end

return ServerModule