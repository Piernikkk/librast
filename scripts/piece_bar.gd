extends Node2D

@onready var block_scene = preload("res://sprites/block.tscn");
@onready var shape_scene = preload("res://sprites/shape.tscn");

@onready var grid_ref = get_parent().get_node("Grid");
@onready var shapes_instance = preload("res://scripts/shapes.gd").new();
var current_shapes = [];

func _ready() -> void:
	await get_tree().process_frame;
	
	position_bar();
	spawn_shapes();
	
	get_viewport().size_changed.connect(_on_viewport_resized);

func _on_viewport_resized() -> void:
	position_bar();
	update_shape_sizes();

func position_bar() -> void:
	var window_size = DisplayServer.window_get_size();
	var viewport = get_viewport();
	var viewport_size = viewport.get_visible_rect().size;
	
	var effective_size: Vector2;
	if window_size.x > viewport_size.x:
		effective_size = Vector2(window_size);
	else:
		effective_size = viewport_size;
	
	position = Vector2(effective_size.x / 2, effective_size.y * 0.85);

func spawn_shapes() -> void:
	for shape in current_shapes:
		if is_instance_valid(shape):
			shape.queue_free();
	current_shapes.clear();
	
	var shape_datas = [];
	var temp_shapes = [];
	for i in range(3):
		var shape_data = shapes_instance.get_random_shape();
		var shape = shape_scene.instantiate();
		add_child(shape);
		
		shape.setup_shape(shape_data, block_scene);
		shape.grid_ref = grid_ref;
		shape.shape_placed.connect(_on_shape_placed.bind(shape));
		shape.update_size(true);
		
		temp_shapes.append(shape);
		shape_datas.append(shape_data);
		current_shapes.append(shape);
	
	var block_size = grid_ref.dynamic_block_size * 0.6;
	var total_width = 0;
	var max_width = 0;
	
	for shape_data in shape_datas:
		var width = shape_data.width * block_size;
		total_width += width;
		if width > max_width:
			max_width = width;
	
	var padding = block_size * 1.5;
	total_width += padding * 2;
	
	var start_x = - total_width / 2.0;
	var current_x = start_x;
	
	for i in range(3):
		var shape = temp_shapes[i];
		var shape_data = shape_datas[i];
		var shape_width = shape_data.width * block_size;
		
		shape.position = Vector2(current_x + shape_width / 2.0, 0);
		current_x += shape_width + padding;

func update_shape_sizes() -> void:
	var block_size = grid_ref.dynamic_block_size * 0.6;
	var total_width = 0;
	var shape_widths = [];
	
	for shape in current_shapes:
		if is_instance_valid(shape):
			shape.update_size(true);
			var width = 0;
			for block_data in shape.blocks:
				var x = block_data.grid_pos.x;
				if (x + 1) * block_size > width:
					width = (x + 1) * block_size;
			shape_widths.append(width);
			total_width += width;
	
	var padding = block_size * 1.5;
	if shape_widths.size() > 1:
		total_width += padding * (shape_widths.size() - 1);
	
	var start_x = - total_width / 2.0;
	var current_x = start_x;
	
	var idx = 0;
	for shape in current_shapes:
		if is_instance_valid(shape) and idx < shape_widths.size():
			var shape_width = shape_widths[idx];
			shape.position = Vector2(current_x + shape_width / 2.0, 0);
			current_x += shape_width + padding;
			idx += 1;
			
func _on_shape_placed(placed_shape) -> void:
	current_shapes.erase(placed_shape);
	if Globals.DEBUG_VERBOSE:
		print("Shape placed! Remaining shapes: ", current_shapes.size());
	
	if not current_shapes.is_empty():
		check_game_over();
	
	if current_shapes.is_empty():
		if Globals.DEBUG_VERBOSE:
			print("All shapes used! Respawning...");
		await get_tree().create_timer(0.3).timeout;
		spawn_shapes();
		check_game_over();

func check_game_over() -> void:
	var any_can_fit = false;
	
	for shape in current_shapes:
		if is_instance_valid(shape) and shape.blocks.size() > 0:
			if grid_ref.can_shape_fit(shape.blocks):
				any_can_fit = true;
				break ;
	
	if not any_can_fit:
		print("GAME OVER - No shapes can fit!");
