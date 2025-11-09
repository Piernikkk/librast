extends Control

@onready var score_label: Label = %Points;

func _ready() -> void:
	score_label.text = "0";


func _on_grid_add_points(points: int) -> void:
	var current_score = int(score_label.text);
	current_score += points;
	score_label.text = str(current_score);