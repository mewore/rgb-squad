extends KinematicBody2D

class_name Player

onready var BULLET_CONTAINER: Node2D = Global.get_bullet_container()
export(PackedScene) var BULLET_SCENE: PackedScene
const BULLET_SPEED: float = 500.0
var shooting_angle: float = 0
var is_shooting: bool = false setget set_is_shooting
onready var SHOOT_COOLDOWN_TIMER: Timer = $ShootCooldown

onready var SPRITE: Sprite = $Sprite
var COLOUR_MAP: Dictionary = {
    Types.RgbColour.RED: Color.indianred,
    Types.RgbColour.GREEN: Color.aquamarine,
    Types.RgbColour.BLUE: Color.mediumslateblue,
}
var colour: int = Global.player_colour setget set_colour

onready var HURTBOX: Area2D = $Hurtbox
onready var INITIAL_PHYSICS_LAYER: int = HURTBOX.collision_layer

func _ready() -> void:
    update_colour()
    
    var center_position: Vector2 = Global.get_room_center().position
    var distance_from_center: float = center_position.distance_to(position)
    position = center_position + \
        Global.room_enter_direction * -distance_from_center

func set_colour(new_colour: int) -> void:
    colour = new_colour
    Global.player_colour = colour
    update_colour()

func update_colour() -> void:
    SPRITE.self_modulate = COLOUR_MAP[colour]
    HURTBOX.collision_layer = INITIAL_PHYSICS_LAYER << colour

func take_damage(damage: int) -> void:
    Global.player_hp -= damage

func set_is_shooting(new_is_shooting: bool) -> void:
    if new_is_shooting != is_shooting:
        is_shooting = new_is_shooting
        if is_shooting and SHOOT_COOLDOWN_TIMER.is_stopped():
            shoot()
            SHOOT_COOLDOWN_TIMER.start()

func _on_ShootCooldown_timeout() -> void:
    if is_shooting:
        shoot()
    else:
        SHOOT_COOLDOWN_TIMER.stop()

func shoot() -> void:
    var bullet: Bullet = BULLET_SCENE.instance()
    bullet.position = self.position
    bullet.speed = Vector2.RIGHT.rotated(shooting_angle) * BULLET_SPEED
    bullet.colour = colour
    BULLET_CONTAINER.add_child(bullet)
