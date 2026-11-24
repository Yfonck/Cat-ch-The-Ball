extends CharacterBody2D

signal head_hit_ball
signal jumped

@export var left_x: float = 120.0
@export var right_x: float = 520.0
@export var jump_height: float = 200.0
@export var base_jump_duration: float = 0.65
@export var cat_speed_per_ball: float = 0.4

var is_active: bool = true
var grounded: bool = true
var facing_left: bool = false
var headbutt_time: float = 0.0

var _ground_y: float = 0.0
var _jumping: bool = false
var _jump_t: float = 0.0
var _jump_duration: float = 0.65
var _start_x: float = 0.0
var _target_x: float = 0.0
var _ball_speed: float = 1.0

@onready var visual: AnimatedSprite2D = get_node_or_null("Visual") as AnimatedSprite2D

func _ready() -> void:
	_ground_y = position.y
	position.x = left_x
	facing_left = false
	_jump_duration = base_jump_duration
	_apply_facing()
	_play_anim(&"idle")

func set_ball_speed_multiplier(value: float) -> void:
	_ball_speed = maxf(value, 1.0)

func _physics_process(delta: float) -> void:
	# The jump and animation keep running even when the cat is inactive,
	# so it always finishes landing instead of freezing mid-air.
	if _jumping:
		_update_jump(delta)

	if headbutt_time > 0.0:
		headbutt_time = maxf(headbutt_time - delta, 0.0)
		_play_anim(&"headbutt")
	elif _jumping:
		if _jump_t < 0.5:
			_play_anim(&"jump")
		else:
			_play_anim(&"fall")
	else:
		_play_anim(&"idle")

func _input(event: InputEvent) -> void:
	if not is_active or not grounded:
		return

	if event.is_action_pressed("jump"):
		_start_jump()

func _update_jump(delta: float) -> void:
	_jump_t = minf(_jump_t + delta / _jump_duration, 1.0)
	position.x = lerpf(_start_x, _target_x, _jump_t)
	position.y = _ground_y - sin(_jump_t * PI) * jump_height

	if _jump_t >= 1.0:
		_land()

func _start_jump() -> void:
	grounded = false
	_jumping = true
	_jump_t = 0.0
	_start_x = position.x
	_target_x = right_x if _start_x <= (left_x + right_x) * 0.5 else left_x

	var cat_speed := 1.0 + (_ball_speed - 1.0) * cat_speed_per_ball
	_jump_duration = maxf(base_jump_duration / maxf(cat_speed, 0.01), 0.01)

	jumped.emit()

func _land() -> void:
	position = Vector2(_target_x, _ground_y)
	_jumping = false
	grounded = true
	facing_left = _target_x > _start_x
	_apply_facing()

func _on_head_area_body_entered(body: Node2D) -> void:
	if body.name == "Ball" and is_active:
		head_hit_ball.emit()

func play_headbutt() -> void:
	headbutt_time = 0.18
	_play_anim(&"headbutt")

func _play_anim(anim: StringName) -> void:
	if visual == null or visual.sprite_frames == null:
		return
	if visual.sprite_frames.has_animation(anim) and visual.animation != anim:
		visual.play(anim)

func _apply_facing() -> void:
	if visual:
		visual.flip_h = facing_left
