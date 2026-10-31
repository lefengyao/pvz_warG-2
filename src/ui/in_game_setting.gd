extends Control


@export var game_control: Control


@export var main_menu_scene: PackedScene = load("res://scenes/levels/chose_map.tscn")


@export var resume_control: Control



func pause_game() -> void :
	if game_control:
		game_control.process_mode = PROCESS_MODE_DISABLED
	visible = true



func go_to_main_menu() -> void :

	if game_control:
		game_control.process_mode = PROCESS_MODE_INHERIT


	if main_menu_scene:
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		push_error("主菜单场景未设置！")
	visible = false


func resume_game() -> void :
	if game_control:
		game_control.process_mode = PROCESS_MODE_INHERIT
	visible = false



func _on_button_pressed() -> void :
	go_to_main_menu()


func _on_button_2_pressed() -> void :
	resume_game()
