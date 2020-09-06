extends Node2D

class_name Enemy

signal dead()

export(PackedScene) var BULLET_SCENE: PackedScene
onready var PLAYER: Node2D = Global.get_player()
onready var BULLET_CONTAINER: Node2D = Global.get_bullet_container()

export(float) var MAX_HP: int = 3
var hp = MAX_HP

export(float) var BULLET_SPEED: int = 100.0

onready var SPRITE: Sprite = $Sprite
var COLOUR_MAP: Dictionary = {
    Types.RgbColour.RED: Color.indianred,
    Types.RgbColour.GREEN: Color.aquamarine,
    Types.RgbColour.BLUE: Color.indigo,
}
var colour: int = randi() % 3
onready var HURTBOX: Area2D = $Hurtbox
onready var INITIAL_PHYSICS_LAYER: int = HURTBOX.collision_layer

func _ready() -> void:
    if Global.room_is_cleared:
        queue_free()
    else:
        update_colour()

func set_colour(new_colour: int) -> void:
    colour = new_colour
    update_colour()

func update_colour() -> void:
    SPRITE.self_modulate = COLOUR_MAP[colour]
    HURTBOX.collision_layer = INITIAL_PHYSICS_LAYER << colour

func shoot_at_player() -> void:
    var bullet: Bullet = BULLET_SCENE.instance()
    bullet.position = self.position
    bullet.speed = (PLAYER.position - self.position).normalized() * BULLET_SPEED
    bullet.colour = colour
    BULLET_CONTAINER.add_child(bullet)

func take_damage(damage: int) -> void:
    hp -= damage
    if hp <= 0:
        emit_signal("dead")
        queue_free()
