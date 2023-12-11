extends Node2D

export var health = 0
export var _speed = 0
var can_move = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if can_move:
		var path_follow = get_parent()
		path_follow.set_offset(path_follow.get_offset() + _speed * delta)
