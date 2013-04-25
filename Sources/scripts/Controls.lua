module(..., package.seeall)

Controls = {}

local padding = 10
local scaleFactor = 0.5
local touchScaleFactor = 8

function Controls:calculateCoordinates()
end

function Controls:setCoordinates()
    self.group.x = self.x
    self.group.y = self.y

    self.angleText.text = self.angle .. "°"
    self.angleLine.rotation = self.angle
end

-- Constructor
function Controls:new(o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

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

    o.fireButton = display.newImage("images/castle_control/fire_button.png")
    o.fireButton:scale(scaleFactor, scaleFactor)
    o.fireButton.x = (o.slidePad.width / 2 + padding + o.fireButton.width / 2) * scaleFactor
    o.fireButton.y = yControls
    o.group:insert(o.fireButton)

    o.angleLine = display.newImage("images/castle_control/angle_stick.png")
    o.angleLine:scale(scaleFactor, scaleFactor)
    o.angleLine:setReferencePoint(display.BottomCenterReferencePoint);
    o.angleLine.x = 0
    o.angleLine.y = 0
    o.angleLine.rotation = o.angle
    o.group:insert(o.angleLine)
    o.group.x = -1000
    o.group.y = -1000

    o.world:insert(o.group)
    return o
end

function Controls:touch(event)
    if event.phase == "began" then
        self.lastAngle = self.angle
        self.beginX = event.x
    elseif event.phase == "moved" then
        self.delta = self.beginX - event.x
        self.angle = self.lastAngle - round(self.delta / touchScaleFactor)
        if (self.angle < -90) then self.angle = -90 end
        if (self.angle > 90) then self.angle = 90 end
    elseif event.phase == "ended" or event.phase == "cancelled" then
        self.lastAngle = self.angle
    end
end

function Controls:render()
    self:calculateCoordinates()
    self:setCoordinates()
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


