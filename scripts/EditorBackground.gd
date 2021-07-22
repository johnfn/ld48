# tool
extends Node2D

export(int) var num_bgs = 4
export(String) var texture_name = "GrassTexture"

func _process(_delta):
  if Engine.editor_hint:
    var texture = get_node(texture_name)
    
    for ch in get_children():
      ch.visible = false
    
    texture.visible = true
    
    for i in range(get_child_count(), num_bgs):
      var new_child = texture.duplicate()
      new_child.position.y += 1280 * i
      add_child(new_child)
    for i in range(num_bgs, get_child_count()):
      get_child(i).queue_free()
  else:
    visible = false
