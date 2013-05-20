module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")

Bullet = { pixels = {} }

-- Constructor
-- Requires object with game parametres
function Bullet:new(o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

local function onCollision(self, event)
    if event.other.myName == "brick" then
        self:removeSelf()
        event.other.myName = "n"
        -- if game.vibrateOn then
        system.vibrate()
        -- end
        table.insert(Memmory.timerStash, timer.performWithDelay( 10, function() 
                -- physics.removeBody(event.other)
                event.other.bodyType = "dynamic"
                event.other:setLinearVelocity( 100, 100 )
                -- event.other:applyTorque( 100 )
                local that = event.other
                -- do we need memmory management here?
                table.insert(Memmory.timerStash, timer.performWithDelay(3000, function()
                        display.remove(event.other)
                        -- that:removeSelf()
                    end))
            end))
        self.state = "removed"
        event.other.state = "removed"
    end
end

local function createCannonBallPixel(x, y, pixel)
    local result = display.newRect(x, y, pixel, pixel)
    result.myName = "cannonball"
    result.strokeWidth = 1
    result:setFillColor(26, 55, 37)
    result:setStrokeColor(26, 55, 37)
    Memmory.trackPhys(result); physics.addBody(result, { density = 100, friction = 0, bounce = 0 })
    result.isBullet = true
    return result
end

function Bullet:fireBullet(x, y, dx, dy)
    local cbp1 = createCannonBallPixel(x, y, self.game.pixel)
    local cbp2 = createCannonBallPixel(x + self.game.pixel, y, self.game.pixel)
    local cbp3 = createCannonBallPixel(x, y + self.game.pixel, self.game.pixel)
    local cbp4 = createCannonBallPixel(x + self.game.pixel, y + self.game.pixel, self.game.pixel)
    cbp1.collision = onCollision
    cbp1:addEventListener("collision", cbp1)
    cbp2.collision = onCollision
    cbp2:addEventListener("collision", cbp2)
    cbp3.collision = onCollision
    cbp3:addEventListener("collision", cbp3)
    cbp4.collision = onCollision
    cbp4:addEventListener("collision", cbp4)
    table.insert(self.pixels, cbp1)
    table.insert(self.pixels, cbp2)
    table.insert(self.pixels, cbp3)
    table.insert(self.pixels, cbp4)
    self.game.world:insert(cbp1)
    self.game.world:insert(cbp2)
    self.game.world:insert(cbp3)
    self.game.world:insert(cbp4)
    local joint1 = physics.newJoint("weld", cbp1, cbp2, x + self.game.pixel, y + self.game.pixel)
    local joint2 = physics.newJoint("weld", cbp2, cbp3, x + self.game.pixel, y + self.game.pixel)
    local joint3 = physics.newJoint("weld", cbp3, cbp4, x + self.game.pixel, y + self.game.pixel)
    local joint4 = physics.newJoint("weld", cbp4, cbp1, x + self.game.pixel, y + self.game.pixel)
    --local force = 450
    --local force = 750
    local force = 1650
    cbp1:applyForce(dx * force, -dy * force, x, y)
    cbp2:applyForce(dx * force, -dy * force, x + self.game.pixel, y + self.game.pixel)
    cbp3:applyForce(dx * force, -dy * force, x + self.game.pixel, y + self.game.pixel)
    cbp4:applyForce(dx * force, -dy * force, x + self.game.pixel, y + self.game.pixel)
end

function Bullet:getX()
    self.xCount = 0
    self.xSum = 0
    for i, v in ipairs(self.pixels) do
        if (v ~= nil and v.state ~= "removed") then
            self.xCount = self.xCount + 1
            self.xSum = self.xSum + v.x
        end
    end
    if (self.xCount ~= 0) then
        return self.xSum /self.xCount
    else
        return nil
    end
end

function Bullet:getY()
    self.yCount = 0
    self.ySum = 0
    for i, v in ipairs(self.pixels) do
        if (v ~= nil and v.state ~= "removed") then
            self.yCount = self.yCount + 1
            self.ySum = self.ySum + v.y
        end
    end
    if (self.yCount ~= 0) then
        return self.ySum / self.yCount
    else
        return nil
    end
end

function Bullet:remove()
    for i, v in ipairs(self.pixels) do
        self.pixels[i] = nil
    end
end

function Bullet:isAlive()
    local atleastOnePixel = false
    for i, v in ipairs(self.pixels) do
        if (v.state ~= "removed") then
            atleastOnePixel = true
            break
        end
    end
    if ((not atleastOnePixel) or self:getX() > self.game.levelWidth * self.game.pixel or self:getX() < 0 or self:getY() > self.game.levelHeight * self.game.pixel) then
        return false
    else
        return true
    end
end
