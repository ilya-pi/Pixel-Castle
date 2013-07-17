module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")
local imageHelper = require("scripts.util.Image")
local bullets = imageHelper.loadImageData("data/bullets.json");

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
    local hit = self.hit  --todo: here we should have access to Bullet.hit
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
        game.earth:calculateHit(event.other, hit) --todo: here we should have access to Bullet.hit
    end
    return true
end

function Bullet:fireNBullets(x, y, angleInDegrees, bulletName, count, dAngleInDegrees)
    audio.play(fireSound)
    self.hit = bullets[bulletName]
    local angleInRadians = math.rad(angleInDegrees)
    local dAngleInRadians = math.rad(dAngleInDegrees)
    self.pixels = {}

    for i = 1, count do
        self.bullet = display.newRect(x, y, 20, 20)
        self.bullet.myName = "cannonball"
        self.bullet.hit = self.hit --todo: think how to store hit not in display object
        self.bullet.strokeWidth = 0
        self.bullet:setFillColor(26, 55, 37)
        game.world:insert(self.bullet)
        self.pixels[i] = self.bullet
        Memmory.trackPhys(self.bullet); physics.addBody(self.bullet, { density = 100, friction = 10, bounce = 10, isSensor = true})

        -- without this flag it still runs fine, and should not consume as much resources
        -- self.bullet.isBullet = true
        self.bullet.collision = onCollision
        self.bullet:addEventListener("collision", self.bullet)
    end

    local angleForStart = - ((count - 1) * dAngleInRadians / 2) + angleInRadians

    for i = 1, #self.pixels do
        local force = game.levelConfig.screens[1].levels[game.selectedLevel].bulletImpulse
        local currentAngle = angleForStart + (i - 1) * dAngleInRadians
        local dx = force * math.sin(currentAngle)
        local dy = force * math.cos(currentAngle)
        -- twenty downbelow is a magic number that enables to adjust rotation speed accordingly to the x velocity
        self.pixels[i]:applyTorque(math.floor(dx * force / 20))
        self.pixels[i]:applyForce(dx, -dy, self.pixels[i].x, self.pixels[i].y)
    end
end


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
