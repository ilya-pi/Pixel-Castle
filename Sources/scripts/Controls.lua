module(..., package.seeall)

Controls = {}

local blackBorderWidth = 5
local touchAreaWidth = 130
local touchAreaHeight = 38
local buttonHeight, buttonWidth = touchAreaHeight, touchAreaHeight
local angleCircleRadius = 33
local circleTouchPadding = 12
local buttonTouchPadding = 12
local linePadding = 4
local lineThickness = 1

local fullHeight = angleCircleRadius * 2 + touchAreaHeight + circleTouchPadding
local fullWidth = touchAreaWidth + buttonWidth + buttonTouchPadding

function Controls:calculateCoordinates()
    self.angleCircleX = self.x + touchAreaWidth / 2 + 4
    self.angleCircleY = self.y + angleCircleRadius

    self.angleHorisontalLineX1 = self.angleCircleX - angleCircleRadius + linePadding
    self.angleHorisontalLineY1 = self.angleCircleY
    self.angleHorisontalLineX2 = self.angleCircleX + angleCircleRadius - linePadding
    self.angleHorisontalLineY2 = self.angleCircleY

    self.angleVectorLineX1 = self.angleCircleX
    self.angleVectorLineY1 = self.angleCircleY
    self.tmpAngle = math.rad(self.angle)
    self.angleVectorLineX2 = (angleCircleRadius - linePadding) * math.sin(self.tmpAngle) + self.angleVectorLineX1
    self.angleVectorLineY2 = -((angleCircleRadius - linePadding) * math.cos(self.tmpAngle)) + self.angleVectorLineY1

    self.angleTextX = self.angleCircleX + 23
    self.angleTextY = self.angleCircleY + 2

    self.touchX = self.x
    self.touchY = self.y + angleCircleRadius * 2 + circleTouchPadding

    self.buttonX = self.x + touchAreaWidth + buttonTouchPadding
    self.buttonY = self.touchY

    self.buttonTextX = self.buttonX + buttonWidth/2 + 3
    self.buttonTextY = self.buttonY + buttonHeight/2 + 3
end

function Controls:setCoordinates()
    self.angleCircle.x = self.angleCircleX
    self.angleCircle.y = self.angleCircleY
    self.angleHorisontalLine.x = self.angleHorisontalLineX1
    self.angleHorisontalLine.y = self.angleHorisontalLineY1
    self.angleText.x = self.angleTextX
    self.angleText.y = self.angleTextY
    self.angleText.text = self.angle .. "°"
    --print(self)

    self.touchArea.x = self.touchX
    self.touchArea.y = self.touchY

    self.button.x = self.buttonX
    self.button.y = self.buttonY
    self.buttonText.x = self.buttonTextX
    self.buttonText.y = self.buttonTextY

    self.angleVectorLine:removeSelf()
    self.angleVectorLine = display.newLine(self.angleVectorLineX1, self.angleVectorLineY1, self.angleVectorLineX2, self.angleVectorLineY2)
    self.angleVectorLine.width = lineThickness
    self.angleVectorLine:setColor(0, 0, 0)
    self.group:insert(self.angleVectorLine)
end

-- Constructor
function Controls:new(o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

    --creating objects
    o.group = display.newGroup()
    o.angleCircle = display.newCircle(-100, -100, angleCircleRadius)
    o.angleCircle.strokeWidth = blackBorderWidth
    o.angleCircle:setStrokeColor(0, 0, 0)
    o.angleCircle:setFillColor(255, 255, 255)
    o.group:insert(o.angleCircle)

    o.angleHorisontalLine = display.newLine(0, -100, (angleCircleRadius - linePadding)*2, -100)
    o.angleHorisontalLine.width = lineThickness
    o.angleHorisontalLine:setColor(0, 0, 0)
    o.group:insert(o.angleHorisontalLine)

    o.angleText = display.newText( "fake", -100, -100, native.systemFont, 20) --todo change font
    o.angleText:setReferencePoint(display.TopRightReferencePoint)
    o.angleText.x = -100
    o.angleText.y = -100
    o.angleText:setTextColor(0, 0, 0)
    o.group:insert(o.angleText)

    o.touchArea = display.newRect(-100, -100, touchAreaWidth, touchAreaHeight)
    o.touchArea.strokeWidth = blackBorderWidth
    o.touchArea:setStrokeColor(0, 0, 0)
    o.touchArea:setFillColor(207, 229, 130)
    o.touchArea:setReferencePoint(display.TopLeftReferencePoint)
    o.group:insert(o.touchArea)
    o.listener = o.touchArea:addEventListener("touch", o)

    o.button = display.newRect(-100, -100, buttonWidth, buttonHeight)
    o.button.strokeWidth = blackBorderWidth
    o.button:setStrokeColor(0, 0, 0)
    o.button:setFillColor(214, 79, 116)
    o.button:setReferencePoint(display.TopLeftReferencePoint)
    o.group:insert(o.button)

    o.buttonText = display.newText("FIRE", -100, -100, native.systemFontBold, 12)
    o.buttonText:setReferencePoint(display.CenterReferencePoint);
    o.buttonText:setTextColor(255, 255, 255)
    o.group:insert(o.buttonText)

    o.angleVectorLine = display.newLine(0, 0, 0, 0)
    o.group:insert(o.angleVectorLine)

    return o
end

function Controls:touch(event)
    local angleNew = math.floor((event.x - self.x)/touchAreaWidth * 180 - 90)
    if (angleNew < -90) then angleNew = -90 end
    if (angleNew > 90) then angleNew = 90 end
    self.angle = angleNew
    --print(self)
end

function Controls:render(x, y)
--[[    local extBorder = display.newRect(x, y, fullWidth, fullHeight)
    extBorder.strokeWidth = 1
    extBorder:setStrokeColor(255, 0, 0)
    extBorder:setFillColor(0, 0, 0, 0)]]
    --print("x="..x .." y="..y .. " width="..fullWidth .. " height=".. fullHeight)

    --if(self.x ~= x or self.y ~= y) then
        self.x = x
        self.y = y
        self:calculateCoordinates()
        self:setCoordinates()
        --print(self)
   --end
    --(167, 185, 255)
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


