extends Node2D

# This is an autoload, so anyone can call Letterbox.animate_in or animate_out

onready var TopRect = $CanvasLayer/TopRect
onready var BottomRect = $CanvasLayer/BottomRect

var animation_length = 60.0

# are we currently in any sort of cinematic at all?
var in_cinematic = false

# are we currently animating the letterbox? (are the boxes actually moving?)
var is_animating = false


func _ready():
    z_index = 10000
    
    TopRect.rect_position.y -= TopRect.rect_size.y
    BottomRect.rect_position.y += BottomRect.rect_size.y

func animate_in():
  if is_animating: 
    return
    
  is_animating = true
  
  for x in range(int(animation_length)):
    yield(get_tree(), "idle_frame")
    
    TopRect.rect_position.y += TopRect.rect_size.y / animation_length
    BottomRect.rect_position.y -= TopRect.rect_size.y / animation_length
    
  is_animating = false

func animate_out():
  if is_animating: 
    return
    
  is_animating = true
    
  for x in range(int(animation_length)):
    yield(get_tree(), "idle_frame")
    
    TopRect.rect_position.y -= TopRect.rect_size.y / animation_length
    BottomRect.rect_position.y += TopRect.rect_size.y / animation_length

  is_animating = false
