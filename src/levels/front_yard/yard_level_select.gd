extends Control

var level: int = 1
var chosemapscene: PackedScene = load("res://scenes/levels/chose_map.tscn")


@export var level_resources: Array[LevelResource] = []

@onready var label: Label = $HBoxContainer / TextureRect / Label
@onready var label1: Label = $Label

@export var tap_sfx: AudioStream


var max_level: int:
	get:
		return level_resources.size()


func _ready() -> void :

	update_labels()


func _on_texture_button_pressed() -> void :
	level -= 1
	level = clampi(level, 1, max_level)
	Audiomanager.play_sfx(tap_sfx)
	update_labels()


func _on_texture_button_2_pressed() -> void :
	level += 1
	level = clampi(level, 1, max_level)
	Audiomanager.play_sfx(tap_sfx)
	update_labels()


func update_labels() -> void :

	label.text = str(level)


	if max_level > 0 and level - 1 < max_level:
		var res = level_resources[level - 1]
		if res != null:
			label1.text = res.level_name
		else:
			label1.text = "？？？"
	else:
		label1.text = "无关卡"


func _on_button_pressed() -> void :
	if max_level == 0:
		return

	var res: LevelResource = level_resources[level - 1]
	if res == null or res.level_scene == null:
		return

	var level_instance = res.level_scene.instantiate()
	if res.logic_scene != null and "level_logic" in level_instance:
		level_instance.level_logic = res.logic_scene

	get_tree().change_scene_to_node(level_instance)


func _on_button2_pressed() -> void :
	get_tree().change_scene_to_packed(chosemapscene)
