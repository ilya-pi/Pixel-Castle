module(..., package.seeall)

physics = require("physics")

timerStash = {}
transitionStash = {}
physicsStash = {}

function monitorMem()
    collectgarbage()
    print( "MemUsage: " .. collectgarbage("count") )

    local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
    print( "TexMem:   " .. textMem )
end

function cancelAllTimers()
    local k, v

    for k,v in pairs(timerStash) do
        timer.cancel( v )
        v = nil; k = nil
    end

    timerStash = nil
    timerStash = {}
end

function cancelAllTransitions()
    local k, v

    for k,v in pairs(transitionStash) do
        transition.cancel( v )
        v = nil; k = nil
    end

    transitionStash = nil
    transitionStash = {}
end

function trackPhys(obj)
    table.insert(physicsStash, obj)
end

function clearPhysics()
    local k, v

    for k,v in pairs(physicsStash) do
        if v ~= nil and v.state ~= "removed" then
            physics.removeBody( v )
            v:removeSelf()
            v = nil; k = nil
        end
    end

    physicsStash = nil
    physicsStash = {}
end
