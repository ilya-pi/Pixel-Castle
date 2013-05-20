module(..., package.seeall)

local widget = require("widget")

function text(message, x, y, size, group, referencePoint)
    local text = display.newText(message, x + 2, y + 2, "TrebuchetMS-Bold", size)
    local textShadow = display.newText(message, x, y, "TrebuchetMS-Bold", size)
    text:setReferencePoint((referencePoint ~= nil) and referencePoint or display.CenterReferencePoint)
    textShadow:setReferencePoint((referencePoint ~= nil) and referencePoint or display.CenterReferencePoint)
    text.x, text.y = x + 2, y + 2
    textShadow.x, textShadow.y = x, y
    group:insert(text)
    group:insert(textShadow)
    text:setTextColor(37, 54, 34)
    textShadow:setTextColor(255, 255, 255)
    text.text = message
    textShadow.text = message
end

local toggleSheetOptions = {
    frames = { 
    {
        x = 0, y = 0,
        width = 213, height = 62},
    {
        x = 213, y = 0,
        width = 213, height = 62},
    {
        x = 426, y = 0,
        width = 213, height = 62},
    },
    sheetContentWidth = 639,
    sheetContentHeight = 62
}
local toggleSheet = graphics.newImageSheet( "images/toggle_sheet.png", toggleSheetOptions )

function checkbox(left, top, id, initial, handler)
    return widget.newSwitch{
        left = left,
        top = top,
        style = "checkbox",
        id = id,
        sheet = toggleSheet,
        width = 106,
        height = 31,
        frameOn = 1,
        frameOff = 3,
        initialSwitchState = initial,
        onPress = handler,
    }    
end

local sliderSheetOptions = {
    frames = { 
    {
        x = 0, y = 0,
        width = 36, height = 43},
    {
        x = 37, y = 0,
        width = 36, height = 43},
    {
        x = 73, y = 0,
        width = 35, height = 43},
    },
    sheetContentWidth = 108,
    sheetContentHeight = 43
}
local sliderSheet = graphics.newImageSheet( "images/slider_sheet.png", sliderSheetOptions )

function slider(left, top, width, id, initial, handler)
    return widget.newSlider{
        top = top,
        left = left,
        id = id,
        width = width,        
        leftFrame = 1,
        middleFrame = 3,
        rightFrame = 3,
        fillFrame = 1,
        frameWidth = 10,
        frameHeight = 43,
        handleFrame = 2,
        handleFrameWidth = 36,
        handleFrameHeight = 43, 
        listener = handler,
        sheet = sliderSheet,
        value = initial
    }
end