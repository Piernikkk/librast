extends Node

var shapes = [
	# Single block
	{
		"pattern": [true],
		"width": 1,
		"height": 1,
		"name": "Single"
	},
	# I Shape - 4 blocks horizontal
	{
		"pattern": [true, true, true, true],
		"width": 4,
		"height": 1,
		"name": "I-4"
	},
	# I Shape - 3 blocks horizontal
	{
		"pattern": [true, true, true],
		"width": 3,
		"height": 1,
		"name": "I-3"
	},
	# I Shape - 2 blocks horizontal
	{
		"pattern": [true, true],
		"width": 2,
		"height": 1,
		"name": "I-2"
	},
	# L Shape
	{
		"pattern": [
			true, false,
			true, false,
			true, true
		],
		"width": 2,
		"height": 3,
		"name": "L"
	},
	# Reverse L Shape
	{
		"pattern": [
			false, true,
			false, true,
			true, true
		],
		"width": 2,
		"height": 3,
		"name": "L-Rev"
	},
	# T Shape
	{
		"pattern": [
			true, true, true,
			false, true, false
		],
		"width": 3,
		"height": 2,
		"name": "T"
	},
	# Z Shape
	{
		"pattern": [
			true, true, false,
			false, true, true
		],
		"width": 3,
		"height": 2,
		"name": "Z"
	},
	# S Shape (reverse Z)
	{
		"pattern": [
			false, true, true,
			true, true, false
		],
		"width": 3,
		"height": 2,
		"name": "S"
	},
	# Square 2x2
	{
		"pattern": [
			true, true,
			true, true
		],
		"width": 2,
		"height": 2,
		"name": "Square-2"
	},
	# Square 3x3
	{
		"pattern": [
			true, true, true,
			true, true, true,
			true, true, true
		],
		"width": 3,
		"height": 3,
		"name": "Square-3"
	}
]

func get_random_shape() -> Dictionary:
	var shape = shapes[randi() % shapes.size()]
	var color = Globals.BLOCK_COLORS[randi() % Globals.BLOCK_COLORS.size()]
	
	var rotation_steps = randi() % 4
	
	var result = {
		"pattern": shape.pattern,
		"width": shape.width,
		"height": shape.height,
		"name": shape.name,
		"color": color,
		"rotation_steps": rotation_steps
	}
	
	if rotation_steps > 0:
		result = rotate_shape(result, rotation_steps)
	
	return result

func rotate_shape(shape_data: Dictionary, steps: int) -> Dictionary:
	var pattern = shape_data.pattern
	var width = shape_data.width
	var height = shape_data.height
	
	print("Rotating shape ", shape_data.name, " by ", steps, " steps");
	print("Original: W=", width, " H=", height, " Pattern=", pattern);
	
	for step in range(steps):
		var new_pattern = []
		var new_width = height
		var new_height = width
		
		for new_y in range(new_height):
			for new_x in range(new_width):
				var old_y = new_width - 1 - new_x # old_y = height - 1 - new_x
				var old_x = new_y
				var old_index = old_y * width + old_x
				
				if old_index >= 0 and old_index < pattern.size():
					new_pattern.append(pattern[old_index])
				else:
					new_pattern.append(false)
		
		pattern = new_pattern
		width = new_width
		height = new_height
		
		print("After step ", step + 1, ": W=", width, " H=", height, " Pattern=", pattern);
	
	return {
		"pattern": pattern,
		"width": width,
		"height": height,
		"name": shape_data.name,
		"color": shape_data.color,
		"rotation_steps": shape_data.rotation_steps
	}