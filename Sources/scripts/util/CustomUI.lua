module(..., package.seeall)

local widget = require("widget")

function text(message, x, y, size, group)
    local text = display.newText(message, x + 2, y + 2, "TrebuchetMS-Bold", size)
    local textShadow = display.newText(message, x, y, "TrebuchetMS-Bold", size)
    text:setReferencePoint(display.CenterReferencePoint)
    textShadow:setReferencePoint(display.CenterReferencePoint)
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

function checkbox(left, top, id, handler)
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
        onPress = handler,
    }    
end