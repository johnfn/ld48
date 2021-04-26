extends Node2D

# This is an autoload, so anyone can call Letterbox.animate_in or animate_out

onready var TopRect = $CanvasLayer/TopRect
onready var BottomRect = $CanvasLayer/BottomRect
onready var EntireScreenFadeRect = $CanvasLayer/EnterScreenFadeRect
onready var camera: Camera2D = $"/root/Main/Camera"
onready var main = $"/root/Main"

var letterbox_animation_length = 45.0
var fade_length = 120.0
var zoom_in_amount = 0.8

# are we currently in any sort of cinematic at all?
var in_cinematic = false

# are we currently animating the letterbox? (are the boxes actually moving?)
var is_animating = false
  
func _ready():
    z_index = 10000
    
    TopRect.rect_position.y -= TopRect.rect_size.y
    BottomRect.rect_position.y += BottomRect.rect_size.y
    EntireScreenFadeRect.visible = false

func animate_in(target: Node2D):
  if is_animating: 
    return
    
  is_animating = true
  
  var start_pos = camera.position
  var end_pos = target.position
  
  end_pos.x = start_pos.x # don't adjust x at all
  
  for x in range(int(letterbox_animation_length)):
    yield(get_tree(), "idle_frame")
    
    camera.position = start_pos + (end_pos - start_pos) * (float(x) / letterbox_animation_length)
    camera.zoom = Vector2(1, 1) - Vector2(1 - zoom_in_amount, 1 - zoom_in_amount) * (float(x) / letterbox_animation_length)
    
    TopRect.rect_position.y += TopRect.rect_size.y / letterbox_animation_length
    BottomRect.rect_position.y -= TopRect.rect_size.y / letterbox_animation_length
    
  is_animating = false

func animate_out():
  if is_animating: 
    return
    
  is_animating = true
  
  var start_pos = camera.position
  var end_pos = Vector2(start_pos.x, main.get_desired_cam_position(999999.0)) # pass in massive delta to get the final position
  
  for x in range(int(letterbox_animation_length)):
    yield(get_tree(), "idle_frame")

    camera.position = start_pos + (end_pos - start_pos) * (float(x) / letterbox_animation_length)
    camera.zoom = Vector2(zoom_in_amount, zoom_in_amount) + Vector2(1 - zoom_in_amount, 1 - zoom_in_amount) * (float(x) / letterbox_animation_length)

    TopRect.rect_position.y -= TopRect.rect_size.y / letterbox_animation_length
    BottomRect.rect_position.y += TopRect.rect_size.y / letterbox_animation_length

  is_animating = false

func fade_to_black():
  if is_animating: 
    return
    
  is_animating = true
  
  EntireScreenFadeRect.visible = true
  EntireScreenFadeRect.modulate.a = 0.0
  
  for x in range(int(fade_length)):
    yield(get_tree(), "idle_frame")
    
    EntireScreenFadeRect.modulate.a = (float(x) / fade_length)
  
  is_animating = false
