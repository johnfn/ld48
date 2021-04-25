tool
extends Node2D

export(int) var num_bgs = 4

func _process(delta):
  if Engine.editor_hint:
    var first_child = get_child(0)
    for i in range(get_child_count(), num_bgs):
      var new_child = first_child.duplicate()
      new_child.position.y += 1280 * i
      add_child(new_child)
    for i in range(num_bgs, get_child_count()):
      get_child(i).queue_free()
  else:
    queue_free()
