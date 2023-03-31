local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local Camera = workspace.CurrentCamera

local RECOIL_PATTERN_ENABLED = false

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local WorkspaceFolder = workspace:WaitForChild("AcceleratorFramework")

local PartManager = require(ReplicatedStorageFolder:WaitForChild("PartManager"))
local GunResourcesHandler = require(ReplicatedStorageFolder:WaitForChild("GunResourcesHandler"))
local ClientModule = require(ReplicatedStorageFolder:WaitForChild("ClientModule"))
local ViewmodelHandler = require(ReplicatedStorageFolder:WaitForChild("ViewmodelHandler"))

local gun = {

    -- properties
    Player = nil,
    GunName = "",
    Offset = nil,
    AimOffset = CFrame.new(),
    Aiming = false,

    -- resources
    RecoilPattern = {},
    ViewmodelOffset = CFrame.new(),
    Comms = nil,
    Stats = {},
    Sounds = nil,
    VisualEffects = nil,
    Animations = nil,
    Model = nil,
    Shell = nil,

    -- animations
    EquipAnimation = nil,
    UnequipAnimation = nil,
    IdleAnimation = nil,
    SprintAnimation = nil,
    ShootAnimation = nil,
    EmptyReloadAnimation = nil,
    TacticalReloadAnimation = nil,

    -- recoil
    RecoilSpring = nil,
    Curshot = 0,
	LastClick = tick(),
	RecoilReset = 2,
}

-- Initiate processing of gun, player input
function gun:InitiateProcessing()
    local RecoilPattern, ViewmodelOffset, Comms, Stats, Sounds, VisualEffects, Animations, Model, Shell = GunResourcesHandler:GetGunRecources(self.GunName)

    -- Resources
    self.RecoilPattern = RecoilPattern
    self.ViewmodelOffset = ViewmodelOffset
    self.Comms = Comms
    self.Stats = Stats
    self.Sounds = Sounds
    self.VisualEffects = VisualEffects
    self.Animations = Animations
    self.Model = Model
    self.Shell = Shell

    -- Offsets
    self.Offset = Instance.new("CFrameValue")
    self.Offset.Name = "Offset"
    self.Offset.Value = self.ViewmodelOffset
    self.Offset.Parent = script

    self:LoadAnimations()
    self:CommsProcessing()

    -- Per frame updates
    RunService.RenderStepped:Connect(function()
        -- Aiming
        self:NewAimOffset()
        if self.Aiming == true then
            TweenService:Create(self.Offset, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Value = self.AimOffset}):Play()
        else
            TweenService:Create(self.Offset, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Value = self.ViewmodelOffset}):Play()
        end
    end)
end

-- Loading animations onto viewmodel
function gun:LoadAnimations()
    local Viewmodel = ClientModule:AccessViewmodel()
    local Animator = Viewmodel.AnimationController.Animator

    self.EquipAnimation = Animator:LoadAnimation(self.Animations.Viewmodel.Equip)
    self.UnequipAnimation = Animator:LoadAnimation(self.Animations.Viewmodel.Unequip)
    self.IdleAnimation = Animator:LoadAnimation(self.Animations.Viewmodel.Idle)
    self.SprintAnimation = Animator:LoadAnimation(self.Animations.Viewmodel.Sprint)
    self.ShootAnimation = Animator:LoadAnimation(self.Animations.Viewmodel.Shoot)
    self.EmptyReloadAnimation = Animator:LoadAnimation(self.Animations.Viewmodel.EmptyReload)
    self.TacticalReloadAnimation = Animator:LoadAnimation(self.Animations.Viewmodel.TacticalReload)
end

-- Comms processing
function gun:CommsProcessing()
    self.Comms.OnClientEvent:Connect(function(Request)
        if Request == "Equip" then
            self:Equip()
        end
        if Request == "Unequip" then
            self:Unequip()
        end
    end)
end

