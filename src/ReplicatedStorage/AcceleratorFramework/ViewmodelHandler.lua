local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local ClientModule = require(ReplicatedStorageFolder:WaitForChild("ClientModule"))

-- Spring
local SpringModule = require(ReplicatedStorageFolder:WaitForChild("Spring"))
local SwaySpring = SpringModule:New()
local StrafeSpring = SpringModule:New()

-- Camera offset
local CameraOffset = script:FindFirstChild("CameraOffset") or Instance.new("CFrameValue")
CameraOffset.Name = "CameraOffset"
CameraOffset.Parent = script

-- bobbing stuff
local bobbingSpeed = 0.08
local sinValue = 0
local previousSineX = 0
local previousSineY = 0

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function calculateSine(speed, intensity)
	sinValue += speed
	if sinValue > (math.pi * 2) then
        sinValue = 0
    end
	local sineY = intensity * math.sin(2 * sinValue)
	local sineX = intensity * math.sin(sinValue)
	local sineCFrame = CFrame.new(sineX, sineY, 0)
	return sineCFrame
end

-- used for animating camera
local oldCamCF = CFrame.new()

local ViewmodelHandler = {
    Player = nil,
    Speed = 0.8,
    Modifier = 0.1,
    Aiming = false,
}

-- Initiate processing for Viewmodel
function ViewmodelHandler:Initiate(Player,Speed,Modifier)
    self.Player = Player
    self.Speed = Speed
    self.Modifier = Modifier

    RunService.RenderStepped:Connect(function(dt)
        self:Update(dt)
    end)
end

-- Update viewmodel
function ViewmodelHandler:Update(dt)
    local Character = self.Player.Character
    local Viewmodel = ClientModule:AccessViewmodel()
    local ClientGun = ClientModule:GetEquippedGun(self.Player)
    local HumanoidRootPart = Viewmodel.HumanoidRootPart
    local CamPart = Viewmodel.CamPart

    CameraOffset = script:FindFirstChild("CameraOffset") or Instance.new("CFrameValue")
    CameraOffset.Name = "CameraOffset"
    CameraOffset.Parent = script

    if not Character then
        return
    end

    if not Character:FindFirstChild("Humanoid") then
        return
    end

    local Velocity = Character.HumanoidRootPart.AssemblyLinearVelocity

    -- Viewmodel Positioning

    if ClientGun.Value then
        ClientGun = require(ClientGun.Value)
        HumanoidRootPart.CFrame = Camera.CFrame * ClientGun.Offset.Value
    else
        HumanoidRootPart.CFrame = Camera.CFrame
    end

    -- Animate Camera
    self:AnimateCamera(HumanoidRootPart,CamPart)

    -- Bobbing
    self:Bob(HumanoidRootPart,Character,Velocity)

    -- Strafing
    self:Strafe(HumanoidRootPart,Character,dt)

    -- Swaying
    self:Sway(dt,HumanoidRootPart)
end

-- Animate Camera
function ViewmodelHandler:AnimateCamera(HumanoidRootPart,CamPart)
    local newCamCF = CamPart.CFrame:ToObjectSpace(HumanoidRootPart.CFrame)

    if oldCamCF then
        local _,_,z = newCamCF:ToOrientation()
        local x,y,_ = newCamCF:ToObjectSpace(oldCamCF):ToEulerAnglesXYZ()
        Camera.CFrame = Camera.CFrame * CFrame.Angles(x,y, -z)
    end

    oldCamCF = newCamCF
end

-- Bobbing
function ViewmodelHandler:Bob(HumanoidRootPart,Character,Velocity)
    local movementVector = Camera.CFrame:VectorToObjectSpace(Velocity / math.max(Character.Humanoid.WalkSpeed, 0.01))
    local speedModifier = (Character.Humanoid.WalkSpeed / 16)

    local sineCFrame = calculateSine(bobbingSpeed * speedModifier, movementVector.Z * speedModifier)
    local lerpedSineX = lerp(previousSineX, sineCFrame.X, 0.03)
    local lerpedSineY = lerp(previousSineY, sineCFrame.Y, 0.03)

    HumanoidRootPart.CFrame *= CFrame.new(lerpedSineX * 0.1, lerpedSineY * 0.1, 0)
    previousSineX = lerpedSineX
    previousSineY = lerpedSineY
end

-- Strafing
function ViewmodelHandler:Strafe(HumanoidRootPart,Character,dt)
    local StrafeValue = -Character.HumanoidRootPart.CFrame.RightVector:Dot(Character.Humanoid.MoveDirection)
    local JumpValue = -Character.HumanoidRootPart.CFrame.UpVector:Dot(Character.HumanoidRootPart.Velocity)

    StrafeSpring:shove(Vector3.new(JumpValue * 0.1, 0, StrafeValue * 3))

    local Strafe = StrafeSpring:update(dt)

    HumanoidRootPart.CFrame *= CFrame.fromEulerAnglesYXZ(math.rad(Strafe.X), 0, math.rad(Strafe.Z))
end

-- Swaying
function ViewmodelHandler:Sway(dt,HumanoidRootPart)
    local MouseDelta = UserInputService:GetMouseDelta()
    SwaySpring:shove(Vector3.new(MouseDelta.X / 500, MouseDelta.Y / 500))
    local sway = SwaySpring:update(dt)
    HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(sway.Y, sway.X, sway.Z)
end

-- Humanoid State Changed
function ViewmodelHandler:HumanoidStateChanged(State)
    if State == tostring(Enum.HumanoidStateType.Jumping) then
        --SwaySpring:shove(Vector3.new(0,0.5,0))
    elseif State == tostring(Enum.HumanoidStateType.Landed) then
        --SwaySpring:shove(Vector3.new(0,-0.5,0))
    end
end

-- Viewmodel transparency
function ViewmodelHandler:Transparency(Transparency)
    local Viewmodel = ClientModule:AccessViewmodel()
    local HumanoidRootPart = Viewmodel.HumanoidRootPart
    local CamPart = Viewmodel.CamPart

    for _,v in pairs(Viewmodel:GetDescendants()) do
        if v:IsA("BasePart") and v ~= HumanoidRootPart and v ~= CamPart then
            v.Transparency = Transparency
        end
    end
end

return ViewmodelHandler