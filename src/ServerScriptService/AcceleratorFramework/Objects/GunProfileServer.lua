local GunProfileServer = {}

-- Constructor
local GunProfileServerModule = {}
function GunProfileServerModule:New(Metadata)
	Metadata = Metadata or {}
	setmetatable(Metadata, GunProfileServer)
	GunProfileServer.__index = GunProfileServer
	return Metadata
end

return GunProfileServerModule