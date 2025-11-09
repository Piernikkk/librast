extends Camera2D

func _ready() -> void:
	center_camera();
	
	get_viewport().size_changed.connect(center_camera);

func center_camera() -> void:
	var window_size = DisplayServer.window_get_size();
	var viewport_size = get_viewport().get_visible_rect().size;
	
	var effective_size: Vector2;
	if window_size.x > viewport_size.x:
		effective_size = Vector2(window_size);
	else:
		effective_size = viewport_size;
	
	position = effective_size / 2.0;
	
	if Globals.DEBUG_VERBOSE:
		print("Camera centered at: ", position);
