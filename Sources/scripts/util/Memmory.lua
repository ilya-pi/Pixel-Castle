module(..., package.seeall)

timerStash = {}
transitionStash = {}

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