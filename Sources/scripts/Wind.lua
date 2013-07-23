module(..., package.seeall)

physics = require("physics")
local scaleFactor = 0.5
local pixelsPadding = 1
local leftMargin = 44

Wind = {}

-- Constructor
function Wind:new (o)
    print("vieable content " .. display.viewableContentWidth .. " " .. display.contentHeight)
    print("display content " .. display.contentWidth .. " " .. display.viewableContentHeight)
    print("origin content " .. display.screenOriginX .. " " .. display.screenOriginY)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.speed = 0
    o.pixels = {}

    o.group = display.newGroup()
    o.group.alpha = 0.8

    o.wind_hud = display.newImage("images/wind/wind_hud.png")
    o.wind_hud:scale(scaleFactor, scaleFactor)
    o.wind_hud:setReferencePoint(display.TopLeftReferencePoint)
    o.wind_hud.x = 0
    o.wind_hud.y = 0

    o.group:insert(o.wind_hud)
    o.group.x = display.screenOriginX
    o.group.y = display.screenOriginY

    local tmp = display.newImage("images/wind/triangle_left.png")
    o.arrowWidth = tmp.width * scaleFactor
    tmp:removeSelf()
    tmp = display.newImage("images/wind/wind_point.png")
    o.windPointWidth = tmp.width * scaleFactor
    tmp:removeSelf()

    return o
end

function Wind:hide()
    self.group.isVisible = false
end

function Wind:show()
    self.group.isVisible = true
end

function Wind:dismiss()
    self.group:removeSelf()
end

function Wind:update()
    self.speed = self.speed - math.random(-2, 2)
    if self.speed < -5 then self.speed = -5 end
    if self.speed > 5 then self.speed = 5 end
    -- self.speed = -5 --todo: testing purpose
    self.physicsSpeed = game.levelConfig.screens[1].levels[game.selectedLevel].maxWindForce / 5 * self.speed
    physics.setGravity(self.physicsSpeed, 9.8)

    local centerOfArrow = (self.wind_hud.width * scaleFactor - leftMargin) / 2 + leftMargin
    local lengthOfArrow = self.arrowWidth + pixelsPadding + math.abs(self.speed) * self.windPointWidth + (math.abs(self.speed) - 1) * pixelsPadding
    local pixelsX = centerOfArrow - lengthOfArrow / 2
    --local pixelsX = leftMargin
    local pixelsY = self.wind_hud.height / 2 * scaleFactor - 2

    for i, v in ipairs(self.pixels) do
        v:removeSelf()
        self.pixels[i] = nil
    end

    if (self.speed < 0) then
        local arrow = display.newImage("images/wind/triangle_left.png")
        arrow:scale(scaleFactor, scaleFactor)
        arrow:setReferencePoint(display.CenterLeftReferencePoint)
        arrow.x = pixelsX
        arrow.y = pixelsY
        pixelsX = pixelsX + arrow.width * scaleFactor + pixelsPadding
        self.group:insert(arrow)
        table.insert(self.pixels, arrow)
        self:drawPixels(pixelsX, pixelsY, math.abs(self.speed))
    elseif (self.speed > 0) then
        local lineEndX = self:drawPixels(pixelsX, pixelsY, math.abs(self.speed))
        pixelsX = lineEndX

        local arrow = display.newImage("images/wind/triangle_right.png")
        arrow:scale(scaleFactor, scaleFactor)
        arrow:setReferencePoint(display.CenterLeftReferencePoint)
        arrow.x = pixelsX
        arrow.y = pixelsY
        self.group:insert(arrow)
        table.insert(self.pixels, arrow)
    else
        --todo: draw 0?
    end
end

function Wind:drawPixels(x, y, count)
    local currentX = x
    print(count)
    for i = 1, count do
        local pixel = display.newImage("images/wind/wind_point.png")
        pixel:scale(scaleFactor, scaleFactor)
        pixel:setReferencePoint(display.CenterLeftReferencePoint)
        pixel.x = currentX
        pixel.y = y
        self.group:insert(pixel)
        table.insert(self.pixels, pixel)
        currentX = currentX + pixel.width * scaleFactor + pixelsPadding
    end
    return currentX
end
