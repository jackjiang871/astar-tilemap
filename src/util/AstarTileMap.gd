extends TileMap
class_name AstarTileMap

const DIRECTIONS := [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
const PAIRING_LIMIT = int(pow(2, 30))
enum pairing_methods {
	CANTOR_UNSIGNED,	# positive values only
	CANTOR_SIGNED,		# both positive and negative values	
	SZUDZIK_UNSIGNED,	# more efficient than cantor
	SZUDZIK_SIGNED,		# both positive and negative values
	SZUDZIK_IMPROVED,	# improved version (best option)
}

export(pairing_methods) var current_pairing_method = pairing_methods.SZUDZIK_IMPROVED

export var diagonals := true

var astar := AStar2D.new()
var obstacles := []
var units := []

func _ready() -> void:
	update()

func update() -> void:
	var obstacleNodes = get_tree().get_nodes_in_group("Obstacles")
	for obstacleNode in obstacleNodes:
		add_obstacle(obstacleNode)
	create_pathfinding_points()

func create_pathfinding_points() -> void:
	astar.clear()
	var used_cell_positions = get_used_cell_global_positions()
	for cell_position in used_cell_positions:
		if not position_has_obstacle(cell_position):
			astar.add_point(get_point(cell_position), cell_position)

	for cell_position in used_cell_positions:
		if not position_has_obstacle(cell_position):
			connect_cardinals(cell_position)

func add_obstacle(obstacle: Object) -> void:
	obstacles.append(obstacle)
	if not obstacle.is_connected("tree_exiting", self, "remove_obstacle"):
		var _error := obstacle.connect("tree_exiting", self, "remove_obstacle", [obstacle])
		if _error != 0: push_error(str(obstacle) + ": failed connect() function")

func remove_obstacle(obstacle: Object) -> void:
	obstacles.erase(obstacle)

func position_has_obstacle(obstacle_position: Vector2, ignore_obstacle_position = null) -> bool:
	if obstacle_position == ignore_obstacle_position: return false
	for obstacle in obstacles:
		# walls/towers are all 2x2
		var pos1 = obstacle.global_position
		var pos2 = Vector2(obstacle.global_position.x, obstacle.global_position.y + cell_size.y)
		var pos3 = Vector2(obstacle.global_position.x + cell_size.x, obstacle.global_position.y)
		var pos4 = Vector2(obstacle.global_position.x + cell_size.x, obstacle.global_position.y + cell_size.y)
		if obstacle_position in [pos1, pos2, pos3, pos4]: return true
	return false

func get_astar_path(start_position: Vector2, end_position: Vector2, max_distance := -1) -> Array:
	var astar_path := astar.get_point_path(get_point(start_position), get_point(end_position))
	return set_path_length(astar_path, max_distance)

func set_path_length(point_path: Array, max_distance: int) -> Array:
	if max_distance < 0: return point_path
	var new_size := int(min(point_path.size(), max_distance))
	point_path.resize(new_size)
	return point_path

func path_directions(path) -> Array:
	# Convert a path into directional vectors whose sum would be path[length-1]
	var directions = []
	for p in range(1, path.size()):
		directions.append(path[p] - path[p - 1])
	return directions

func get_point(point_position: Vector2) -> int:
	var a := int(point_position.x)
	var b := int(point_position.y)
	match current_pairing_method:
		pairing_methods.CANTOR_UNSIGNED:
			assert(a >= 0 and b >= 0, "Board: pairing method has failed. Choose method that supports negative values.")
			return cantor_pair(a, b)
		pairing_methods.SZUDZIK_UNSIGNED:
			assert(a >= 0 and b >= 0, "Board: pairing method has failed. Choose method that supports negative values.")			
			return szudzik_pair(a, b)
		pairing_methods.CANTOR_SIGNED:
			return cantor_pair_signed(a, b)	
		pairing_methods.SZUDZIK_SIGNED:
			return szudzik_pair_signed(a, b)
		pairing_methods.SZUDZIK_IMPROVED:
			return szudzik_pair_improved(a, b)
	return szudzik_pair_improved(a, b)

func cantor_pair(a:int, b:int) -> int:
	var result := 0.5 * (a + b) * (a + b + 1) + b
	return int(result)

func cantor_pair_signed(a:int, b:int) -> int:
	if a >= 0:
		a = a * 2
	else:
		a = (a * -2) - 1
	if b >= 0:
		b = b * 2
	else:
		b = (b * -2) - 1
	return cantor_pair(a, b)

func szudzik_pair(a:int, b:int) -> int:
	if a >= b: 
		return (a * a) + a + b
	else: 
		return (b * b) + a	

func szudzik_pair_signed(a: int, b: int) -> int:
	if a >= 0: 
		a = a * 2
	else: 
		a = (a * -2) - 1
	if b >= 0:
		b = b * 2
	else: 
		b = (b * -2) - 1
	return int(szudzik_pair(a, b))

func szudzik_pair_improved(x:int, y:int) -> int:
	var a: int
	var b: int
	if x >= 0:
		a = x * 2
	else: 
		a = (x * -2) - 1
	if y >= 0: 
		b = y * 2
	else: 
		b = (y * -2) - 1	
	var c = szudzik_pair(a,b)
	if a >= 0 and b < 0 or b >= 0 and a < 0:
		return -c - 1
	return c

func has_point(point_position: Vector2) -> bool:
	var point_id := get_point(point_position)
	return astar.has_point(point_id)

func get_used_cell_global_positions() -> Array:
	var cells = get_used_cells()
	var cell_positions := []
	for cell in cells:
		var cell_position := global_position + map_to_world(cell)
		cell_positions.append(cell_position)
	return cell_positions

func connect_cardinals(point_position) -> void:
	var center := get_point(point_position)
	var directions := DIRECTIONS
	
	if diagonals: 
		var diagonals_array := [Vector2(1,1), Vector2(1,-1)]	# Only two needed for generation
		directions += diagonals_array
	
	for direction in directions:
		var cardinal_point := get_point(point_position + map_to_world(direction))
		if cardinal_point != center and astar.has_point(cardinal_point):
			if direction == Vector2(1,1) or direction == Vector2(1,-1): # make sure diagonal does not go through 2 walls
				var right = point_position + map_to_world(Vector2(direction.x, 0))
				var bot = point_position + map_to_world(Vector2(0, direction.y))
				var p1 = not position_has_obstacle(right) || astar.has_point(get_point(right))
				var p2 = not position_has_obstacle(bot) || astar.has_point(get_point(bot))
				if p1 or p2:
					astar.connect_points(center, cardinal_point, true)
			else:
				astar.connect_points(center, cardinal_point, true)

func get_grid_distance(distance: Vector2) -> float:
	var vec := world_to_map(distance).abs().floor()
	return vec.x + vec.y