-- Graphical User Interface
function gun:UpdateAmmoGui(Ammo,MaxAmmo)
    self.Player.PlayerGui.AcceleratorFramework.Ammo.Text = Ammo.."/"..MaxAmmo
end

-- Welding model to viewmodel
function gun:WeldModelToViewmodel(Model)
    local viewmodel = ClientModule:AccessViewmodel()

    local handle = Model.GunComponents.Handle

    -- Creating Handle weld
    local handleMotor = viewmodel.HumanoidRootPart:FindFirstChild("Handle") or Instance.new("Motor6D")
    handleMotor.Name = "Handle"
    handleMotor.Parent = viewmodel.HumanoidRootPart
    handleMotor.Part0 = viewmodel.HumanoidRootPart
    handleMotor.Part1 = handle

    Model.Parent = viewmodel
    viewmodel.Parent = game.Workspace.CurrentCamera
end

-- Breaking model to viewmodel weld
function gun:BreakdModelWeldToViewmodel()
    local viewmodel = ClientModule:AccessViewmodel()
    local handleMotor = viewmodel.HumanoidRootPart:FindFirstChild("Handle")
    local GunModel = viewmodel:FindFirstChild(self.GunName)

    if handleMotor then
        handleMotor:Destroy()
    end

    if GunModel then
        GunModel:Destroy()
    end
end

-- Builds the model which to be placed in the player character
function gun:BuildModel()
    local Model = self.Model:Clone()
    local handle = Model:WaitForChild("GunComponents"):WaitForChild("Handle")

    -- SInserting sounds
    for _,v in pairs(self.Sounds:GetChildren()) do
        v:Clone().Parent = Model.GunComponents.Handle
    end

    -- Inserting visual effects
    for _,v in pairs(self.VisualEffects:GetChildren()) do
        v:Clone().Parent = Model.GunComponents.Barrel
    end

    -- Welding Gun Components (Not Animateable)
    for _,v in pairs(Model.GunComponents:GetChildren()) do
        if v:IsA("BasePart") and v ~= handle then
            local newMotor = Instance.new("Weld")
            newMotor.Name = v.Name
            newMotor.Part0 = handle
            newMotor.Part1 = v
            newMotor.C0 = newMotor.Part0.CFrame:inverse() * newMotor.Part1.CFrame
            newMotor.Parent = handle
        end
    end

    -- Welding Parts (Animateable)
    for _,v in pairs(Model:GetChildren()) do
        if v:IsA("BasePart") and v ~= handle then
            local newMotor = Instance.new("Motor6D")
            newMotor.Name = v.Name
            newMotor.Part0 = handle
            newMotor.Part1 = v
            newMotor.C0 = newMotor.Part0.CFrame:inverse() * newMotor.Part1.CFrame
            newMotor.Parent = handle
        end
    end

    -- Collision group
    for _,v in pairs(Model:GetDescendants()) do
        if v:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(v, "GunModels")
        end
    end

    return Model
end

-- Equip gun
function gun:Equip()
    -- Change equipped gun
    ClientModule:EquipGun(self.Player,script)

    -- Ammo gui
    self:UpdateAmmoGui(self.Stats.Ammo,self.Stats.MaxAmmo)

    -- Build model
    local Model = self:BuildModel()
    self:WeldModelToViewmodel(Model)

    -- Equip on Server
    self.Comms:FireServer("Equip")

    -- Animations and sound
    self.IdleAnimation:Play()
    ViewmodelHandler:Transparency(0)
    self:PlaySfx("Handle", "EquipSound")
    self.EquipAnimation:Play()
    task.wait(self.EquipAnimation.Length)
end

-- Unequip gun
function gun:Unequip()
    -- Unequip on Server
    self.Comms:FireServer("Unequip")

    -- Ammo gui
    self:UpdateAmmoGui(0,0)

    -- Stop all animations and play enquip animation and sound
    self.IdleAnimation:Stop()
    self.SprintAnimation:Stop()
    self.EmptyReloadAnimation:Stop()
    self.TacticalReloadAnimation:Stop()
    self:PlaySfx("Handle", "UnequipSound")
    self.UnequipAnimation:Play()

    -- Model welds
    task.wait(self.UnequipAnimation.Length)
    self:BreakdModelWeldToViewmodel()

    -- Change equipped gun
    ClientModule:UnequipGun(self.Player)

    -- Viewmodel transparency
    ViewmodelHandler:Transparency(1)
