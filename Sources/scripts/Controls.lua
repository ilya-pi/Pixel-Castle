module(..., package.seeall)

Controls = {} --properties(game, angle)

local blackBorderWidth = 5
local touchAreaWidth = 130
local touchAreaHeight = 38
local buttonHeight, buttonWidth = touchAreaHeight, touchAreaHeight
local angleCircleRadius = 33
local circleTouchPadding = 14
local buttonTouchPadding = 12
local linePadding = 4
local lineThickness = 1

local fullHeight = angleCircleRadius * 2 + touchAreaHeight + circleTouchPadding
local fullWidth = touchAreaWidth + buttonWidth + buttonTouchPadding

-- Constructor
function Controls:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function Controls:touch(event)
    local angle = math.floor((event.x - self.x)/touchAreaWidth * 180 - 90)
    --print(angle)
    if (angle < -90) then angle = -90 end
    if (angle > 90) then angle = 90 end
    self.angle = angle

end



function Controls:render(x, y)
--[[    local extBorder = display.newRect(x, y, fullWidth, fullHeight)
    extBorder.strokeWidth = 1
    extBorder:setStrokeColor(255, 0, 0)
    extBorder:setFillColor(0, 0, 0, 0)]]
    self.x = x
    self.y = y

    local angleCircleX = x + touchAreaWidth / 2
    local angleCircleY = y + angleCircleRadius
    local circle = display.newCircle(angleCircleX, angleCircleY, angleCircleRadius)
    circle.strokeWidth = blackBorderWidth
    circle:setStrokeColor(0, 0, 0)
    circle:setFillColor(255, 255, 255)
    local line = display.newLine(angleCircleX - angleCircleRadius + linePadding, angleCircleY, angleCircleX + angleCircleRadius - linePadding, angleCircleY)
    line.width = lineThickness
    line:setColor(0, 0, 0)
    local angleText = display.newText( self.angle.."°", angleCircleX, angleCircleY, native.systemFont, 20) --todo change font
    angleText:setReferencePoint(display.TopRightReferencePoint)
    angleText.x = angleCircleX + 25
    angleText.y = angleCircleY + 2
    angleText:setTextColor(0, 0, 0)

    local touchX = x
    local touchY = y + angleCircleRadius * 2 + circleTouchPadding
    local touchArea = display.newRect(touchX, touchY, touchAreaWidth, touchAreaHeight)
    touchArea.strokeWidth = blackBorderWidth
    touchArea:setStrokeColor(0, 0, 0)
    touchArea:setFillColor(207, 229, 130)
    if(self.listener == nil) then
        self.listener = touchArea:addEventListener("touch", self)
    end

    local buttonX = x + touchAreaWidth + buttonTouchPadding
    local buttonY = touchY
    local button = display.newRect(buttonX, buttonY, buttonWidth, buttonHeight)
    button.strokeWidth = blackBorderWidth
    button:setStrokeColor(0, 0, 0)
    button:setFillColor(214, 79, 116)
    local text = display.newText("FIRE", buttonX + buttonWidth/2, buttonY + buttonHeight/2, native.systemFontBold, 12)
    text:setReferencePoint(display.CenterReferencePoint);
    text.x = buttonX + buttonWidth/2
    text.y = buttonY + buttonHeight/2
    text:setTextColor(255, 255, 255)

    --(167, 185, 255)

end
