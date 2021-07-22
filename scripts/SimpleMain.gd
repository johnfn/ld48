class_name SimpleMain
extends Node2D

onready var Letterbox = $"/root/Main/Letterbox"
onready var Player = $Levels/Player
onready var Cam = $"/root/Main/Camera"
onready var Ui = $"/root/Main/UI"
onready var Levels = $"/root/Main/Levels"
onready var CanvasModulate = $CanvasModulate
var WeaponName = preload("res://scripts/WeaponName.gd").WeaponName

var screen_shake_time_left = 0.0

export(float) var max_camera_speed = 300
export(float) var camera_offset = 370
export(int) var start_level_num = 0

var curr_level_name: String

var center_camera = false
var inventory = []
var Level: Node2D = null
var OldLevel: Node2D = null
var level_height = null
const BASE_VIEWPORT_HEIGHT = 1280 # TODO this sucks
const WALL_THICKNESS = 10
const TRANSITION_LEN = 380
var bgs = [0, 1, 2, 3]
# new_scene and loaded_scene are temp vars
var initial_cam_x

func add_to_inventory(item_name):
  inventory.append(item_name)
  Ui.display_items(inventory)

func start_level(level_path: String) -> void:
  if Level != null:
    Level.queue_free()
  
  if OldLevel != null:
    OldLevel.queue_free()
    OldLevel = null
  
  curr_level_name = level_path
  
  Player.position.x = Level.spawn_point.x
  jump_view(Level.spawn_point.y - Player.position.y)
  Player.reset()
  Cam.current = true
  SoundManager.update_song(Level.get_song())
  
  wire_item_signals() 
  SoundManager.update_possible_rivers()
  Cam.position.y = Level.bottom_wall - BASE_VIEWPORT_HEIGHT / 2.0

func set_bg_type(name: String):
  for ch in $Background.get_children():
    for bg_tile in ch.get_children():
      if not (bg_tile is Sprite):
        continue
        
      if bg_tile.name == name:
        bg_tile.visible = true
      else:
        bg_tile.visible = false
        
#func load_cave(level: String, exit_name: String, is_cave: bool) -> void:
#  if level == curr_level_name:
#    return
#
#  Letterbox.in_cinematic = true
#  yield(Letterbox.fade_to_black(30.0), "completed")
#
#  if is_cave:
#    set_lighting_on(true, false)
#  else:
#    set_lighting_on(false, false)
#
#  Letterbox.unfade_to_black_instant()
#  Letterbox.in_cinematic = false
#
#  var exit_node = Level.get_node(exit_name)
#
#  Levels.add_child(Level)
#
#  # Move the level so that the place you exited into is right on top of the player
#  Player.global_position = exit_node.global_position
#
#  SoundManager.update_possible_rivers()
#  wire_item_signals() 

func set_lighting_on(light: bool, shading: bool) -> void:
  CanvasModulate.visible = shading or light
  
  if light and not shading:
    CanvasModulate.color = Color(0.2, 0.2, 0.2, 1.0)
  else:
    CanvasModulate.color = Color(0.5, 0.5, 0.5, 1.0)
  
  $Levels/Player/Light2D.visible = light and shading
  $Levels/Player/Light2DDark.visible = light and (not shading)
  
func _ready():  
  if CanvasModulate != null:
    set_lighting_on(false, false)
  
  if Globals.debug_lighting_on:
    set_lighting_on(true, true)
  
  initial_cam_x = Cam.position.x
  Ui.player = Player
  Player.connect("died", self, "handle_player_died")
  CloudSpawner.initial_cloud_spawn()
  
  for audio in get_children():
    if audio as AudioStreamPlayer != null:
      audio.volume_db = SoundManager.get_db()
    for child in audio.get_children():
      if child as AudioStreamPlayer != null:
        child.volume_db = SoundManager.get_db()

func jump_view(dist):
  for bg in $Background.get_children():
    bg.get_node('Hitbox').disabled = true
  Player.position.y += dist
  Cam.position.y += dist
  for bg in $Background.get_children():
    bg.position.y += dist
    bg.get_node('Hitbox').disabled = false

func screen_shake(duration: float):
  screen_shake_time_left = duration

func get_desired_cam_position(delta: float):
  var cam_pos = Player.position.y
  
  var shake = Vector2.ZERO
  
  if screen_shake_time_left > 0:
    shake = Vector2(randf() * 5.0 - 2.0, randf() * 5.0 - 2.0)
    screen_shake_time_left -= delta
  
  return Vector2(initial_cam_x, cam_pos) + shake

func _process(delta: float):
  # In this case, the letterbox takes care of camera location
  
  if not Letterbox.in_cinematic and Cam.current:
    Cam.position = get_desired_cam_position(delta)
  
  SoundManager.update_river_volume(Player.global_position.y)

func wire_item_signals():
  var items = get_tree().get_nodes_in_group("items")
  
  for item_node in items:
    item_node.connect("body_entered", self, "handle_item_body_entered", [item_node])

func handle_item_body_entered(body: Node, item_node):
  if body == Player and not Letterbox.in_cinematic:
    if item_node is Pickup:
      var pickup: Pickup = item_node
      
      yield(Letterbox.get_item_cinematic(pickup), "completed")
      
      Player.get_weapon(pickup.weapon_id)
      Player.set_active(pickup.weapon_id)
      
      item_node.queue_free()

func handle_player_died():
  print("TODO!")
  
  Letterbox.in_cinematic = true
  
  for x in range(60):
    yield(get_tree(), "idle_frame")
    Player.Sprite.material.set_shader_param("white", min(1.0, x / 30.0))
    Player.Hand.material.set_shader_param("white", min(1.0, x / 30.0))
    Player.modulate.a = 1.0 - float(x) / 60.0
    
  yield(Letterbox.fade_to_black(120.0), "completed")
  
  Player.modulate.a = 1.0
  Player.Sprite.material.set_shader_param("white", 0.0)
  Player.Hand.material.set_shader_param("white", 0.0)
  
  yield(get_tree(), "idle_frame")
  
  Letterbox.unfade_to_black_instant()
  Letterbox.in_cinematic = false
  
const BACKGROUND_HEIGHT = 2560
func _on_background_entered(body, i):
  if body.has_method("is_player") and body.is_player():
    if i == bgs[0]:
      var last = bgs.pop_back()
      bgs.push_front(last)
      $Background.get_child(last).position.y -= BACKGROUND_HEIGHT * len(bgs)
    elif i == bgs[len(bgs)-1]:
      var front = bgs.pop_front()
      bgs.push_back(front)
      $Background.get_child(front).position.y += BACKGROUND_HEIGHT * len(bgs)

onready var PauseMenu = load("res://scenes/PauseMenu.tscn")

func _unhandled_input(_event):
  if Input.is_action_just_pressed("pause"):
    add_child(PauseMenu.instance())
    
