module(..., package.seeall)

EventTrack = {
    happend = {}
}

-- Constructor
function EventTrack:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function EventTrack:keep(event)        
	table.insert(self.happend, event)
end

function EventTrack:flush()
    self.happend = {}
end

function EventTrack:missed()
	for i, v in ipairs(self.happend) do
		if (v ~= nil) then
			if (v.action == "hit") then
				return false			
			end
		end
	end
	return true
end