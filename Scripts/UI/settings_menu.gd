extends Control


@onready var music_slider = $CenterContainer/GridContainer/MusicSlider
@onready var sfx_slider = $CenterContainer/GridContainer/SFXSlider
@onready var fullscreen_check = $CenterContainer/GridContainer/FullscreenCheck
@onready var flash_check = $CenterContainer/GridContainer/FlashCheck
@onready var back_button = $BackButton

func _ready():
	music_slider.value = GameManager.music_volume
	sfx_slider.value = GameManager.sfx_volume
	fullscreen_check.button_pressed = GameManager.fullscreen
	flash_check.button_pressed = GameManager.flash_enabled
	
	music_slider.value_changed.connect(func(value):
		GameManager.music_volume = value
		MusicManager.set_music_volume(value)
		GameManager.save_data()
	)
	sfx_slider.value_changed.connect(func(value):
		GameManager.sfx_volume = value
		SoundManager.set_sfx_volume(value)
		GameManager.save_data()
	)
	fullscreen_check.toggled.connect(func(enabled):
		GameManager.fullscreen = enabled
		
		if enabled:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		GameManager.save_data()
	)
	flash_check.toggled.connect(func(enabled):
		GameManager.flash_enabled = enabled
		GameManager.save_data()
	)
	
	back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(func():
		SoundManager.play_sfx("interface_hover")
	)
	

func _on_back_pressed():
	SoundManager.play_sfx("clash")
	GameManager.return_to_menu()
