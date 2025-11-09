extends Node2D

const block_scene = preload("res://sprites/block.tscn")

var grid_ref = null

func _ready() -> void:
	grid_ref = get_parent().get_node("Grid");
	
	await get_tree().process_frame;
	
	position_bar();
	spawn_test_blocks();
	
	get_viewport().size_changed.connect(_on_viewport_resized);

func _on_viewport_resized() -> void:
	position_bar();
	update_block_sizes();

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

func spawn_test_blocks() -> void:
	# Create 3 test blocks
	for i in range(3):
		var block = block_scene.instantiate();
		add_child(block);
		
		# Give the block a reference to the grid first
		block.grid_ref = grid_ref;
		
		# Position blocks horizontally
		var spacing = grid_ref.dynamic_block_size * 1.5;
		block.position = Vector2((i - 1) * spacing, 0);
		
		# Set different colors
		var colors = [Color.RED, Color.GREEN, Color.BLUE];
		block.set_color(colors[i]);
		
		# Scale block to match grid block size
		block.update_size();

func update_block_sizes() -> void:
	for child in get_children():
		if child.has_method("update_size"):
			child.update_size()
			# Also reposition with new spacing
			var index = child.get_index()
			var spacing = grid_ref.dynamic_block_size * 1.5
			child.position = Vector2((index - 1) * spacing, 0)
