extends KinematicBody2D

class_name Player

onready var SPRITE: Sprite = $Sprite
enum RgbColour {RED, GREEN, BLUE}
var COLOUR_MAP: Dictionary = {
    RgbColour.RED: Color.indianred,
    RgbColour.GREEN: Color.aquamarine,
    RgbColour.BLUE: Color.indigo,
}
export(RgbColour) var colour: int = RgbColour.RED

func _ready() -> void:
    update_colour()

func set_red() -> void:
    colour = RgbColour.RED
    update_colour()

func set_green() -> void:
    colour = RgbColour.GREEN
    update_colour()

func set_blue() -> void:
    colour = RgbColour.BLUE
    update_colour()

func update_colour() -> void:
    SPRITE.self_modulate = COLOUR_MAP[colour]

func take_damage(damage: int) -> void:
    print("Taking %d damage... NOT." % damage)
