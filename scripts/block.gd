extends ColorRect

var grid_pos: Vector2i = Vector2i.ZERO;
var shape_parent = null;

func set_block_color(new_color: Color) -> void:
	modulate = new_color;

func check_nearby_grid_placements(grid_ref, snap_tolerance: float) -> Array:
	if not grid_ref:
		return [];
	
	var block_size = grid_ref.dynamic_block_size;
	var block_global_pos = global_position;
	var local_pos = block_global_pos - grid_ref.global_position;
	
	var center_x = local_pos.x / block_size;
	var center_y = local_pos.y / block_size;
	
	var check_cells = [
		Vector2i(int(floor(center_x)), int(floor(center_y))),
		Vector2i(int(ceil(center_x)), int(floor(center_y))),
		Vector2i(int(floor(center_x)), int(ceil(center_y))),
		Vector2i(int(ceil(center_x)), int(ceil(center_y))),
		Vector2i(int(round(center_x)), int(round(center_y)))
	];
	
	var valid_placements = [];
	
	for grid_cell in check_cells:
		var grid_x = grid_cell.x;
		var grid_y = grid_cell.y;
		
		var potential_anchor = Vector2i(grid_x, grid_y) - grid_pos;
		
		var grid_cell_center = grid_ref.global_position + Vector2(
			grid_x * block_size + block_size / 2.0,
			grid_y * block_size + block_size / 2.0
		);
		var distance = block_global_pos.distance_to(grid_cell_center);
		
		if distance < snap_tolerance:
			valid_placements.append({
				"anchor": potential_anchor,
				"distance": distance
			});
	
	return valid_placements;

func can_be_placed_at(grid_ref, target_grid_pos: Vector2i) -> bool:
	return grid_ref.can_place_block(target_grid_pos);
