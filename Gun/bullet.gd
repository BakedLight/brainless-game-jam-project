extends Area2D

var direction: Vector2 = Vector2.UP
@export var speed: int = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_life_time_timeout() -> void:
	queue_free()

func destroy():
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.damage_taken(Globals.current_weapon_damage)
		destroy()
	else:
		destroy()
