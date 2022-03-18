local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local Viewmodel_Prototype = ReplicatedStorageFolder:WaitForChild("GunResources"):WaitForChild("Viewmodel")
local Spring = require(ReplicatedStorageFolder:WaitForChild("Modules"):WaitForChild("Spring"))

local ViewmodelProfile = {}

-- Properties
ViewmodelProfile.Player = nil
ViewmodelProfile.Character = nil
ViewmodelProfile.Viewmodel = nil
ViewmodelProfile.Enabled = false
ViewmodelProfile.BobSpring = {}
ViewmodelProfile.SwaySpring = {}
ViewmodelProfile.StrafeSpring = {}
ViewmodelProfile.onCharacterAddedConnection = nil
ViewmodelProfile.UpdateConnection = nil

-- Starter function to assemble the whole profile for functionality
function ViewmodelProfile:Initiate()
    self.onCharacterAddedConnection = self.Player.CharacterAdded:Connect(function(Character)
		self:onCharacterAdded(Character)
	end)
    self.Character = self.Player.Character
    self.BobSpring = Spring:New()
    self.SwaySpring = Spring:New({Speed = 5})
    self.StrafeSpring = Spring:New({Speed = 8})
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
function ViewmodelProfile:Update(DeltaTime)
    if not self.Enabled then return end
    local CameraCFrame = Camera.CFrame
    local ViewmodelHumanoidRootPart = self.Viewmodel.HumanoidRootPart
    if not self.Character then
        return
    end
    if not self.Character:FindFirstChildOfClass("Humanoid") then
        return
    end
    local CharacterHumanoid = self.Character:FindFirstChildOfClass("Humanoid")
    local CharacterHumanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
    local Bobble = self:UpdateBob(DeltaTime, CharacterHumanoidRootPart)
    local Sway = self:UpdateSway(DeltaTime)
    local Strafe = self:UpdateStrafe(DeltaTime, CharacterHumanoid, CharacterHumanoidRootPart)
    ViewmodelHumanoidRootPart.CFrame = CameraCFrame
    ViewmodelHumanoidRootPart.CFrame = ViewmodelHumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(Bobble.X * 0.7, Bobble.Y * 0.7, 0))
    ViewmodelHumanoidRootPart.CFrame = ViewmodelHumanoidRootPart.CFrame * CFrame.Angles(Bobble.X * 0.1, Bobble.Y * 0.5, 0)
    ViewmodelHumanoidRootPart.CFrame = ViewmodelHumanoidRootPart.CFrame * CFrame.Angles(Sway.Y, Sway.X, Sway.Z)
    ViewmodelHumanoidRootPart.CFrame = ViewmodelHumanoidRootPart.CFrame * CFrame.fromEulerAnglesYXZ(math.rad(Strafe.X), 0, math.rad(Strafe.Z))
end

-- Bob viewmodel
function ViewmodelProfile:UpdateBob(DeltaTime, CharacterHumanoidRootPart)
    local Speed = 8
	local Modifier = 0.1
    local BobValue = math.sin(tick() * Speed) * Modifier
    local BobSpringShove = Vector3.new(BobValue, BobValue, BobValue)
    self.BobSpring:shove((BobSpringShove / 25) * DeltaTime * 60 * CharacterHumanoidRootPart.AssemblyLinearVelocity.Magnitude)
    local Bobble = self.BobSpring:update(DeltaTime)
    return Bobble
end

-- Sway viewmodel
function ViewmodelProfile:UpdateSway(DeltaTime)
    local MouseDelta = UserInputService:GetMouseDelta()
    self.SwaySpring:shove(Vector3.new(MouseDelta.X / 200, MouseDelta.Y / 150))
    local Sway = self.SwaySpring:update(DeltaTime)
    return Sway
end

-- Strafe viewmodel
function ViewmodelProfile:UpdateStrafe(DeltaTime, CharacterHumanoid, CharacterHumanoidRootPart)
    local StrafeValue = -CharacterHumanoidRootPart.CFrame.RightVector:Dot(CharacterHumanoid.MoveDirection)
    local JumpValue = -CharacterHumanoidRootPart.CFrame.UpVector:Dot(CharacterHumanoidRootPart.Velocity)
    self.StrafeSpring:shove(Vector3.new(JumpValue * 0.3, 0, StrafeValue * 4))
    local Strafe = self.StrafeSpring:update(DeltaTime)
    return Strafe
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