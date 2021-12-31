local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Accelerator framework folder in ReplicatedStorage
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local GunResourcesFolder = ReplicatedStorageFolder:WaitForChild("GunResources")

---------------------------
-- Gun resources handler --
---------------------------

local GunResourcesHandler = {}

-- Returns a resource for a gun, an object or a table if resource in module script
function GunResourcesHandler:GetResource(ResourceType, GunName)
    local ResourceContainer = GunResourcesFolder:FindFirstChild(ResourceType)

    if not ResourceContainer then return end

    local Resource = ResourceContainer:FindFirstChild(GunName)

    if ResourceContainer:IsA("ModuleScript") then
        Resource = require(ResourceContainer)[GunName]
    end

    return Resource
end

-- Get gun resources
function GunResourcesHandler:GetGunRecources(GunName)
    local RecoilPattern = self:GetResource("RecoilPattern", GunName)
    local ViewmodelOffset = self:GetResource("ViewmodelOffset", GunName)
    local Comms = self:GetResource("Comms", GunName)
    local Stats = self:GetResource("Stats", GunName)
    local Sounds = self:GetResource("Sounds", GunName)
    local VisualEffects = self:GetResource("VisualEffects", GunName)
    local Animations = self:GetResource("Animations", GunName)
    local Model = self:GetResource("Models", GunName)
    local Shell = self:GetResource("Shells", GunName)

    return RecoilPattern, ViewmodelOffset, Comms, Stats, Sounds, VisualEffects, Animations, Model, Shell
end

-- Get Viewmodel
function GunResourcesHandler:GetViewmodel()
    return GunResourcesFolder:FindFirstChild("Viewmodel")
end

return GunResourcesHandler