extends Control

@onready var coins_label = $CoinsLabel
@onready var back_button = $BackButton
@onready var grid = $GridContainer

func _ready() -> void:
	update_coins()
	generate_skin_buttons()
	refresh_all_buttons()
	back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(func():
		SoundManager.play_sfx("interface_hover")
	)


func _on_back_pressed():
	SoundManager.play_sfx("clash")
	GameManager.return_to_menu()

func update_coins():
	coins_label.text = "RYO : " + str(roundi(GameManager.coins))
	
func generate_skin_buttons():
	for skin_name in GameManager.skins_data.keys():
		var btn = create_skin_button(skin_name)
		grid.add_child(btn)
		

func create_skin_button(skin_name:String) -> Button:
	var btn = Button.new()

	btn.custom_minimum_size = Vector2(160, 160) # 🔥 taille fixe
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL

	btn.set_meta("skin", skin_name)

	# container
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn.add_child(vbox)

	# preview sprite
	var preview = AnimatedSprite2D.new()
	preview.name = "Preview"
	preview.scale = Vector2(2,2) # ajuste selon ton jeu

	vbox.add_child(preview)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	preview.position = Vector2(100, 100)

	# label texte
	var label = Label.new()
	label.name = "Label"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	# charger frames
	var path = "res://Assets/SpriteFrames/%s_SpriteFrames.tres" % skin_name
	if ResourceLoader.exists(path):
		preview.frames = load(path)

	update_button_visual(btn)

	btn.pressed.connect(func():
		SoundManager.play_sfx("skin_select", -10)
		on_skin_pressed(skin_name)
	)
	
	btn.mouse_entered.connect(func():
		if btn.disabled:
			return
		SoundManager.play_sfx("interface_hover")
	)
	
	return btn


func update_button_text(btn:Button, skin_name:String):
	if skin_name in GameManager.unlocked_skins:
		if skin_name == GameManager.equipped_skin:
			btn.text = skin_name + "\n(EQUIPPED)"
			btn.modulate = Color(0.6, 1, 0.6)
		else:
			btn.text = skin_name + "\nEquip"
			btn.modulate = Color(1,1,1)
	else:
		var cost = GameManager.skins_data[skin_name]["cost"]
		btn.text = skin_name + "\n" + str(roundi(cost)) + " RYO"
		btn.modulate = Color(0.8,0.8,0.8)


func on_skin_pressed(skin_name:String):
	if skin_name in GameManager.unlocked_skins:
		GameManager.equip_skin(skin_name)
	else:
		if GameManager.buy_skin(skin_name):
			GameManager.equip_skin(skin_name)

	refresh_all_buttons()
	update_coins()
	

func refresh_all_buttons():
	for btn in grid.get_children():
		update_button_visual(btn)

func update_button_visual(btn:Button):
	var skin_name = btn.get_meta("skin")
	var preview = btn.get_node_or_null("VBox/Preview")

	

	if preview == null:
		print("Preview not found for", skin_name)
		return
	
	var label = btn.get_node("VBox/Label")

	var unlocked = skin_name in GameManager.unlocked_skins
	var equipped = skin_name == GameManager.equipped_skin

	var can_afford = GameManager.coins >= GameManager.skins_data[skin_name]["cost"]

	if not unlocked and not can_afford:
		btn.disabled = true
	else:
		btn.disabled = false

	# preview
	if equipped:
		preview.play("idle")
	else:
		preview.play("idle")
		preview.stop()
		preview.frame = 0

	# texte
	if equipped:
		label.text = "EQUIPPED"
		btn.modulate = Color(0.6, 1, 0.6)
	elif unlocked:
		label.text = "Equip"
		btn.modulate = Color(1,1,1)
	else:
		var cost = GameManager.skins_data[skin_name]["cost"]
		label.text = str(cost) + " RYO"
		btn.modulate = Color(0.7,0.7,0.7)
