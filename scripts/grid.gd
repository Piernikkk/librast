extends Node2D

const GRID_WIDTH = 8;
const GRID_HEIGHT = 8;

const block = preload("res://sprites/block.tscn");

var grid = [];
var grid_pixel_width = 0;
var grid_pixel_height = 0;
var dynamic_block_size = 0;

func _ready() -> void:
	initialize_grid();
	calculate_dynamic_sizes();
	center_grid();
	redraw_grid();
	get_viewport().size_changed.connect(_on_viewport_resized);

func _on_viewport_resized() -> void:
	calculate_dynamic_sizes();
	center_grid();
	redraw_grid();

func calculate_dynamic_sizes() -> void:
	var window_size = DisplayServer.window_get_size();
	var viewport = get_viewport();
	var viewport_size = viewport.get_visible_rect().size;
	
	var effective_size: Vector2;
	if window_size.x > viewport_size.x:
		effective_size = Vector2(window_size);
	else:
		effective_size = viewport_size;
	
	var available_width = effective_size.x * 0.9;
	var available_height = effective_size.y * 0.6;

	var block_size_by_width = available_width / GRID_WIDTH;
	var block_size_by_height = available_height / GRID_HEIGHT;
	
	dynamic_block_size = int(min(block_size_by_width, block_size_by_height));
	
	grid_pixel_width = GRID_WIDTH * dynamic_block_size;
	grid_pixel_height = GRID_HEIGHT * dynamic_block_size;
	
	print("Dynamic block size: ", dynamic_block_size, " | Grid size: ", grid_pixel_width, "x", grid_pixel_height);

func center_grid() -> void:
	var window_size = DisplayServer.window_get_size();
	var viewport = get_viewport();
	var viewport_size = viewport.get_visible_rect().size;
	
	var effective_size: Vector2;
	if window_size.x > viewport_size.x:
		effective_size = Vector2(window_size);
	else:
		effective_size = viewport_size;
	
	position = Vector2(
		(effective_size.x - grid_pixel_width) / 2.0,
		(effective_size.y - grid_pixel_height) / 2.0 - effective_size.y * 0.05 # Offset up slightly
	);
	
	print("Grid centered at: ", position, " | Window: ", window_size, " | Viewport: ", viewport_size);

func initialize_grid():
	for x in range(GRID_HEIGHT):
		var row = [];
		for y in range(GRID_WIDTH):
			row.append(null);
		grid.append(row);

func can_place_block(grid_pos: Vector2i) -> bool:
	if grid_pos.x < 0 or grid_pos.x >= GRID_WIDTH:
		return false;
	if grid_pos.y < 0 or grid_pos.y >= GRID_HEIGHT:
		return false;
	
	return grid[grid_pos.y][grid_pos.x] == null;

func place_block(grid_pos: Vector2i, block_node) -> void:
	if can_place_block(grid_pos):
		grid[grid_pos.y][grid_pos.x] = block_node;
		print("Block placed at: ", grid_pos);

func remove_block(grid_pos: Vector2i) -> void:
	if grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT:
		var block_node = grid[grid_pos.y][grid_pos.x];
		grid[grid_pos.y][grid_pos.x] = null;
		if block_node and is_instance_valid(block_node):
			block_node.queue_free();

func check_and_clear_lines() -> int:
	var rows_to_clear = [];
	var cols_to_clear = [];
	
	for y in range(GRID_HEIGHT):
		if is_row_full(y):
			rows_to_clear.append(y);
	
	for x in range(GRID_WIDTH):
		if is_column_full(x):
			cols_to_clear.append(x);
	
	if rows_to_clear.is_empty() and cols_to_clear.is_empty():
		return 0;
	
	animate_and_clear_lines(rows_to_clear, cols_to_clear);
	
	var blocks_cleared = rows_to_clear.size() * GRID_WIDTH + cols_to_clear.size() * GRID_HEIGHT;
	print("Cleared ", rows_to_clear.size(), " rows and ", cols_to_clear.size(), " columns. Total blocks: ", blocks_cleared);
	
	return blocks_cleared;

func animate_and_clear_lines(rows: Array, cols: Array) -> void:
	var blocks_to_animate = [];
	
	for y in rows:
		for x in range(GRID_WIDTH):
			if grid[y][x] != null:
				var block_node = grid[y][x];
				if not blocks_to_animate.has(block_node):
					blocks_to_animate.append(block_node);
	
	for x in cols:
		for y in range(GRID_HEIGHT):
			if grid[y][x] != null:
				var block_node = grid[y][x];
				if not blocks_to_animate.has(block_node):
					blocks_to_animate.append(block_node);
	
	for block_node in blocks_to_animate:
		animate_block_clear(block_node);
	
	await get_tree().create_timer(0.3).timeout;
	
	for y in rows:
		for x in range(GRID_WIDTH):
			grid[y][x] = null;
	
	for x in cols:
		for y in range(GRID_HEIGHT):
			grid[y][x] = null;

func animate_block_clear(block_node: Node2D) -> void:
	if not block_node or not is_instance_valid(block_node):
		return ;
	
	var tween = create_tween();
	tween.set_parallel(true);
	
	tween.tween_property(block_node, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.1);
	tween.tween_property(block_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1).set_delay(0.1);
	
	tween.tween_property(block_node, "scale", Vector2.ZERO, 0.2).set_delay(0.15);
	
	tween.tween_property(block_node, "modulate:a", 0.0, 0.15).set_delay(0.15);
	
	tween.tween_callback(block_node.queue_free).set_delay(0.3);

func is_row_full(y: int) -> bool:
	for x in range(GRID_WIDTH):
		if grid[y][x] == null:
			return false;
	return true;

func is_column_full(x: int) -> bool:
	for y in range(GRID_HEIGHT):
		if grid[y][x] == null:
			return false;
	return true;

func clear_row(y: int) -> int:
	var cleared = 0;
	for x in range(GRID_WIDTH):
		if grid[y][x] != null:
			remove_block(Vector2i(x, y));
			cleared += 1;
	return cleared;

func clear_column(x: int) -> int:
	var cleared = 0;
	for y in range(GRID_HEIGHT):
		if grid[y][x] != null:
			remove_block(Vector2i(x, y));
			cleared += 1;
	return cleared;

func can_shape_fit(shape_blocks: Array) -> bool:
	for try_y in range(GRID_HEIGHT):
		for try_x in range(GRID_WIDTH):
			var anchor = Vector2i(try_x, try_y);
			var can_fit = true;
			
			for block_data in shape_blocks:
				var grid_pos = anchor + block_data.grid_pos;
				if not can_place_block(grid_pos):
					can_fit = false;
					break ;
			
			if can_fit:
				return true;
	
	return false;

func get_block_size() -> int:
	return dynamic_block_size;

func redraw_grid() -> void:
	queue_redraw();

func _draw() -> void:
	for y in range(GRID_HEIGHT + 1):
		draw_line(
			Vector2(0, y * dynamic_block_size),
			Vector2(GRID_WIDTH * dynamic_block_size, y * dynamic_block_size),
			Globals.GRID_COLOR,
			2
		);

	for x in range(GRID_WIDTH + 1):
		draw_line(
			Vector2(x * dynamic_block_size, 0),
			Vector2(x * dynamic_block_size, GRID_HEIGHT * dynamic_block_size),
			Globals.GRID_COLOR,
			2
		);