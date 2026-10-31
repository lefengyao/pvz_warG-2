extends CanvasLayer

var in_game_setting: PackedScene = load("res://scenes/ui/in_game_setting.tscn")
var ingameset: Control

func _ready() -> void :
	layer = 10
	_migrate_audio_settings()
	ingameset = in_game_setting.instantiate()
	add_child(ingameset)
	ingameset.visible = false


func _migrate_audio_settings(save_path: String = "user://audio_settings.tres") -> void:
	# Older saves serialize the script path without a UID. Preserve their values
	# and a backup before ResourceLoader sees the moved resource.
	const CURRENT_SCRIPT := "res://src/ui/music/music_setting.gd"
	var legacy_script := "res://" + "UI/UI/music/music_setting.gd"
	if not FileAccess.file_exists(save_path):
		return
	var contents := FileAccess.get_file_as_string(save_path)
	if not contents.contains(legacy_script):
		return
	var backup_path := save_path + ".before_layout_migration.bak"
	if not FileAccess.file_exists(backup_path):
		var copy_error := DirAccess.copy_absolute(
			ProjectSettings.globalize_path(save_path),
			ProjectSettings.globalize_path(backup_path)
		)
		if copy_error != OK:
			push_error("Cannot back up legacy audio settings: ", copy_error)
			return
	var migrated_path := save_path + ".migration_tmp"
	var migrated_file := FileAccess.open(migrated_path, FileAccess.WRITE)
	if migrated_file == null:
		push_error("Cannot write migrated audio settings: ", FileAccess.get_open_error())
		return
	migrated_file.store_string(contents.replace(legacy_script, CURRENT_SCRIPT))
	migrated_file.close()
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(migrated_path),
		ProjectSettings.globalize_path(save_path)
	)
	if rename_error != OK:
		push_error("Cannot replace migrated audio settings: ", rename_error)
