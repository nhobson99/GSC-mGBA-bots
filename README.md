# GSC-mGBA-bots
A collection of bots for shiny or otherwise hunting in the GBC Pokemon games!

# Usage
Load any of these scripts in mGBA (through the Tools->Scripting submenu) after entering tall grass and cornering. You should use a repel _before_ running any of the scripts if you want to use the repel trick to limit encounters, though you should know this hurts the shiny rates of certain encounters.

# NEW
You can now enable an alarm when a shiny is found for even _more_ AFK! Just uncomment the alarm line by removing the dash.

## encounter_and_flee_GSC_COMPAT
This version gets into a wild encounter, and if it's not shiny, it runs away. This is compatible with all the GBC Pokemon games, including Korean and Japanese versions! (Just modify the address as shown in the Lua file.) The script will terminate automatically when a shiny is encountered. It works at unbounded speed, tested for many, many hours at over 8000fps.

## shiny_brute_force_mgba_GSC_COMPAT
This version savestates before an encounter, and tries many, many frames, reloading the savestate as necessary and making a new one. This is compatible with all the GBC Pokemon games, including Korean and Japanese versions! (Just modify the address as shown in the Lua file.) The script will terminate automatically when a shiny is encountered. It works at unbounded speed, tested for many, many hours at over 8000fps. It's currently set up for hunting Dunsparse, but you can change it to hunt for anything.

## static_suicune_sr
This is literally just for catching Suicune. It has been tested on a livestream by Chaotic Meatball. To use it, just save a few tiles south of the Tin Tower entrance. Crystal only, for obvious reasons. It static resets until it encounters a shiny, then stops just like all the other scripts.

## shiny_roamers_rta
This is for hunting Raikou and Entei in Crystal version (currently hardcoded for Raikou). Usage is as follows: Put repels as your first bag item, and save just south of the north gate to the Ruins of Alph. Then just run the script. Not thoroughly tested yet, and it's very slow. I wrote this specifically to be a real-time viable strat, equivalent to the player cycling and checking the Pokedex to find the roamer's location, then use a repel and encounter it, and soft reset if it's not shiny. If you don't care about doing things """legit""", then you can just use the shiny brute force method instead (savestate abuse, basically).

# Speed
These scripts are tested at very high speeds to ensure they are deterministic. For the fastest speeds:
- Go to Tools->Settings->Audio/Video and set "Display driver" to "Software (Qt)".
- Set Frameskip as high as it will go.
- Go to Emulation->Fast Forard Speed and set it to "Unbounded".
- Enable Fast Forward.

# The Unlicense
This project is free to use, modify, and distribute in open or closed source projects. I do ask for a name drop out of kindness, but it's not necessary. Happy hunting!
