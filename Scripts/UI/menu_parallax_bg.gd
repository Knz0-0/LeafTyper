extends ParallaxBackground

@onready var parallax_layer = $SkyLayer
@onready var parallax_layer2 = $SkyLayer2
@onready var parallax_layer3 = $SkyLayer3
@onready var parallax_layer4 = $SkyLayer4
@onready var parallax_layer5 = $SkyLayer5
@onready var parallax_layer6 = $SkyLayer6
var layer2_base_y
var layer3_base_y
var layer4_base_y
var layer5_base_y
var layer6_base_y

var bg_time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta):
	bg_time += delta
	update_background()


func update_background():
	parallax_layer.scale = Vector2.ONE * (1.0 + sin(bg_time * 0.08) * 0.01)
	parallax_layer2.motion_offset.x += 2 * get_process_delta_time()
	parallax_layer3.motion_offset.x += 3 * get_process_delta_time()
	parallax_layer4.motion_offset.x += 5 * get_process_delta_time()
	parallax_layer5.motion_offset.x += 6 * get_process_delta_time()
	parallax_layer6.motion_offset.x += 8 * get_process_delta_time()
	
	parallax_layer2.motion_offset.y = sin(bg_time * 0.25) * 2
	parallax_layer3.motion_offset.y = sin(bg_time * 0.35) * 3
	parallax_layer4.motion_offset.y = sin(bg_time * 0.45) * 5
	parallax_layer3.motion_offset.y = sin(bg_time * 0.50) * 6
	parallax_layer4.motion_offset.y = sin(bg_time * 0.60) * 8
