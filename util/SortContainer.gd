extends YSort

func _ready():
    for node in get_tree().get_nodes_in_group("y_sortable"):
        take_node(node)
    get_tree().connect("node_added", self, "_on_node_added")

func _on_node_added(node: Node) -> void:
    if node.is_in_group("y_sortable"):
        take_node(node)

func take_node(node: Node) -> void:
    print("Taking: ", node.name)
    node.get_parent().remove_child(node)
    add_child(node)