end

-- Sprint start
function gun:SprintStart()
    self.Comms:FireServer("SprintStart")
    self.SprintAnimation:Play()
end

-- Sprint stop
function gun:SprintStop()
    self.Comms:FireServer("SprintStop")
    self.SprintAnimation:Stop()
end

-- Create new aiming offset
function gun:NewAimOffset()
    local Viewmodel = ClientModule:AccessViewmodel()
    local HumanoidRootPart = Viewmodel.HumanoidRootPart
    self.AimOffset = CFrame.new()

    local Gun

    if HumanoidRootPart:FindFirstChild("Handle") then
        if HumanoidRootPart.Handle.Part1 then
            Gun = HumanoidRootPart.Handle.Part1.Parent.Parent
        end
    end

    if not Gun then return end

    local AimPart = Gun.GunComponents.Aim
    local AimPartPosition = (HumanoidRootPart.CFrame:Inverse() * AimPart.CFrame).Position
    self.AimOffset = CFrame.new(-AimPartPosition.X,-AimPartPosition.Y,-AimPartPosition.Z)
end

-- Aiming in
function gun:AimIn()
    self.Aiming = true
    self.Comms:FireServer("AimIn")
    UserInputService.MouseIconEnabled = false
    self:PlaySfx("Handle", "AimInSound")
    TweenService:Create(self.Offset, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Value = self.AimOffset}):Play()
end

-- Aiming out
function gun:AimOut()
    self.Aiming = false
    self.Comms:FireServer("AimOut")
    UserInputService.MouseIconEnabled = true
    self:PlaySfx("Handle", "AimOutSound")
    TweenService:Create(self.Offset, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Value = self.ViewmodelOffset}):Play()
end

-- Playing Sound Effects
function gun:PlaySfx(GUN_COMPONENT,NAME)
    local Viewmodel = ClientModule:AccessViewmodel()
    local GunModel = Viewmodel:FindFirstChild(self.GunName)

    if not GunModel then return end

    local GunComponent = GunModel.GunComponents:FindFirstChild(GUN_COMPONENT)

    if not GunComponent then return end

    local Sfx = GunComponent:FindFirstChild(NAME)

    if not Sfx then return end

    Sfx.TimePosition = 0
    Sfx:Play()
end

-- Displaying Visual Effects
function gun:PlayVfx(GUN_COMPONENT,NAME)
    local Viewmodel = ClientModule:AccessViewmodel()
    local GunModel = Viewmodel:FindFirstChild(self.GunName)

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

local function Lerp(a, b, t)
    return a * (1 - t) + (b * t)
end

-- Reloading gun
function gun:Reload()
    if not (self.Stats.Ammo < self.Stats.MaxAmmo) then return end

    self.Comms:FireServer("Reload")
    self:PlaySfx("Handle", "ReloadSound")

    if self.Stats.Ammo == 0 then
        self:PlaySfx("Handle", "EmptyReloadSound")
        self.EmptyReloadAnimation:Play()
        task.wait(self.EmptyReloadAnimation.Length)
    else
        self:PlaySfx("Handle", "TacticalReloadSound")
        self.TacticalReloadAnimation:Play()
        task.wait(self.TacticalReloadAnimation.Length)
    end

    if self.IdleAnimation.isPlaying == true then
        self.Curshot = 0
        self.Stats.Ammo = self.Stats.MaxAmmo
        self:UpdateAmmoGui(self.Stats.Ammo,self.Stats.MaxAmmo)
    end
end

