extends Node2D

onready var debug = $AstarDebug
onready var board = $Board
onready var path = $Path2D
onready var wallButton = $WallButton
onready var towerButton = $TowerButton
onready var tileHighlight = $TileHighlight
onready var towerAmountLabel = $TowerAmountLabel
onready var wallAmountLabel = $WallAmountLabel
onready var enemyScene = load("res://src/enemies/default_enemy/Enemy.tscn")
onready var wallScene = load("res://src/towers/wall/Wall.tscn")
onready var towerScene = load("res://src/towers/basic_tower/BasicTower.tscn")

onready var path_follow = PathFollow2D.new()

onready var selected_tower_name = 'WALL'

onready var tower_name_to_scene_map = {
	'WALL': wallScene,
	'TOWER': towerScene
}

var towers_available = 2
var walls_available = 15

var random_walls = 10

var start_cell = Vector2(0, 0)
var end_cell = Vector2(960, 960)

func set_towers_available(num):
	towers_available = num
	towerAmountLabel.set_text(str(towers_available))

func set_walls_available(num):
	print(num)
	walls_available = num
	wallAmountLabel.set_text(str(walls_available))

func get_available_selected_tower():
	if selected_tower_name == 'TOWER':
		return towers_available
	elif selected_tower_name == 'WALL':
		return walls_available
	return 0

func _input(event):
	if event.is_action_pressed("mouse_left"):
		var mouse_position = event.position
		var target_cell = (mouse_position / board.cell_size).floor() * board.cell_size
		# 2x2 is free
		var pos1 = board.get_point(target_cell)
		var pos2 = board.get_point(target_cell + board.cell_size)
		var pos3 = board.get_point(target_cell + Vector2(board.cell_size.x, 0))
		var pos4 = board.get_point(target_cell + Vector2(0, board.cell_size.y))
		
		var mouse_is_in_board = mouse_position.x >= 0 and mouse_position.x <= 960 and mouse_position.y >= 0 and mouse_position.y <= 960
		var area_is_free = board.astar.has_point(pos1) and board.astar.has_point(pos2) and board.astar.has_point(pos3) and board.astar.has_point(pos4)
		var has_tower_available = get_available_selected_tower() > 0
		
		if mouse_is_in_board and area_is_free and has_tower_available:
			var tower_to_create = tower_name_to_scene_map[selected_tower_name].instance()
			tower_to_create.position = target_cell
			if tower_to_create.is_in_group('Towers'):
				set_towers_available(towers_available - 1)
				tower_to_create.attack_damage = 1
				tower_to_create.attack_range = 150
				tower_to_create.attack_speed = 1.0
			elif tower_to_create.is_in_group('Walls'):
				set_walls_available(walls_available - 1)
			board.add_child(tower_to_create)
			board.update()
			reset_enemy_path()

func add_enemy():
	var enemy = enemyScene.instance()
	enemy.can_move = true
	enemy._speed = 100
	enemy.health = 10
	path_follow.add_child(enemy)

func reset_enemy_path():
	var path_points = board.get_astar_path(start_cell, end_cell)
	if not path_points:
		return false
	var new_curve = Curve2D.new()
	for point in path_points:
		new_curve.add_point(point)
	path.position = board.cell_size/2 # Use offset to move line to center of tiles
	path.set_curve(new_curve)
	return true

func _ready():
	reset_enemy_path()
	path.add_child(path_follow)
	add_enemy()
	wallAmountLabel.set_text(str(walls_available))
	towerAmountLabel.set_text(str(towers_available))

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	if mouse_position.x >= 0 and mouse_position.x <= 1024 and mouse_position.y >= 0 and mouse_position.y <= 1024:
		if not tileHighlight.visible:
			tileHighlight.show()
		var target_cell = (mouse_position / board.cell_size).floor() * board.cell_size
		tileHighlight.position = target_cell
	elif tileHighlight.visible:
		tileHighlight.hide()

func _on_WallButton_pressed():
	selected_tower_name = 'WALL'

func _on_TowerButton_pressed():
	selected_tower_name = 'TOWER'
