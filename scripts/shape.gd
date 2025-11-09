extends Node2D

signal shape_placed();

var dragging = false;
var drag_offset = Vector2.ZERO;
var original_position = Vector2.ZERO;
var grid_ref = null;
var blocks = [];
var shape_pattern = [];
var base_scale = Vector2.ONE;
var mass_center = Vector2.ZERO;
var piece_bar_scale = 0.6;
var grid_scale = 1.0;

func _ready() -> void:
	original_position = global_position;
	calculate_mass_center();

func setup_shape(shape_data: Dictionary, block_scene: PackedScene) -> void:
	var pattern = shape_data.pattern;
	var grid_width = shape_data.width;
	var grid_height = shape_data.height;
	var color = shape_data.color;
	
	shape_pattern = pattern;
	
	print("Creating shape: ", shape_data.name, " - Width: ", grid_width, " Height: ", grid_height);
	print("Pattern: ", pattern);
	
	var idx = 0
	var blocks_created = 0
	for y in range(grid_height):
		for x in range(grid_width):
			if idx < pattern.size() and pattern[idx]:
				var block = block_scene.instantiate();
				add_child(block);
				block.set_color(color);
				block.position = Vector2(x * 64, y * 64);
				
				block.grid_pos = Vector2i(x, y);
				block.shape_parent = self;
				
				blocks.append({"node": block, "grid_pos": Vector2i(x, y)});
				blocks_created += 1;
				print("  Block ", blocks_created, " at grid pos: ", Vector2i(x, y), " world pos: ", Vector2(x * 64, y * 64));
			idx += 1;
	
	print("Total blocks created: ", blocks_created);
	calculate_mass_center();
	print("Mass center: ", mass_center);

func calculate_mass_center() -> void:
	if blocks.is_empty():
		mass_center = Vector2.ZERO;
		return ;
	
	var sum_pos = Vector2.ZERO;
	for block_data in blocks:
		sum_pos += block_data.node.position;
	
	mass_center = sum_pos / blocks.size();

func update_size(use_piece_bar_scale: bool = true) -> void:
	if grid_ref:
		var block_size = grid_ref.dynamic_block_size;
		
		if use_piece_bar_scale:
			block_size *= piece_bar_scale;
		
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
		
		if grid_ref:
			if can_place_shape():
				modulate = Color(1, 1, 1, 1.0);
			else:
				modulate = Color(1, 1, 1, 0.5);

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
	z_index = 100;
	
	update_size(false);
	scale = scale * 1.05;
	base_scale = scale;

func stop_drag() -> void:
	dragging = false;
	z_index = 0;
	modulate = Color(1, 1, 1, 1.0);
	
	if grid_ref:
		if can_place_shape():
			place_shape();
		else:
			return_to_original();
			update_size(true);
	else:
		return_to_original();
		update_size(true);

func can_place_shape() -> bool:
	if not grid_ref:
		return false
	
	var anchor_pos = get_best_placement_position();
	if anchor_pos == Vector2i(-1, -1):
		return false;
	
	for block_data in blocks:
		var grid_pos = anchor_pos + block_data.grid_pos;
		if not grid_ref.can_place_block(grid_pos):
			return false;
	return true;

func get_best_placement_position() -> Vector2i:
	if not grid_ref:
		return Vector2i(-1, -1);
	
	var block_size = grid_ref.dynamic_block_size;
	var snap_tolerance = block_size * 1.5;
	
	var best_anchor = Vector2i(-1, -1);
	var min_distance = INF;
	
	for block_data in blocks:
		var block = block_data.node;
		
		var placements = block.check_nearby_grid_placements(grid_ref, snap_tolerance);
		
		for placement in placements:
			var potential_anchor = placement.anchor;
			var distance = placement.distance;
			
			var is_valid = true;
			for other_block_data in blocks:
				var test_grid_pos = potential_anchor + other_block_data.grid_pos;
				if not other_block_data.node.can_be_placed_at(grid_ref, test_grid_pos):
					is_valid = false;
					break ;
			
			if is_valid and distance < min_distance:
				min_distance = distance;
				best_anchor = potential_anchor;
	
	return best_anchor;

func get_grid_position_for_anchor() -> Vector2i:
	return get_best_placement_position();

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
