extends CharacterBody2D

signal scored
signal game_over

@export var gravity: float = 900.0
@export var bounce_force: float = -900.0
@export var max_fall_speed: float = 900.0
@export var max_bounce_height: float = 600.0

var current_speed_multiplier: float = 1.0
var is_active: bool = true

@onready var visual: Node = get_node_or_null("Visual")

func _ready() -> void:
	if visual is AnimatedSprite2D and visual.sprite_frames:
		if visual.sprite_frames.has_animation("spin"):
			visual.play("spin")
		elif visual.sprite_frames.has_animation("idle"):
			visual.play("idle")

func _physics_process(delta: float) -> void:
	if not is_active:
		return

	velocity.y += gravity * delta * current_speed_multiplier
	velocity.y = min(velocity.y, max_fall_speed * current_speed_multiplier)
	move_and_slide()

	if visual and visual is Sprite2D:
		visual.rotation += velocity.y * delta * 0.01

	if is_on_floor():
		is_active = false
		game_over.emit()

func bounce() -> void:
	if not is_active:
		return
	var gravity_now := gravity * current_speed_multiplier
	var bounce_speed := absf(bounce_force) * current_speed_multiplier
	var max_bounce_speed := sqrt(2.0 * gravity_now * max_bounce_height)
	velocity.y = -minf(bounce_speed, max_bounce_speed)
	scored.emit()

	if visual is AnimatedSprite2D and visual.sprite_frames:
		if visual.sprite_frames.has_animation("spin"):
			visual.play("spin")
