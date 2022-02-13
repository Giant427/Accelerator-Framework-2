local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local Viewmodel_Prototype = ReplicatedStorageFolder:WaitForChild("GunResources"):WaitForChild("Viewmodel")

local ViewmodelProfile = {}

-- Properties
ViewmodelProfile.Player = nil
ViewmodelProfile.Character = nil
ViewmodelProfile.Viewmodel = nil
ViewmodelProfile.Enabled = false
ViewmodelProfile.onCharacterAddedConnection = nil
ViewmodelProfile.UpdateConnection = nil

-- Starter function to assemble the whole profile for functionality
function ViewmodelProfile:Initiate()
    self.onCharacterAddedConnection = self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)
    self.Character = self.Player.Character
    self:CreateViewmodel()
    self.UpdateConnection = RunService.RenderStepped:Connect(function(DeltaTime)
        self:Update(DeltaTime)
    end)
end

-- Create a viewmodel
function ViewmodelProfile:CreateViewmodel()
    self.Viewmodel = Viewmodel_Prototype:Clone()
    self.Viewmodel.Parent = Camera
end

-- Destroy the viewmodel in the camera
function ViewmodelProfile:DestroyViewmodel()
    if self.Viewmodel then
        self.Viewmodel:Destroy()
    
   end
end

-- Update viewmodel position and perform various movements and stuff, I can't really explain this just read the code and test it
function ViewmodelProfile:Update()
    if not self.Enabled then return end
    local CameraCFrame = Camera.CFrame
    self.Viewmodel.HumanoidRootPart.CFrame = CameraCFrame
end

-- On character added
function ViewmodelProfile:onCharacterAdded(Character)
	self.Character = Character
end

-- Destructor
function ViewmodelProfile:Destroy()
    self.Enabled = false
    self.onCharacterAddedConnection:Disconnect()
    self.UpdateConnection:Disconnect()
    self:DestroyViewmodel()
	for i,_ in pairs(self) do
		self[i] = nil
	end
	for i,_ in pairs(getmetatable(self)) do
		getmetatable(self)[i] = nil
	end
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