extends Node

func on_block_picked_up():
	Input.vibrate_handheld(50);

func on_block_placed():
	Input.vibrate_handheld(100);

func on_lines_cleared():
	Input.vibrate_handheld(200);


func on_game_over():
	Input.vibrate_handheld(100);
	await get_tree().create_timer(0.2).timeout;
	Input.vibrate_handheld(300);