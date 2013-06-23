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
    if (event.other.myName == "brick") then
        --self:removeSelf()
        --event.other:removeSelf()
        if game.vibration then
            system.vibrate()
        end        
        self.state = "removed"
        event.other.state = "removed"
    end
    if event.other.myName == "brick" then
        self:removeSelf()
        event.other.myName = "n"
        if game.vibration then
            system.vibrate()
        end
        table.insert(Memmory.timerStash, timer.performWithDelay( 10, function()
                event.other.bodyType = "dynamic"
                event.other:setLinearVelocity( 100, 100 )
                -- event.other:applyTorque( 100 )
                local that = event.other
                --todo: do we need memmory management here?
                table.insert(Memmory.timerStash, timer.performWithDelay(3000, function()
                        physics.removeBody(event.other)
                        --display.remove(event.other)
                        that:removeSelf()
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
    game.world:insert(cbp1)
    game.world:insert(cbp2)
    game.world:insert(cbp3)
    game.world:insert(cbp4)
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

--[[
function Bullet:fireBullet(x, y, dx, dy)
    self.bullet = display.newRect(x, y, 20, 20)
    self.bullet.myName = "cannonball"
    self.bullet.strokeWidth = 0
    self.bullet:setFillColor(26, 55, 37)
    game.world:insert(self.bullet)
    Memmory.trackPhys(self.bullet); physics.addBody(self.bullet, { density = 100, friction = 0, bounce = 0 })
    self.bullet.isBullet = true
    self.bullet.collision = onCollision
    self.bullet:addEventListener("collision", self.bullet)

    local force = 7650
    self.bullet:applyForce(dx * force, -dy * force, x, y)
end
]]

--[[function Bullet:getX()
    if self.bullet ~= nil then
        return self.bullet.x
    else
        return nil
    end
end

function Bullet:getY()
    if self.bullet ~= nil then
        return self.bullet.y
    else
        return nil
    end
end

function Bullet:remove()
    self.bullet = nil
end

function Bullet:isAlive()
    if self.bullet ~= nil then
        local x = self:getX()
        local y = self:getY()
        --todo: use screenOriginX and Y below?
        if x ~= nil and y ~= nil and self:getX() < game.levelWidth * game.pixel and self:getX() > 0 and self:getY() < game.levelHeight * game.pixel then
            return true
        end
    end

    return false
end]]




 --todo: left this here for the probably bullet from 3 pieces
function Bullet:getX()
    self.xCount = 0
    self.xSum = 0
    for i, v in ipairs(self.pixels) do --todo: room for optimization: do not use "ipairs"
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
    for i, v in ipairs(self.pixels) do  --todo: room for optimization: do not use "ipairs"
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
