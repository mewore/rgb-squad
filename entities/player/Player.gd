extends KinematicBody2D

class_name Player

onready var SPRITE: Sprite = $Sprite
var COLOUR_MAP: Dictionary = {
    Types.RgbColour.RED: Color.indianred,
    Types.RgbColour.GREEN: Color.aquamarine,
    Types.RgbColour.BLUE: Color.indigo,
}
export(Types.RgbColour) var colour: int = Types.RgbColour.RED

onready var HURTBOX: Area2D = $Hurtbox
onready var INITIAL_PHYSICS_LAYER: int = HURTBOX.collision_layer

func _ready() -> void:
    update_colour()

func set_red() -> void:
    colour = Types.RgbColour.RED
    update_colour()

func set_green() -> void:
    colour = Types.RgbColour.GREEN
    update_colour()

func set_blue() -> void:
    colour = Types.RgbColour.BLUE
    update_colour()

func update_colour() -> void:
    SPRITE.self_modulate = COLOUR_MAP[colour]
    HURTBOX.collision_layer = INITIAL_PHYSICS_LAYER << colour

func take_damage(damage: int) -> void:
    print("Taking %d damage... NOT." % damage)
