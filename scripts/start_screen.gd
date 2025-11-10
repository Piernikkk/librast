extends Control


@onready var high_score = %HighScore;

func _ready() -> void:
	high_score.text = str(Globals.high_score);


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn");

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn");
