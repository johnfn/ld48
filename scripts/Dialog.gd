# TODO: Don't go off edge

extends Control

onready var ZSorter: Node2D = $ZSorter
onready var Image: NinePatchRect = $ZSorter/Image
onready var Text: Label = $ZSorter/Text
onready var PressXKey: Sprite = $PressXKey

var max_width = 350
var min_height = 50

# Here's how you use this:
#  display_text_sequence_co([
#    "Hewo I am a small child",
#    "blah blah blah my doggy blah oh noooooo no" 
#  ])

func _ready():
  ZSorter.z_index = 500
  PressXKey.visible = false

func display_text_sequence_co(target: Node2D, sequence: Array) -> void:
  target.add_child(self)
  rect_position = Vector2(0, -120)
  
  for phrase in sequence:
    yield(display_text_co(phrase), "completed")
    yield(get_tree().create_timer(0.3), "timeout")
    
  PressXKey.visible = false
  visible = false

func display_text_co(new_text: String) -> void:
  var cur_text = ""
  var size = Text.get_font("font").get_string_size(cur_text)
  
  PressXKey.visible = false
  var one_last_loop = false
  
  for x in new_text:
    cur_text += x
    
    if one_last_loop:
      cur_text = new_text
    
    Text.text = cur_text
    var size_w = Text.get_font("font").get_string_size(cur_text).x
    var size_h = min_height
    
    if size_w > max_width:
      size_w = max_width
      size = Text.get_font("font").get_wordwrap_string_size(cur_text, max_width)
      size_h = size.y
    
    Text.rect_size  = Vector2(max_width, 1000)
    Image.rect_size = (Vector2(size_w, size_h) + Vector2(20, 40))
    
    rect_position.y = -size_h - 100
    
    if one_last_loop:
      break
      
    yield(get_tree(), "idle_frame")
    if Input.is_action_just_pressed("interact"): one_last_loop = true
    
    yield(get_tree(), "idle_frame")
    if Input.is_action_just_pressed("interact"): one_last_loop = true
    
    yield(get_tree(), "idle_frame")
    if Input.is_action_just_pressed("interact"): one_last_loop = true
    
  Image.rect_size += Vector2(60, 0)
  PressXKey.position = size + Vector2(50, 0)
  PressXKey.visible = true
  
  while true:
    PressXKey.visible = true
    
    for x in range(20):
      yield(get_tree(), "idle_frame")
      if Input.is_action_just_pressed("interact"):
        return

    PressXKey.visible = false
    
    for x in range(20):
      yield(get_tree(), "idle_frame")
      if Input.is_action_just_pressed("interact"):
        return
