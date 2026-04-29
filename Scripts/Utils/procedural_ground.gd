extends Node2D

func _ready():
	generate_grass()

func generate_grass():
	var width = 4000
	var height = 400

	position.x = -width / 2

	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))

	for x in range(width):
		var blade_h = randi_range(4, 12)

		var top_y = 30 - blade_h

		# Herbe
		for y in range(top_y, 30):
			if y >= 0:
				image.set_pixel(x, y, Color(0.05,0.05,0.05,1))

		# Bloc noir dessous
		for y in range(30, height):
			image.set_pixel(x, y, Color(0.02,0.02,0.02,1))

		# pics occasionnels
		if randf() < 0.14:
			var extra = randi_range(2, 7)
			for y in range(top_y - extra, top_y):
				if y >= 0:
					image.set_pixel(x, y, Color(0.07,0.07,0.07,1))

	var tex = ImageTexture.create_from_image(image)
	$GrassTop.texture = tex
