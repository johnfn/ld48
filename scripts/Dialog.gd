extends Control

onready var Image: NinePatchRect = $Image
onready var Text: Label = $Text
onready var PressXKey: Sprite = $PressXKey

func _ready():
  PressXKey.visible = false 
  
  display_text_sequence_co([
    "Hewo I am a small child",
    "blah blah blah my doggy blah oh noooooo no" 
  ])

func display_text_sequence_co(sequence: Array) -> void:
  for phrase in sequence:
    yield(display_text_co(phrase), "completed")
    yield(get_tree().create_timer(0.3), "timeout")
    
  PressXKey.visible = false
  visible = false

func display_text_co(new_text: String) -> void:
  var cur_text = ""
  var size = $Text.get_font("font").get_string_size(cur_text)
  
  PressXKey.visible = false
  
  for x in new_text:
    cur_text += x
    
    $Text.text = cur_text
    size = $Text.get_font("font").get_string_size(cur_text)
    Image.rect_size = (size + Vector2(20, 20))
    
    yield(get_tree().create_timer(0.05), "timeout")
    
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
