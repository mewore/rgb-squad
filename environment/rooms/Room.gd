extends Node2D

var LOG: Log = LogManager.get_log(self)

onready var ENEMY_CONTAINER: Node = $Enemies
onready var enemies_left: int = ENEMY_CONTAINER.get_child_count()

func _ready() -> void:
    LOG.info("Enemy count: %d" % [enemies_left])
    for _enemy in ENEMY_CONTAINER.get_children():
        LOG.info("Connecting enemy...")
        var enemy: Enemy = _enemy
        LOG.check_error_code(enemy.connect("dead", self, "_on_enemy_dead"),
            "Connecting an enemy's 'dead' signal to the room's '_on_enemy_dead' method")

func _on_enemy_dead() -> void:
    enemies_left -= 1
    LOG.info("Enemy died. Enemies left: %d" % enemies_left)
    if enemies_left <= 0:
        destroy_bullets()

func destroy_bullets() -> void:
    for _bullet in get_tree().get_nodes_in_group("enemy_bullets"):
        var bullet: Bullet = _bullet
        bullet.disappear()

func open_doors() -> void:
    pass
