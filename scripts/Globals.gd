extends Node2D

# Debug flags
export var skip_cinematics = false
export var debug_has_sword = false
export var debug_has_bow = false
export var mute_sound = false
export var debug_lighting_on = false
export var debug_f_die = false
export var mute_sfx = false

var active_dialog_enemy = null
var active_dialog_player = null

var seen_dialogs = {}

func get_camera() -> Camera2D:
  var camera_override: Camera2D = $"/root/Main/Levels/LevelRunner/Camera"
  var camera_normal: Camera2D = $"/root/Main/Camera"
  
  if camera_override != null and camera_override.current:
    return camera_override
  
  if camera_normal.current:
    return camera_normal
    
  print("What the...")
  return null  


# gets the width and height of the camera display in game units
func cam_extents() -> Rect2:
  var ctrans = get_canvas_transform()
  
  # The canvas transform applies to everything drawn,
  # so scrolling right offsets things to the left, hence the '-' to get the world position.
  # Same with zoom so we divide by the scale.
  var min_pos = -ctrans.get_origin() / ctrans.get_scale()

  # The maximum edge is obtained by adding the rectangle size.
  # Because it's a size it's only affected by zoom, so divide by scale too.
  var view_size = get_camera().get_viewport_rect().size / ctrans.get_scale()
  var max_pos = min_pos + view_size
  
  return Rect2(min_pos, view_size)
