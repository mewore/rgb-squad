extends State

class_name EnemyState

const MOVING: String = "shooting"
var enemy: Enemy

func set_owner(owner: Node) -> void:
    .set_owner(owner)
    self.enemy = owner
