extends Node2D

signal shape_placed();

var dragging = false
var drag_offset = Vector2.ZERO
var original_position = Vector2.ZERO
var grid_ref = null
var blocks = [] # Array of block sprites
var shape_pattern = [] # The pattern definition
var base_scale = Vector2.ONE
var mass_center = Vector2.ZERO # Center of mass for the shape

func _ready() -> void:
	original_position = global_position;
	calculate_mass_center();

func setup_shape(shape_data: Dictionary, block_scene: PackedScene) -> void:
	var pattern = shape_data.pattern;
	var grid_width = shape_data.width;
	var grid_height = shape_data.height;
	var color = shape_data.color;
	
	shape_pattern = pattern;
	
	var idx = 0
	for y in range(grid_height):
		for x in range(grid_width):
			if idx < pattern.size() and pattern[idx]:
				var block = block_scene.instantiate();
				add_child(block);
				block.set_color(color);
				block.position = Vector2(x * 64, y * 64);
				blocks.append({"node": block, "grid_pos": Vector2i(x, y)});
			idx += 1;
	
	calculate_mass_center();

func calculate_mass_center() -> void:
	if blocks.is_empty():
		mass_center = Vector2.ZERO;
		return ;
	
	var sum_pos = Vector2.ZERO;
	for block_data in blocks:
		sum_pos += block_data.node.position;
	
	mass_center = sum_pos / blocks.size();

func update_size() -> void:
	if grid_ref:
		var block_size = grid_ref.dynamic_block_size;
		
		for block_data in blocks:
			var block = block_data.node;
			if block.texture:
				var texture_size = block.texture.get_size();
				var scale_factor = block_size / texture_size.x;
				block.scale = Vector2(scale_factor, scale_factor);
				
				block.position = Vector2(block_data.grid_pos) * block_size;
		
		calculate_mass_center();
		base_scale = scale;

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = get_global_mouse_position();
				if is_mouse_over(mouse_pos):
					start_drag(mouse_pos);
			else:
				if dragging:
					stop_drag();
	
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() + drag_offset;

func is_mouse_over(mouse_pos: Vector2) -> bool:
	for block_data in blocks:
		var block = block_data.node;
		var rect = block.get_rect();
		var local_mouse = block.to_local(mouse_pos);
		if rect.has_point(local_mouse):
			return true;
	return false;

func start_drag(mouse_pos: Vector2) -> void:
	dragging = true;
	drag_offset = global_position - mouse_pos;
	original_position = global_position;
	base_scale = scale;
	z_index = 100;
	scale = base_scale * 1.1;

func stop_drag() -> void:
	dragging = false;
	z_index = 0;
	scale = base_scale;
	
	if grid_ref:
		if can_place_shape():
			place_shape();
		else:
			return_to_original();
	else:
		return_to_original();

func can_place_shape() -> bool:
	if not grid_ref:
		return false
	
	# Get the anchor grid position (top-left block position on grid)
	var anchor_pos = get_grid_position_for_anchor()
	
	# Check if all blocks can be placed
	for block_data in blocks:
		var grid_pos = anchor_pos + block_data.grid_pos
		if not grid_ref.can_place_block(grid_pos):
			return false
	
	return true

func get_grid_position_for_anchor() -> Vector2i:
	if not grid_ref:
		return Vector2i(-1, -1);
	
	var block_size = grid_ref.dynamic_block_size;
	var mass_center_global = global_position + mass_center * scale;
	var local_pos = mass_center_global - grid_ref.global_position;
	
	var mass_grid_x = int(round(local_pos.x / block_size));
	var mass_grid_y = int(round(local_pos.y / block_size));
	
	var mass_center_in_grid = mass_center / block_size;
	var anchor = Vector2i(
		mass_grid_x - int(round(mass_center_in_grid.x)),
		mass_grid_y - int(round(mass_center_in_grid.y))
	);
	
	return anchor;

func place_shape() -> void:
	if not can_place_shape():
		return ;
	
	var anchor_pos = get_grid_position_for_anchor();
	
	for block_data in blocks:
		var grid_pos = anchor_pos + block_data.grid_pos;
		grid_ref.place_block(grid_pos, block_data.node);
	
	for block_data in blocks:
		var block = block_data.node;
		var world_pos = block.global_position;
		remove_child(block);
		grid_ref.add_child(block);
		block.global_position = world_pos;
		
		var grid_pos = anchor_pos + block_data.grid_pos;
		var block_size = grid_ref.dynamic_block_size;
		block.position = Vector2(
			grid_pos.x * block_size + block_size / 2.0,
			grid_pos.y * block_size + block_size / 2.0
		);
	
	shape_placed.emit();

	blocks.clear()
	queue_free()

func return_to_original() -> void:
	global_position = original_position;
