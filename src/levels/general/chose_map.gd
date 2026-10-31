extends Control
@onready var setting: TextureRect = $setting / setting
@onready var option_button: OptionButton = $OptionButton
@export var next_scene: PackedScene


var url_map: = {
	"作者": "https://space.bilibili.com/1986364363?spm_id_from=333.1007.0.0", 
	"美术": "https://space.bilibili.com/169529553?spm_id_from=333.337.0.0", 
	"源代码": "https://github.com/lefengyao/pvz_warG"
}

func _ready() -> void :
	Audiomanager.fade_out_and_stop_current()
func _on_texture_button_pressed() -> void :
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)


func _on_button_pressed() -> void :
	var selected_text = option_button.text
	if url_map.has(selected_text):
		OS.shell_open(url_map[selected_text])
	else:
		print("未找到对应的网址：", selected_text)


func _on_button3_pressed() -> void :
	setting.visible = true
	pass


func _on_button_2_pressed() -> void :
	setting.visible = false
	pass
