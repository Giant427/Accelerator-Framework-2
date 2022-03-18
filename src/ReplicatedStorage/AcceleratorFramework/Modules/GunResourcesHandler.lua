local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local GunResourcesFolder = ReplicatedStorageFolder:WaitForChild("GunResources")

local GunResourcesHandler = {}

-- Returns a resource for a gun, an object or a table if resource is in module script
function GunResourcesHandler:GetResource(ResourceType, GunName)
    local ResourceContainer = GunResourcesFolder:FindFirstChild(ResourceType)
    if not ResourceContainer then
        error("Resource type "..ResourceType.." doesn't exist")
        return
    end
    local Resource = ResourceContainer:FindFirstChild(GunName):Clone()
    if ResourceContainer:IsA("ModuleScript") then
        Resource = require(ResourceContainer)[GunName]
    end
    if not Resource then
        error("Resource "..ResourceType.." doesn't exist for gun "..GunName)
        return
    end
    return Resource
end

-- Get gun resources
function GunResourcesHandler:GetGunRecources(GunName)
    local RecoilPattern = self:GetResource("RecoilPattern", GunName)
    local ViewmodelOffset = self:GetResource("ViewmodelOffset", GunName)
    local Comms = self:GetResource("Comms", GunName)
    local Stats = self:GetResource("Metadata", GunName)
    local Sounds = self:GetResource("Sounds", GunName)
    local VisualEffects = self:GetResource("VisualEffects", GunName)
    local Animations = self:GetResource("Animations", GunName)
    local Model = self:GetResource("Models", GunName)
    local Shell = self:GetResource("Shells", GunName)

    return RecoilPattern, ViewmodelOffset, Comms, Stats, Sounds, VisualEffects, Animations, Model, Shell
end

-- Get Viewmodel
function GunResourcesHandler:GetViewmodel()
    return GunResourcesFolder:FindFirstChild("Viewmodel"):Clone()
end

return GunResourcesHandler