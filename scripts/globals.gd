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
const SAVE_FILE_PATH: String = "user://high_score.save";

var score: int = 0;
var high_score: int = 0;

func _ready() -> void:
	load_high_score();

func calculate_points(rows: int, cols: int) -> int:
	var points = 0;

	if rows > 0 and cols > 0:
		points = rows * cols * POINT_MULTIPLIER;
	elif rows > 0:
		points = rows * POINT_MULTIPLIER;
	elif cols > 0:
		points = cols * POINT_MULTIPLIER;

	return points;

func load_high_score() -> void:
	var config = ConfigFile.new();
	var err = config.load(SAVE_FILE_PATH);
	
	if err == OK:
		high_score = config.get_value("game", "high_score", 0);
		print("High score loaded: ", high_score);
	else:
		high_score = 0;
		print("No save file found");

func save_high_score(new_score: int) -> void:
	if new_score > high_score:
		high_score = new_score;
		
		var config = ConfigFile.new();
		config.set_value("game", "high_score", high_score);
		var err = config.save(SAVE_FILE_PATH);
		
		if err == OK:
			print("New high score saved: ", high_score);
		else:
			print("Error saving high score: ", err);
		
		return ;
	
	print("Score ", new_score, " did not beat high score ", high_score);