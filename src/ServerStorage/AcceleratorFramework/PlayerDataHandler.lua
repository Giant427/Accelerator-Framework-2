local ServerStorage = game:GetService("ServerStorage")
local ServerStorageFolder = ServerStorage:WaitForChild("AcceleratorFramework")

local PlayerDataFolder = Instance.new("Folder")
PlayerDataFolder.Name = "PlayerData"
PlayerDataFolder.Parent = ServerStorageFolder

local PlayerDataHandler = {}

-- Add player folder
function PlayerDataHandler:AddPlayerData(player)
    local DataFolder = PlayerDataFolder:FindFirstChild(player.Name)

    if not DataFolder then
        DataFolder = Instance.new("Folder")
        DataFolder.Name = player.Name
        DataFolder.Parent = PlayerDataFolder
    end

    self:AddPlayerAim(player)
    self:AddPlayerInventory(player)
end

-- Get player folder
function PlayerDataHandler:GetPlayerData(player)
    local DataFolder = PlayerDataFolder:FindFirstChild(player.Name)

    if not DataFolder then
        self:AddPlayerData(player)
        return
    end

    return DataFolder
end

-- Remove player folder
function PlayerDataHandler:RemovePlayerData(player)
    local DataFolder = PlayerDataFolder:FindFirstChild(player.Name)

    if DataFolder then
        DataFolder:Destroy()
    end
end

-- Add aim folder in player folder
function PlayerDataHandler:AddPlayerAim(player)
    local DataFolder = PlayerDataHandler:GetPlayerData(player)

    if not DataFolder then
        return
    end

    local Aim = DataFolder:FindFirstChild("Aim") or Instance.new("CFrameValue")
    Aim.Name = "Aim"
    Aim.Parent = DataFolder
end

-- Update aim values in aim folder
function PlayerDataHandler:UpdatePlayerAim(player,cframe)
    local DataFolder = PlayerDataHandler:GetPlayerData(player)

    if not DataFolder then
        return
    end

    local Aim = DataFolder:FindFirstChild("Aim")

    if not Aim then
        self:AddPlayerAim(player)
        return
    end

    Aim.Value = cframe
end

-- Get aim of player
function PlayerDataHandler:GetPlayerAim(player)
    local DataFolder = PlayerDataHandler:GetPlayerData(player)

    if not DataFolder then
        return
    end

    local Aim = DataFolder:FindFirstChild("Aim")

    if not Aim then
        self:AddPlayerAim(player)
        return
    end

    return Aim.Value
end

-- Add inventory folder in player folder
function PlayerDataHandler:AddPlayerInventory(player)
    local DataFolder = self:GetPlayerData(player)

    if not DataFolder then
        return
    end

    local InventoryFolder = Instance.new("Folder")
    InventoryFolder.Name = "Inventory"
    InventoryFolder.Parent = DataFolder
end

-- Get inventory folder from player folder
function PlayerDataHandler:GetPlayerInventory(player)
    local DataFolder = self:GetPlayerData(player)

    if not DataFolder then
        return
    end

    local InventoryFolder = DataFolder:FindFirstChild("Inventory")

    if not InventoryFolder then
        return
    end

    return InventoryFolder
end

-- Add item in inventory folder
function PlayerDataHandler:AddItemInPlayerInventory(player,ITEM,SLOT_NUMBER)
    local InventoryFolder = self:GetPlayerInventory(player)

    if not InventoryFolder then
        return
    end

    ITEM.Name = SLOT_NUMBER
    ITEM.Parent = InventoryFolder
end

-- Remove item from inventory folder
function PlayerDataHandler:RemoveItemInPlayerInventory(player,ITEM_NAME)
    local InventoryFolder = self:GetPlayerInventory(player)

    if not InventoryFolder then
        self:AddPlayerInventory(player)
    end

    local Item = InventoryFolder:FindFirstChild(ITEM_NAME)

    if not Item then
        return
    end

    Item:Destroy()
end

-- Get item from inventory folder
function PlayerDataHandler:GetItemInPlayerInventory(player,ITEM_NAME)
    local InventoryFolder = self:GetPlayerInventory(player)

    if not InventoryFolder then
        self:AddPlayerInventory(player)
    end

    local Item = InventoryFolder:FindFirstChild(ITEM_NAME)

    if not Item then
        return
    end

    return Item
end

return PlayerDataHandler