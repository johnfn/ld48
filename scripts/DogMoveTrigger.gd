extends Area2D

onready var Letterbox = $"/root/Main/Letterbox"
onready var camera: Camera2D = $"/root/Main/Camera"
export var destinations: Array
export var dog_path: NodePath
export(Array) var dog_speak: Array = ["Yip yip!"]

var DialogScene = load("res://scenes/Dialog.tscn")
var triggered = false

var dog

func _ready():
  if connect("body_entered", self, "body_entered") != OK: print("connect error [3]")
  
  dog = get_node(dog_path)

func body_entered(other: Node2D):
  if triggered:
    return
  
  triggered = true
  
  if other is Player:
    if Globals.skip_cinematics():
      return
    begin_cinematic(other)
    
func begin_cinematic(_player: Player):
  Letterbox.in_cinematic = true
  
  yield(Letterbox.animate_in(dog), "completed")
  
  var new_dialog = DialogScene.instance()
  yield(new_dialog.display_text_sequence_co(dog, dog_speak), "completed")
  
  dog.Sprite.play("run")
  
  for dest in destinations:
    var dest_node = get_node(dest)
    var dir = dog.global_position.direction_to(dest_node.global_position)
    
    while dog.global_position.distance_to(dest_node.global_position) > 30:
      dog.global_position += dir * 5.0
      yield(get_tree(), "idle_frame")
      
  dog.visible = false
  
  yield(Letterbox.animate_out(), "completed")
  
  Letterbox.in_cinematic = false
