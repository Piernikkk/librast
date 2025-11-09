extends Sprite2D

var dragging = false
var drag_offset = Vector2.ZERO
var original_position = Vector2.ZERO
var grid_ref = null
var base_scale = Vector2.ONE # Store the base scale for dynamic sizing

func _ready() -> void:
	original_position = global_position
	base_scale = scale # Store initial scale

func set_color(new_color: Color) -> void:
	modulate = new_color

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = get_global_mouse_position()
				if is_mouse_over(mouse_pos):
					start_drag(mouse_pos)
			else:
				if dragging:
					stop_drag()
	
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() + drag_offset

func is_mouse_over(mouse_pos: Vector2) -> bool:
	var rect = get_rect()
	var local_mouse = to_local(mouse_pos)
	return rect.has_point(local_mouse)

func start_drag(mouse_pos: Vector2) -> void:
	dragging = true
	drag_offset = global_position - mouse_pos
	original_position = global_position
	base_scale = scale # Update base scale before enlarging
	z_index = 100
	scale = base_scale * 1.1 # Enlarge by 10% from base scale

func stop_drag() -> void:
	dragging = false
	z_index = 0
	scale = base_scale # Return to base scale
	
	if grid_ref:
		var grid_pos = get_grid_position()
		if grid_ref.can_place_block(grid_pos):
			grid_ref.place_block(grid_pos, self)
			snap_to_grid(grid_pos)
		else:
			return_to_original()
	else:
		return_to_original()

func get_grid_position() -> Vector2i:
	if not grid_ref:
		return Vector2i(-1, -1)
	
	var block_size = grid_ref.dynamic_block_size;
	var local_pos = global_position - grid_ref.global_position
	var grid_x = int(local_pos.x / block_size)
	var grid_y = int(local_pos.y / block_size)
	return Vector2i(grid_x, grid_y)

func snap_to_grid(grid_pos: Vector2i) -> void:
	if grid_ref:
		var block_size = grid_ref.dynamic_block_size
		global_position = grid_ref.global_position + Vector2(
			grid_pos.x * block_size + block_size / 2.0,
			grid_pos.y * block_size + block_size / 2.0
		)

func return_to_original() -> void:
	global_position = original_position

func update_size() -> void:
	# Update block size based on grid's dynamic block size
	if grid_ref and texture:
		var texture_size = texture.get_size()
		var target_size = grid_ref.dynamic_block_size
		base_scale = Vector2(target_size / texture_size.x, target_size / texture_size.y)
		if not dragging:
			scale = base_scale
