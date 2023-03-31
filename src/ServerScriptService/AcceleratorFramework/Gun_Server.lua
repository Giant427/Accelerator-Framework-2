local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")

local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local ServerStorageFolder = ServerStorage:WaitForChild("AcceleratorFramework")
local WorkspaceFolder = workspace:WaitForChild("AcceleratorFramework")
local ServerScriptServiceFolder = game:GetService("ServerScriptService"):WaitForChild("AcceleratorFramework")

local ServerModule = require(ServerScriptServiceFolder:WaitForChild("ServerModule"))
local PlayerDataHandler = require(ServerStorageFolder:WaitForChild("PlayerDataHandler"))
local GunResourcesHandler = require(ReplicatedStorageFolder:WaitForChild("GunResourcesHandler"))

local gun = {
    -- properties
    Player = nil,
    GunName = "",
    Aiming = false,

    -- Resources
    RecoilPattern = {},
    Comms = nil,
    Stats = {},
    Sounds = nil,
    VisualEffects = nil,
    Animations = nil,
    Model = nil,
    Shell = nil,

    -- Animations
    EquipAnimation = nil,
    UnequipAnimation = nil,
    IdleAnimation = nil,
    AimIdleAnimation = nil,
    SprintAnimation = nil,
    ShootAnimation = nil,
    AimShootAnimation = nil,
    EmptyReloadAnimation = nil,
    TacticalReloadAnimation = nil,
}

-- Initiate processing
function gun:InitiateProcessing()
    local RecoilPattern, ViewmodelOffset, Comms, Stats, Sounds, VisualEffects, Animations, Model, Shell = GunResourcesHandler:GetGunRecources(self.GunName)

    -- Resources
    self.RecoilPattern = RecoilPattern
    self.Comms = Comms
    self.Stats = Stats
    self.Sounds = Sounds
    self.VisualEffects = VisualEffects
    self.Animations = Animations
    self.Model = Model
    self.Shell = Shell

    -- Loading Animations
    local CharacterDiedConnection
    local function CharacterDied()
        self:CharacterDied()
    end

    if self.Player.Character then
        self:LoadAnimations()
    end

    self.Player.CharacterAdded:Connect(function()
        self:LoadAnimations()

        repeat
            task.wait()
        until self.Player.Character:FindFirstChild("Humanoid")

        if CharacterDiedConnection then
            CharacterDiedConnection:Disconnect()
        end
        CharacterDiedConnection = self.Player.Character.Humanoid.Died:Connect(CharacterDied)
    end)

    -- Communications
    self:CommsProcessing()
end

-- Character died
function gun:CharacterDied()
    self.Comms:FireClient(self.Player, "Unequip")
end

-- Loading Animations
function gun:LoadAnimations()
    local Character = self.Player.Character

    if not Character then return end

    repeat
        task.wait()
    until Character:FindFirstChild("Humanoid")

    local Humanoid = Character:FindFirstChild("Humanoid")

    if not Humanoid then return end

    local Animator = Humanoid:FindFirstChild("Animator")

    if not Animator then return end

    self.EquipAnimation = Animator:LoadAnimation(self.Animations.Character.Equip)
    self.UnequipAnimation = Animator:LoadAnimation(self.Animations.Character.Unequip)
    self.IdleAnimation = Animator:LoadAnimation(self.Animations.Character.Idle)
    self.AimIdleAnimation = Animator:LoadAnimation(self.Animations.Character.AimIdle)
    self.SprintAnimation = Animator:LoadAnimation(self.Animations.Character.Sprint)
    self.ShootAnimation = Animator:LoadAnimation(self.Animations.Character.Shoot)
    self.AimShootAnimation = Animator:LoadAnimation(self.Animations.Character.AimShoot)
    self.EmptyReloadAnimation = Animator:LoadAnimation(self.Animations.Character.EmptyReload)
    self.TacticalReloadAnimation = Animator:LoadAnimation(self.Animations.Character.TacticalReload)
end

-- Comms processing
function gun:CommsProcessing()
    self.Comms.OnServerEvent:Connect(function(Player,Request)
        if Player == self.Player then
            -- Equiping
            if Request == "Equip" then
                self:Equip()
            end
            if Request == "Unequip" then
                self:Unequip()
            end

            -- Sprinting
            if Request == "SprintStart" then
                self:SprintStart()
            end

            if Request == "SprintStop" then
                self:SprintStop()
            end

            -- Aiming
            if Request == "AimIn" then
                self:AimIn()
            end
            if Request == "AimOut" then
                self:AimOut()
            end

            -- Reloading

            if Request == "Reload" then
                self:Reload()
            end

            -- Shooting

            if Request == "Shoot" then
                self:Shoot()
            end
        end
    end)
end

-- Weld model to player character
function gun:WeldModelToCharacter(Model)
    local motor = Instance.new("Motor6D")
    motor.Name = "HandleWeld"

    local Character = self.Player.Character

    if not Character then
        return
    end

    local part0 = Character:FindFirstChild("RightLowerArm")

    if part0 then
        motor.Parent = part0
        motor.Part0 = part0
    end

    motor.Part1 = Model.GunComponents.Handle
    Model.Parent = Character
end

-- Break model to character weld
function gun:BreakModelWeldToCharacter()
    local Character = self.Player.Character

    if not Character then
        return
    end

    local part0 = Character:FindFirstChild("RightLowerArm")

    if not part0 then
        return
    end

    local motor = part0:FindFirstChild("HandleWeld")

    if not motor then
        return
    end

    local GunModel = Character:FindFirstChild(self.GunName)

    if not GunModel then
        return
    end

    GunModel:Destroy()
    motor:Destroy()
