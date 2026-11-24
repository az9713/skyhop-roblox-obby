# Skyhop Obby

Built directly in the open Roblox Studio `Place1` using Roblox's installed first-party `StudioMCP.exe`.

## Gameplay

- Stage 1: Rainbow Steps — five broad stepping stones.
- Stage 2: Lava Lane — four lava bars, a lava pool, and an exit jump.
- Stage 3: Summit Sprint — five gently rising, wide platforms and a checkered finish gate with a trophy.
- Three green checkpoints; falling or touching lava respawns at the last checkpoint.
- Fifteen coins, collected independently for each player. Collected coins disappear for that player and survive death within the current run.
- HUD, progress meter, finish card, confetti, and Play Again button.
- WASD or arrow keys to move, Space to jump; standard Roblox touch controls on mobile.

Progress is kept for the current server session; cross-session saving was not requested and is not implemented.

## Playtest results

Actual Humanoid movement and jumps were exercised through MCP, with server-owned progression and coin counts checked. No teleport was used to traverse the stages. One character reload was used to reset test position at checkpoint 2 while tuning the test driver.

| Check | Result |
| --- | --- |
| Five rainbow jumps and checkpoint 2 | Passed; 5 coins |
| Coin visual disappears after collection | Passed |
| Repeated coin contact does not award duplicates | Passed |
| Lava kills and respawns at checkpoint 2 | Passed; 6 coins retained |
| Four lava jumps and exit gaps to checkpoint 3 | Passed; 10 coins |
| Fall resets to checkpoint 3 | Passed; 10 coins retained |
| Five summit jumps and finish line | Passed after widening summit platforms; 15 coins |
| Finish card and full coin count | Visually checked |
| Click Play Again | Passed; coins reset, checkpoint 1, win card hidden, coins visible again |
| Final playtest console | Only game initialization and finish messages; no runtime errors |

The summit entrance was made more forgiving after its first playtest. The tested geometry was applied to Edit mode afterward. Mobile layout and multiple simultaneous players were outside this test run.

Raw MCP results are available for [Rainbow Steps](qa_stage1_result.json), [Lava Lane](qa_stage2_result.json), [Summit Sprint](qa_stage3_result.json), [lava respawn](qa_lava_respawn_result.json), [fall respawn](qa_fall_respawn_result.json), and [replay](qa_restart_result.json).

## Studio organization

- `Workspace.SkyhopObby`: platforms, hazards, checkpoints, coins, scenery, finish trigger.
- `ServerScriptService.SkyhopServer`: authoritative gameplay.
- `StarterPlayer.StarterPlayerScripts.SkyhopClient`: HUD and visual effects.
- `ReplicatedStorage.SkyhopRestart`: rate-limited replay request, accepted only after finishing.

Existing baseplate and spawn objects were retained. The original spawn was disabled; the baseplate and its textures were hidden. Their prior values are recorded in `SkyhopOriginalEnabled` / `SkyhopOriginalTransparency` attributes. Lighting was adjusted for the course.

## Local sources

`build_world.luau`, `course.server.luau`, and `course.client.luau` are editable source backups. `install_course.luau` combines the world builder and gameplay scripts for a fresh Studio place. The installer intentionally refuses to replace an existing `SkyhopObby` model. Use the archived `.rbxl` for the exact tested place.

The original build used a small Python CLI bridge to call the first-party Studio MCP server. The [repository README](../../README.md) explains how to connect Codex to your own Studio session.

Version 1.0 ships as a local Studio place file.
