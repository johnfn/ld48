extends Area2D

export var dog_exit_path: Array

func _ready():
  leave_screen()

func leave_screen():
  for node_path in dog_exit_path:
    var node = get_node(node_path)
    print(node)
