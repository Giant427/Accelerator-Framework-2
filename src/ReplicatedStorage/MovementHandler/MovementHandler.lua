--[[
	Made by: GiantDefender427

	Devforum Post: https://devforum.roblox.com/t/movementhandler-crouch-sprint-slide-prone/1539379

	Accelerator Framework version
]]

-- Service dependencies
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

----------------------
-- MOVEMENT HANDLER --
----------------------

local MovementHandler = {}

-- Properties

-- Reourses
do
	MovementHandler.ReplicatedStorageDirectory = game.ReplicatedStorage:WaitForChild("MovementHandler")
	MovementHandler.AnimationFolder = MovementHandler.ReplicatedStorageDirectory:WaitForChild("Animations")
	MovementHandler.MovementState = MovementHandler.ReplicatedStorageDirectory:WaitForChild("MovementState")
	MovementHandler.HumanoidState = MovementHandler.ReplicatedStorageDirectory:WaitForChild("HumanoidState")
end

-- Local player
do
	MovementHandler.Player = nil
	MovementHandler.Character = nil
	MovementHandler.Humanoid = nil
	MovementHandler.Animator = nil
end

-- Camera offset tweens
do
	MovementHandler.CameraOffsetTweens = {}
	MovementHandler.CameraOffsetTweens.Default = nil
	MovementHandler.CameraOffsetTweens.Crouch = nil
	MovementHandler.CameraOffsetTweens.Prone = nil
	MovementHandler.CameraOffsetTweens.Slide = nil
end

-- States
do
	MovementHandler.States = {}
	MovementHandler.States.Sprinting = false
	MovementHandler.States.Crouching = false
	MovementHandler.States.Proning = false
	MovementHandler.States.Sliding = false
end

-- Configurations
do
	MovementHandler.Configurations = {}
	MovementHandler.Configurations.WalkSpeed = 16
	MovementHandler.Configurations.SprintSpeed = 30
	MovementHandler.Configurations.CrouchSpeed = 6
	MovementHandler.Configurations.ProneSpeed = 4
end

-- Animations
do
	MovementHandler.Animations = {}
	MovementHandler.Animations.CrouchIdle = MovementHandler.AnimationFolder.CrouchIdle
	MovementHandler.Animations.CrouchWalk = MovementHandler.AnimationFolder.CrouchWalk
	MovementHandler.Animations.ProneIdle = MovementHandler.AnimationFolder.ProneIdle
	MovementHandler.Animations.ProneWalk = MovementHandler.AnimationFolder.ProneWalk
	MovementHandler.Animations.Slide = MovementHandler.AnimationFolder.Slide
end

-- Animation tracks
do
	MovementHandler.AnimationTracks = {}
	MovementHandler.AnimationTracks.CrouchIdle = nil
	MovementHandler.AnimationTracks.CrouchWalk = nil
	MovementHandler.AnimationTracks.ProneIdle = nil
	MovementHandler.AnimationTracks.ProneWalk = nil
	MovementHandler.AnimationTracks.Slide = nil
end

-- Functions

-- Lerp
function MovementHandler:Lerp(a, b, t)
	return a * (1 - t) + (b * t)
end

-- Starter function to assemble the whole profile for functionality --
function MovementHandler:Initiate()
	self.Character = self.Player.Character

	-- On character added
	self.Player.CharacterAdded:Connect(function(Model)
		self:onCharacterAdded(Model)
	end)

	-- Get player input duhh
	self:GetPlayerInput()
end

-- On character added
function MovementHandler:onCharacterAdded(Model)
	-- Character properties
	self.Humanoid = Model:WaitForChild("Humanoid")
	self.Character = Model
	self.Animator = self.Humanoid:FindFirstChildOfClass("Animator")

	-- Reload animations
	self:LoadAnimationTracks()

	-- Reset humanoid event listeners
	self.Humanoid.StateChanged:Connect(function(OldState, NewState)
		self:onHumanoidStateChanged(OldState, NewState)
	end)
	self.Humanoid.Running:Connect(function(Speed)
		self:onHumanoidRunning(Speed)
	end)
	self.Humanoid.Jumping:Connect(function(Jumping)
		self:onHumanoidJumping(Jumping)
	end)

	-- Reset camera offset tweens
	self:ResetCameraOffsetTweens()
end

-- Load animations
function MovementHandler:LoadAnimationTracks()
	self.AnimationTracks.CrouchIdle = self.Animator:LoadAnimation(self.Animations.CrouchIdle)
	self.AnimationTracks.CrouchWalk = self.Animator:LoadAnimation(self.Animations.CrouchWalk)
	self.AnimationTracks.ProneIdle = self.Animator:LoadAnimation(self.Animations.ProneIdle)
	self.AnimationTracks.ProneWalk = self.Animator:LoadAnimation(self.Animations.ProneWalk)
	self.AnimationTracks.Slide = self.Animator:LoadAnimation(self.Animations.Slide)
end

-- Reset camera offset tweens
function MovementHandler:ResetCameraOffsetTweens()
	self.CameraOffsetTweens.Default = TweenService:Create(self.Humanoid, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CameraOffset = Vector3.new(0, 0, 0)})
	self.CameraOffsetTweens.Crouch = TweenService:Create(self.Humanoid, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CameraOffset = Vector3.new(0, -1, 0)})
	self.CameraOffsetTweens.Prone = TweenService:Create(self.Humanoid, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CameraOffset = Vector3.new(0, -3, 0)})
	self.CameraOffsetTweens.Slide = TweenService:Create(self.Humanoid, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CameraOffset = Vector3.new(0, -2, 0)})
end

