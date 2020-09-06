extends State

class_name EnemyState

const SHOOTING: String = "shooting"
const WAITING: String = "waiting"
var enemy: Enemy

func set_owner(owner: Node) -> void:
    .set_owner(owner)
    self.enemy = owner
