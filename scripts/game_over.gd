extends Control

@onready var high_score_label: Label = %HighScore;

func _ready() -> void:
	high_score_label.text = str(Globals.score);

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn");


func _on_main_menu_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/start_screen.tscn");
