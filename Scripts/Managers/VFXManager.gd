extends CanvasLayer

@onready var flash = $Flash

func _ready():
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.color = Color(1,1,1,0)

func white_flash(strength := 0.8, duration := 0.08):
	if not GameManager.flash_enabled:
		return
	flash.color = Color(1,1,1,strength)
	var t = create_tween()
	t.tween_property(flash, "color:a", 0.0, duration)
	
func black_flash(strength := 0.6, duration := 0.12):
	if not GameManager.flash_enabled:
		return
	flash.color = Color(0,0,0,strength)
	var t = create_tween()
	t.tween_property(flash, "color:a", 0.0, duration)
