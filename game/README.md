# IwolNoLogout Godot Project

## Requirements

- Godot `4.7.2` or a compatible Godot 4.x version

## Run

1. Open `project.godot` in Godot.
2. Press `F6` or `F5` to run the project.
3. The boot scene automatically opens the foundation test room.

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

