extends Node

const BLOCK_SIZE: int = 64;
const BLOCK_SPACING: int = 4;

var GRID_COLOR: Color = Color.from_rgba8(88, 91, 112);

var BLOCK_COLORS: Array[Color] = [
	Color.from_rgba8(243, 139, 168), # Red
	Color.from_rgba8(166, 227, 161), # Green
	Color.from_rgba8(137, 180, 250), # Blue
	Color.from_rgba8(249, 226, 175), # Yellow
	Color.from_rgba8(203, 166, 247), # Mauve
	Color.from_rgba8(116, 199, 236), # Sapphire
	Color.from_rgba8(250, 179, 135), # Orange
	Color.from_rgba8(245, 194, 231) # Pink
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