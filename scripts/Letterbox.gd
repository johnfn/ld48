extends Node2D

# This is an autoload, so anyone can call Letterbox.animate_in or animate_out

onready var TopRect = $CanvasLayer/TopRect
onready var BottomRect = $CanvasLayer/BottomRect
onready var EntireScreenFadeRect = $CanvasLayer/EnterScreenFadeRect

var letterbox_animation_length = 60.0
var fade_length = 120.0

# are we currently in any sort of cinematic at all?
var in_cinematic = false

# are we currently animating the letterbox? (are the boxes actually moving?)
var is_animating = false


func _ready():
    z_index = 10000
    
    TopRect.rect_position.y -= TopRect.rect_size.y
    BottomRect.rect_position.y += BottomRect.rect_size.y
    EntireScreenFadeRect.visible = false

func animate_in():
  if is_animating: 
    return
    
  is_animating = true
  
  for x in range(int(letterbox_animation_length)):
    yield(get_tree(), "idle_frame")
    
    TopRect.rect_position.y += TopRect.rect_size.y / letterbox_animation_length
    BottomRect.rect_position.y -= TopRect.rect_size.y / letterbox_animation_length
    
  is_animating = false

func animate_out():
  if is_animating: 
    return
    
  is_animating = true
    
  for x in range(int(letterbox_animation_length)):
    yield(get_tree(), "idle_frame")
    
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
