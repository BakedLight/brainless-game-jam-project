extends CharacterBody2D

signal shoot(object, pos, dir)

var direction: Vector2 = Vector2.ZERO
@export var normal_speeed: int = 80
@export var sprint_speed: int = 120
@export var acceleration: int = 15
@export var rotation_speed: int = 7
var current_speed:int = 50

# Weapons Management
var current_special:String = "knife"

var can_shoot:bool = true
var specials:Array = ["knife"]

# Smooth rotation
var angle_to_rotate:float = 0.0
var dir_to_mouse:Vector2 = Vector2.ZERO
var correction_angle:float = -PI / 2

#Camera Shake
var shaking_cam: bool = false
var time: float = 0.5
var intensity: float = 5.0
var frequency: int = 10
var camera_tween: Tween
var damping:float = 0.1

@onready var bullet_positions: Array = $BulletSpawners.get_children()
@onready var bullet_pos: Marker2D = $BulletSpawners/BulletPos
@onready var weapon_switcher: AnimationPlayer = $Weapons/WeaponSwitcher
@onready var revolver: Sprite2D = $Weapons/Primary/Revolver
@onready var primary: Node2D = $Weapons/Primary
@onready var main_weapon = primary.get_child(0)
@onready var knife_holder: Sprite2D = $Weapons/Special/KnifeHolder
@onready var camera_2d: Camera2D = $Camera2D
@onready var shake_time: Timer = $Camera2D/ShakeTime

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(direction)
	main_weapon.cooldown_ended.connect(can_shoot_now)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Movement
	Globals.player_pos = global_position
	velocity = lerp(velocity, direction * current_speed, acceleration * delta)
	move_and_slide()

	# Rotation
	dir_to_mouse = get_global_mouse_position() - global_position
	angle_to_rotate = (-atan2(dir_to_mouse.x, dir_to_mouse.y)) - correction_angle
	rotation = lerp_angle(rotation, angle_to_rotate, rotation_speed * delta)
	
	# Shooting Main Weapon
	if Input.is_action_pressed("shoot_main"):
		if can_shoot:
			var prev_bullet_pos = bullet_pos
			while prev_bullet_pos == bullet_pos:
				bullet_pos = bullet_positions[randi_range(0, bullet_positions.size() - 1)]
			if main_weapon.auto_shoot:
				shoot.emit("bullet", bullet_pos.global_position, Vector2((get_global_mouse_position().x - global_position.x), (get_global_mouse_position().y - global_position.y)).normalized())
				main_weapon.animation_player.play("Shoot")
				camera_shake(0.5, 10, 2, 0.1)
				can_shoot = false
				main_weapon.fire_cooldown.start()
			else:
				if Input.is_action_just_pressed("shoot_main"):
					shoot.emit("bullet", bullet_pos.global_position, Vector2((get_global_mouse_position().x - global_position.x), (get_global_mouse_position().y - global_position.y)).normalized())
					main_weapon.animation_player.play("Shoot")
					can_shoot = false
					camera_shake(0.5, 10, 2, 0.1)
					main_weapon.fire_cooldown.start()

	# Camera Shake
	if shaking_cam:
		if camera_tween: camera_tween.kill()
		camera_tween = camera_2d.create_tween()
		var rand_x = randf_range(-intensity, intensity)
		var equivalent_y = (dir_to_mouse.y/dir_to_mouse.x) * rand_x
		equivalent_y = clamp(equivalent_y, -rand_x, rand_x)
		camera_tween.tween_property(camera_2d, "offset", Vector2(rand_x, equivalent_y), time/frequency)
		intensity = lerp(intensity, 0.0, damping)

# Inputs
func _input(_event: InputEvent) -> void:

	# Movement inputs
	direction = Vector2.ZERO
	if Input.is_action_pressed("upward"):
		direction.y -= 1
	if Input.is_action_pressed("downward"):
		direction.y += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	direction = direction.normalized()
	
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	else:
		current_speed = normal_speeed

	# Weapon input
	if Input.is_action_just_pressed("special"):
		main_weapon.fire_cooldown.stop()
		can_shoot = false
		weapon_switcher.play("gun_to_special")

func throw_special():
	Globals.current_weapon_damage = knife_holder.damage
	shoot.emit(current_special, bullet_pos.global_position, Vector2((get_global_mouse_position().x - global_position.x), (get_global_mouse_position().y - global_position.y)).normalized())
	
func can_shoot_now():
	can_shoot = true

func camera_shake(t, f, i, d):
	time = t
	frequency = f
	intensity = i
	damping = d
	shake_time.wait_time = time
	shake_time.start()
	shaking_cam = true


func _on_shake_time_timeout() -> void:
	shaking_cam = false
	if camera_tween: camera_tween.kill()
	camera_tween = camera_2d.create_tween()
	camera_tween.tween_property(camera_2d, "offset", Vector2.ZERO, 0.1)
