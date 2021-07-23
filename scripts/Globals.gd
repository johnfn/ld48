extends Node2D

# Debug flags

# This overrides all flags to their prod values
export var prod_build = false

# Don't use these externally - they are intended to be used in the editor only
export var _skip_cinematics = false
export var _debug_has_sword = false
export var _debug_has_bow = false
export var _mute_sound = false
export var _debug_lighting_on = false
export var _debug_f_die = false
export var _debug_g_give_money = false
export var _mute_sfx = false
export var _always_drop_arrow = false
export var _always_drop_coin = false
export var _debug_invincible = false
export var _debug_hyper_run = false

var active_dialog_enemy = null
var active_dialog_player = null

var seen_dialogs = {}

func skip_cinematics() -> bool:
  return _skip_cinematics and not prod_build

func debug_has_sword() -> bool:
  return _debug_has_sword and not prod_build

func debug_has_bow() -> bool:
  return _debug_has_bow and not prod_build

func mute_sound() -> bool:
  return _mute_sound and not prod_build

func debug_lighting_on() -> bool:
  return _debug_lighting_on and not prod_build

func debug_f_die() -> bool:
  return _debug_f_die and not prod_build

func debug_g_give_money() -> bool:
  return _debug_g_give_money and not prod_build

func mute_sfx() -> bool:
  return _mute_sfx and not prod_build

func always_drop_arrow() -> bool:
  return _always_drop_arrow and not prod_build

func always_drop_coin() -> bool:
  return _always_drop_coin and not prod_build

func debug_invincible() -> bool:
  return _debug_invincible and not prod_build

func debug_hyper_run() -> bool:
  return _debug_hyper_run and not prod_build

func get_camera() -> Camera2D:
  var camera_override: Camera2D = get_node_or_null("/root/Main/Levels/LevelRunner/Camera")
  var camera_normal: Camera2D = get_node_or_null("/root/Main/Camera")
  
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
  
  return Rect2(min_pos, view_size)

