local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local WorkspaceFolder = workspace:WaitForChild("AcceleratorFramework")

local PartManager = require(ReplicatedStorageFolder:WaitForChild("PartManager"))
local GunResourcesHandler = require(ReplicatedStorageFolder:WaitForChild("GunResourcesHandler"))

local GunObject = ReplicatedStorageFolder:WaitForChild("Gun_Client")

local ClientModule = {}

-- Get the player inventory
function ClientModule:GetPlayerInventory(player)
    local PlayerScriptsFolder = player:FindFirstChild("PlayerScripts")

    if not PlayerScriptsFolder then
        return
    end

    local PlayerFolder = PlayerScriptsFolder:FindFirstChild("AcceleratorFramework")

    return PlayerFolder
end

-- Add gun to player inventory
function ClientModule:AddGun(player,GUN_NAME)
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

    return self:GetGun(player,Slot.Name)
end

-- Get gun from player inventory
function ClientModule:GetGun(player,SLOT_NUMBER)
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
function ClientModule:RemoveGun(player,SLOT_NUMBER)
    local PlayerInventory = self:GetPlayerInventory(player)

    local EquippedGun = PlayerInventory:FindFirstChild("Equipped").Value

    if EquippedGun then
        if EquippedGun.Parent.Name == SLOT_NUMBER then
            EquippedGun.Parent:Destroy()
        end
    end

    local DeletingGun = PlayerInventory:FindFirstChild("Inventory"):FindFirstChild(SLOT_NUMBER)

    if DeletingGun then
        DeletingGun:Destroy()
    end

    self:ReorderInventory(player,SLOT_NUMBER)
end

-- Get equipped gun
function ClientModule:GetEquippedGun(player)
    local PlayerFolder = self:GetPlayerInventory(player)

    local Equipped = PlayerFolder:FindFirstChild("Equipped")

    return Equipped
end

-- Reorder inventory
function ClientModule:ReorderInventory(player,STARTING_INDEX)
    local PlayerFolder = self:GetPlayerInventory(player)
    local Inventory = PlayerFolder:FindFirstChild("Inventory")

    for i = STARTING_INDEX,#Inventory:GetChildren(),1 do
        Inventory:GetChildren()[i].Name = i
    end
end

-- Equip a gun from inventory
function ClientModule:EquipGun(player,gun_object)
    local PlayerFolder = self:GetPlayerInventory(player)
    local Equipped = PlayerFolder:FindFirstChild("Equipped")

    if Equipped.Value then
        require(Equipped.Value):Unequip()
    end

    Equipped.Value = gun_object
end

-- Unequip a gun from inventory
function ClientModule:UnequipGun(player)
    local PlayerFolder = self:GetPlayerInventory(player)
    local Equipped = PlayerFolder:FindFirstChild("Equipped")

    Equipped.Value = nil
end

-- Access the viewmodel or create a new one
function ClientModule:AccessViewmodel()
    local Viewmodel = game.Workspace.CurrentCamera:FindFirstChild("Viewmodel") or GunResourcesHandler:GetViewmodel():Clone()

    for _,v in pairs(Viewmodel:GetDescendants()) do
		if v:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(v, "Viewmodel")
		end
	end

    Viewmodel.Parent = game.Workspace.CurrentCamera

    return Viewmodel
end

local function Lerp(a, b, t)
    return a * (1 - t) + (b * t)
end

-- Replicating sound effects
function ClientModule:PlaySfx(Player,GUN_NAME,GUN_COMPONENT,NAME)
    local Character = Player.Character

    if not Character then return end

    local GunModel = Character:FindFirstChild(GUN_NAME)

    if not GunModel then return end

    local GunComponent = GunModel.GunComponents:FindFirstChild(GUN_COMPONENT)

    if not GunComponent then return end

    local Sfx = GunComponent:FindFirstChild(NAME)

    if not Sfx then return end

    Sfx.TimePosition = 0
    Sfx:Play()
end

-- Replicating visual effects
function ClientModule:PlayVfx(Player,GUN_NAME,GUN_COMPONENT,NAME)
    local Character = Player.Character

    if not Character then return end

    local GunModel = Character:FindFirstChild(GUN_NAME)

    if not GunModel then return end

    local GunComponent = GunModel.GunComponents:FindFirstChild(GUN_COMPONENT)

    if not GunComponent then return end

    local Vfx = GunComponent:FindFirstChild(NAME)

    if not Vfx then return end

    task.spawn(function()
        Vfx.Rotation = NumberRange.new(math.random(-180, 180))
        Vfx.Enabled = true
        task.wait(0.1)
        Vfx.Enabled = false
    end)
end

