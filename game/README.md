# IwolNoLogout Godot Project

## Requirements

- Godot `4.7.2` or a compatible Godot 4.x version

## Run

1. Open `project.godot` in Godot.
2. Press `F6` or `F5` to run the project.
3. The boot scene opens the title screen.
4. Select `새 게임` to begin the logout-failure prologue and first candidate round.
5. Progress is saved automatically. `이어하기` resumes the last story or selection step.

To launch the game at a specific window position, use Godot's `--position` option. The display manager preserves a command-line position instead of centering the window.

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path game --windowed --resolution 1280x720 --position 640,1360
```

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD or arrow keys | Left stick |
| Interact | E or Enter | A / Cross |
| Pause | Escape | Start |
| Toggle fullscreen | F11 | — |
| Toggle debug overlay | F3 | — |
| Navigate menus | Arrow keys | D-pad / left stick |
| Confirm menu | Enter or Space | A / Cross |
| Cancel dialog | Escape | B / Circle |

## UI Review Gallery

Debug builds show an `UI 검수` button on the title screen. The gallery displays all 43 approved layout prototypes in order.

| Action | Keyboard | Gamepad |
|---|---|---|
| Previous screen | Left arrow | D-pad left |
| Next screen | Right arrow or Enter | D-pad right or A / Cross |
| Return to title | Escape | B / Circle |

Screens `02` through `43` are layout prototypes. They do not count as completed gameplay systems until their Control nodes, input, and data logic are connected.

## Current Playable Flow

- Broadcast closing and logout failure
- Tuto AI introduction and first suspicious clue
- Round 1 limited-information impression
- Simultaneous reveal of Seoyun and Doyun
- Permanent companion confirmation or permanent abandonment of both
- Automatic save and continue from the latest phase

The foundation test room remains available as `scenes/system/test_room.tscn`, but it is no longer the default new-game destination.

## Validate

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script tests/smoke_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --quit-after 3
```

The current test room validates project startup, pixel-resolution settings, input registration, scene loading, display controls, player movement, collision, camera behavior, and interaction detection.

Run the movement test with:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script tests/player_movement_test.gd
```

