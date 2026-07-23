extends CharacterBody2D

enum States {
	PETROLLING,
	HUNTING_PLAYER,
	REACHING_PLAYER,
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
@export var chase_speed: int = 60
@export var turn_time: float = 0.2
@export var health: int = 20

@onready var path_follow: PathFollow2D = $".."
@onready var path_2d: Path2D = $"../.."
@onready var progress_bar_anchor: Node2D = $"ProgressBar Anchor"
@onready var texture_progress_bar: TextureProgressBar = $"ProgressBar Anchor/TextureProgressBar"
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var collision_check1: RayCast2D = $CollisionCheck1
@onready var collision_check2: RayCast2D = $CollisionCheck2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
			
		States.REACHING_PLAYER:
			if can_view():
				current_state = States.SHOOTING
			else:
				navigation_agent.target_position = Globals.player_pos
				#rotation_degrees = lerp(rotation_degrees, rad_to_deg(get_angle_to(navigation_agent.get_next_path_position())), 0.2)
				velocity = global_position.direction_to(navigation_agent.get_next_path_position()).normalized() * chase_speed
				rotation = lerp_angle(rotation, get_angle_to(navigation_agent.get_next_path_position()), 0.2)
				move_and_slide()
		
		States.SHOOTING:
			if can_view():
				look_at(Globals.player_pos)
				#rotation = lerp_angle(rotation, global_position.angle_to(Globals.player_pos), 0.5)
			else:
				current_state = States.REACHING_PLAYER
		
		States.HURT:
			is_tweening = false
			if translation_tween: translation_tween.pause()
			if rotation_tween: rotation_tween.pause()
			# Wait for the damage cooldown before returning to the previous state
			animation_player.play("Blink")
			await get_tree().create_timer(animation_player.current_animation_length).timeout
			current_state = States.REACHING_PLAYER
		
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

func can_view() -> bool:
	#collision_check.target_position = collision_check.target_position.lerp(to_local(Globals.player_pos), 0.2)
	collision_check1.target_position = to_local(Vector2(Globals.player_pos.x, Globals.player_pos.y))
	collision_check2.target_position = to_local(Vector2(Globals.player_pos.x, Globals.player_pos.y))
	if collision_check1.is_colliding() or collision_check2.is_colliding():
		return false
	else:
		return true
