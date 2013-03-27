module(..., package.seeall)

Bullet = { pixels = {} }



-- Constructor
-- Requires object with game, world and display parametres
function Bullet:new(o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

local function createCannonBallPixel(x, y, self)
    local result = display.newRect(x, y, self.game.pixel, self.game.pixel)
    result.myName = "cannonball"
    result.strokeWidth = 1
    result:setFillColor(26, 55, 37)
    result:setStrokeColor(26, 55, 37)
    physics.addBody(result, {density = 100, friction = 0, bounce = 0})
    result.isBullet = true
    return result
end

function Bullet:fireBullet(x, y, dx, dy)
    local cbp1 = createCannonBallPixel(x, y)
    local cbp2 = createCannonBallPixel(x + self.game.pixel, y)
    local cbp3 = createCannonBallPixel(x, y + self.game.pixel)
    local cbp4 = createCannonBallPixel(x + self.game.pixel, y + self.game.pixel)
    table.insert(self.pixels, cbp1)
    table.insert(self.pixels, cbp2)
    table.insert(self.pixels, cbp3)
    table.insert(self.pixels, cbp4)
    self.world:insert(cbp1)
    self.world:insert(cbp2)
    self.world:insert(cbp3)
    self.world:insert(cbp4)
    local joint1 = physics.newJoint( "weld", cbp1, cbp2, x + self.game.pixel, y + self.game.pixel)
    local joint2 = physics.newJoint( "weld", cbp2, cbp3, x + self.game.pixel, y + self.game.pixel)
    local joint3 = physics.newJoint( "weld", cbp3, cbp4, x + self.game.pixel, y + self.game.pixel)
    local joint4 = physics.newJoint( "weld", cbp4, cbp1, x + self.game.pixel, y + self.game.pixel)
    cbp1:applyForce(dx * 750, - dy * 750, x, y)
    cbp2:applyForce(dx * 750, - dy * 750, x + self.game.pixel, y + self.game.pixel)
    cbp3:applyForce(dx * 750, - dy * 750, x + self.game.pixel, y + self.game.pixel)
    cbp4:applyForce(dx * 750, - dy * 750, x + self.game.pixel, y + self.game.pixel)
end

function Bullet:getX()
    self.xCount = 0
    self.xSum = 0
    for i,v in ipairs(self.pixels) do
        if(v ~= nil) then
            self.xCount = self.xCount + 1
            self.xSum = self.xSum + v.x
        end
    end
    if(self.xCount ~= 0) then
        return self.xCount / self.xSum
    else
        return nil
    end
end

function Bullet:getY()
    self.yCount = 0
    self.ySum = 0
    for i,v in ipairs(self.pixels) do
        if(v ~= nil) then
            self.yCount = self.yCount + 1
            self.ySum = self.ySum + v.y
        end
    end
    if(self.yCount ~= 0) then
        return self.yCount / self.ySum
    else
        return nil
    end
end

function Bullet:remove()
    for i,v in ipairs(self.pixels) do
        self.pixels[i] = nil
    end
    self.listener()
end

local function onCollision(event, self)
    if (event.object1.myName == "brick" or event.object2.myName == "brick") then
        event.object1.state = "removed"
        event.object2.state = "removed"
        event.object1:removeSelf()
        event.object2:removeSelf()
        if(table.getn(self.pixels) == 0) then
            self.listener()
        end
    end
end