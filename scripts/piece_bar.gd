extends Node2D

@onready var game_ui = %GameUI;

@onready var block_scene = preload("res://sprites/block.tscn");
@onready var shape_scene = preload("res://sprites/shape.tscn");

@onready var grid_ref = get_parent().get_parent().get_node("GridContainer/Grid");
@onready var shapes_instance = preload("res://scripts/shapes.gd").new();
var current_shapes = [];

func _ready() -> void:
	await get_tree().process_frame;
	
	spawn_shapes();
	
	get_viewport().size_changed.connect(_on_viewport_resized);

func _on_viewport_resized() -> void:
	update_shape_sizes();

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
	
	var viewport = get_viewport();
	var viewport_size = viewport.get_visible_rect().size;
	var slot_width = viewport_size.x / 3.0;
	
	for i in range(3):
		var shape = temp_shapes[i];
		var slot_center_x = slot_width * (i + 0.5);
		
		var shape_visual_center = get_shape_visual_center(shape);
		
		shape.position = Vector2(slot_center_x - shape_visual_center.x, 50.0);

func get_shape_visual_center(shape: Node2D) -> Vector2:
	"""Calculate the visual center of a shape based on its blocks' positions"""
	if shape.blocks.is_empty():
		return Vector2.ZERO;
	
	var min_pos = Vector2(INF, INF);
	var max_pos = Vector2(-INF, -INF);
	
	for block_data in shape.blocks:
		var block = block_data.node;
		var block_pos = block.position;
		
		min_pos.x = min(min_pos.x, block_pos.x);
		min_pos.y = min(min_pos.y, block_pos.y);
		max_pos.x = max(max_pos.x, block_pos.x);
		max_pos.y = max(max_pos.y, block_pos.y);
	
	return (min_pos + max_pos) / 2.0;

func update_shape_sizes() -> void:
	for shape in current_shapes:
		if is_instance_valid(shape):
			shape.update_size(true);
	
	var viewport = get_viewport();
	var viewport_size = viewport.get_visible_rect().size;
	var slot_width = viewport_size.x / 3.0;
	
	var all_shapes_array = [null, null, null];
	for shape in current_shapes:
		if is_instance_valid(shape):
			var slot_index = int(shape.position.x / slot_width);
			slot_index = clamp(slot_index, 0, 2);
			all_shapes_array[slot_index] = shape;
	
	for i in range(3):
		if all_shapes_array[i] != null:
			var shape = all_shapes_array[i];
			var slot_center_x = slot_width * (i + 0.5);
			
			var shape_visual_center = get_shape_visual_center(shape);
			
			shape.position = Vector2(slot_center_x - shape_visual_center.x, 50.0);
			
func _on_shape_placed(placed_shape) -> void:
	current_shapes.erase(placed_shape);
	print("Shape placed! Remaining shapes: ", current_shapes.size());
	
	if not current_shapes.is_empty():
		check_game_over();
	
	if current_shapes.is_empty():
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
		game_ui.call("game_over");
