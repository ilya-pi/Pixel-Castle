module(..., package.seeall)

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
