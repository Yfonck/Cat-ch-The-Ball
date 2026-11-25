# Cat-ch the Ball

A 2D game for **Godot 4.7** (GL Compatibility). A cat leaps from one side to
the other and headbutts the ball to keep it in the air. Every point makes the
ball and the cat faster. If the ball touches the ground, you lose one of your
three lives.

The high score persists between sessions, and the game includes background
music and sound effects.

## Requirements

- [Godot 4.7](https://godotengine.org/) with the GL Compatibility renderer.

## How to run

1. Open Godot 4.7.
2. Import the `project.godot` file from this folder.
3. Press **F5**. The main scene is `scenes/MainMenu.tscn`.

## Controls

| Action | Key |
|---|---|
| Leap to the opposite side / restart after game over | **Shift** |
| Return to the menu / close the instructions | **Escape** |

## Gameplay

- The cat starts on the left. Press **Shift** to leap in an arc to the
  opposite side.
- On landing the cat flips automatically, ready to leap back. Jumps alternate
  between left and right.
- If the cat's head hits the ball, the ball bounces, you earn **1 point**, and
  both the ball and the cat speed up (the ball up to 3× and the cat up to
  about 1.8×).
- You have **3 lives**, shown as heart icons in the HUD. Each time the ball
  touches the ground you lose one life, and the ball falls again from above
  after a short delay.
- The cat always finishes its jump animation, even when a life is lost or the
  game is over, so it never stays suspended in mid-air.
- When all 3 lives are gone, the `game_over.png` banner appears with the score,
  the top score, and the restart/menu hints.
- Speed affects the ball's gravity, its bounce force, and the cat's jump speed.

## Score and high score

- The score is shown in the top-right corner during play.
- The top score is shown in the menu and on the game over screen.
- A new record is saved only when you beat the previous one; the game over
  screen then shows **New Record!**.
- The record is stored in `user://record.cfg`. On Windows this is
  `%APPDATA%\Godot\app_userdata\Cat-ch the ball\record.cfg`.

## Audio

- Separate background music for the menu and for gameplay.
- Sound effects: menu button click, cat jump, ball bounce, and game over.

| Sound | File |
|---|---|
| Menu click | `assets/audio/ui_click.wav` |
| Cat jump | `assets/audio/cat_jumps.wav` |
| Ball bounce | `assets/audio/ball_bounce.wav` |
| Game over | `assets/audio/game_over.wav` |
| Menu music | `assets/audio/music_menu.wav` |
| Gameplay music | `assets/audio/music_game.wav` |

The repository includes the audio files used by the game. The music and most
sound effects are placeholder WAVs generated with Python (mono, 44.1 kHz /
16-bit). You can replace any of them with real audio as long as you keep the
filenames referenced by `scripts/AudioManager.gd`.

To regenerate the placeholder audio:

```bash
python tools/generate_audio.py
```

> **Warning:** the generator overwrites the WAV files in `assets/audio/`.
> Back up any custom sounds before running it.

## Project structure

```
scenes/
  MainMenu.tscn      Main menu and instructions panel
  Main.tscn          Game scene (background, cat, ball, floor, HUD)
scripts/
  GameState.gd       Autoload: loads and saves the persistent high score
  AudioManager.gd    Autoload: SFX pool and music with track switching
  MainMenu.gd        Menu buttons, instructions panel, and menu music
  Main.gd            Score, high score, progressive speed, lives, game over
  cat.gd             Lateral jump, animations, and head-hit detection
  ball.gd            Falling, bouncing, reset, and round end
  HitArea.gd         Bridge between Area2D signals and the cat script
assets/
  room.png                        Game and menu background
  heart_full.png                  Life icon
  game_over.png                   Game over banner
  Gato atrapa la pelota acuarela.png  Menu illustration
  gato_spriteframes.tres          Cat animations (idle/jump/fall/headbutt)
  pelota_spriteframes.tres        Ball spin animation
  gato_spritesheet_16_frames/     Cat frames (01-14 are used)
  pelota_giro_16_frames/          Ball frames (01-16 are used)
  audio/                          Music and sound effects
fonts/
  Baloo-Regular.ttf
  Caveat-Regular.ttf
  PatrickHand-Regular.ttf
tools/
  generate_audio.py  Deterministic placeholder WAV generator
```

## Technical notes

- Viewport: **640×960**, stretch mode `canvas_items`.
- The menu uses standard `Button` nodes (not `TextureButton`).
- The background `room.png` is a standard non-interlaced PNG (941×1672). The
  game scene scales it to cover the viewport without distortion; the menu uses
  a `TextureRect` with cover stretch mode.
- The repository keeps only the assets referenced by the game. Unused art and
  audio were removed to keep the project clean; they can still be recovered
  from Git history if needed.