-- Replicating bullet shell ejections
function ClientModule:EjectShell(Player,GUN_NAME)
    local Character = Player.Character

    if not Character then return end

    local GunModel = Character:FindFirstChild(GUN_NAME)

    if not GunModel then return end

    local Bolt = GunModel.GunComponents:FindFirstChild("Bolt")

    if not Bolt then return end

    local Shell = PartManager:Get("Shells_"..GUN_NAME)
    Shell.Anchored = false

    Shell.CFrame = Bolt.CFrame * CFrame.Angles(0, 90, 0) * CFrame.new(Bolt.Size / 2 + Shell.Size / 2,0,0)
    Shell.Anchored = false

    local Vector = Vector3.new(1, 0, 0) * 5
    local Alpha = 0.77

    task.spawn(function()
        local num = 0
        while math.abs(num - Vector.X) > 0.01 do
            num = Lerp(num, Vector.X, Alpha)
            local rec = num / 10
            Shell.CFrame = Shell.CFrame * CFrame.new(rec, 0, 0)
            RunService.RenderStepped:Wait()
        end
    end)

    task.spawn(function()
        task.wait(0.3)
        self:PlaySfx(Player, GUN_NAME, "Handle", "ShellEjectSound")

        task.wait(2.7)

        Shell.Anchored = true
        PartManager:Return("Shells_"..GUN_NAME, Shell)
    end)
end

-- Replicating Raycast
function ClientModule:ReplicateRaycast(Player, GUN_NAME, FILTER_INSTANCES)
    task.spawn(function()
        local Character = Player.Character

        if not Character then return end

        local GunModel = Character:FindFirstChild(GUN_NAME)

        if not GunModel then return end

        local Barrel = GunModel.GunComponents:FindFirstChild("Barrel")

        if not Barrel then return end

        local AIM_CFRAME = Barrel.CFrame
        local Bullet

        local function ConfigureFilterInstances(FilterInstancesProxy)
            table.insert(FilterInstancesProxy, Player.Character)
            table.insert(FilterInstancesProxy, workspace.Markers)
            table.insert(FilterInstancesProxy, WorkspaceFolder)
            table.insert(FilterInstancesProxy, self:AccessViewmodel())

            return FilterInstancesProxy
        end

        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = ConfigureFilterInstances(FILTER_INSTANCES)
        raycastParams.IgnoreWater = true

        local Raycast
        local Connection

        local function Cast()
            Raycast = workspace:Raycast(AIM_CFRAME.Position, AIM_CFRAME.LookVector * 5, raycastParams)

            -- Move Bullet
            Bullet.CFrame *= CFrame.new(0,0,-5) * CFrame.Angles(-0.001,0,0)

            -- Move AimCFrame
            AIM_CFRAME *= CFrame.new(0,0,-5) * CFrame.Angles(-0.001,0,0)

            if Raycast then
                Connection:Disconnect()
                Bullet.Anchored = true
                PartManager:Return("Bullets", Bullet)

                return
            end
        end

        Raycast = workspace:Raycast(AIM_CFRAME.Position, AIM_CFRAME.LookVector * 10000, raycastParams)

        if Raycast then
            AIM_CFRAME = CFrame.new(AIM_CFRAME.Position, Raycast.Position)
            Bullet = PartManager:Get("Bullets")
            Bullet.CFrame = AIM_CFRAME
            Connection = RunService.RenderStepped:Connect(Cast)
        else
            return
        end
    end)
end

-- Raycast hit
function ClientModule:Hit(RaycastResult, AimCFrame, FilterInstances)
    local HitPart = RaycastResult.Instance

    local Character
    local Humanoid

    if HitPart.Parent:IsA("Accessory") then
        -- HitPart is an Accessory, ignore it and continue Raycast

        table.insert(FilterInstances, HitPart)

        return false, FilterInstances
    else
        if HitPart.Parent:FindFirstChildOfClass("Humanoid") then
            -- Hit a Player, damage them

            Character = HitPart.Parent
            Humanoid = Character:FindFirstChildOfClass("Humanoid")

            if HitPart.Name == "Head" then
                Humanoid:TakeDamage(self.Stats.HeadshotDamage)
                print(self.Stats.HeadshotDamage, "damage given to:", Character.Name)
            else
                Humanoid:TakeDamage(self.Stats.BodyshotDamage)
                print(self.Stats.BodyshotDamage, "damage given to:", Character.Name)
            end

            return true, FilterInstances
        else
            -- Hit a part, check to see if wallbang is possible

            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
            raycastParams.FilterDescendantsInstances = {HitPart}
            raycastParams.IgnoreWater = true

            local RaycastCFrame = CFrame.new((AimCFrame * CFrame.new(0, 0, -500)).Position, RaycastResult.Position)

            local Raycast = workspace:Raycast(RaycastCFrame.Position, RaycastCFrame.LookVector * 50000, raycastParams)

            if Raycast then
                table.insert(FilterInstances, HitPart)

                return false, FilterInstances
            end
        end
    end
end

return ClientModule