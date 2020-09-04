extends State

class_name PlayerState

const MOVING: String = "moving"
var player: Player

func set_owner(owner: Node) -> void:
    .set_owner(owner)
    self.player = owner
