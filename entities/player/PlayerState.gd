extends State

class_name PlayerState

const MOVING: String = "moving"
const ENTERING_ROOM: String = "enteringroom"
const WAITING: String = "waiting"
var player: Player

func set_owner(owner: Node) -> void:
    .set_owner(owner)
    self.player = owner
