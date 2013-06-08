module(..., package.seeall)

dkjson = require("scripts.util.dkjson")

-- Renders image with an appropriate referencce point and tint if present in the game
function ourImage(path, width, height, group)
    local result = display.newImageRect(path, width, height)
    result:setReferencePoint(display.TopLeftReferencePoint)
    if game.tint then
        result:setFillColor(game.tintColor.r, game.tintColor.g, game.tintColor.b)
    end
    group:insert(result)
    result.x = 0
    result.y = 0
    return result
end

function ourImageSheet(sheet, frame, width, height, group)
    local result = display.newImageRect(sheet, frame, width, height)
    result:setReferencePoint(display.TopLeftReferencePoint)
    if game.tint then
        result:setFillColor(game.tintColor.r, game.tintColor.g, game.tintColor.b)
    end
    group:insert(result)
    result.x = 0
    result.y = 0
    return result
end

function renderImage(xPosition, yPosition, image, pixel)
    local pixels = {}
    local primitiveColorsCount = 4
    for y = 0, image.height - 1 do
        for x = 0, image.width - 1 do
            local rPosition = y * image.width * primitiveColorsCount + x * primitiveColorsCount + 1
            local r = image.pixels[rPosition]
            local g = image.pixels[rPosition + 1]
            local b = image.pixels[rPosition + 2]
            local a = image.pixels[rPosition + 3]
            if (a ~= 0) then
                local left = (xPosition + x) * pixel
                local top = (yPosition + y) * pixel
                local pixel = display.newRect(left, top, pixel, pixel)
                pixel.strokeWidth = 0
                pixel:setFillColor(r, g, b, a)
                pixel:setStrokeColor(r, g, b, a)
                table.insert(pixels, pixel)
            end
        end
    end
    return pixels
end

--[[function renderPart(xPosition, yPosition, image, pixel, partSize, xPart, yPart)
    local pixels = {}
    local primitiveColorsCount = 4

    local startX = (xPart - 1) * partSize
    local startY = (yPart - 1) * partSize

    for y = startY, startY + partSize - 1 do
        for x = startX, startX + partSize - 1 do
            local rPosition = y * image.width * primitiveColorsCount + x * primitiveColorsCount + 1
            local r = image.pixels[rPosition]
            local g = image.pixels[rPosition + 1]
            local b = image.pixels[rPosition + 2]
            local a = image.pixels[rPosition + 3]
            if (a ~= 0) then
                print("found pixel")
                local left = (xPosition + x) * pixel
                local top = (yPosition + y) * pixel
                local pixel = display.newRect(left, top, pixel, pixel)
                pixel.strokeWidth = 0
                pixel:setFillColor(r, g, b, a)
                pixel:setStrokeColor(r, g, b, a)
                table.insert(pixels, pixel)
            end
        end
    end
    return pixels
end]]

function pixel(x, y, image)
    local pixels = {}
    local primitiveColorsCount = 4
    local rPosition = (y % image.height) * image.width * primitiveColorsCount + (x % image.width) * primitiveColorsCount + 1
    local r = image.pixels[rPosition]
    local g = image.pixels[rPosition + 1]
    local b = image.pixels[rPosition + 2]
    local a = image.pixels[rPosition + 3]
    return r, g, b, a
end

function loadImageData(filename)
    -- set default base dir if none specified
    local base = system.ResourceDirectory

    -- create a file path for corona i/o
    local path = system.pathForFile( filename, base )

    -- will hold contents of file
    local contents

    -- io.open opens a file at path. returns nil if no file found
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        contents = file:read( "*a" )
        io.close( file )    -- close the file after using it
        --return decoded json string

        local obj, pos, err = dkjson.decode (contents, 1, nil)
        if err then
            print ("Error:", err)
        else
            return obj
        end
    else
        --or return nil if file didn't ex
        return nil
    end
end