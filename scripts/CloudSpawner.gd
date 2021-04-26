extends Node2D

onready var player = $"/root/Main/Player"
onready var main = $'/root/Main'

var CloudScene = load("res://scenes/Cloud.tscn")
var tick = 2.0

func _ready():
  initial_cloud_spawn()
  
func initial_cloud_spawn():
  yield(get_tree(), "idle_frame")
  
  for i in range(50):
    var c = spawn_cloud()
    
    print(1, player.position)
    c.position = player.position + Vector2(randf() * 1000.0 - 1000.0, - randf() * 20000.0)

func spawn_cloud():
  var new_cloud = CloudScene.instance()
  main.add_child(new_cloud)

  var scale = 2.0 + randf() * 2.0
  new_cloud.position = player.position
  new_cloud.position.y += randi() % int(get_viewport_rect().size.y) - int(get_viewport_rect().size.y / 2.0)
  new_cloud.position.x -= get_viewport_rect().size.x
  new_cloud.scale = Vector2(scale, scale)
  new_cloud.speed = 5.0 + randf() * 30.0
  
  return new_cloud

func _process(delta):
  tick += delta

  if tick > 10.0:
    tick = 0.0
    
    spawn_cloud()
