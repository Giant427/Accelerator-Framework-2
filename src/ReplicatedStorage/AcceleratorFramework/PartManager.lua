local PhysicsService = game:GetService("PhysicsService")

local MasterFolder = Instance.new("Folder")
MasterFolder.Name = "PartManager"
MasterFolder.Parent = workspace.AcceleratorFramework

local PartManager = {}

-- New part type
function PartManager:New(NAME, QUANTITY, PART, COLLISION_GROUP)
    if QUANTITY == 0 then return end

    if not (PART:IsA("BasePart") or PART:IsA("Model")) then return end

    if PART:IsA("Model") then
        local SanityCheckPart = PART:FindFirstChildOfClass("BasePart")
        if SanityCheckPart  then
            return
        end
    end

    local PartFolder = Instance.new("Folder")
    PartFolder.Name = NAME
    PartFolder.Parent = MasterFolder

    local Available = Instance.new("Folder")
    Available.Name = "Available"
    Available.Parent = PartFolder

    local Busy = Instance.new("Folder")
    Busy.Name = "Busy"
    Busy.Parent = PartFolder

    for i = 1,QUANTITY,1 do
        local object = PART:Clone()
        object.Parent = Available
        if PART:IsA("Model") then
            object:MoveTo(Vector3.new(0, 10e7, 0))
        else
            object.CFrame = CFrame.new(0, 10e7, 0)
        end

        for _,v in pairs(game.PhysicsService:GetCollisionGroups()) do
            if v.name == COLLISION_GROUP then
                PhysicsService:SetPartCollisionGroup(object, COLLISION_GROUP)
                break
            end
        end
    end
end

-- Get a part type
function PartManager:Get(NAME)
    local PartFolder = MasterFolder:FindFirstChild(NAME)

    if not PartFolder then return end

    local Available = PartFolder:FindFirstChild("Available")
    local Busy = PartFolder:FindFirstChild("Busy")

    if not (Available and Busy) then return end

    local Part = Available:GetChildren()[1]

    if not Part then return end

    Part.Parent = Busy

    return Part
end

-- Return a part type
function PartManager:Return(NAME, PART, ROOT_PART_WELDS)
    local PartFolder = MasterFolder:FindFirstChild(NAME)

    if not PartFolder then return end

    local Available = PartFolder:FindFirstChild("Available")

    if not Available then return end

    PART.Parent = Available

    if PART:IsA("Model") then
        if ROOT_PART_WELDS == true then
            PART.PrimaryPart.CFrame = CFrame.new(0, 10e7, 0)
        else
            PART:MoveTo(Vector3.new(0, 10e7, 0))
        end
    else
        PART.CFrame = CFrame.new(0, 10e7, 0)
    end
end

return PartManager