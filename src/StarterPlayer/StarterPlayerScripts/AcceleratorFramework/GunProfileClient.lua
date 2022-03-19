local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorageFolder = ReplicatedStorage:WaitForChild("AcceleratorFramework")
local GunResourcesHandler = require(ReplicatedStorageFolder:WaitForChild("Modules"):WaitForChild("GunResourcesHandler"))
local GunProfileClient = {}

-- Properties
GunProfileClient.Player = nil
GunProfileClient.Character = nil
GunProfileClient.GunName = ""
GunProfileClient.Parent = {}
GunProfileClient.ViewmodelOffset = CFrame.new()
GunProfileClient.RemoteEvent = nil
GunProfileClient.Animations = {}
GunProfileClient.RecoilPattern = {}
GunProfileClient.RecoilSpring = nil
GunProfileClient.Curshot = 0
GunProfileClient.LastClick = tick()
GunProfileClient.RecoilReset = 2

-- Initiate
function GunProfileClient:Initiate()
	local RecoilPattern, ViewmodelOffset, RemoteEvent, Metadata, Sounds, Particles, Animations, Model, Shell = GunResourcesHandler:GetGunRecources(self.GunName)
	self.RecoilPattern = RecoilPattern
	self.ViewmodelOffset = ViewmodelOffset
	self.RemoteEvent = RemoteEvent
	self:LoadAnimations(Animations.Viewmodel)
end

-- Load animations
function GunProfileClient:LoadAnimations(Animations)
	local Viewmodel = self.Parent.ViewmodelProfile.Viewmodel
	local AnimationController = Viewmodel.AnimationController
	for _,v in pairs(Animations:GetChildren()) do
		if v:IsA("Animation") then
			self.Animations[v.Name] = AnimationController:LoadAnimation(v)
		end
	end
end

-- Equip
function GunProfileClient:Equip()
	local Model = GunResourcesHandler:GetResource(self.GunName, "Models")
	local Sounds = GunResourcesHandler:GetResource(self.GunName, "Sounds")
	local Particles = GunResourcesHandler:GetResource(self.GunName, "Particles")
	Model = self:BuildModel(Model, Sounds, Particles)
	self:WeldGunModelToViewmodel(Model)
	self.Animations.Idle:Play()
	self.Parent.ViewmodelProfile.ViewmodelOffset = self.ViewmodelOffset
	self.Animations.Equip:Play()
end

-- Weld gun model to viewmodel
function GunProfileClient:WeldGunModelToViewmodel(Model)
	local Viewmodel = self.Parent.ViewmodelProfile.Viewmodel
	local Handle = Model.GunComponents.Handle
	local HandleMotor = Viewmodel.HumanoidRootPart:FindFirstChild("Handle") or Instance.new("Motor6D")
	HandleMotor.Name = "Handle"
	HandleMotor.Parent = Viewmodel.HumanoidRootPart
	HandleMotor.Part0 = Viewmodel.HumanoidRootPart
	HandleMotor.Part1 = Handle
	Model.Parent = Viewmodel
	Viewmodel.Parent = game.Workspace.CurrentCamera
end

-- Break gun model to viewmodel weld
function GunProfileClient:BreakdGunModelWeldToViewmodel()
	local Viewmodel = self.Parent.ViewmodelProfile.Viewmodel
	local HandleMotor = Viewmodel.HumanoidRootPart:FindFirstChild("Handle")
	local GunModel = Viewmodel:FindFirstChild(self.GunName)
	if HandleMotor then
		HandleMotor:Destroy()
	end
	if GunModel then
		GunModel:Destroy()
	end
end

-- Builds the model which to be placed in the player character
function GunProfileClient:BuildModel(Model, Sounds, Particles)
	local Handle = Model:WaitForChild("GunComponents"):WaitForChild("Handle")
	-- Sounds
	for _,v in pairs(Sounds:GetChildren()) do
		v.Parent = Model.GunComponents.Handle
	end
	-- Particle emitters
	for _,v in pairs(Particles:GetChildren()) do
		v.Parent = Model.GunComponents.Barrel
	end
	for _,v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	-- Welding gun components (not animateable)
	for _,v in pairs(Model.GunComponents:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			local Weld = Instance.new("Weld")
			Weld.Name = v.Name
			Weld.Part0 = Handle
			Weld.Part1 = v
			Weld.C0 = Weld.Part0.CFrame:Inverse() * Weld.Part1.CFrame
			Weld.Parent = Handle
		end
	end
	-- Welding gun parts (animateable)
	for _,v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			local Motor = Instance.new("Motor6D")
			Motor.Name = v.Name
			Motor.Part0 = Handle
			Motor.Part1 = v
			Motor.C0 = Motor.Part0.CFrame:Inverse() * Motor.Part1.CFrame
			Motor.Parent = Handle
		end
	end
	return Model
end

-- Constructor
function GunProfileClient:New(Metadata)
	Metadata = Metadata or {}
	setmetatable(Metadata, GunProfileClient)
	GunProfileClient.__index = GunProfileClient
	return Metadata
end

return GunProfileClient