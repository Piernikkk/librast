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
		return false
	if grid_pos.y < 0 or grid_pos.y >= GRID_HEIGHT:
		return false
	
	return grid[grid_pos.y][grid_pos.x] == null

func place_block(grid_pos: Vector2i, block_node) -> void:
	if can_place_block(grid_pos):
		grid[grid_pos.y][grid_pos.x] = block_node
		print("Block placed at: ", grid_pos)

func remove_block(grid_pos: Vector2i) -> void:
	if grid_pos.x >= 0 and grid_pos.x < GRID_WIDTH and grid_pos.y >= 0 and grid_pos.y < GRID_HEIGHT:
		grid[grid_pos.y][grid_pos.x] = null

func get_block_size() -> int:
	return dynamic_block_size;

func redraw_grid() -> void:
	queue_redraw();

func _draw() -> void:
	# Draw horizontal lines
	for y in range(GRID_HEIGHT + 1):
		draw_line(
			Vector2(0, y * dynamic_block_size),
			Vector2(GRID_WIDTH * dynamic_block_size, y * dynamic_block_size),
			Globals.GRID_COLOR,
			2
		);

	# Draw vertical lines
	for x in range(GRID_WIDTH + 1):
		draw_line(
			Vector2(x * dynamic_block_size, 0),
			Vector2(x * dynamic_block_size, GRID_HEIGHT * dynamic_block_size),
			Globals.GRID_COLOR,
			2
		);