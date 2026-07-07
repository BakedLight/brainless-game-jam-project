extends Node2D

@onready var player: CharacterBody2D = $Player

@onready var bullet_scene = preload("res://Gun/bullet.tscn")
@onready var bullet_container: Node2D = $BulletContainer
@onready var knife_scene = preload("res://Projectiles/knife.tscn")
@onready var specials_container: Node2D = $SpecialsContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("shoot", spawn_bullet)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_bullet(obj, pos, dir):
	match obj:
		"bullet":
			var bullet = bullet_scene.instantiate()
			bullet.position = pos
			bullet.direction = dir
			bullet.look_at(get_global_mouse_position())
			bullet_container.add_child(bullet)
		"knife":
			var knife = knife_scene.instantiate()
			knife.position = pos
			knife.direction = dir
			knife.look_at(get_global_mouse_position())
			specials_container.add_child(knife)
