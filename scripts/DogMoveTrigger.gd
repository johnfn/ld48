extends Area2D

export var destinations: Array
export var dog_path: NodePath

var DialogScene = load("res://scenes/Dialog.tscn")
var triggered = false
onready var area = $DialogTrigger
var dog

func _ready():
  connect("body_entered", self, "body_entered")
  dog = get_node(dog_path)

func body_entered(other: Node2D):
  if triggered:
    return
  
  triggered = true
  
  if other is Player:
    begin_cinematic(other)
    
func begin_cinematic(player: Player):
  Letterbox.in_cinematic = true
  
  yield(Letterbox.animate_in(dog), "completed")
  
  var new_dialog = DialogScene.instance()
  yield(new_dialog.display_text_sequence_co(dog, ["Yip yip!"]), "completed")
  
  for dest in destinations:
    var dest_node = get_node(dest)
    var dir = dog.position.direction_to(dest_node.position)
    
    while dog.position.distance_to(dest_node.position) > 30:
      dog.position += dir * 5.0
      yield(get_tree(), "idle_frame")
  
  yield(Letterbox.animate_out(), "completed")
  
  Letterbox.in_cinematic = false
