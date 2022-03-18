local ObjectCreator = {}
local Objects = script.Parent:WaitForChild("Objects")

-- Objects
local PlayerProfile = Objects:WaitForChild("PlayerProfile")
local Rjac = require(Objects:WaitForChild("Rjac"))
local GunProfileServer = require(Objects:WaitForChild("GunProfileServer"))

-- Creating player profile
function ObjectCreator:CreatePlayerProfile(Player)
    local ProfileInfo = {}
    ProfileInfo.Player = Player
    local Profile = require(PlayerProfile):New(ProfileInfo)
    return Profile
end

-- Creating rjac profile
function ObjectCreator:CreateRjacProfile(Player)
    local ProfileInfo = {}
    ProfileInfo.Player = Player
    local Profile = Rjac:New(ProfileInfo)
    return Profile
end

-- Creating gun profile server
function ObjectCreator:CreateGunProfileServer(Metadata)
    local Profile = GunProfileServer:New(Metadata)
    return Profile
end

return ObjectCreator