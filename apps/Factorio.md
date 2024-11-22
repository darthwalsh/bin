## System to collect stats during gameplay
https://wiki.factorio.com/Replay_system
I thought the replay system would be more useful for collecting statistics, but it has several limitations 
- The replay file is really just a list of actions (a.k.a. [[Event Sourcing]])
- you need the exact version of the factorio app in order to play it back correctly 
- The replay might not work right if you have specific mods enabled
- If you were going to add any mod that exported statistics while watching the replay... you might as well just have that mod enabled when you were recording the replay and there's no point to the replay in order to get stats

## Mod to find which resource is limiting
#app-idea 
- [x] Read through logic in 

### GIVEN
I have my Factorio mod installed
### WHEN
I see that my Green Science production is limiting, and isn't getting the right input ingredients
### THEN
The plugin would show what is the bottleneck in my global production
- [ ] Give more specific example

## Notes on existing Bottleneck plugin
I've been using https://github.com/raiguard/BottleneckLite which has no runtime cost, and just adds the red/yellow/green indicators to the sprites at setup.

https://github.com/troelsbjerre/Bottleneck has a check that runs on every `on_tick()` 
I wouldn't need to run logic on every tick, but could only check every 5s? i.e. `on_tick()` skips running anything 99% of the time?

- mod API
	-  [`find_entities_filtered(type=)`](https://lua-api.factorio.com/stable/classes/LuaSurface.html#find_entities_filtered) finds all entities
	- [`entity_status`](https://lua-api.factorio.com/stable/defines.html#defines.entity_status) has `.low_power .working .full_output` 
	- [`LuaEntity .status`](https://lua-api.factorio.com/stable/classes/LuaEntity.html#status)  is one of `entity_status`
- Bottleneck 
	- [sets](https://github.com/troelsbjerre/Bottleneck/blob/5826c545cfcc5f5f772f03f64938e4983f9f900e/settings.lua#L194) `settings.global ["bottleneck-show-low_power-color"]` to [`"red"`](https://github.com/troelsbjerre/Bottleneck/blob/5826c545cfcc5f5f772f03f64938e4983f9f900e/settings.lua#L175) 
	- [`update_settings()`](https://github.com/troelsbjerre/Bottleneck/blob/5826c545cfcc5f5f772f03f64938e4983f9f900e/control.lua#L212) gets `bottleneck-show-low_power-color`  and `icon` and sets `STYLE[low_power]` to the color
	- `on_tick()` [updates](https://github.com/troelsbjerre/Bottleneck/blob/5826c545cfcc5f5f772f03f64938e4983f9f900e/control.lua#L183) graphics from `STYLE` using `.status`
