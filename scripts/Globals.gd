extends Node2D

# Debug flags
export var skip_cinematics = false
export var has_sword = false
export var mute_sound = false
export var debug_lighting_on = false
export var debug_f_die = false

var seen_dialogs = {}

# gets the width and height of the camera display in game units
func camera_viewport_size():
  var viewport = get_viewport()
  var size: Vector2
  
  if viewport.size_override_stretch:
    size = viewport.get_size_override()
  else:
    size = viewport.size
  
  return size
