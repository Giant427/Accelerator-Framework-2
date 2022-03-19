local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local GunResourcesFolder = ReplicatedStorageFolder:WaitForChild("GunResources")

local GunResourcesHandler = {}

-- Returns a resource for a gun, an object or a table if resource is in module script
function GunResourcesHandler:GetResource(GunName, ResourceType)
    local ResourceContainer = GunResourcesFolder:FindFirstChild(ResourceType)
    if not ResourceContainer then
        error("Resource type "..ResourceType.." doesn't exist")
        return
    end
    local Resource
    if ResourceContainer:IsA("ModuleScript") then
        Resource = require(ResourceContainer)[GunName]
    else
        Resource = ResourceContainer:FindFirstChild(GunName):Clone()
    end
    if not Resource then
        error("Resource "..ResourceType.." doesn't exist for gun "..GunName)
        return
    end
    return Resource
end

-- Get gun resources
function GunResourcesHandler:GetGunRecources(GunName)
    local RecoilPattern = self:GetResource(GunName, "RecoilPattern")
    local ViewmodelOffset = self:GetResource(GunName, "ViewmodelOffset")
    local RemoteEvent = self:GetResource(GunName, "RemoteEvents")
    local Metadata = self:GetResource(GunName, "Metadata")
    local Sounds = self:GetResource(GunName, "Sounds")
    local Particles = self:GetResource(GunName, "Particles")
    local Animations = self:GetResource(GunName, "Animations")
    local Model = self:GetResource(GunName, "Models")
    local Shell = self:GetResource(GunName, "Shells")

    return RecoilPattern, ViewmodelOffset, RemoteEvent, Metadata, Sounds, Particles, Animations, Model, Shell
end

-- Get Viewmodel
function GunResourcesHandler:GetViewmodel()
    return GunResourcesFolder:FindFirstChild("Viewmodel"):Clone()
end

return GunResourcesHandler