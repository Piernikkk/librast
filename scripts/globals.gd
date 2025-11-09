extends Node

const BLOCK_SIZE: int = 64;

const GRID_COLOR: Color = Color(0.3, 0.3, 0.3);

const BLOCK_COLORS: Array[Color] = [
	Color(1, 0, 0), # Red
	Color(0, 1, 0), # Green
	Color(0, 0, 1), # Blue
	Color(1, 1, 0), # Yellow
	Color(1, 0, 1), # Magenta
	Color(0, 1, 1), # Cyan
	Color(1, 0.5, 0), # Orange
	Color(0.5, 0, 1) # Purple
];

const DEBUG_VERBOSE: bool = false;

const POINT_MULTIPLIER: int = 10;


func calculate_points(rows: int, cols: int) -> int:
	var points = 0;

	if rows > 0 and cols > 0:
		points = rows * cols * POINT_MULTIPLIER;
	elif rows > 0:
		points = rows * POINT_MULTIPLIER;
	elif cols > 0:
		points = cols * POINT_MULTIPLIER;

	return points;