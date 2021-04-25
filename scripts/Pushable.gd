extends KinematicBody2D

const PUSH_TRIGGER_TIME = 0.25
var pushing_player = null
var time_pushing = 0
var dirs_held = [false, false, false, false]
var dir_map = {
  move_left = 2,
  move_up = 3,
  move_right = 0,
  move_down = 1
 }
var target = null
export(float) var speed = 300
export(float) var push_distance = 128

func _ready():
  $PushBounds.connect("body_entered", self, "_on_push_entered")
  $PushBounds.connect("body_exited", self, "_on_push_exited")


func _on_push_entered(body):
  if body.has_method('is_player') and body.is_player():
    pushing_player = body


func _on_push_exited(body):
  if body == pushing_player:
    pushing_player = null


func _physics_process(delta):
  var push_dir = get_push_dir()
  if push_dir != null:
    time_pushing += delta
    if time_pushing > PUSH_TRIGGER_TIME:
      time_pushing = 0
      attempt_push(push_dir)
  else:
    time_pushing = 0
  if target != null:
    var move_dir = position.direction_to(target)
    var move_dist = delta * speed
    if move_dist >= position.distance_to(target):
      move_dist = position.distance_to(target) 
      target = null
    move_and_collide(move_dir * move_dist)


func get_push_dir():
  if pushing_player == null:
    return null
  var push_angle = pushing_player.position.angle_to_point(position)
  var dir_i = int((push_angle / TAU + 0.5) * 4 + 0.5) % 4 # im sorry
  return dir_i if dirs_held[dir_i] else null


func _unhandled_input(event: InputEvent) -> void:
  for dir_name in dir_map.keys():
    if Input.is_action_just_pressed(dir_name):
      dirs_held[dir_map[dir_name]] = true
    elif Input.is_action_just_released(dir_name):
      dirs_held[dir_map[dir_name]] = false 


func attempt_push(push_dir):
  # check for possible collisions TODO
  # TODO round target to grid
  target = position
  match push_dir:
    0:
      target.x += push_distance
    1:
      target.y += push_distance
    2:
      target.x -= push_distance
    3:
      target.y -= push_distance