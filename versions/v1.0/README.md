# Skyhop version 1.0

`Skyhop-v1.0.rbxl` is the full original Roblox place, saved through Studio's native Save to File dialog.

`Skyhop-v1.0.rbxm` is an additional native serialization archive with the original course, gameplay scripts, coin and checkpoint objects, original baseplate and spawn, camera, and lighting settings. Studio successfully deserialized all 248 archived instances and verified both script sources and the course hierarchy count. The model package omits the unused empty Terrain.

Open the `.rbxl` file in Roblox Studio to return to version 1.0. `RESTORE-V1.luau` is an alternative self-contained restoration command for MCP Edit mode. It keeps the current objects in a temporary rollback folder under ServerStorage; it was used successfully to materialize the full version 1.0 place file.

The adjacent source files, [project notes](PROJECT.md), playtest results, and finish screenshot document the original course. Use the `.rbxl` to open the exact tested level. The Luau source and installer record how the course was built and tuned.
