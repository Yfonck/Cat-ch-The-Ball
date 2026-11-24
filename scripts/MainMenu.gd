extends Control

@onready var play_button: TextureButton = $MenuPanel/VBoxContainer/PlayButton
@onready var instructions_button: TextureButton = $MenuPanel/VBoxContainer/InstructionsButton
@onready var quit_button: TextureButton = $MenuPanel/VBoxContainer/QuitButton
@onready var record_label: Label = $RecordLabel
@onready var instructions_panel: PanelContainer = $InstructionsPanel
@onready var close_button: Button = $InstructionsPanel/VBoxContainer/CloseButton

const GAME_SCENE := "res://scenes/Main.tscn"

const TINT_NORMAL := Color(1, 1, 1, 1)
const TINT_HOVER := Color(0.9, 0.9, 0.9, 1)
const TINT_PRESSED := Color(0.75, 0.75, 0.75, 1)

var _button_states: Dictionary = {}

func _ready() -> void:
	instructions_panel.visible = false
	record_label.text = "Top Score: %d" % GameState.high_score
	AudioManager.play_music(&"menu")

	_register_texture_button(play_button)
	_register_texture_button(instructions_button)
	_register_texture_button(quit_button)

	play_button.pressed.connect(_on_play_pressed)
	instructions_button.pressed.connect(_on_instructions_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_button.pressed.connect(_on_close_pressed)

	play_button.grab_focus()

func _register_texture_button(button: TextureButton) -> void:
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_button_states[button] = {"hover": false, "focus": false, "pressed": false}

	button.mouse_entered.connect(_set_button_state.bind(button, "hover", true))
	button.mouse_exited.connect(_set_button_state.bind(button, "hover", false))
	button.focus_entered.connect(_set_button_state.bind(button, "focus", true))
	button.focus_exited.connect(_set_button_state.bind(button, "focus", false))
	button.button_down.connect(_set_button_state.bind(button, "pressed", true))
	button.button_up.connect(_set_button_state.bind(button, "pressed", false))

func _set_button_state(button: TextureButton, key: String, active: bool) -> void:
	if not _button_states.has(button):
		return

	var state: Dictionary = _button_states[button]
	state[key] = active

	if state["pressed"]:
		button.modulate = TINT_PRESSED
	elif state["hover"] or state["focus"]:
		button.modulate = TINT_HOVER
	else:
		button.modulate = TINT_NORMAL

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and instructions_panel.visible:
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func _on_play_pressed() -> void:
	AudioManager.play_sfx(&"click")
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_instructions_pressed() -> void:
	AudioManager.play_sfx(&"click")
	instructions_panel.visible = true
	close_button.grab_focus()

func _on_close_pressed() -> void:
	AudioManager.play_sfx(&"click")
	instructions_panel.visible = false
	play_button.grab_focus()

func _on_quit_pressed() -> void:
	AudioManager.play_sfx(&"click")
	await get_tree().create_timer(0.12).timeout
	get_tree().quit()
