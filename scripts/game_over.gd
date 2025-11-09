extends Control


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn");


func _on_main_menu_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/start_screen.tscn");
