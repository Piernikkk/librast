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
	
	for i in range(3):
		var shape_data = shapes_instance.get_random_shape();
		var shape = shape_scene.instantiate();
		add_child(shape);
		
		shape.setup_shape(shape_data, block_scene);
		shape.grid_ref = grid_ref;
		
		shape.shape_placed.connect(_on_shape_placed.bind(shape));
		
		var spacing = grid_ref.dynamic_block_size * 4;
		shape.position = Vector2((i - 1) * spacing, 0);
		
		shape.update_size();
		
		current_shapes.append(shape);

func update_shape_sizes() -> void:
	var idx = 0
	for shape in current_shapes:
		if is_instance_valid(shape) and shape.has_method("update_size"):
			shape.update_size();
			var spacing = grid_ref.dynamic_block_size * 4;
			shape.position = Vector2((idx - 1) * spacing, 0);
			idx += 1;
			
func _on_shape_placed(placed_shape) -> void:
	current_shapes.erase(placed_shape);
	print("Shape placed! Remaining shapes: ", current_shapes.size());
	
	if current_shapes.is_empty():
		print("All shapes used! Respawning...");
		await get_tree().create_timer(0.3).timeout;
		spawn_shapes();
