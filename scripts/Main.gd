extends Node2D

@onready var ball: CharacterBody2D = $Ball
@onready var cat: CharacterBody2D = $Cat
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var game_over_label: Label = %GameOverLabel

var score: int = 0
var speed_multiplier: float = 1.0
var speed_increase_rate: float = 0.08
var max_speed_multiplier: float = 3.0
var game_over_shown: bool = false

func _ready() -> void:
	game_over_label.visible = false
	ball.add_collision_exception_with(cat)
	cat.add_collision_exception_with(ball)
	cat.head_hit_ball.connect(_on_cat_hit_ball)
	cat.body_hit_ball.connect(_on_cat_body_hit)
	cat.jumped.connect(_on_cat_jumped)
	ball.game_over.connect(_on_ball_game_over)
	ball.scored.connect(_on_ball_scored)
	AudioManager.play_music(&"game")
	_update_score_label()
	_update_high_score_label()

func _on_cat_hit_ball() -> void:
	if not ball.is_active:
		return

	ball.bounce()
	score += 1
	_update_score_label()
	_update_high_score_label()

	speed_multiplier = min(speed_multiplier + speed_increase_rate, max_speed_multiplier)
	ball.current_speed_multiplier = speed_multiplier

	cat.play_headbutt()

	var tween := create_tween()
	tween.tween_property(cat, "scale", Vector2(1.15, 0.85), 0.06)
	tween.tween_property(cat, "scale", Vector2(1.0, 1.0), 0.10)

func _on_cat_body_hit() -> void:
	if ball.is_active:
		ball.is_active = false
		cat.is_active = false
		_show_game_over()

func _on_ball_game_over() -> void:
	cat.is_active = false
	_show_game_over()

func _on_cat_jumped() -> void:
	AudioManager.play_sfx(&"jump", 0.05)

func _on_ball_scored() -> void:
	AudioManager.play_sfx(&"bounce", 0.08)

func _show_game_over() -> void:
	if game_over_shown:
		return
	game_over_shown = true

	var new_record := GameState.submit_score(score)
	AudioManager.play_sfx(&"game_over")

	var text := "¡Juego terminado!\nPuntuación: %d\nRécord: %d\n" % [score, GameState.high_score]
	if new_record:
		text += "\n¡Nuevo récord!\n"
	text += "\nShift: reiniciar\nEscape: menú"
	game_over_label.text = text
	game_over_label.visible = true
	_update_high_score_label()

func _update_score_label() -> void:
	score_label.text = "Puntuación: %d" % score

func _update_high_score_label() -> void:
	high_score_label.text = "Récord: %d" % maxi(GameState.high_score, score)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	elif event.is_action_pressed("jump") and not ball.is_active:
		get_tree().reload_current_scene()
