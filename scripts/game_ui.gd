extends Control

@onready var score_label: Label = %Points;
@onready var pause_menu: MarginContainer = %PauseMenu;

func _ready() -> void:
	score_label.text = "0";


func _on_grid_add_points(points: int) -> void:
	var current_score = int(score_label.text);
	current_score += points;
	score_label.text = str(current_score);

func _on_resume_pressed() -> void:
	pause_menu.visible = false;


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn");


func _on_pause_button_pressed() -> void:
	pause_menu.visible = true;

func game_over() -> void:
	Globals.score = int(score_label.text);
	get_tree().change_scene_to_file("res://scenes/game_over.tscn");