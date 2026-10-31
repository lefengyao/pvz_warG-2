extends TextureButton
@onready var texture_rect: TextureRect = $TextureRect
@export var tap_sfx: AudioStream
func _ready() -> void :
	mouse_entered.connect(mouse_enter)
	mouse_exited.connect(mouse_exite)

func mouse_enter():
	texture_rect.visible = true
	Audiomanager.play_sfx(tap_sfx)

func mouse_exite():
	texture_rect.visible = false
