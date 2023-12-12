extends Node2D

onready var board = $Board
onready var path = $Path2D
onready var wallButton = $WallButton
onready var towerButton = $TowerButton
onready var tileHighlight = $TileHighlight
onready var enemyScene = load("res://src/enemies/default_enemy/Enemy.tscn")
onready var wallScene = load("res://src/towers/wall/Wall.tscn")
onready var towerScene = load("res://src/towers/basic_tower/BasicTower.tscn")

onready var path_follow = PathFollow2D.new()

onready var selected_tower = wallScene

func _input(event):
	if event.is_action_pressed("mouse_left"):
		var mouse_position = event.position
		if mouse_position.x >= 0 and mouse_position.x <= 1024 and mouse_position.y >= 0 and mouse_position.y <= 1024:
			var target_cell = (mouse_position / board.cell_size).floor() * board.cell_size
			var tower_to_create = selected_tower.instance()
			board.add_child(tower_to_create)
			tower_to_create.position = target_cell
			board.update()
			reset_enemy_path()

func add_enemy():
	var enemy = enemyScene.instance()
	enemy.can_move = true
	enemy._speed = 100
	enemy.health = 10
	path_follow.add_child(enemy)

func reset_enemy_path():
	var start_cell = Vector2(0, 0)
	var end_cell = Vector2(960, 960)
	print(start_cell, end_cell)
	print(board.get_used_cells().size())
	var path_points = board.get_astar_path(start_cell, end_cell)
	var new_curve = Curve2D.new()
	for point in path_points:
		new_curve.add_point(point)
		print(point)
	print(new_curve.get_point_count())
	path.position = board.cell_size/2 # Use offset to move line to center of tiles
	path.set_curve(new_curve)

func _ready():
	reset_enemy_path()
	path.add_child(path_follow)
	add_enemy()

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
	selected_tower = wallScene
	pass # Replace with function body.

func _on_TowerButton_pressed():
	selected_tower = towerScene
	pass # Replace with function body.

