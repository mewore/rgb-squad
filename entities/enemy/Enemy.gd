extends Node2D

class_name Enemy

export(PackedScene) var BULLET_SCENE: PackedScene
onready var PLAYER: Node2D = Global.get_player()
onready var BULLET_CONTAINER: Node2D = Global.get_bullet_container()
var colour: int = randi() % 3

func shoot_at_player(speed: float) -> void:
    var bullet: Bullet = BULLET_SCENE.instance()
    bullet.position = self.position
    bullet.speed = (PLAYER.position - self.position).normalized() * speed
    bullet.colour = colour
    BULLET_CONTAINER.add_child(bullet)
