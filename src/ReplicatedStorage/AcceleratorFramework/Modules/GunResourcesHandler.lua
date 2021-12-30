local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Accelerator framework folder in ReplicatedStorage
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local GunResourcesFolder = ReplicatedStorageFolder:WaitForChild("GunResources")

---------------------------
-- Gun resources handler --
---------------------------

local GunResourcesHandler = {}

-- Get a particular resource
function GunResourcesHandler:GetResource(RESOURCE_TYPE, GUN_NAME)
    local ResourceContainer = GunResourcesFolder:FindFirstChild(RESOURCE_TYPE)

    if not ResourceContainer then return end

    local Resource = ResourceContainer:FindFirstChild(GUN_NAME)

    if ResourceContainer:IsA("ModuleScript") then
        Resource = require(ResourceContainer)[GUN_NAME]
    end

    return Resource
end

-- Get gun resources
function GunResourcesHandler:GetGunRecources(GUN_NAME)
    local RecoilPattern = self:GetResource("RecoilPattern", GUN_NAME)
    local ViewmodelOffset = self:GetResource("ViewmodelOffset", GUN_NAME)
    local Comms = self:GetResource("Comms", GUN_NAME)
    local Stats = self:GetResource("Stats", GUN_NAME)
    local Sounds = self:GetResource("Sounds", GUN_NAME)
    local VisualEffects = self:GetResource("VisualEffects", GUN_NAME)
    local Animations = self:GetResource("Animations", GUN_NAME)
    local Model = self:GetResource("Models", GUN_NAME)
    local Shell = self:GetResource("Shells", GUN_NAME)

    return RecoilPattern, ViewmodelOffset, Comms, Stats, Sounds, VisualEffects, Animations, Model, Shell
end

-- Get Viewmodel
function GunResourcesHandler:GetViewmodel()
    return GunResourcesFolder:FindFirstChild("Viewmodel")
end

return GunResourcesHandler