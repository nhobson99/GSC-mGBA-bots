-- Function to check if a given IV value is shiny
function isShiny(attack, defense, speed, special)
    return (special == 10 and speed == 10 and defense == 10 and ((attack & 2) > 0))
end

local state = emu:saveStateBuffer()
local totalEncounterCounter = 0
local previousFrame = emu:currentFrame() + 100
local buffer = console:createBuffer("Tracker")
local cb

-- OPTIONS

-- enemyAddr: Stores the memory location for wild Total encounters
-- Follow these instructions:
--      English Gold/Silver, set enemyAddr to 0xd0f5
--      Japanese Gold/Silver, set enemyAddr to 0xd0e7
--      Korean Gold/Silver, set enemyAddr to 0xd1b2
--      Japanese Crystal, set enemyAddr to 0xd23d
--      English Crystal, set enemyAddr to 0xd20c
local enemyAddr = 0xd20c

-- encounterDir1, encounterDir2
-- These are the directions to walk in to get into an encounter
-- It's best to use the corner method:
--     Align your character with a corner
--     The two directions with walls, use these as encounterDir1 and encounterDir2
local encounterDir1 = C.GB_KEY.RIGHT
local encounterDir2 = C.GB_KEY.DOWN

-- Main function
local function onFrame()
    local currentFrame = emu:currentFrame() - previousFrame

    if currentFrame > 1200 then
        emu:clearKey(C.GB_KEY.A)
        emu:clearKey(C.GB_KEY.B)
        emu:clearKey(C.GB_KEY.LEFT)
        emu:clearKey(C.GB_KEY.RIGHT)
        emu:clearKey(C.GB_KEY.UP)
        emu:clearKey(C.GB_KEY.DOWN)
        previousFrame = emu:currentFrame() + 200
        return
    end

    if emu:read8(enemyAddr+0x22) == 0 then
        if currentFrame == 2 then
            emu:addKey(encounterDir1)
        end
        if currentFrame == 4 then
            emu:clearKey(encounterDir1)
            emu:addKey(encounterDir2)
        end
        if currentFrame >= 6 then
            emu:clearKey(encounterDir2)
            previousFrame = emu:currentFrame() + 1
        end
        return
    end
    if emu:read8(enemyAddr+0x21) == 1 then
        if currentFrame >= 990 then
            emu:addKey(C.GB_KEY.B)
            return
        end
        if currentFrame >= 910 then
            emu:clearKey(C.GB_KEY.B)
            return
        end
        if currentFrame >= 900 then
            emu:addKey(C.GB_KEY.B)
            return
        end
        if currentFrame >= 890 then
            emu:clearKey(C.GB_KEY.A)
            return
        end
        if currentFrame >= 880 then
            emu:clearKey(C.GB_KEY.DOWN)
            emu:addKey(C.GB_KEY.A)
            return
        end
        if currentFrame >= 870 then
            emu:clearKey(C.GB_KEY.RIGHT)
            emu:addKey(C.GB_KEY.DOWN)
            return
        end
        if currentFrame >= 860 then
            emu:addKey(C.GB_KEY.RIGHT)
            return
        end
        if currentFrame >= 410 then
            emu:clearKey(C.GB_KEY.B)
            return
        end
        if currentFrame >= 400 then
            emu:addKey(C.GB_KEY.B)
            return
        end
        if currentFrame == 300 then
            emu:clearKey(C.GB_KEY.LEFT)
            emu:clearKey(C.GB_KEY.DOWN)
            emu:clearKey(C.GB_KEY.RIGHT)
            emu:clearKey(C.GB_KEY.UP)

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
            buffer:print("Compound Odds: " .. string.format("%.3f", 100*(1-(8191/8192)^totalEncounterCounter)) .. "%\n")
            buffer:print("DVS:\n  def(" .. defense .. ")\n  atk(" .. attack .. ")\n  speed(" .. speed .. ")\n  spec(" .. special .. ")")
            

            if isShiny(attack, defense, speed, special) then
                console:log("Shiny Encounter! Total Encounters: " .. totalEncounterCounter)
                callbacks:remove(cb)
            end

            return
        end
    end
end

cb = callbacks:add("frame", onFrame)
