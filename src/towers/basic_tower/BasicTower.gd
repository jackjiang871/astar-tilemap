extends Node2D

export var attack_range = 0
export var attack_damage = 0
export var attack_speed = 1

onready var collisionShape = $AttackArea/CollisionShape2D
onready var projectileScene = load("res://src/towers/basic_tower/Projectile.tscn")

var units_in_attack_range = []
var can_attack = true
onready var cooldown = 1.0 / attack_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	var attack_area_shape = CircleShape2D.new()
	attack_area_shape.set_radius(attack_range)
	collisionShape.set_shape(attack_area_shape)

func _physics_process(delta):
	# print(units_in_attack_range, can_attack, attack_range)
	if units_in_attack_range and can_attack:
		perform_attack(units_in_attack_range[0])
	if not can_attack:
		cooldown -= delta
		if cooldown <= 0:
			can_attack = true

# fire a projectile at unit
func perform_attack(unit):
	can_attack = false
	cooldown = 1.0 / attack_speed
	var newProjectile = projectileScene.instance()
	newProjectile._speed = 400
	newProjectile.target = unit
	newProjectile.connect("area_entered", self, "_on_projectile_hit", [newProjectile])
	self.add_child(newProjectile)

func _on_AttackArea_area_entered(other):
	units_in_attack_range.push_back(other)

func _on_AttackArea_area_exited(other):
	var i = units_in_attack_range.find(other)
	units_in_attack_range.remove(i)

func _on_projectile_hit(other, projectile):
	print(other.health)
	other.health -= attack_damage
	print(other.health)
	projectile.queue_free()
