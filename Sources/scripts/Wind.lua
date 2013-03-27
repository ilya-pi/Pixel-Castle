module(..., package.seeall)

physics = require("physics")

Wind = {}

-- Constructor
function Wind:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.speed = 0
    o.text = display.newText( o.speed, o.x, o.y, native.systemFont, 20) --todo change font
    o.text:setTextColor(0, 0, 0)
    return o
end

function Wind:update()
    self.speed = math.random(-5, 5)
    physics.setGravity(self.speed, 9.8)
    self.text.text = self.speed
end

--[[
function Wind:render()
    self.text.text = self.speed
end]]