-- Humanoid state changed
function MovementHandler:onHumanoidStateChanged(OldState, NewState)
	self.HumanoidState.Value = tostring(NewState)
end

-- Humanoid running
function MovementHandler:onHumanoidRunning(Speed)
	-- Crouching
	if Speed == 0 then
		self.AnimationTracks.CrouchWalk:Stop()
	elseif self.States.Crouching then
		self.AnimationTracks.CrouchWalk:Play()
		self.AnimationTracks.CrouchWalk:AdjustSpeed(Speed / self.AnimationTracks.CrouchWalk.Length)
	end

	-- Proning
	if Speed == 0 then
		self.AnimationTracks.ProneWalk:Stop()
	elseif self.States.Proning then
		self.AnimationTracks.ProneWalk:Play()
		self.AnimationTracks.ProneWalk:AdjustSpeed(Speed / self.AnimationTracks.ProneWalk.Length)
	end
end

-- Humnanoid jumping
function MovementHandler:onHumanoidJumping(Jumping)
	if Jumping then
		if self.States.Crouching then
			self:StopCrouching()
			self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed
		end
		if self.States.Proning then
			self:StopProning()
			self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed
		end
	end
end

-- Sprint
function MovementHandler:StartSprinting()
	-- If the player is crouching, cancel the crouch
	if self.States.Crouching then
		self:StopCrouching()
	end

	-- If the player is proning, cancel the prone
	if self.States.Proning then
		self:StopCrouching()
	end

	-- If the player is sliding, don't change the State
	if not self.States.Sliding then
		self.MovementState.Value = "Sprinting"
	end

	self.States.Sprinting = true
	self.Humanoid.WalkSpeed = self.Configurations.SprintSpeed
end

function MovementHandler:StopSprinting()
	self.States.Sprinting = false
	self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed

	-- Don't change the state if the player is sliding
	if not self.States.Sliding then
		self.MovementState.Value = ""
	end
end

-- Crouch
function MovementHandler:StartCrouching()
	if self.States.Proning then
		self:StopProning()
	end

	self.MovementState.Value = "Crouching"
	self.States.Crouching = true
	self.AnimationTracks.CrouchIdle:Play()
	self.CameraOffsetTweens.Crouch:Play()
	self.Humanoid.WalkSpeed = self.Configurations.CrouchSpeed
end

function MovementHandler:StopCrouching()
	self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed
	self.MovementState.Value = ""
	self.States.Crouching = false
	self.AnimationTracks.CrouchIdle:Stop()
	self.AnimationTracks.CrouchWalk:Stop()
	self.CameraOffsetTweens.Default:Play()
end

-- Prone
function MovementHandler:StartProning()
	self:StopCrouching()
	self.MovementState.Value = "Proning"
	self.States.Proning = true
	self.AnimationTracks.ProneIdle:Play()
	self.CameraOffsetTweens.Prone:Play()
	self.Humanoid.WalkSpeed = self.Configurations.ProneSpeed
end

function MovementHandler:StopProning()
	self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed
	self.MovementState.Value = ""
	self.States.Proning = false
	self.AnimationTracks.ProneIdle:Stop()
	self.AnimationTracks.ProneWalk:Stop()
	self.CameraOffsetTweens.Default:Play()
end

-- Slide
function MovementHandler:StartSliding()
	local HumanoidRootPart = self.Character.HumanoidRootPart
	local JumpPower = self.Humanoid.JumpPower
	local JumpHeight = self.Humanoid.JumpHeight
	local num = 0

	self.MovementState.Value = "Slide"
	self.States.Sliding = true
	self.AnimationTracks.Slide:Play()
	self.CameraOffsetTweens.Slide:Play()
	self.Humanoid.JumpPower = 0
	self.Humanoid.JumpHeight = 0

	while math.abs(num - 5) > 0.01 do
		num = self:Lerp(num, 5, 0.1)
		local rec = num / 10
		HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -rec)
		RunService.RenderStepped:Wait()
	end

	self.Humanoid.JumpPower = JumpPower
	self.Humanoid.JumpHeight = JumpHeight
	self.MovementState.Value = ""
	self.States.Sliding = false
	self.AnimationTracks.Slide:Stop()
	self.CameraOffsetTweens.Default:Play()

	if self.States.Sprinting then
		self:StartSprinting()
	end
end

-- Process input
function MovementHandler:ProcessInput(ActionName, InputState, InputObject)
	if InputObject.KeyCode == Enum.KeyCode.LeftShift then
		if InputState == Enum.UserInputState.Begin then
			self:StartSprinting()
		else
			self:StopSprinting()
		end
	end

	if InputObject.KeyCode == Enum.KeyCode.C and InputState == Enum.UserInputState.Begin and self.States.Sliding == false then
		if self.States.Sprinting then
			self:StartSliding()
		else
			if self.States.Crouching then
				self:StartProning()
			else
				self:StartCrouching()
			end
		end
	end
end

-- Get player input
function MovementHandler:GetPlayerInput()
	local function PlayerInput(ActionName, InputState, InputObject)
		self:ProcessInput(ActionName, InputState, InputObject)
	end

	ContextActionService:BindAction("Sprint", PlayerInput, true, Enum.KeyCode.LeftShift)
	ContextActionService:SetTitle("Sprint", "Sprint")
	ContextActionService:SetPosition(("Sprint"), UDim2.new(1, -90, 1, -150))

	ContextActionService:BindAction("Crouch", PlayerInput, true, Enum.KeyCode.C)
	ContextActionService:SetTitle("Crouch", "Crouch")
	ContextActionService:SetPosition(("Crouch"), UDim2.new(1, -160, 1, -60))
end

return MovementHandler
