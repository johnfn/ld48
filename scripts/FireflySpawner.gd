extends Node2D

var player = null
var main = null

var CloudScene = load("res://scenes/Firefly.tscn")
var tick = 2.0

var started = false

func initial_firefly_spawn():
  main = $'/root/Main'
  player = $"/root/Main/Levels/Player"
  yield(get_tree(), "idle_frame")
  
  for _i in range(50):
    var c = spawn_firefly()
    
    c.position = player.position + Vector2(randf() * 1000.0 - 1000.0, - randf() * 20000.0)

func spawn_firefly():
  if player == null:
    return
  
  started = true
  var new_cloud = CloudScene.instance()
  main.add_child(new_cloud)

  var scale = 0.3 + randf() * 1.0
  new_cloud.position = player.position
  new_cloud.position.y += randi() % int(get_viewport_rect().size.y) - int(get_viewport_rect().size.y / 2.0)
  new_cloud.position.x -= get_viewport_rect().size.x
  new_cloud.scale = Vector2(scale, scale)
  new_cloud.speed = 5.0 + randf() * 30.0
  
  return new_cloud

func _process(delta):
  if started:
    tick += delta

    if tick > 10.0:
      tick = 0.0
      
      spawn_firefly()
