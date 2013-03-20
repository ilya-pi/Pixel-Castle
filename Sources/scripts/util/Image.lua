module(..., package.seeall)

function renderImage(xPosition, yPosition, image, game)
    local pixels = {}
    local primitiveColorsCount = 3
    for y = 0, image.height - 1 do
        for x = 0, image.width - 1 do
            local rPosition = y * image.width * primitiveColorsCount + x * primitiveColorsCount + 1
            local r = image.pixels[rPosition]
            local g = image.pixels[rPosition + 1]
            local b = image.pixels[rPosition + 2]
            if (r + g + b ~= 0) then
                local left = (xPosition + x) * game.pixel
                local top = (yPosition + y) * game.pixel
                local pixel = display.newRect(left, top, game.pixel, game.pixel)
                pixel.strokeWidth = 0
                pixel:setFillColor(r, g, b)
                pixel:setStrokeColor(r, g, b)
                table.insert(pixels, pixel)
            end
        end
    end
    return pixels
end