end

-- Build model to be inserted in character
function gun:BuildModel()
    local Model = self.Model:Clone()
    local handle = Model.GunComponents.Handle

    -- Inserting sounds
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
    for _,v in pairs(ReplicatedStorageFolder.Models:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            PhysicsService:SetPartCollisionGroup(v, "PlayerCharacter")
        end
    end

    return Model
end

-- Equiping gun
function gun:Equip()
    -- Change equipped gun
    ServerModule:EquipGun(self.Player,script)

    -- Build model
    local Model = self:BuildModel()
    self:WeldModelToCharacter(Model)

    -- Animations and sound
    self.IdleAnimation:Play()
    self:PlaySfx("Handle", "EquipSound")
    self.EquipAnimation:Play()
    task.wait(self.EquipAnimation.Length)
end

-- Unequiping gun
function gun:Unequip()
    -- Stop all animations and play enquip animation and sound
    self.AimIdleAnimation:Stop()
    self.AimShootAnimation:Stop()
    self.IdleAnimation:Stop()
    self.SprintAnimation:Stop()
    self.EmptyReloadAnimation:Stop()
    self.TacticalReloadAnimation:Stop()
    self:PlaySfx("Handle", "UnequipSound")
    self.UnequipAnimation:Play()

    -- Break welds
    task.wait(self.UnequipAnimation.Length)
    self:BreakModelWeldToCharacter()

    -- Unequip in inventory
    ServerModule:UnequipGun(self.Player)
end

-- Sprint start
function gun:SprintStart()
    self.SprintAnimation:Play()
end

-- Sprint stop
function gun:SprintStop()
    self.SprintAnimation:Stop()
end

-- Aiming in
function gun:AimIn()
    self.Aiming = true
    self:PlaySfx("Handle", "AimInSound")
    self.AimIdleAnimation:Play()
end

-- Aiming out
function gun:AimOut()
    self.Aiming = false
    self:PlaySfx("Handle", "AimOutSound")
    self.AimIdleAnimation:Stop()
end

-- Playing Sound Effects
function gun:PlaySfx(GUN_COMPONENT,NAME)
    ServerModule:PlaySfx(self.Player,self.GunName,GUN_COMPONENT,NAME)
end

-- Displaying Visual Effects
function gun:PlayVfx(GUN_COMPONENT,NAME)
    ServerModule:PlayVfx(self.Player,self.GunName,GUN_COMPONENT,NAME)
end

-- Reloading
function gun:Reload()
    if not (self.Stats.Ammo < self.Stats.MaxAmmo) then return end

    if self.Stats.Ammo == 0 then
        self:PlaySfx("Handle", "EmptyReloadSound")
        self.EmptyReloadAnimation:Play()
        task.wait(self.EmptyReloadAnimation.Length)
    else
        self:PlaySfx("Handle", "TacticalReloadSound")
        self.TacticalReloadAnimation:Play()
        task.wait(self.TacticalReloadAnimation.Length)
    end

    self.Stats.Ammo = self.Stats.MaxAmmo
end

-- Ejecting bullet shells
function gun:EjectShell()
    ServerModule:EjectShell(self.Player,self.GunName)
end

-- Shooting
function gun:Shoot()
    if not (self.EmptyReloadAnimation.isPlaying == false and self.TacticalReloadAnimation.isPlaying == false) then return end

    if self.Stats.Ammo == 0 then
        task.spawn(function()
            self:Reload()
        end)
        return
    end

    local AimCFrame = PlayerDataHandler:GetPlayerAim(self.Player)

    self:PlaySfx("Handle", "ShootSound")
    self:PlayVfx("Barrel", "MuzzleFlash")
    self:PlayVfx("Barrel", "MuzzleSmoke")
    self:EjectShell()

    self:ReplicateRaycast({})
    self:Raycast(AimCFrame, {})

    self.Stats.Ammo -= 1
    if self.Aiming == true then
        self.AimShootAnimation:Play()
    else
        self.ShootAnimation:Play()
    end
end

-- Replicating Raycast
function gun:ReplicateRaycast(FilterInstances)
    ServerModule:ReplicateRaycast(self.Player, self.GunName, FilterInstances)
end

-- Raycast
function gun:Raycast(cframe, FilterInstances)
    task.spawn(function()
        local AimCFrame = cframe

        local function ConfigureFilterInstances(FilterInstancesProxy)
            table.insert(FilterInstancesProxy, self.Player.Character)
            table.insert(FilterInstancesProxy, workspace.Markers)
            table.insert(FilterInstancesProxy, WorkspaceFolder)

            return FilterInstancesProxy
        end

        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = ConfigureFilterInstances(FilterInstances)
        raycastParams.IgnoreWater = true

        local Raycast
        local Connection

        local function Cast()
            Raycast = workspace:Raycast(AimCFrame.Position, AimCFrame.LookVector * 5, raycastParams)

            -- Move AimCFrame
            AimCFrame *= CFrame.new(0,0,-5) * CFrame.Angles(-0.001,0,0)

            if Raycast then
                Connection:Disconnect()

                return
            end
        end

        Raycast = workspace:Raycast(AimCFrame.Position, AimCFrame.LookVector * 10000, raycastParams)

        if Raycast then
            Connection = RunService.Heartbeat:Connect(Cast)
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
