extends Node2D

onready var TopRect = null
onready var BottomRect = null
onready var EntireScreenFadeRect = null
onready var camera: Camera2D = null
onready var main = null
onready var Cards = [$CanvasLayer/Title1, $CanvasLayer/Title2]

var shown_card = [false, false, false, false]
var letterbox_animation_length = 45.0
var zoom_in_amount = 0.8

# are we currently in any sort of cinematic at all?
var in_cinematic = false

# are we currently animating the letterbox? (are the boxes actually moving?)
var is_animating = false

var max_dusk = 0.2
var max_night = 0.3

func _ready():
  TopRect = $CanvasLayer/TopRect
  BottomRect = $CanvasLayer/BottomRect
  EntireScreenFadeRect = $CanvasLayer/EnterScreenFadeRect
  camera = $"/root/Main/Camera"
  main = $"/root/Main"

  z_index = 1000
  
  TopRect.rect_position.y -= TopRect.rect_size.y
  BottomRect.rect_position.y += BottomRect.rect_size.y
  EntireScreenFadeRect.visible = false 
  
  for card in Cards:
    card.visible = false

#  DuskOverlay.modulate.a = 0.0
#  NightOverlay.modulate.a = 0.0

#func _process(f: float):
#  DuskOverlay.modulate.a = 0.2
#  NightOverlay.modulate.a = 1
  
func animate_in(target: Node2D):
  if is_animating: 
    return
    
  is_animating = true
  
  var start_pos = camera.global_position
  var end_pos = target.global_position
  
  end_pos.x = start_pos.x # don't adjust x at all
  
  for x in range(int(letterbox_animation_length)):
    yield(get_tree(), "idle_frame")
    
    camera.global_position = start_pos + (end_pos - start_pos) * (float(x) / letterbox_animation_length)
    camera.zoom = Vector2(1, 1) - Vector2(1 - zoom_in_amount, 1 - zoom_in_amount) * (float(x) / letterbox_animation_length)
    
    TopRect.rect_position.y += TopRect.rect_size.y / letterbox_animation_length
    BottomRect.rect_position.y -= TopRect.rect_size.y / letterbox_animation_length
    
  is_animating = false

func animate_out():
  if is_animating: 
    return
    
  is_animating = true
  
  var start_pos = camera.global_position
  var end_pos = Vector2(start_pos.x, main.get_desired_cam_position(999999.0)) # pass in massive delta to get the final position
  
  for x in range(int(letterbox_animation_length)):
    yield(get_tree(), "idle_frame")

    camera.global_position = start_pos + (end_pos - start_pos) * (float(x) / letterbox_animation_length)
    camera.zoom = Vector2(zoom_in_amount, zoom_in_amount) + Vector2(1 - zoom_in_amount, 1 - zoom_in_amount) * (float(x) / letterbox_animation_length)

    TopRect.rect_position.y -= TopRect.rect_size.y / letterbox_animation_length
    BottomRect.rect_position.y += TopRect.rect_size.y / letterbox_animation_length

  is_animating = false

func fade_to_black(fade_length):
  if is_animating: 
    return
    
  is_animating = true
  
  EntireScreenFadeRect.visible = true
  EntireScreenFadeRect.modulate.a = 0.0
  
  for x in range(int(fade_length)):
    yield(get_tree(), "idle_frame")
    
    EntireScreenFadeRect.modulate.a = (float(x) / fade_length)
  
  is_animating = false
  
func unfade_to_black_timed(fade_length):
  if is_animating: 
    return
    
  is_animating = true
  EntireScreenFadeRect.visible = true
  EntireScreenFadeRect.modulate.a = 1.0
  
  for x in range(int(fade_length)):
    yield(get_tree(), "idle_frame")
    
    EntireScreenFadeRect.modulate.a = 1.0 - (float(x) / fade_length)
  
  EntireScreenFadeRect.visible = false
  is_animating = false

func show_title_card(num: int) -> void:
  if shown_card[num + 1]:
    return
  
  shown_card[num + 1] = true
  
  in_cinematic = true
  
  yield(fade_to_black(30), "completed")
  
  var c = Cards[num - 1]
  c.visible = true
  
  for x in range(30):
    c.modulate.a = x / 30.0
    yield(get_tree(), "idle_frame")
  
  yield(get_tree().create_timer(2.0), "timeout")
  
  for x in range(30):
    c.modulate.a = 1.0 - x / 30.0
    yield(get_tree(), "idle_frame")
  
  c.visible = false
  
  yield(unfade_to_black_timed(30), "completed")
  
  in_cinematic = false
  
func unfade_to_black_instant():
  EntireScreenFadeRect.visible = false
  EntireScreenFadeRect.modulate.a = 0.0
