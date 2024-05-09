-- Function to check if a given IV value is shiny
function isShiny(attack, defense, speed, special)
    return (special == 10 and speed == 10 and defense == 10 and ((attack & 2) > 0))
end

local state = emu:saveStateBuffer()
local totalEncounterCounter = 0
local previousFrame = emu:currentFrame() + 2
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

-- desiredSpecies
-- Tells the script which mon you are looking for
-- Look up the species ID here: https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_index_number_(Generation_II)
-- If -1, searches for all possible species
local desiredSpecies = 206

-- Main function
local function onFrame()
    currentFrame = emu:currentFrame() - previousFrame
    if currentFrame < -1 then
        return
    end
    if currentFrame == -1 then
        console:log("reset")
        state = emu:saveStateBuffer()
    end

    if emu:read8(enemyAddr+0x22) == 0 then
        local rand = math.random()
        if rand < 0.1 then
            emu:clearKey(encounterDir2)
            emu:addKey(encounterDir1)
        else 
            if rand < 0.2 then
                    emu:clearKey(encounterDir1)
                    emu:addKey(encounterDir2)
            else
                emu:clearKey(encounterDir1)
                emu:clearKey(encounterDir2)
            end
        end
        previousFrame = emu:currentFrame() + 1
        return
    end
    if emu:read8(enemyAddr+0x21) == 1 and emu:read8(enemyAddr+0x22) > 0 then
        emu:clearKey(C.GB_KEY.LEFT)
        emu:clearKey(C.GB_KEY.DOWN)

        if currentFrame > 1 then
            if desiredSpecies ~= -1 and emu:read8(enemyAddr+0x22) ~= desiredSpecies then
                emu:loadStateBuffer(state)
                previousFrame = emu:currentFrame() + 200
                console:log("Not the desired species. Moving on...")
                return
            end
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
            buffer:print("DVS: def(" .. defense .. ") atk(" .. attack .. ") speed(" .. speed .. ") spec(" .. special .. ")")

            if isShiny(attack, defense, speed, special) then
                console:log("Shiny Encounter! Total Encounters: " .. totalEncounterCounter)
                
                -- Enable alarm by uncommenting this line (Windows only, though you could modify it for Mac/Linux/etc)
                -- os.execute("explorer.exe https://www.youtube.com/video/SAjRuGdXeOE")

                callbacks:remove(cb)
            end

            emu:loadStateBuffer(state)
            previousFrame = emu:currentFrame() + 200
        end
    end
end

cb = callbacks:add("frame", onFrame)
