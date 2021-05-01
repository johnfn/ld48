# TODO: Don't go off edge

extends Control

onready var ZSorter: Node2D = $ZSorter

onready var BlackImage: NinePatchRect = $ZSorter/BlackImage
onready var WhiteImage: NinePatchRect = $ZSorter/WhiteImage

onready var WhiteText: Label = $ZSorter/WhiteText
onready var BlackText: Label = $ZSorter/BlackText

onready var PressSpaceBlack = $ZSorter/PressSpaceBlack
onready var PressSpaceWhite = $ZSorter/PressSpaceWhite

var active_text: Label
var active_image: NinePatchRect
var active_press_space: Node2D

var max_width = 350
var min_height = 50

var lifespan = 0.3
var auto_advance = false

# Here's how you use this:
#  display_text_sequence_co([
#    "Hewo I am a small child",
#    "blah blah blah my doggy blah oh noooooo no" 
#  ])

func _ready():
  ZSorter.z_index = 500
  hide_everything()

var tick = 0

func _process(delta):
  tick += delta
  PressSpaceBlack.modulate.a = 0.5 + (sin(tick * 5.0) + 1) / 4.0
  PressSpaceWhite.modulate.a = 0.5 + (sin(tick * 5.0) + 1) / 4.0

func hide_everything():
  BlackImage.visible = false
  WhiteImage.visible = false
  WhiteText.visible = false
  BlackText.visible = false
  PressSpaceWhite.visible = false
  PressSpaceBlack.visible = false

func display_text_sequence_co(target: Node2D, sequence: Array, already_a_child=false) -> void:
  if not already_a_child:
    target.call_deferred("add_child", self)
  
  self.modulate = Color.white
  
  yield(self, "ready")
  
  hide_everything()
  
  if target is Player or target is Dog:
    BlackText.visible = true
    WhiteImage.visible = true
    active_text = BlackText
    active_image = WhiteImage
    active_press_space = PressSpaceBlack
  else:
    WhiteText.visible = true
    BlackImage.visible = true
    active_text = WhiteText
    active_image = BlackImage
    active_press_space = PressSpaceBlack
  
  rect_position = Vector2(0, -120)
  
  for phrase in sequence:
    yield(display_text_co(phrase), "completed")
    yield(get_tree().create_timer(lifespan), "timeout")
  
  $Tween.interpolate_property(
    self, 
    "modulate",
    self.modulate,
    Color(1, 1, 1, 0),
    1.0,
    Tween.TRANS_LINEAR, 
    Tween.EASE_IN_OUT
  )
  $Tween.start()
  
  yield($Tween, "tween_completed")
  
  visible = false

func display_text_co(new_text: String) -> void:
  var cur_text = ""
  var size = active_text.get_font("font").get_string_size(cur_text)
  
  var one_last_loop = false
  
  active_press_space.visible = false
  
  for x in new_text:
    cur_text += x
    
    if one_last_loop:
      cur_text = new_text
    
    active_text.text = cur_text
    var size_w = active_text.get_font("font").get_string_size(cur_text).x
    var size_h = min_height
    
    if size_w > max_width:
      size_w = max_width
      size = active_text.get_font("font").get_wordwrap_string_size(cur_text, max_width)
      size_h = size.y
    
    active_text.rect_size  = Vector2(max_width, 1000)
    active_image.rect_size = (Vector2(size_w, size_h) + Vector2(20, 40))
    
    rect_position.y = -size_h - 200
    
    if one_last_loop:
      break
    
    yield(get_tree(), "idle_frame")
    if Input.is_action_just_pressed("interact") and not auto_advance: one_last_loop = true
    
  active_image.rect_size += Vector2(60, 0)
  
  if auto_advance:
    return
  
  active_press_space.visible = true
  active_press_space.position = active_image.rect_position + active_image.rect_size - Vector2(160, 0)
  
  # autodismiss after 3 sec roughly
  for x in range(180):
    yield(get_tree(), "idle_frame")
    
    if Input.is_action_just_pressed("interact"):
      return
