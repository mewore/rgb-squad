extends KinematicBody2D

class_name Player

onready var BULLET_CONTAINER: Node2D = Global.get_bullet_container()
export(PackedScene) var BULLET_SCENE: PackedScene
const BULLET_SPEED: float = 1000.0
const BULLET_SIZE: float = 4.0
const POWER_BULLET_SIZE: float = 0.1
const RED_HOMING_PER_POWER: float = 0.3
const GREEN_BULLET_ABSORB_PER_POWER: float = 0.3
const BLUE_ENEMY_PIERCE_PER_POWER: float = 0.1
const BLUE_FREEZE_PER_POWER: float = 0.01
const BULLET_DAMAGE_PER_POWER: float = 0.5
const BULLET_OPACITY: float = 0.5
var facing_direction: int = Types.Direction.DOWN setget set_facing_direction
var moving: bool = false setget set_moving
var shooting_angle: float = 0
var is_shooting: bool = false setget set_is_shooting
onready var SHOOT_COOLDOWN_TIMER: Timer = $ShootCooldown
onready var SHOOT_COOLDOWN: float = SHOOT_COOLDOWN_TIMER.wait_time
onready var SPEED_PER_POWER: float = 0.005
onready var MIN_COOLDOWN: float = 0.05

onready var STATE_MACHINE: StateMachine = $StateMachine

onready var SPRITE: Sprite = $Sprite
onready var INITIAL_SPRITE_X_SCALE: float = SPRITE.scale.x
onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer

export(Texture) var RED_SPRITE_TEXTURE: Texture
export(Texture) var GREEN_SPRITE_TEXTURE: Texture
export(Texture) var BLUE_SPRITE_TEXTURE: Texture
var SPRITE_TEXTURE_MAP: Dictionary = {
    Types.RgbColour.RED: RED_SPRITE_TEXTURE,
    Types.RgbColour.GREEN: GREEN_SPRITE_TEXTURE,
    Types.RgbColour.BLUE: BLUE_SPRITE_TEXTURE,
}
var COLOUR_MAP: Dictionary = {
    Types.RgbColour.RED: Color.indianred,
    Types.RgbColour.GREEN: Color.aquamarine,
    Types.RgbColour.BLUE: Color.mediumslateblue,
}
var colour: int = Global.player_colour setget set_colour

onready var HURTBOX: Area2D = $Hurtbox
onready var INITIAL_PHYSICS_LAYER: int = HURTBOX.collision_layer

var is_active: bool = false

func _ready() -> void:
    update_colour()
    
    var center_position: Vector2 = Global.get_room_center().position
    var distance_from_center: float = center_position.distance_to(position)
    var is_entering_room: bool = not is_zero_approx(Global.room_enter_direction.length_squared())
    if is_entering_room:
        shooting_angle = Global.room_enter_direction.angle()
        if not Global.is_room_cleared():
            STATE_MACHINE.set_state("enteringroom")
    
    self.facing_direction = angle_to_direction(shooting_angle)
    position = center_position + \
        Global.room_enter_direction * -distance_from_center
    refresh_animation()

func angle_to_direction(angle: float) -> int:
    if is_equal_approx(angle, Vector2.LEFT.angle()):
        return Types.Direction.LEFT
    elif is_equal_approx(angle, Vector2.RIGHT.angle()):
        return Types.Direction.RIGHT
    elif is_equal_approx(angle, Vector2.UP.angle()):
        return Types.Direction.UP
    else:
        return Types.Direction.DOWN

func set_facing_direction(new_facing_direction: int) -> void:
    facing_direction = new_facing_direction
    refresh_animation()

func set_moving(new_moving: bool) -> void:
    moving = new_moving
    refresh_animation()

func refresh_animation() -> void:
    SPRITE.scale.x = INITIAL_SPRITE_X_SCALE * \
        (-1 if facing_direction == Types.Direction.RIGHT else 1)
    var animation_prefix = "front_" if facing_direction == Types.Direction.DOWN \
        else ("back_" if facing_direction == Types.Direction.UP else "left_")
    ANIMATION_PLAYER.play(animation_prefix + ("run" if moving else "idle"))

func set_colour(new_colour: int) -> void:
    colour = new_colour
    Global.player_colour = colour
    update_colour()

func update_colour() -> void:
    match colour:
        Types.RgbColour.RED:
            SPRITE.texture = RED_SPRITE_TEXTURE
        Types.RgbColour.GREEN:
            SPRITE.texture = GREEN_SPRITE_TEXTURE
        Types.RgbColour.BLUE:
            SPRITE.texture = BLUE_SPRITE_TEXTURE
            
    # TODO: Fix this
#    SPRITE.texture = SPRITE_TEXTURE_MAP[colour]
    HURTBOX.collision_layer = INITIAL_PHYSICS_LAYER << colour
    
    var power_ratio: float = sqrt(Global.player_power[colour])
    SHOOT_COOLDOWN_TIMER.wait_time = max(
        SHOOT_COOLDOWN - power_ratio * SPEED_PER_POWER, MIN_COOLDOWN)

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
    var power_ratio: float = sqrt(Global.player_power[colour])
    bullet.position = self.position
    bullet.scale = Vector2.ONE * (BULLET_SIZE + POWER_BULLET_SIZE * power_ratio)
    bullet.speed = Vector2.RIGHT.rotated(shooting_angle) * BULLET_SPEED
    bullet.colour = colour
    bullet.modulate.a = BULLET_OPACITY
    bullet.damage = 1 + int(power_ratio * BULLET_DAMAGE_PER_POWER)
    
    if colour == Types.RgbColour.RED:
        bullet.homing = true
        bullet.homing_scale = 1.0 + RED_HOMING_PER_POWER * power_ratio
    elif colour == Types.RgbColour.GREEN:
        bullet.collides_with_other_bullets = true
        bullet.bullet_pierce = int(GREEN_BULLET_ABSORB_PER_POWER * power_ratio)
    elif colour == Types.RgbColour.BLUE:
        bullet.entity_pierce = int(BLUE_ENEMY_PIERCE_PER_POWER * power_ratio)
        bullet.freeze_time = BLUE_FREEZE_PER_POWER * power_ratio
    
    bullet.connect("hit", self, "_on_bullet_hit")
    BULLET_CONTAINER.add_child(bullet)

func _on_bullet_hit(colour: int, damage: int) -> void:
    Global.player_power[colour] += damage
