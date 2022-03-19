local UiProfile = {}

-- Properties
UiProfile.Player = nil
UiProfile.ScreenGui = nil
UiProfile.Gun = {}
UiProfile.Gun.Ammo = nil
UiProfile.Gun.GunName = nil
UiProfile.Inventory = nil

-- Initiate
function UiProfile:Initiate()
    self.ScreenGui = self.Player.PlayerGui:WaitForChild("AcceleratorFramework")
    self.Gun.Ammo = self.ScreenGui.Gun.Ammo
    self.Gun.GunName = self.ScreenGui.Gun.GunName
    self.Inventory = self.ScreenGui.Inventory
end

-- Update gun gui
function UiProfile:UpdateGunGui(GunName, MagAmmo, MaxAmmo)
    self.Gun.GunName.Text = GunName
    self.Gun.Ammo.Text = MagAmmo.."/"..MaxAmmo
end

-- Update inventory slot
function UiProfile:UpdateInventorySlot(SlotNumber, GunName)
    local Slot = self.Inventory:FindFirstChild("Slot"..SlotNumber)
    if not Slot then return end
    Slot.GunName.Text = GunName
end

-- Equip inventory slot
function UiProfile:EquipInventorySlot(SlotNumber)
    local Slot = self.Inventory:FindFirstChild("Slot"..SlotNumber)
    if not Slot then return end
    Slot.BorderSizePixel = 3
end

-- Unequip inventory slot
function UiProfile:UnequipInventorySlot(SlotNumber)
    local Slot = self.Inventory:FindFirstChild("Slot"..SlotNumber)
    if not Slot then return end
    Slot.BorderSizePixel = 1
end

-- Constructor
local ClientPlayerProfileModule = {}
function ClientPlayerProfileModule:New(ProfileInfo)
	ProfileInfo = ProfileInfo or {}
	setmetatable(ProfileInfo, UiProfile)
	UiProfile.__index = UiProfile
	return ProfileInfo
end

return ClientPlayerProfileModule