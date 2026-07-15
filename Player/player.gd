extends CharacterBody2D

signal shoot(object, pos, dir)

var direction: Vector2 = Vector2.ZERO
@export var normal_speeed: int = 75
@export var sprint_speed: int = 120

var current_speed:int = 50


var current_special:String = "knife"

var can_shoot:bool = true

var specials:Array = ["knife"]

@onready var bullet_pos: Marker2D = $BulletPos
@onready var weapon_switcher: AnimationPlayer = $Weapons/WeaponSwitcher
@onready var revolver: Sprite2D = $Weapons/Primary/Revolver
@onready var primary: Node2D = $Weapons/Primary
@onready var main_weapon = primary.get_child(0)
@onready var knife_holder: Sprite2D = $Weapons/Special/KnifeHolder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(direction)
	main_weapon.cooldown_ended.connect(can_shoot_now)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	velocity = direction * current_speed
	move_and_slide()
	
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("shoot_main"):
		if can_shoot:
			if main_weapon.auto_shoot:
				shoot.emit("bullet", bullet_pos.global_position, Vector2((get_global_mouse_position().x - global_position.x), (get_global_mouse_position().y - global_position.y)).normalized())
				can_shoot = false
				main_weapon.fire_cooldown.start()
			else:
				if Input.is_action_just_pressed("shoot_main"):
					shoot.emit("bullet", bullet_pos.global_position, Vector2((get_global_mouse_position().x - global_position.x), (get_global_mouse_position().y - global_position.y)).normalized())
					can_shoot = false
					main_weapon.fire_cooldown.start()

func _input(_event: InputEvent) -> void:
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
	 
	if Input.is_action_just_pressed("special"):
		main_weapon.fire_cooldown.stop()
		can_shoot = false
		weapon_switcher.play("gun_to_special")

func throw_special():
	Globals.current_weapon_damage = knife_holder.damage
	shoot.emit(current_special, bullet_pos.global_position, Vector2((get_global_mouse_position().x - global_position.x), (get_global_mouse_position().y - global_position.y)).normalized())
	
func can_shoot_now():
	can_shoot = true
