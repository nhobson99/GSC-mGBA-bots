-- This is literally just for soft resetting for Celebi

-- Function to check if a given IV value is shiny
function isShiny(attack, defense, speed, special)
    return (special == 10 and speed == 10 and defense == 10 and ((attack & 2) > 0))
end

local state = emu:saveStateBuffer()
local totalEncounterCounter = 0
local previousFrame = emu:currentFrame() + 10
local buffer = console:createBuffer("Tracker")
local cb
local enemyAddr = 0xd20c

-- Main function
local function onFrame()
    emu:clearKey(C.GB_KEY.A)
    emu:clearKey(C.GB_KEY.B)
    emu:clearKey(C.GB_KEY.LEFT)
    emu:clearKey(C.GB_KEY.RIGHT)
    emu:clearKey(C.GB_KEY.DOWN)
    emu:clearKey(C.GB_KEY.UP)
    emu:clearKey(C.GB_KEY.START)
    emu:clearKey(C.GB_KEY.SELECT)

    local currentFrame = emu:currentFrame() - previousFrame

    if emu:read8(enemyAddr+0x21) > 0 and emu:read8(enemyAddr+0x22) > 0 and currentFrame > 2500 then
        -- Note: earlier versions of these scripts accidentally swapped speed and spec :)
        local enemyDVsAD = emu:read8(enemyAddr)
        local enemyDVsSS = emu:read8(enemyAddr+1)
        local defense = (enemyDVsAD & 0xF)
        local attack = (enemyDVsAD >> 4)
        local special = (enemyDVsSS & 0xF)
        local speed = (enemyDVsSS >> 4)

        totalEncounterCounter = totalEncounterCounter + 1
        console:log("Total encounters: " .. totalEncounterCounter)
        console:log("DVS: def(" .. defense .. ") atk(" .. attack .. ") speed(" .. speed .. ") spec(" .. special .. ")")
        buffer:clear()
        buffer:print("Total encounters: " .. totalEncounterCounter .. "\n")
        buffer:print("DVS: def(" .. defense .. ") atk(" .. attack .. ") speed(" .. speed .. ") spec(" .. special .. ")")

        if isShiny(attack, defense, speed, special) then
            console:log("Shiny Encounter! Total Encounters: " .. totalEncounterCounter)
            
            -- Enable alarm by uncommenting this line (Windows only, though you could modify it for Mac/Linux/etc)
            -- os.execute("explorer.exe https://www.youtube.com/video/SAjRuGdXeOE")

            callbacks:remove(cb)
        else
            console:log("Reset")
            emu:addKey(C.GB_KEY.A)
            emu:addKey(C.GB_KEY.B)
            emu:addKey(C.GB_KEY.SELECT)
            emu:addKey(C.GB_KEY.START)
        end

        previousFrame = emu:currentFrame() + 2
        return
    end
    if currentFrame < 500 then
        if currentFrame % 20 < 10 then
            emu:addKey(C.GB_KEY.A)
        end
    elseif currentFrame < 600 then
        emu:addKey(C.GB_KEY.UP)
    elseif currentFrame < 2100 then
        if currentFrame % 20 < 10 then
            emu:addKey(C.GB_KEY.A)
        end
    end
end

emu:addKey(C.GB_KEY.A)
emu:addKey(C.GB_KEY.B)
emu:addKey(C.GB_KEY.SELECT)
emu:addKey(C.GB_KEY.START)

-- This lets the emulator have a frame to reset properly
local function firstFrame()
    callbacks:remove(cb)
    cb = callbacks:add("frame", onFrame)
end

cb = callbacks:add("frame", firstFrame)
