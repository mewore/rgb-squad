extends Node

class_name State

signal next_state_requested(requested, next_state)

var LOG: Log = LogManager.get_log(self)

const NO_STATE: String = ""
const PREVIOUS_STATE: String = "<"
const DISAPPEAR_STATE: String = "(x)"

var active: bool = false
var next_state: String

# Using signals would be cleaner-looking, but it might potentially lead to some
# nasty overlapping of state changes unless extra logic is added
func set_next_state(new_next_state: String) -> void:
    if self.active:
        if self.next_state and self.next_state != new_next_state:
            print("The next state is already set to '%s'. Overwriting it with '%s'." %
                [self.next_state, new_next_state])
        self.next_state = new_next_state
        self.emit_signal("next_state_requested", self, new_next_state)
    else:
        LOG.error("Tried to change the next state to '%s' while inactive" % [new_next_state])

# Clear the next state and prevent any updates to it
func deactivate() -> void:
    self.active = false
    self.next_state = NO_STATE

func activate() -> void:
    self.active = true

func initialize() -> void:
    pass

func enter() -> void:
    pass

func exit() -> void:
    pass

func process(_delta: float) -> void:
    pass

func physics_process(_delta: float) -> void:
    pass

func unhandled_input(_event: InputEvent) -> void:
    pass

func unhandled_key_input(_event: InputEventKey) -> void:
    pass
