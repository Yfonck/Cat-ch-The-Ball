extends Area2D

@export var target_method: StringName = &""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if target_method == &"":
		return
	var parent := get_parent()
	if parent and parent.has_method(target_method):
		parent.call(target_method, body)
