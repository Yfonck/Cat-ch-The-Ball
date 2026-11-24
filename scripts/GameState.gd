extends Node

const SAVE_PATH := "user://record.cfg"

var high_score: int = 0

func _ready() -> void:
	load_record()

func load_record() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		high_score = maxi(int(config.get_value("record", "high_score", 0)), 0)

func save_record() -> void:
	var config := ConfigFile.new()
	config.set_value("record", "high_score", high_score)
	var err := config.save(SAVE_PATH)
	if err != OK:
		push_warning("Could not save the record to %s (error %d)." % [SAVE_PATH, err])

func submit_score(points: int) -> bool:
	if points <= high_score:
		return false
	high_score = points
	save_record()
	return true

func reset_record() -> void:
	high_score = 0
	save_record()
