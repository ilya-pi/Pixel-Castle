module(..., package.seeall)

dkjson = require("scripts.util.dkjson")

function renderImage(xPosition, yPosition, image, game)
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
                local left = (xPosition + x) * game.pixel
                local top = (yPosition + y) * game.pixel
                local pixel = display.newRect(left, top, game.pixel, game.pixel)
                pixel.strokeWidth = 0
                pixel:setFillColor(r, g, b, a)
                pixel:setStrokeColor(r, g, b, a)
                table.insert(pixels, pixel)
            end
        end
    end
    return pixels
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