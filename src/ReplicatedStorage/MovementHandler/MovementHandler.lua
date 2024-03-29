local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local ReplicatedStorageDirectory = script.Parent
local AnimationFolder = ReplicatedStorageDirectory:WaitForChild("Animations")

local MovementHandler = {
	-- resources
	ReplicatedStorageDirectory = ReplicatedStorageDirectory,
	AnimationFolder = AnimationFolder,
	State = ReplicatedStorageDirectory:WaitForChild("State"),
	HumanoidState = ReplicatedStorageDirectory:WaitForChild("HumanoidState"),

	-- player
	Player = nil,
	Character = nil,
	Humanoid = nil,
	Animator = nil,

	-- camera offset tweens
	CameraOffsetTweens = {
		Default = nil,
		Crouch = nil,
		Prone = nil,
		Slide = nil
	},

	-- Movement states
	States = {
		Sprinting = false,
		Crouching = false,
		Proning = false,
		Sliding = false
	},

	Configurations = {
		WalkSpeed = 16,
		SprintSpeed = 30,
		CrouchSpeed = 6,
		ProneSpeed = 4
	},

	Animations = {
		CrouchIdle = AnimationFolder.CrouchIdle,
		CrouchWalk = AnimationFolder.CrouchWalk,
		ProneIdle = AnimationFolder.ProneIdle,
		ProneWalk = AnimationFolder.ProneWalk,
		Slide = AnimationFolder.Slide
	},

	AnimationTracks = {
		CrouchIdle = nil,
		CrouchWalk = nil,
		ProneIdle = nil,
		ProneWalk = nil,
		Slide = nil
	}
}

function MovementHandler:New(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

function MovementHandler:Initiate()
	-- Character added, reset stuff
	self.Player.CharacterAdded:Connect(function(Model)
		self:CharacterAdded(Model)
	end)
	self:GetPlayerInput()
end

-- Charcater added
function MovementHandler:CharacterAdded(Model)
	-- Local player
	self.Humanoid = Model:WaitForChild("Humanoid")
	self.Character = Model
	self.Animator = self.Humanoid:FindFirstChildOfClass("Animator")

	-- Load animation tracks
	self:LoadAnimationTracks()

	-- Humanoid events
	self.Humanoid.StateChanged:Connect(function(OldState, NewState)
		self:HumanoidStateChanged(OldState, NewState)
	end)
	self.Humanoid.Running:Connect(function(Speed)
		self:HumanoidRunning(Speed)
	end)
	self.Humanoid.Jumping:Connect(function(Jumping)
		self:HumanoidJumping(Jumping)
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

-- reset camera offset tweens
function MovementHandler:ResetCameraOffsetTweens()
	self.CameraOffsetTweens.Default = TweenService:Create(self.Humanoid, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CameraOffset = Vector3.new(0, 0, 0)})
	self.CameraOffsetTweens.Crouch = TweenService:Create(self.Humanoid, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CameraOffset = Vector3.new(0, -1, 0)})
	self.CameraOffsetTweens.Prone = TweenService:Create(self.Humanoid, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CameraOffset = Vector3.new(0, -3, 0)})
	self.CameraOffsetTweens.Slide = TweenService:Create(self.Humanoid, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {CameraOffset = Vector3.new(0, -2, 0)})
end

-- Lerp
function MovementHandler:Lerp(a, b, t)
	return a * (1 - t) + (b * t)
end

-- Humanoid state changed
function MovementHandler:HumanoidStateChanged(_, NewState)
	self.HumanoidState.Value = tostring(NewState)
end

-- Humanoid running
function MovementHandler:HumanoidRunning(Speed)
	-- Crouching
	if Speed == 0 then
		self.AnimationTracks.CrouchWalk:Stop()
	elseif self.States.Crouching == true and self.AnimationTracks.CrouchWalk.IsPlaying == false then
		self.AnimationTracks.CrouchWalk:Play()
		self.AnimationTracks.CrouchWalk:AdjustSpeed(Speed / self.AnimationTracks.CrouchWalk.Length)
	end

	-- Prone
	if Speed == 0 then
		self.AnimationTracks.ProneWalk:Stop()
	elseif self.States.Proning == true and self.AnimationTracks.ProneWalk.IsPlaying == false then
		self.AnimationTracks.ProneWalk:Play()
		self.AnimationTracks.ProneWalk:AdjustSpeed(Speed / self.AnimationTracks.ProneWalk.Length)
	end