-- Ejecting bullet shell
function gun:EjectShell()
    local Viewmodel = ClientModule:AccessViewmodel()
    local GunModel = Viewmodel:FindFirstChild(self.GunName)

    if not GunModel then return end

    local Bolt = GunModel.GunComponents:FindFirstChild("Bolt")

    if not Bolt then return end

    local Shell = PartManager:Get("Shells_"..self.GunName)

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
        self:PlaySfx("Handle", "ShellEjectSound")
        task.wait(2.7)
        Shell.Anchored = true
        PartManager:Return("Shells_"..self.GunName, Shell)
    end)
end

-- Shooting gun
function gun:Shoot()
    if not (self.EmptyReloadAnimation.isPlaying == false and self.TacticalReloadAnimation.isPlaying == false) then return end

    if self.Stats.Ammo == 0 then
        task.spawn(function()
            self:Reload()
        end)
        return
    end

    self.Comms:FireServer("Shoot")
    self:PlaySfx("Handle", "ShootSound")
    self:PlayVfx("Barrel", "MuzzleFlash")
    self:PlayVfx("Barrel", "MuzzleSmoke")
    self:EjectShell()
    self:ReplicateRaycast({})
    self.ShootAnimation:Play()
    self.Stats.Ammo -= 1
    self:UpdateAmmoGui(self.Stats.Ammo,self.Stats.MaxAmmo)

    if RECOIL_PATTERN_ENABLED == true then
        self.Curshot = (tick() - self.LastClick > self.RecoilReset and 1 or self.Curshot + 1) -- Either reset or increase the current shot we're at
        self.LastClick = tick()

        for _, v in pairs(self.RecoilPattern) do
            if self.Curshot <= v[1] then
                local Vector = Vector3.new(v[2], v[3], v[4])
                local Alpha = 0.3

                -- X
                task.spawn(function()
                    local num = 0
                    while math.abs(num - Vector.X) > 0.05 do
                        num = Lerp(num, Vector.X, Alpha)
                        local rec = num / 50
                        Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(rec), 0, 0)
                        RunService.RenderStepped:Wait()
                    end
                end)

                -- Y
                task.spawn(function()
                    local num = 0
                    while math.abs(num - Vector.Y) > 0.05 do
                        num = Lerp(num, Vector.Y, Alpha)
                        local rec = num / 50
                        Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(rec), 0)
                        RunService.RenderStepped:Wait()
                    end
                end)

                break
            end
        end
    else
        local Vector = Vector3.new(math.random(1,5), math.random(-5,5), 0)
        local Alpha = 0.3

        task.spawn(function()
            local num = 0
            while math.abs(num - Vector.X) > 0.05 do
                num = Lerp(num, Vector.X, Alpha)
                local rec = num / 50
                Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(rec), 0, 0)
                RunService.RenderStepped:Wait()
            end
        end)

        task.spawn(function()
            local num = 0
            while math.abs(num - Vector.Y) > 0.05 do
                num = Lerp(num, Vector.Y, Alpha)
                local rec = num / 50
                Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(rec), 0)
                RunService.RenderStepped:Wait()
            end
        end)
    end
end

-- Replicating Raycast
function gun:ReplicateRaycast(FILTER_INSTANCES)
    task.spawn(function()
        local Viewmodel = ClientModule:AccessViewmodel()
        local GunModel = Viewmodel:FindFirstChild(self.GunName)

        if not GunModel then return end

        local Barrel = GunModel.GunComponents:FindFirstChild("Barrel")

        if not Barrel then return end

        local AIM_CFRAME = Barrel.CFrame
        local Bullet

        local function ConfigureFilterInstances(FilterInstancesProxy)
            table.insert(FilterInstancesProxy, self.Player.Character)
            table.insert(FilterInstancesProxy, workspace.Markers)
            table.insert(FilterInstancesProxy, WorkspaceFolder)
            table.insert(FilterInstancesProxy, Viewmodel)

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

-- Bullet hit
function gun:Hit(RaycastResult, AimCFrame, FilterInstances)
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

return gun