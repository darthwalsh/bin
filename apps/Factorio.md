## System to collect stats during gameplay
https://wiki.factorio.com/Replay_system
I thought the replay system would be more useful for collecting statistics, but it has several limitations 
- The replay file is really just a list of actions (a.k.a. [[Event Sourcing]])
- you need the exact version of the factorio app in order to play it back correctly 
- The replay might not work right if you have specific mods enabled
- If you were going to add any mod that exported statistics while watching the replay... you might as well just have that mod enabled when you were recording the replay and there's no point to the replay in order to get stats