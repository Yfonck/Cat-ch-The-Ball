extends Node2D

const MAX_LIVES: int = 3

@onready var ball: CharacterBody2D = $Ball
@onready var cat: CharacterBody2D = $Cat
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var game_over_label: Label = %GameOverLabel
@onready var lives_container: HBoxContainer = %LivesContainer
@onready var game_over_overlay: ColorRect = %GameOverOverlay
@onready var game_over_banner: TextureRect = %GameOverBanner
@onready var ball_reset_timer: Timer = $BallResetTimer

var score: int = 0
var lives: int = MAX_LIVES
var speed_multiplier: float = 1.0
var speed_increase_rate: float = 0.08
var max_speed_multiplier: float = 3.0
var game_over_shown: bool = false

func _ready() -> void:
	game_over_overlay.visible = false
	game_over_banner.visible = false
	game_over_label.visible = false
	ball.add_collision_exception_with(cat)
	cat.add_collision_exception_with(ball)
	cat.head_hit_ball.connect(_on_cat_hit_ball)
	cat.jumped.connect(_on_cat_jumped)
	ball.game_over.connect(_on_ball_game_over)
	ball.scored.connect(_on_ball_scored)
	ball_reset_timer.timeout.connect(_on_ball_reset_timeout)
	cat.set_ball_speed_multiplier(speed_multiplier)
	AudioManager.play_music(&"game")
	_update_score_label()
	_update_high_score_label()
	_update_lives_display()

func _on_cat_hit_ball() -> void:
	if not ball.is_active or game_over_shown:
		return

	ball.bounce()
	score += 1
	_update_score_label()
	_update_high_score_label()

	speed_multiplier = min(speed_multiplier + speed_increase_rate, max_speed_multiplier)
	ball.current_speed_multiplier = speed_multiplier
	cat.set_ball_speed_multiplier(speed_multiplier)

	cat.play_headbutt()

	var tween := create_tween()
	tween.tween_property(cat, "scale", Vector2(1.15, 0.85), 0.06)
	tween.tween_property(cat, "scale", Vector2(1.0, 1.0), 0.10)

func _on_ball_game_over() -> void:
	if game_over_shown:
		return

	lives = maxi(lives - 1, 0)
	_update_lives_display()

	if lives <= 0:
		ball_reset_timer.stop()
		cat.is_active = false
		_show_game_over()
		return

	ball_reset_timer.start()

func _on_ball_reset_timeout() -> void:
	if game_over_shown:
		return
	ball.reset_ball()

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

	var text := "Score: %d\nTop Score: %d\n" % [score, GameState.high_score]
	if new_record:
		text += "\nNew Record!\n"
	text += "\nShift: restart\nEscape: menu"
	game_over_label.text = text
	game_over_overlay.visible = true
	game_over_banner.visible = true
	game_over_label.visible = true
	_update_high_score_label()

func _update_lives_display() -> void:
	var hearts := lives_container.get_children()
	for i in hearts.size():
		var heart := hearts[i] as CanvasItem
		if heart == null:
			continue
		heart.modulate = Color.WHITE if i < lives else Color(0.25, 0.25, 0.25, 0.45)

func _update_score_label() -> void:
	score_label.text = "Score: %d" % score

func _update_high_score_label() -> void:
	high_score_label.text = "Top Score: %d" % maxi(GameState.high_score, score)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	elif event.is_action_pressed("jump") and game_over_shown:
		get_tree().reload_current_scene()
