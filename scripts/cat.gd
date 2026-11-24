extends CharacterBody2D

signal head_hit_ball
signal body_hit_ball
signal jumped

@export var jump_force: float = -750.0
@export var gravity: float = 1800.0

var can_jump: bool = true
var is_active: bool = true
var headbutt_time: float = 0.0

@onready var visual: AnimatedSprite2D = get_node_or_null("Visual") as AnimatedSprite2D

func _ready() -> void:
	if visual and visual.sprite_frames and visual.sprite_frames.has_animation("idle"):
		visual.play("idle")

func _physics_process(delta: float) -> void:
	if not is_active:
		return

	velocity.y += gravity * delta
	move_and_slide()

	can_jump = is_on_floor()

	if headbutt_time > 0.0:
		headbutt_time = maxf(headbutt_time - delta, 0.0)
		return

	if visual and visual.sprite_frames:
		if is_on_floor():
			if visual.sprite_frames.has_animation("idle") and visual.animation != "idle":
				visual.play("idle")
		else:
			if velocity.y < 0:
				if visual.sprite_frames.has_animation("jump") and visual.animation != "jump":
					visual.play("jump")
			else:
				if visual.sprite_frames.has_animation("fall"):
					if visual.animation != "fall":
						visual.play("fall")
				elif visual.sprite_frames.has_animation("jump"):
					if visual.animation != "jump":
						visual.play("jump")

func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("jump") and can_jump:
		velocity.y = jump_force
		can_jump = false
		jumped.emit()

func _on_head_area_body_entered(body: Node2D) -> void:
	if body.name == "Ball" and velocity.y < 0:
		head_hit_ball.emit()

func _on_body_area_body_entered(body: Node2D) -> void:
	if body.name == "Ball" and is_on_floor() and is_active:
		body_hit_ball.emit()

func play_headbutt() -> void:
	headbutt_time = 0.18
	if visual and visual.sprite_frames and visual.sprite_frames.has_animation("headbutt"):
		visual.play("headbutt")
