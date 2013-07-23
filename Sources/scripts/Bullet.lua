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
        local xV, yV = self:getLinearVelocity()
        game.earth:calculateHit(event.other, hit, xV, yV) --todo: here we should have access to Bullet.hit        

        audio.play(hitSound)
        -- self.bodyType = "static"
        self:removeSelf()
        --event.other:removeSelf()
        if game.vibration then
            system.vibrate()
        end        
        self.state = "removed"
    end
    return true
end

function Bullet:fireNBullets(x, y, angleInDegrees, bulletNumber)
    local bulletName = game.levelConfig.screens[1].bullets[bulletNumber].bulletName
    local count = game.levelConfig.screens[1].bullets[bulletNumber].count
    local dAngleInDegrees = game.levelConfig.screens[1].bullets[bulletNumber].dAngleInDegrees
    local bulletSize = game.levelConfig.screens[1].bullets[bulletNumber].size
    y = y - bulletSize
    x = x - bulletSize / 2
    audio.play(fireSound)
    self.hit = bullets[bulletName]
    local angleInRadians = math.rad(angleInDegrees)
    local dAngleInRadians = math.rad(dAngleInDegrees)
    local force = game.levelConfig.screens[1].levels[game.selectedLevel].bulletSpeed
    self.pixels = {}
    self.pointers = {}

    for i = 1, count do
        self.bullet = display.newRect(x, y, bulletSize, bulletSize)
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

        --add pointers
        self.pointers[i] = display.newRect(x, display.screenOriginY, 20, 20)
        self.pointers[i]:setFillColor(255, 0, 0)
        game.world:insert(self.pointers[i])

    end

    local angleForStart = - ((count - 1) * dAngleInRadians / 2) + angleInRadians

    for i = 1, #self.pixels do
        local currentAngle = angleForStart + (i - 1) * dAngleInRadians
        local dx = force * math.sin(currentAngle)
        local dy = force * math.cos(currentAngle)
        -- twenty downbelow is a magic number that enables to adjust rotation speed accordingly to the x velocity
        self.pixels[i]:applyTorque(dx * 2)
        --self.pixels[i]:applyForce(dx, -dy, self.pixels[i].x, self.pixels[i].y)
        self.pixels[i]:setLinearVelocity(dx, -dy)

    end

    self.cameraAim = display.newRect(x, y, 20, 20)
    self.cameraAim.myName = "camera_aim"
    self.cameraAim:setFillColor(255, 255, 255, 0)
    game.world:insert(self.cameraAim)
    Memmory.trackPhys(self.cameraAim); physics.addBody(self.cameraAim, { density = 100, friction = 10, bounce = 10, isSensor = true})
    self.cameraAim:applyForce(force * math.sin(angleInRadians), -force * math.cos(angleInRadians), self.cameraAim.x, self.cameraAim.y)

end

--[[function Bullet:getX()
    if self.pixels ~= nil and self:isAlive() and self.cameraAim ~= nil then
        return self.cameraAim.x
    else
        return nil
    end
end

function Bullet:getY()
    if self.pixels ~= nil and self:isAlive() and self.cameraAim ~= nil then
        return self.cameraAim.y
    else
        return nil
    end
end]]


function Bullet:getX()
    self.xCount = 0
    self.xSum = 0
    for i, v in ipairs(self.pixels) do --todo: room for optimization: do not use "ipairs"
        if (v ~= nil and v.state ~= "removed") then
            self.xCount = self.xCount + 1
            self.xSum = self.xSum + v.x
            if self.pointers[i] ~= nil then self.pointers[i].x = v.x end
        else
            if self.pointers[i] ~= nil then
                self.pointers[i]:removeSelf()
                self.pointers[i] = nil
            end
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
        if self.pointers[i] ~= nil then
            self.pointers[i]:removeSelf()
            self.pointers[i] = nil
        end
    end
    if self.cameraAim ~= nil then
        self.cameraAim = nil
    end
end

function Bullet:isAlive()
    for i, v in ipairs(self.pixels) do
        if v.state ~= "removed" and
           not (v.x > self.game.levelWidth * self.game.pixel or v.x < 0 or v.y > self.game.levelHeight * self.game.pixel) then
            return true
        end
    end

    if self.cameraAim ~= nil then
        self.cameraAim = nil
    end
    return false
end
