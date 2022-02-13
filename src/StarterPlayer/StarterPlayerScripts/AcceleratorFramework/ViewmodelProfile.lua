local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local Viewmodel_Prototype = ReplicatedStorageFolder:WaitForChild("GunResources"):WaitForChild("Viewmodel")

local ViewmodelProfile = {}

-- Properties
ViewmodelProfile.Player = nil
ViewmodelProfile.Character = nil
ViewmodelProfile.Enabled = false
ViewmodelProfile.Viewmodel = nil

-- Starter function to assemble the whole profile for functionality
function ViewmodelProfile:Initiate()
    self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)
    self.Character = self.Player.Character
    self:CreateViewmodel()
    RunService.RenderStepped:Connect(function(DeltaTime)
        self:Update(DeltaTime)
    end)
end

-- Create a viewmodel
function ViewmodelProfile:CreateViewmodel()
    self.Viewmodel = Viewmodel_Prototype:Clone()
    self.Viewmodel.Parent = Camera
end

-- Update viewmodel position and perform various movements and stuff, I can't really explain this just read the code and test it
function ViewmodelProfile:Update(DeltaTime)
    if not self.Enabled then return end
    local CameraCFrame = Camera.CFrame
    self.Viewmodel.HumanoidRootPart.CFrame = CameraCFrame
end

-- On character added
function ViewmodelProfile:onCharacterAdded(Character)
	self.Character = Character
end

-- Constructor
local ViewmodelProfileModule = {}
function ViewmodelProfileModule:New(ProfileInfo)
	ProfileInfo = ProfileInfo or {}
	setmetatable(ProfileInfo, ViewmodelProfile)
	ViewmodelProfile.__index = ViewmodelProfile
	return ProfileInfo
end

return ViewmodelProfileModule