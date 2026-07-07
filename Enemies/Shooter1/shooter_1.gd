extends CharacterBody2D

enum States {
	PETROLLING,
	FINDING_PLAYER,
	SHOOTING,
	DYING
}
var current_state
var is_tweening: bool = false
var tween: Tween

var petrol_distance = 0
@export var petrol_speed: int = 200

@onready var path_follow = $".."
@onready var path_2d: Path2D = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	petrol_distance = path_2d.curve.get_baked_length()
	current_state = States.PETROLLING
	path_follow.progress_ratio = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	match current_state:
		States.PETROLLING:
			#if is_tweeing: tween.kill()
			if not is_tweening:
				is_tweening = true
				tween = create_tween()
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(path_follow, "progress_ratio", abs(1 - path_follow.progress_ratio), petrol_distance/petrol_speed)
				await get_tree().create_timer(petrol_distance/petrol_speed).timeout
				is_tweening = false