end

-- Humnanoid jumping
function MovementHandler:HumanoidJumping(Jumping)
	if Jumping == true then
		if self.States.Crouching == true then
			self:Crouch(Enum.UserInputState.End)
			self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed
		end
		if self.States.Proning == true then
			self:Prone(Enum.UserInputState.End)
			self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed
		end
	end
end

-- Sprint
function MovementHandler:Sprint(State)
	if State == Enum.UserInputState.Begin then
		-- If the player is crouching, cancel the crouch
		if self.States.Crouching then
			self:Crouch(Enum.UserInputState.End)
		end

		-- If the player is proning, cancel the prone
		if self.States.Proning then
			self:Prone(Enum.UserInputState.End)
		end

		-- If the player is sliding, don't change the State
		if not self.States.Sliding then
			self.State.Value = "Sprinting"
		end

		self.States.Sprinting = true
		self.Humanoid.WalkSpeed = self.Configurations.SprintSpeed
	else
		self.States.Sprinting = false
		self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed

		-- Don't change the state if the player is sliding
		if not self.States.Sliding then
			self.State.Value = ""
		end
	end
end

-- Crouch
function MovementHandler:Crouch(State)
	if State == Enum.UserInputState.Begin then
		if self.States.Proning then
			self:Prone(Enum.UserInputState.End)
		end

		self.State.Value = "Crouching"
		self.States.Crouching = true
		self.AnimationTracks.CrouchIdle:Play()
		self.CameraOffsetTweens.Crouch:Play()
		self.Humanoid.WalkSpeed = self.Configurations.CrouchSpeed
	else
		self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed
		self.State.Value = ""
		self.States.Crouching = false
		self.AnimationTracks.CrouchIdle:Stop()
		self.AnimationTracks.CrouchWalk:Stop()
		self.CameraOffsetTweens.Default:Play()
	end
end

-- Prone
function MovementHandler:Prone(State)
	if State == Enum.UserInputState.Begin then
		self:Crouch(Enum.UserInputState.End)
		self.State.Value = "Proning"
		self.States.Proning = true
		self.AnimationTracks.ProneIdle:Play()
		self.CameraOffsetTweens.Prone:Play()
		self.Humanoid.WalkSpeed = self.Configurations.ProneSpeed
	else
		self.Humanoid.WalkSpeed = self.Configurations.WalkSpeed
		self.State.Value = ""
		self.States.Proning = false
		self.AnimationTracks.ProneIdle:Stop()
		self.AnimationTracks.ProneWalk:Stop()
		self.CameraOffsetTweens.Default:Play()
	end
end

-- Slide
function MovementHandler:Slide(State)
	local HumanoidRootPart = self.Character.HumanoidRootPart
	local JumpPower = self.Humanoid.JumpPower
	local JumpHeight = self.Humanoid.JumpHeight
	local num = 0

	self.State.Value = "Slide"
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
	self.State.Value = ""
	self.States.Sliding = false
	self.AnimationTracks.Slide:Stop()
	self.CameraOffsetTweens.Default:Play()

	if self.States.Sprinting == true then
		self:Sprint(Enum.UserInputState.Begin)
	end
end

-- Process player input
function MovementHandler:ProcessInput(ActionName, InputState, InputObject)
	if InputObject.KeyCode == Enum.KeyCode.LeftShift then
		self:Sprint(InputState)
	end

	if InputObject.KeyCode == Enum.KeyCode.C and InputState == Enum.UserInputState.Begin and self.States.Sliding == false then
		if self.States.Sprinting then
			self:Slide(InputState)
		else
			if self.States.Crouching then
				self:Crouch(Enum.UserInputState.End)
				-- self:Prone(InputState)
			else
				self:Crouch(InputState)
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