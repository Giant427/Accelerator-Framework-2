local WorkspaceFolder = workspace:WaitForChild("AcceleratorFramework")
local CharacterUpdateFolder = Instance.new("Folder")
CharacterUpdateFolder.Name = "CharacterUpdate"
CharacterUpdateFolder.Parent = WorkspaceFolder

local CharacterUpdateHandler = {}

-- Add players character to update
function CharacterUpdateHandler:Add(player)
    local TiltPart
    local BodyPos
    local Enabled

    local NeckC0
    local RightShoulderC0
	local LeftShoulderC0
	local UpperTorsoC0

    -- Tilt Part
    TiltPart = Instance.new("Part")
    TiltPart.Size = Vector3.new(.1, .1, .1)
    TiltPart.Transparency = 1
    TiltPart.CanCollide = false
    TiltPart.Name = player.Name
    TiltPart.Parent = CharacterUpdateFolder

    -- Body Position
    BodyPos = Instance.new("BodyPosition")
    BodyPos.D = 5000
    BodyPos.P = 1000000
    BodyPos.MaxForce = Vector3.new(1000000,1000000,1000000)
    BodyPos.Parent = TiltPart

    -- Enabled
    Enabled = Instance.new("BoolValue")
    Enabled.Name = "Enabled"
    Enabled.Value = false
    Enabled.Parent = TiltPart

    -- Offset Values
    NeckC0 = Instance.new("CFrameValue")
    NeckC0.Name = "NeckC0"
    NeckC0.Parent = TiltPart

    RightShoulderC0 = Instance.new("CFrameValue")
    RightShoulderC0.Name = "RightShoulderC0"
    RightShoulderC0.Parent = TiltPart

    LeftShoulderC0 = Instance.new("CFrameValue")
    LeftShoulderC0.Name = "LeftShoulderC0"
    LeftShoulderC0.Parent = TiltPart

    UpperTorsoC0 = Instance.new("CFrameValue")
    UpperTorsoC0.Name = "UpperTorsoC0"
    UpperTorsoC0.Parent = TiltPart

    -- Character Added
    player.CharacterAdded:Connect(function(character)
        repeat
            task.wait()
        until character:FindFirstChildOfClass("Humanoid")
        NeckC0.Value = character:WaitForChild("Head"):WaitForChild("Neck").C0
        RightShoulderC0.Value = character:WaitForChild("RightUpperArm"):WaitForChild("RightShoulder").C0
		LeftShoulderC0.Value = character:WaitForChild("LeftUpperArm"):WaitForChild("LeftShoulder").C0
		UpperTorsoC0.Value = character:WaitForChild("UpperTorso"):WaitForChild("Waist").C0
        Enabled.Value = true
    end)
end

-- Remove players character to update
function CharacterUpdateHandler:Remove(player)
    local TiltPart = CharacterUpdateFolder:FindFirstChild(player.Name)
    if not TiltPart then return end
    TiltPart:Destroy()
end

-- Update players character
function CharacterUpdateHandler:Update(player)
    local TiltPart = CharacterUpdateFolder:FindFirstChild(player.Name)

    if not TiltPart then
        return
    end

    if not TiltPart.Enabled.Value == true then return end

    if not player.Character then
        warn("Character does not exist for player: "..player.Name)
        TiltPart.Enabled.Value = false
        return
    end

    local Value = CFrame.Angles(math.asin(TiltPart.Position.Y) * 0.5, 0, 0)

    -- Neck
    local Head = player.Character:FindFirstChild("Head")
    local Neck

    if Head then
        Neck = Head:FindFirstChild("Neck")
    end

    local NeckC0 = TiltPart:FindFirstChild("NeckC0").Value

    if Neck then
        Neck.C0 = NeckC0 * Value
    end

    -- Right Shoulder
    local RightUpperArm = player.Character:FindFirstChild("RightUpperArm")
    local RightShoulder

    if RightUpperArm then
        RightShoulder = RightUpperArm:FindFirstChild("RightShoulder")
    end

    local RightShoulderC0 = TiltPart:FindFirstChild("RightShoulderC0").Value

    if RightShoulder then
        RightShoulder.C0 = RightShoulderC0 * Value
    end

    -- Left Shoulder
    local LeftUpperArm = player.Character:FindFirstChild("LeftUpperArm")
    local LeftShoulder

    if LeftUpperArm then
        LeftShoulder = LeftUpperArm:FindFirstChild("LeftShoulder")
    end

    local LeftShoulderC0 = TiltPart:FindFirstChild("LeftShoulderC0").Value

    if LeftShoulder then
        LeftShoulder.C0 = LeftShoulderC0 * Value
    end

	-- Upper Torso
    local UpperTorso = player.Character:FindFirstChild("UpperTorso")
    local Waist

    if UpperTorso then
        Waist = UpperTorso:FindFirstChild("Waist")
    end

    local UpperTorsorC0 = TiltPart:FindFirstChild("UpperTorsoC0").Value

    if Waist then
        Waist.C0 = UpperTorsorC0 * Value
    end
end

-- Update players tilt part
function CharacterUpdateHandler:UpdateTPart(player,CameraCFrame)
    local TiltPart = CharacterUpdateFolder:FindFirstChild(player.Name)

    if not TiltPart then return end

    local BodyPosition = TiltPart:FindFirstChildOfClass("BodyPosition")

    if not BodyPosition then return end

    local Character = player.Character

    if not Character then return end

    BodyPosition.Position = Character.HumanoidRootPart.CFrame:toObjectSpace(CameraCFrame).LookVector
end

return CharacterUpdateHandler
