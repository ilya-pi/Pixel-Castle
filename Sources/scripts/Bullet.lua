module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")

local hit = {
    {0,0,1,1,1,0,0},
    {0,1,2,3,2,1,0},
    {1,2,3,3,3,2,1},
    {1,3,3,3,3,3,1},
    {1,2,3,3,3,2,1},
    {0,1,2,3,2,1,0},
    {0,0,1,1,1,0,0},
}

-- local hit = {
--     {0,0,1,1,1,0,0,1},
--     {0,1,2,3,2,1,0,1},
--     {1,2,3,3,3,2,1,1},
--     {1,3,3,3,3,3,1,1},
--     {1,2,3,3,3,2,1,1},
--     {0,1,2,3,2,1,0,1},
--     {0,0,1,1,1,0,0,1},
--     {0,0,1,1,1,0,0,1},
-- }

local fireSound = audio.loadSound("sound/fire.mp3")
local hitSound = audio.loadSound("sound/hit.mp3")

Bullet = { 
            pixels = {},
         }

-- Constructor
-- Requires object with game parametres
function Bullet:new(o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

local function onCollision(self, event)
    event.contact.isEnabled = false
    if (event.other.myName == "brick") then
        audio.play(hitSound)
        self.bodyType = "static"
        self:removeSelf()
        --event.other:removeSelf()
        if game.vibration then
            system.vibrate()
        end        
        self.state = "removed"
        game.earth:calculateHit(event.other, hit)
    end
    return true
--[[    if event.other.myName == "brick" then
        self:removeSelf()
        event.other.myName = "n"
        if game.vibration then
            system.vibrate()
        end
        table.insert(Memmory.timerStash, timer.performWithDelay( 10, function()
                physics.removeBody(event.other)
                event.other.bodyType = "dynamic"
                event.other:setLinearVelocity( 100, 100 )
                -- event.other:applyTorque( 100 )
                local that = event.other
                --todo: do we need memmory management here?
                table.insert(Memmory.timerStash, timer.performWithDelay(3000, function()
                        display.remove(event.other)
                        -- that:removeSelf()
                    end))
            end))
        self.state = "removed"
        event.other.state = "removed"
    end]]
    end

function Bullet:fireBullet(x, y, dx, dy)
    audio.play(fireSound)

    self.bullet = display.newRect(x, y, 20, 20)
    self.bullet.myName = "cannonball"
    self.bullet.strokeWidth = 0
    self.bullet:setFillColor(26, 55, 37)
    game.world:insert(self.bullet)
    Memmory.trackPhys(self.bullet); physics.addBody(self.bullet, { density = 100, friction = 10, bounce = 10})

    -- without this flag it still runs fine, and should not consume as much resources
    -- self.bullet.isBullet = true
    self.bullet.collision = onCollision
    self.bullet:addEventListener("collision", self.bullet)

    local force = game.levelConfig.screens[1].levels[game.selectedLevel].bulletImpulse
    -- twenty downbelow is a magic number that enables to adjust rotation speed accordingly to the x velocity
    self.bullet:applyTorque(math.floor(dx * force / 20))
    self.bullet:applyForce(dx * force, -dy * force, self.bullet.x, self.bullet.y)
end

function Bullet:getX()
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
end




--[[ --todo: left this here for the probably bullet from 3 pieces
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
end]]
