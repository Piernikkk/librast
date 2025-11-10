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

var last_check_time = 0.0;
var check_interval = 0.05;

func _ready() -> void:
	original_position = global_position;
	calculate_mass_center();

func setup_shape(shape_data: Dictionary, block_scene: PackedScene) -> void:
	var pattern = shape_data.pattern;
	var grid_width = shape_data.width;
	var grid_height = shape_data.height;
	var color = shape_data.color;
	
	shape_pattern = pattern;
	
	if Globals.DEBUG_VERBOSE:
		print("Creating shape: ", shape_data.name, " - Width: ", grid_width, " Height: ", grid_height);
		print("Pattern: ", pattern);
	
	var idx = 0
	var blocks_created = 0
	for y in range(grid_height):
		for x in range(grid_width):
			if idx < pattern.size() and pattern[idx]:
				var block = block_scene.instantiate();
				add_child(block);
				block.set_block_color(color);
				block.position = Vector2(x * 64 + 32, y * 64 + 32);
				
				block.grid_pos = Vector2i(x, y);
				block.shape_parent = self;
				
				blocks.append({"node": block, "grid_pos": Vector2i(x, y)});
				blocks_created += 1;
				if Globals.DEBUG_VERBOSE:
					print("  Block ", blocks_created, " at grid pos: ", Vector2i(x, y), " world pos: ", Vector2(x * 64, y * 64));
			idx += 1;
	
	if Globals.DEBUG_VERBOSE:
		print("Total blocks created: ", blocks_created);
	calculate_mass_center();
	if Globals.DEBUG_VERBOSE:
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
		
		scale = Vector2.ONE;
		
		for block_data in blocks:
			var block = block_data.node;
			block.set_block_size(block_size);
			block.position = Vector2(block_data.grid_pos) * block_size + Vector2(block_size / 2.0, block_size / 2.0);
		
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
			var current_time = Time.get_ticks_msec() / 1000.0;
			if current_time - last_check_time >= check_interval:
				last_check_time = current_time;
				if can_place_shape():
					modulate = Color(1, 1, 1, 1.0);
				else:
					modulate = Color(1, 1, 1, 0.5);

func is_mouse_over(mouse_pos: Vector2) -> bool:
	if blocks.is_empty():
		return false;
	
	var local_mouse = to_local(mouse_pos);
	
	var min_pos = Vector2(INF, INF);
	var max_pos = Vector2(-INF, -INF);
	
	for block_data in blocks:
		var block = block_data.node;
		var block_pos = block.position;
		var rect = block.get_block_rect();
		
		var block_min = block_pos + rect.position;
		var block_max = block_pos + rect.position + rect.size;
		
		min_pos.x = min(min_pos.x, block_min.x);
		min_pos.y = min(min_pos.y, block_min.y);
		max_pos.x = max(max_pos.x, block_max.x);
		max_pos.y = max(max_pos.y, block_max.y);
	
	var bounding_rect = Rect2(min_pos, max_pos - min_pos);
	
	return bounding_rect.has_point(local_mouse);

func start_drag(mouse_pos: Vector2) -> void:
	dragging = true;
	Vibrations.on_block_picked_up();
	drag_offset = global_position - mouse_pos;
	original_position = global_position;
	z_index = 100;
	
	update_size(false);
	scale = Vector2.ONE * 1.05;
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

func place_shape() -> void:
	Vibrations.on_block_placed();
	
	var anchor_pos = get_best_placement_position();
	
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
	
	var blocks_cleared = grid_ref.check_and_clear_lines();
	if blocks_cleared > 0 and Globals.DEBUG_VERBOSE:
		print("Cleared ", blocks_cleared, " blocks");
	
	shape_placed.emit();

	blocks.clear()
	queue_free()

func return_to_original() -> void:
	global_position = original_position;
