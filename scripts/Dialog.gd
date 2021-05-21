# TODO: Don't go off edge

extends Control

onready var ZSorter: Node2D = $ZSorter

onready var BlackImage: NinePatchRect = $ZSorter/BlackImage
onready var WhiteImage: NinePatchRect = $ZSorter/WhiteImage

onready var WhiteText: Label = $ZSorter/WhiteText
onready var BlackText: Label = $ZSorter/BlackText

onready var PressSpaceBlack = $ZSorter/PressSpaceBlack
onready var PressSpaceWhite = $ZSorter/PressSpaceWhite

onready var DialogAdvanceArrow = $ZSorter/DialogAdvanceArrow

var active_text: Label
var active_image: NinePatchRect
var active_press_space: Node2D

var max_width = 350
var min_height = 50

var lifespan = 0.3
var auto_advance = false

var is_player = false
var is_enemy = false

var coin_drop = load("res://components/CoinDrop.tscn")

var is_ready = false

# Here's how you use this:
#  display_text_sequence_co([
#    "Hewo I am a small child",
#    "blah blah blah my doggy blah oh noooooo no" 
#  ])

func _ready():
  ZSorter.z_index = 500
  hide_everything()
  is_ready = true

var tick = 0

func _process(delta):
  tick += delta
  PressSpaceBlack.modulate.a = 0.5 + (sin(tick * 5.0) + 1) / 4.0
  PressSpaceWhite.modulate.a = 0.5 + (sin(tick * 5.0) + 1) / 4.0
  DialogAdvanceArrow.modulate = Color(
    1.0, # - (sin(tick * 5.0) + 1) / 6.0,
    0 + (sin(tick * 5.0) + 1) / 4.0,
    0.0,
    1.0
   )

func hide_everything():
  BlackImage.visible = false
  WhiteImage.visible = false
  WhiteText.visible = false
  BlackText.visible = false
  PressSpaceWhite.visible = false
  PressSpaceBlack.visible = false
  DialogAdvanceArrow.visible = false

func display_text_sequence_co(target: Node2D, sequence: Array, autodismiss_time_sec = 10.0) -> void:
  target.call_deferred("add_child", self)
  self.call_deferred("set_owner", target)
  
  self.modulate = Color.white
  
  if not is_ready:
    yield(self, "ready")
  
  hide_everything()
  
  if target is Player or target is Dog:
    is_player = true
    
    BlackText.visible = true
    WhiteImage.visible = true
    active_text = BlackText
    active_image = WhiteImage
    active_press_space = PressSpaceBlack
    
    if Globals.active_dialog_player:
      Globals.active_dialog_player.visible = false
      
    Globals.active_dialog_player = self
    
  else:
    is_enemy = true
    
    WhiteText.visible = true
    BlackImage.visible = true
    active_text = WhiteText
    active_image = BlackImage
    active_press_space = PressSpaceBlack
    
  for phrase in sequence:
    yield(display_text_co(phrase, autodismiss_time_sec), "completed")
  
  $Tween.interpolate_property(
    self, 
    "modulate",
    Color(modulate.r, modulate.g, modulate.b, 0.6),
    Color(1, 1, 1, 0),
    0.1
  )
  $Tween.start()
  
  yield($Tween, "tween_completed")
  
  visible = false
  
  if is_player:
    Globals.active_dialog_player = null
    
  queue_free()

func calc_rect_position(text):
  rect_position = Vector2(0, -120)

  # Keep dialog within window
  
  var eventual_width = active_text.get_font("font").get_wordwrap_string_size(text, max_width).x
  var cam_extents = Globals.cam_extents()
  var our_bounds = Rect2($Zero.global_position, Vector2(eventual_width, 1000))
  var off_screen_amount_left = cam_extents.position.x - our_bounds.position.x
  var off_screen_amount_right = our_bounds.end.x - cam_extents.end.x
  
  if off_screen_amount_left > 0:
    rect_position += Vector2(off_screen_amount_left, 0)

  if off_screen_amount_right > 0:
     rect_position -= Vector2(off_screen_amount_right, 0)
  
  return rect_position

func display_text_co(new_text: String, autodismiss_time_sec: float) -> void:
  var cur_text = ""
  var size = active_text.get_font("font").get_string_size(cur_text)
  
  var skipped_dialog = false
  
  active_press_space.visible = false
  DialogAdvanceArrow.visible = false
  
  for x in new_text:
    rect_position = calc_rect_position(new_text)
    
    cur_text += x
    
    SoundManager.play_sound("OliveSpeakSound")
    
    if skipped_dialog:
      cur_text = new_text
    
    active_text.text = cur_text
    
    var text_size = active_text.get_font("font").get_wordwrap_string_size(cur_text, max_width)
    text_size.x = min(text_size.x, active_text.get_font("font").get_string_size(cur_text).x)
    
    active_text.rect_size  = Vector2(max_width, 1000)
    active_image.rect_size = Vector2(min(text_size.x + 40, max_width), text_size.y + 40)
    
    rect_position.y = -text_size.y - 200
    
    if skipped_dialog:
      break
    
    yield(get_tree(), "idle_frame")
    if Input.is_action_just_pressed("ui_accept") and not auto_advance: skipped_dialog = true
    yield(get_tree(), "idle_frame")
    if Input.is_action_just_pressed("ui_accept") and not auto_advance: skipped_dialog = true
    
  active_image.rect_size += Vector2(20, 0)
  
  if auto_advance:
    return
  
  if not skipped_dialog:
    for x in range(60):
      yield(get_tree(), "idle_frame")
      if Input.is_action_just_pressed("ui_accept"): break
  
  
  SoundManager.play_sound("SpeakCompleteSound")
  DialogAdvanceArrow.visible = true
  DialogAdvanceArrow.position = active_image.rect_position + Vector2(active_image.rect_size.x / 2.0, active_image.rect_size.y)
  # active_press_space.visible = true
  active_press_space.position = active_image.rect_position + active_image.rect_size - Vector2(160, -10)
  
  # autodismiss after 3 sec roughly
  
  print("Auto", autodismiss_time_sec)
  for x in range(autodismiss_time_sec * 60.0):
    yield(get_tree(), "idle_frame")
    
    if Input.is_action_just_pressed("ui_accept"):
      return
