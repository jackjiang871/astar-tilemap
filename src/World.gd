extends Node2D

onready var board = $Board
onready var path = $Path2D
onready var enemyScene = load("res://src/enemies/default_enemy/Enemy.tscn")

func _input(event):
	if event.is_action_pressed("mouse_left"):
		var target_cell = (event.position / board.cell_size).floor() * board.cell_size
		var path_points = board.get_astar_path(Vector2(256, 64), target_cell)
		var new_curve = Curve2D.new()
		var new_path_follow = PathFollow2D.new()
		var enemy = enemyScene.instance()
		enemy.can_move = true
		enemy._speed = 100
		enemy.health = 10
		new_path_follow.add_child(enemy)
		for point in path_points:
			new_curve.add_point(point)
			print(point)
		print(new_curve.get_point_count())
		path.position = board.cell_size/2 # Use offset to move line to center of tiles
		path.set_curve(new_curve)
		path.add_child(new_path_follow)
