extends Polygon2D

@export var fire_cooldown: float = 0.2

#@onready var fire_cooldown: Timer = $FireCooldown

var auto_shoot: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#
#func _input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("shoot_main"):
		#fire_cooldown.start()
