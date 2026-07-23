extends Sprite2D

signal cooldown_ended

@onready var fire_cooldown: Timer = $FireCooldown
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var auto_shoot: bool = true
@export var damage:int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_fire_cooldown_timeout() -> void:
	cooldown_ended.emit()
