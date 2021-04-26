extends Node2D

export(Vector2) var spawn_point = Vector2(0, 0)
export(float) var top_wall = 0;
export(float) var bottom_wall = 0;
export(bool) var is_top_open = false;
var dirty = false

var player = null
var main_cam = null
var player_min_y = null

onready var cam_steal_y = $Markers/CameraSteal.global_position.y
onready var cam_return_y = $Markers/CameraReturn.global_position.y
onready var Cam = $Camera
onready var Runner = $Runner

var is_beginning_running = false
var is_running = false
const FOLLOW_DIST = 640
onready var RUNNER_HEIGHT = 360
export(float) var cam_speed = 310


func get_song():
  return "BossSong"
  

func _ready():
  if spawn_point == Vector2(0, 0):
    spawn_point = $Markers/SpawnPoint.position
  top_wall = $Markers/CamTop.position.y
  bottom_wall = $Markers/LevelBottom.position.y
  player_min_y = spawn_point.y
  dirty = true


func _process(delta):
  var player_y = player.global_position.y
  if player_min_y > player_y:
    if player_min_y > cam_steal_y and player_y <= cam_steal_y:
      start_runner_cam()
    elif player_min_y > cam_return_y and player_y <= cam_return_y:
      end_runner_cam()
    player_min_y = player_y
  
  if is_running:
    Cam.position.y -= delta * cam_speed
    Runner.position.y -= delta * cam_speed
    top_wall = min(top_wall, Cam.position.y - FOLLOW_DIST)
    bottom_wall = Cam.position.y + FOLLOW_DIST
    dirty = true
  
  if is_beginning_running:
    var move_dist = delta * cam_speed
    if move_dist > abs(Runner.position.y - (Cam.position.y + FOLLOW_DIST)):
      is_beginning_running = false
      is_running = true
      move_dist = abs(Runner.position.y - (Cam.position.y + FOLLOW_DIST))
    Runner.position.y -= move_dist


func start_runner_cam():
  print(Cam.global_position, main_cam.global_position)
  Cam.global_position = main_cam.global_position
  print(Cam.global_position, main_cam.global_position)
  main_cam.current = false
  Cam.current = true
  is_beginning_running = true
  Runner.position.y = Cam.position.y + RUNNER_HEIGHT + FOLLOW_DIST
  dirty = true


func end_runner_cam():
  is_top_open = true
  dirty = true
  main_cam.global_position = Cam.global_position
  Cam.current = false
  main_cam.current = true
  is_running = false
  is_beginning_running = false
  top_wall = $Markers/LevelTop.position.y


func set_player(p):
  player = p


func set_camera(c):
  main_cam = c


func _on_body_entered(body):
  if body.has_method("is_player") and body.is_player():
    end_runner_cam()
    body.damage(10000, self) # get rekt kiddo
