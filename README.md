# GSC-mGBA-bots
A collection of bots for shiny or otherwise hunting in the GBC Pokemon games!

# Usage
Load any of these scripts in mGBA (through the Tools->Scripting submenu) after entering tall grass and cornering. You should use a repel _before_ running any of the scripts if you want to use the repel trick to limit encounters, though you should know this hurts the shiny rates of certain encounters.

## encounter_and_flee_GSC_COMPAT
This version gets into a wild encounter, and if it's not shiny, it runs away. This is compatible with all the GBC Pokemon games, including Korean and Japanese versions! (Just modify the address as shown in the Lua file.) The script will terminate automatically when a shiny is encountered. It works at unbounded speed, tested for many, many hours at over 8000fps.

## shiny_brute_force_mgba_GSC_COMPAT
This version savestates before an encounter, and tries many, many frames, reloading the savestate as necessary and making a new one. This is compatible with all the GBC Pokemon games, including Korean and Japanese versions! (Just modify the address as shown in the Lua file.) The script will terminate automatically when a shiny is encountered. It works at unbounded speed, tested for many, many hours at over 8000fps. It's currently set up for hunting Dunsparse, but you can change it to hunt for anything.

# Speed
These scripts are tested at very high speeds to ensure they are deterministic. For the fastest speeds:
- Go to Tools->Settings->Audio/Video and set "Display driver" to "Software (Qt)".
- Set Frameskip as high as it will go.
- Go to Emulation->Fast Forard Speed and set it to "Unbounded".
- Enable Fast Forward.

# The Unlicense
This project is free to use, modify, and distribute in open or closed source projects. I do ask for a name drop out of kindness, but it's not necessary. Happy hunting!
