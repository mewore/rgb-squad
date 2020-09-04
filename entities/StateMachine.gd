extends Node

class_name StateMachine

signal state_changed()

var LOG: Log = LogManager.get_log(self)

export(NodePath) var FIRST_STATE
export(NodePath) var OWNER = ".."

var current_state_name: String
var current_state: State

var state_map: Dictionary = {}

var history: Array = []

func _ready() -> void:
    self.owner = get_node(OWNER)
    if has_node(FIRST_STATE):
        current_state = get_node(FIRST_STATE)
    else:
        LOG.error("The initial state has not been set! Defaulting to the first state!")
        current_state = get_child(0)

    current_state_name = current_state.name.to_lower()
    for _child in get_children():
        var child: State = _child
        child.set_owner(owner)
        state_map[child.name.to_lower()] = child
        var connect_result: int = child.connect("next_state_requested", self, "_on_next_state_requested")
        if connect_result != OK:
            printerr("Error [%d] when connecting to the 'next_state_requested' signal of node '%s'" %
                [connect_result, child.name])
    
    yield(self.owner, "ready")
    LOG.info("The available states are: [%s]" % [PoolStringArray(state_map.keys()).join(", ")])
    for _child in get_children():
        var child: State = _child
        LOG.debug("Initializing state: ", child.name)
        child.initialize()
    history.append(current_state_name)
    _enter_state()
    
func change_to(new_state_name: String) -> void:
    new_state_name = new_state_name.to_lower()
    if new_state_name == State.PREVIOUS_STATE:
        self.back()
    elif new_state_name == State.DISAPPEAR_STATE:
        if owner.has_method("disappear"):
            owner.disappear()
        else:
            owner.queue_free()
    else:
        set_state(new_state_name)
        history.append(new_state_name)

func back() -> void:
    if history.size() >= 2:
        var last_history_state: String = history.pop_back()
        if last_history_state != current_state_name:
            LOG.error("last_history_state (%s) is different from state_name (%s)" %
                [last_history_state, current_state_name])
        var previous_state: String = history.back()
        LOG.debug("Going back from state '%s' to '%s'" % [current_state_name, previous_state])
        set_state(previous_state)
    else:
        LOG.error("Cannot go to a previous state! The history is empty!")

func set_state(new_state_name: String) -> void:
    LOG.debug("Changing state to '%s'" % [new_state_name])
    if !state_map.has(new_state_name):
        LOG.error("State '%s' does not exist! The available states are: %s" %
            [new_state_name, PoolStringArray(state_map.keys()).join(", ")])
        return
    _exit_state()
    current_state_name = new_state_name
    current_state = self.state_map[new_state_name]
    _enter_state()
    emit_signal("state_changed")

func _on_next_state_requested(requester: Node, next_state: String) -> void:
    if requester == current_state:
        self.change_to(next_state)
    else:
        LOG.error(("State '%s' has requested a change to state '%s' but it isn't active at the moment " +
            "(The active state is '%s')") % [requester.name.to_lower(), next_state, current_state_name])

func _enter_state() -> void:
    if current_state:
        LOG.debug("Entering state: ", current_state.name)
        current_state.activate()
        current_state.enter()

func _exit_state() -> void:
    if current_state:
        LOG.debug("Exiting state: ", current_state.name)
        current_state.exit()
        current_state.deactivate()

func _process(delta: float) -> void:
    if current_state:
        if self.current_state.next_state:
            self.change_to(self.current_state.next_state)
    
        current_state.process(delta)

func _physics_process(delta: float):
    if current_state:
        if self.current_state.next_state:
            self.change_to(self.current_state.next_state)
    
        current_state.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
    if current_state:
        current_state.unhandled_input(event)

func _unhandled_key_input(event: InputEventKey) -> void:
    if current_state:
        current_state.unhandled_key_input(event)
