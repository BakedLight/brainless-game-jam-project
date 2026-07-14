extends CharacterBody2D

enum States {
	PETROLLING,
	FINDING_PLAYER,
	SHOOTING,
	DYING
}
var current_state
var is_tweening: bool = false
var translation_tween: Tween
var rotation_tween: Tween

var petrol_distance = 0
@export var petrol_speed: int = 50
@export var turn_time: float = 0.2

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

				#Making it move on path using tweening
				if translation_tween: translation_tween.kill()
				is_tweening = true
				translation_tween = create_tween()
				translation_tween.set_ease(Tween.EASE_IN_OUT)
				translation_tween.set_parallel(true)
				translation_tween.tween_property(path_follow, "progress_ratio", (1 - path_follow.progress_ratio), petrol_distance/petrol_speed)
				# Making it rotate at half distance
				await get_tree().create_timer(petrol_distance/(2*petrol_speed)).timeout
				rotation_tween = create_tween()
				rotation_tween.set_ease(Tween.EASE_IN_OUT)
				rotation_tween.tween_property(self, "rotation_degrees", 180, turn_time)
				# Then rotate back to original rotation at the end of the path
				await get_tree().create_timer(petrol_distance/(2*petrol_speed)).timeout
				rotation_tween.kill()
				rotation_tween = create_tween()
				rotation_tween.set_ease(Tween.EASE_IN_OUT)
				rotation_tween.tween_property(self, "rotation_degrees", 360, turn_time)
				is_tweening = false
				# Resetting the rotation to 0 degrees after the rotation is complete
				await get_tree().create_timer(turn_time).timeout
				rotation_degrees = 0
				rotation_tween.kill()
				
