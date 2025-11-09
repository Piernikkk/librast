extends Camera2D

func _ready() -> void:
	center_camera();
	
	get_viewport().size_changed.connect(center_camera);

func center_camera() -> void:
	var viewport_size = get_viewport().get_visible_rect().size;
	position = viewport_size / 2.0;
	
	if Globals.DEBUG_VERBOSE:
		print("Camera centered at: ", position);
