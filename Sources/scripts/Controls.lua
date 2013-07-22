module(..., package.seeall)

local widget = require("widget")
local Memmory = require("scripts.util.Memmory")

Controls = {}

local padding = 25
local scaleFactor = 0.5
local touchScaleFactor = 8

function Controls:calculateCoordinates()
end

function Controls:setCoordinates()
    self.group.x = self.x
    self.group.y = self.y

    self.angleText.text = self.angle .. "°"
    self.angleLine.rotation = self.angle

--[[
    if self.name == "left" then
        self:drawParabolaWind()
    end
]]

end

-- Constructor
function Controls:new(o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

    o.speed = game.levelConfig.screens[1].levels[game.selectedLevel].bulletSpeed
    o.pixels = {}
    o.pixelsW = {}
    --creating objects
    o.group = display.newGroup()

    o.circle = display.newImage("images/castle_control/circle.png")
    o.circle:scale(scaleFactor, scaleFactor)
    o.circle.x = 0
    o.circle.y = 0
    o.group:insert(o.circle)

    o.angleText = display.newText( o.angle .. "°", 0, 10, native.systemFont, 20) --todo change font
    o.angleText:setReferencePoint(display.CenterReferencePoint)
    o.angleText.x = 0
    o.angleText.y = o.circle.height / 4 * scaleFactor - 4
    o.angleText:setTextColor(0, 0, 0)
    o.group:insert(o.angleText)

    o.slidePad = display.newImage("images/castle_control/slide-pad.png")
    o.slidePad:scale(scaleFactor, scaleFactor)
    o.slidePad.x = 0
    local yControls = (o.circle.height / 2 + padding * 2 + o.slidePad.height / 2) * scaleFactor
    o.slidePad.y = yControls
    o.listener = o.slidePad:addEventListener("touch", o)
    o.group:insert(o.slidePad)

    -- o.fireButton = display.newImage("images/castle_control/fire_button.png")
    -- o.fireButton:scale(scaleFactor, scaleFactor)
    -- o.fireButton.x = (o.slidePad.width / 2 + padding + o.fireButton.width / 2) * scaleFactor
    -- o.fireButton.y = yControls
    -- o.group:insert(o.fireButton)

    o.fireButton = widget.newButton{
        width = 42,
        height = 42,
        defaultFile = "images/castle_control/fire_button.png",
        overFile = "images/castle_control/fire_button_pressed.png",
        id = "firebtn",
        label = "FIRE",
        font = "TrebuchetMS-Bold",
        fontSize = 12,
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = o.onFire
    }
    o.fireButton.x, o.fireButton.y = (o.slidePad.width / 2 + padding + o.fireButton.width / 2) * scaleFactor, yControls
    o.group:insert(o.fireButton)

    local gunX = (o.slidePad.width / 2 + padding + o.fireButton.width / 2) * scaleFactor
    local gunY = yControls - 42 - 4
    local gunW = 42
    o.selectedGun = 1
    o.guns = {}
    local overdo = 15
    o.openArmory = function()
        o.gunBtn:removeSelf()
        for i=1,3 do
            local bImage
            if o.selectedGun == i then 
                bImage = "images/castle_control/weapon" .. i .. "_pressed.png"
            else 
                bImage = "images/castle_control/weapon" .. i .. ".png"
            end
            local b = widget.newButton{
                width = 42,
                height = 42,
                defaultFile = bImage,
                overFile = "images/castle_control/weapon" .. i .. "_pressed.png",
                id = "gun" .. i,
                label = "",
                font = "TrebuchetMS-Bold",
                fontSize = 12,
                labelColor = { default = { 255 }, over = { 0 } },
                onRelease = function()
                    o.closeArmory(i)
                end
            }
            o.group:insert(b)
            b.x, b.y = gunX, gunY
            transition.to(b,{x = gunX + (gunW + 7) * ( i - 1) + overdo, transition = easing.inExpo, time = 100, onComplete = function()
                transition.to(b, {x = b.x - overdo, time = 50})
                end})
            o.guns[i] = b
        end
    end

    o.closeArmory = function(gun)
        for k,v in pairs(o.guns) do
            v:removeSelf()
        end
        o.gunBtn = widget.newButton{
            width = gunW,
            height = 42,
            defaultFile = "images/castle_control/weapon" .. gun .. "_pressed.png",
            overFile = "images/castle_control/weapon" .. gun .. ".png",
            id = "gunbtn",
            label = "",
            font = "TrebuchetMS-Bold",
            fontSize = 12,
            labelColor = { default = { 255 }, over = { 0 } },
            onRelease = o.openArmory
        }
        o.gunBtn.x, o.gunBtn.y = gunX, gunY
        o.group:insert(o.gunBtn)
        o.selectedGun = gun
    end    

    o.closeArmory(game.START_GUN)

    o.angleLine = display.newImage("images/castle_control/angle_stick.png")
    o.angleLine:scale(scaleFactor, scaleFactor)
    o.angleLine:setReferencePoint(display.BottomCenterReferencePoint);
    o.angleLine.x = 0
    o.angleLine.y = 0
    o.angleLine.rotation = o.angle
    o.group:insert(o.angleLine)
    if o.container ~= nil then
        o.container:insert(o.group)
    else
        game.world:insert(o.group)
    end
    return o
end

function Controls:touch(event)
    if event.phase == "began" then
        self.lastAngle = self.angle
        self.beginX = event.x
    elseif event.phase == "moved" and self.beginX ~= nil then        
        self.delta = self.beginX - event.x
        self.angle = self.lastAngle - round(self.delta / touchScaleFactor)
        if (self.angle < -90) then self.angle = -90 end
        if (self.angle > 90) then self.angle = 90 end        
    elseif event.phase == "ended" or event.phase == "cancelled" then
        self.lastAngle = self.angle
    end

    self:setCoordinates()
    -- return true, so that touch event wont be fired for the background
    return true
end

function Controls:render()
    self:calculateCoordinates()
    self:setCoordinates()
    self.group:toFront()
end

function Controls:drawParabolaWind()
    local angleInRadians = math.rad(self.angle - (self.angle - 45) * 2)
    local speed = self.speed * 0.184 --magic number picked manually
    local xV = speed * math.cos(angleInRadians)
    local yV = -speed * math.sin(angleInRadians)
    local xA = game.wind.physicsSpeed
    local yA = game_gravity

    local x0 = self.x
    local y0 = self.y

    for t = 0, 35, 0.4 do
        local x = x0 + xV * t + xA * t * t / 2
        local y = y0 + yV * t + yA * t * t / 2

        if self.pixelsW[t] == nil then
            local pix = display.newRect(x, y, 5, 5)
            pix:setFillColor(255, 0, 0)
            self.pixelsW[t] = pix
            game.world:insert(pix)
        end
        self.pixelsW[t].x = x
        self.pixelsW[t].y = y
    end
end

function Controls:hide()
    self.group.isVisible = false
end

function Controls:show()
    self.group.isVisible = true
end

function Controls:getAngle()
    return self.angle
end

function round(x) --> (number)
    if x >= 0 then
        return math.ceil(x + 0.5)
    else
        return math.floor(x - 0.5)
    end
end


