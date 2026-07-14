extends CharacterBody2D

enum States {
	PETROLLING,
	FINDING_PLAYER,
	SHOOTING,
	HURT,
	DYING
}
var current_state
var is_tweening: bool = false
var translation_tween: Tween
var rotation_tween: Tween
var health_tween: Tween

var petrol_distance = 0
@export var petrol_speed: int = 40
@export var turn_time: float = 0.2
@export var health: int = 50

@onready var path_follow = $".."
@onready var path_2d: Path2D = $"../.."
@onready var progress_bar_anchor: Node2D = $"ProgressBar Anchor"
@onready var texture_progress_bar: TextureProgressBar = $"ProgressBar Anchor/TextureProgressBar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	petrol_distance = path_2d.curve.get_baked_length()
	current_state = States.PETROLLING
	path_follow.progress_ratio = 0

	texture_progress_bar.max_value = health
	texture_progress_bar.value = health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	progress_bar_anchor.global_position = global_position
	
	match current_state:

		States.PETROLLING:
			#if is_tweeing: tween.kill()
			if not is_tweening:

				#Making it move on half the path using tweening
				if translation_tween: translation_tween.kill()
				is_tweening = true
				translation_tween = create_tween()
				translation_tween.set_ease(Tween.EASE_IN_OUT)
				translation_tween.tween_property(path_follow, "progress_ratio", 0.5, petrol_distance/(2*petrol_speed))

				# Making it rotate at half distance
				await translation_tween.finished
				translation_tween.kill()
				rotation_tween = create_tween()
				rotation_tween.set_ease(Tween.EASE_IN_OUT)
				rotation_tween.tween_property(self, "rotation_degrees", 180, turn_time)

				# Making it move on the second half of the path using tweening
				await rotation_tween.finished
				rotation_tween.kill()
				translation_tween = create_tween()
				translation_tween.set_ease(Tween.EASE_IN_OUT)
				translation_tween.tween_property(path_follow, "progress_ratio", 1, petrol_distance/(2*petrol_speed))

				# Then rotate back to original rotation at the end of the path
				await translation_tween.finished
				translation_tween.kill()
				rotation_tween = create_tween()
				rotation_tween.set_ease(Tween.EASE_IN_OUT)
				rotation_tween.tween_property(self, "rotation_degrees", 360, turn_time)
				is_tweening = false

				# Resetting the rotation to 0 degrees after the rotation is complete
				await rotation_tween.finished
				rotation_degrees = 0
				rotation_tween.kill()
			
		States.HURT:
			is_tweening = false
			if translation_tween: translation_tween.pause()
			if rotation_tween: rotation_tween.pause()
			# Wait for the damage cooldown before returning to the previous state
			await get_tree().create_timer(Globals.damage_cooldown).timeout
			current_state = States.FINDING_PLAYER
		
		States.DYING:
			die()

func damage_taken(damage:int) -> void:
	# Handle damage logic here
	current_state = States.HURT
	health -= damage
	if health_tween: health_tween.kill()
	health_tween = create_tween()
	health_tween.set_ease(Tween.EASE_IN_OUT)
	health_tween.tween_property(texture_progress_bar, "value", health, Globals.damage_cooldown)
	await health_tween.finished
	if health <= 0:
		current_state = States.DYING

func die() -> void:
	# Handle death logic here
	queue_free()
