class_name Main
extends Node2D

onready var Letterbox = $"/root/Main/Letterbox"
onready var Player = $Levels/Player
onready var Cam = $Camera
onready var Ui = $UI
onready var Levels = $Levels
onready var TransitionTop = $Levels/TransitionTop
onready var TransitionBottom = $Levels/TransitionBottom
onready var TopWall = $Walls/BottomWall
onready var BottomWall = $Walls/BottomWall
onready var teleport_y = $Levels/TransitionTop/Markers/TeleportPoint.position.y + TransitionTop.position.y
onready var load_y = $Levels/TransitionTop/Markers/LoadPoint.position.y + TransitionTop.position.y
onready var despawn_y = $Levels/TransitionBottom/Markers/DespawnPoint.position.y + TransitionBottom.position.y
onready var FireflySpawner = $"/root/Main/FireflySpawner"
onready var CanvasModulate = $CanvasModulate
var WeaponName = preload("res://scripts/WeaponName.gd").WeaponName

var screen_shake_time_left = 0.0

export(float) var max_camera_speed = 300
export(float) var camera_offset = 370

# Uncomment one of the level_scenes variables: 1 OR 2
# 1: Chauncey's list of levels. DO NOT EDIT UNLESS YOU INTEND TO CHANGE THE STANDARD LEVEL ORDER.
export(Array) var level_scenes = ["res://levels/Level0.tscn","res://levels/Level1-0.tscn", "res://levels/Level1-1.tscn","res://levels/Level1-2.tscn", "res://levels/Level1-3.tscn","res://levels/Level1-4.tscn", "res://levels/Level1-5.tscn","res://levels/LevelRunner.tscn", "res://levels/Level2-1.tscn","res://levels/Level2-2.tscn", "res://levels/Level2-3.tscn" , "res://levels/Level2-4.tscn", "res://levels/LevelBoss.tscn", "res://levels/LevelOutro.tscn"]

# 2: PLAY LEVELS. FEEL FREE TO EDIT THIS LIST.
#export(Array) var level_scenes = ["res://levels/Level0.tscn", "res://levels/Level1-0.tscn", "res://levels/Level1-1.tscn", "res://levels/Level1-3Mock.tscn", "res://levels/LevelMock.tscn", "res://levels/Level5Mock.tscn"]

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
var last_player_y = 0
var is_transitioning = false
var bgs = [0, 1, 2, 3]
# new_scene and loaded_scene are temp vars
var new_scene = null
var loaded_scene = null
var initial_cam_x
var already_loaded_levels = {}

func add_to_inventory(item_name):
  inventory.append(item_name)
  Ui.display_items(inventory)


func load_level(level_name: String) -> Node2D:
  var new_level: Node2D
  
  if already_loaded_levels.has(level_name):
    new_level = already_loaded_levels[level_name]
  else:
    loaded_scene = load(level_name)
    assert(loaded_scene != null, "ERROR: %s not a valid level. Check Main->Inspector->Level Scenes (sometimes from level_scenes) matches available names in /levels." % level_name)
    new_level = loaded_scene.instance()
    loaded_scene = null
    assert(new_level.get_node("Markers/LevelBottom") != null)
    assert(new_level.get_node("Markers/LevelTop") != null)
  
  already_loaded_levels[level_name] = new_level
  
  level_height = new_level.get_node("Markers/LevelBottom").position.y - new_level.get_node("Markers/LevelTop").position.y
  
  if new_level.has_method('set_player'):
    new_level.set_player(Player)
    
  if new_level.has_method('set_camera'):
    new_level.set_camera(Cam)
    
  return new_level

func start_level(level_path: String) -> void:
  if Level != null:
    Level.queue_free()
  
  if OldLevel != null:
    OldLevel.queue_free()
    OldLevel = null
  
  curr_level_name = level_path
  is_transitioning = false
  
  Level = load_level(level_path)
  Levels.add_child(Level)
  
  Player.position.x = Level.spawn_point.x
  jump_view(Level.spawn_point.y - Player.position.y)
  Player.reset()
  Cam.current = true
  SoundManager.update_song(Level.get_song())
  
  wire_item_signals() 
  SoundManager.update_possible_rivers()
  Cam.position.y = Level.bottom_wall - BASE_VIEWPORT_HEIGHT / 2
  last_player_y = Player.position.y
  TransitionBottom.global_position.y = Level.get_node("Markers/LevelBottom").position.y
  TransitionTop.global_position.y = Level.get_node("Markers/LevelTop").position.y - TRANSITION_LEN
  update_wall_positions()
  teleport_y = $Levels/TransitionTop/Markers/TeleportPoint.position.y + TransitionTop.position.y
  load_y = $Levels/TransitionTop/Markers/LoadPoint.position.y + TransitionTop.position.y
  despawn_y = $Levels/TransitionBottom/Markers/DespawnPoint.position.y + TransitionBottom.position.y

func set_bg_type(name: String):
  for ch in $Background.get_children():
    for bg_tile in ch.get_children():
      if not (bg_tile is Sprite):
        continue
        
      if bg_tile.name == name:
        bg_tile.visible = true
      else:
        bg_tile.visible = false
        
func load_cave(level: String, exit_name: String, is_cave: bool) -> void:
  if level == curr_level_name:
    return
  
  Letterbox.in_cinematic = true
  yield(Letterbox.fade_to_black(30.0), "completed")
  
  if is_cave:
    set_lighting_on(true, false)
  else:
    set_lighting_on(false, false)
  
  Letterbox.unfade_to_black_instant()
  Letterbox.in_cinematic = false
  
  curr_level_name = level
  
  Level.get_parent().remove_child(Level)
  
  Level = load_level(level)
  
  var background_name = Level.get_node("Background").texture_name
  
  set_bg_type(background_name)
  
  var exit_node = Level.get_node(exit_name)
  
  Levels.add_child(Level)
  
  # Move the level so that the place you exited into is right on top of the player
  Player.global_position = exit_node.global_position

  SoundManager.update_possible_rivers()
  wire_item_signals() 

func load_new_level(level: String) -> void:
  OldLevel = Level
  
  if level == curr_level_name:
    return
  
  Level = load_level(level)
  assert(Level.get_node("Markers/LevelBottom") != null)
  Level.position.y = get_node("Levels/TransitionTop").position.y - Level.get_node("Markers/LevelBottom").position.y
  Levels.add_child(Level)
  
  SoundManager.update_possible_rivers()
  wire_item_signals() 
  update_wall_positions()


func update_wall_positions() -> void:
  var walled_level = OldLevel if is_transitioning else Level
  get_node("Walls/BottomWall/Box").position.y = walled_level.bottom_wall + walled_level.position.y
  get_node("Walls/TopWall/Box").one_way_collision = walled_level.is_top_open
  get_node("Walls/TopWall/Box").position.y = walled_level.top_wall + walled_level.position.y
  walled_level.dirty = false

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
  
  if Globals.debug_lighting_on():
    set_lighting_on(true, true)
  
  initial_cam_x = Cam.position.x
  Ui.player = Player
  Player.connect("died", self, "handle_player_died")
  start_level(level_scenes[start_level_num])
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
  var walled_level = OldLevel if is_transitioning else Level
  var max_cam = walled_level.bottom_wall - BASE_VIEWPORT_HEIGHT / 2 + walled_level.position.y
  max_cam = max(max_cam, Cam.position.y)
  var cam_pos = Player.position.y - camera_offset
  if center_camera:
    cam_pos = walled_level.get_camera_center().y
  var player_moved_y = (Player.position.y - last_player_y)
  cam_pos = min(Cam.position.y + max(0, player_moved_y) + max_camera_speed * delta, cam_pos)
  cam_pos = max(Cam.position.y + min(0, player_moved_y) - max_camera_speed * delta, cam_pos)
  cam_pos = min(max_cam, cam_pos)
  if not walled_level.is_top_open and not is_transitioning:
    cam_pos = max(walled_level.top_wall + BASE_VIEWPORT_HEIGHT / 2 + walled_level.position.y, cam_pos)
  
  var shake = Vector2.ZERO
  
  if screen_shake_time_left > 0:
    shake = Vector2(randf() * 5.0 - 2.0, randf() * 5.0 - 2.0)
    screen_shake_time_left -= delta
  
  return Vector2(initial_cam_x, cam_pos) + shake

# Returns the current level number, or -1 if you're in a cave
func curr_level_num():
  # name never gets updated!
  
  var index = level_scenes.find(curr_level_name)
  
  if index == -1:
    print("You're transitioning in a cave - this should never happen!")
  
  return index

func _process(delta: float):
  # In this case, the letterbox takes care of camera location
    
  if not Letterbox.in_cinematic and Cam.current:
    Cam.position = get_desired_cam_position(delta)
  
  if Player.position.y < load_y and not is_transitioning:
    is_transitioning = true
    
    var num = curr_level_num()
    
    if num != -1:
      load_new_level(level_scenes[num + 1])
    
  if Player.position.y < teleport_y:
    var bottom = get_node("Levels/TransitionBottom")
    var top = get_node("Levels/TransitionTop")
    
    bottom.position.y = top.position.y
    top.position.y -= TRANSITION_LEN + level_height
    teleport_y = $Levels/TransitionTop/Markers/TeleportPoint.position.y + top.position.y
    load_y = $Levels/TransitionTop/Markers/LoadPoint.position.y + top.position.y
    despawn_y = $Levels/TransitionBottom/Markers/DespawnPoint.position.y + bottom.position.y
    curr_level_name = level_scenes[curr_level_num() + 1]
    is_transitioning = false
    SoundManager.update_song(Level.get_song())
    
  if Player.position.y < despawn_y and OldLevel != null and not is_transitioning:
    OldLevel.queue_free()
    OldLevel = null
    
  last_player_y = Player.position.y
  SoundManager.update_river_volume(Player.global_position.y)


func _physics_process(delta):
  if (is_transitioning and OldLevel.dirty) or (Level.dirty and not is_transitioning):
    update_wall_positions()

func wire_item_signals():
  var items = get_tree().get_nodes_in_group("items")
  
  for item_node in items:
    item_node.connect("body_entered", self, "handle_item_body_entered", [item_node])

func handle_item_body_entered(body: Node, item_node):
  if body == Player and not is_transitioning and not Letterbox.in_cinematic:
    if item_node is Pickup:
      var pickup: Pickup = item_node
      
      yield(Letterbox.get_item_cinematic(pickup), "completed")
      
      Player.get_weapon(pickup.weapon_id)
      Player.set_active(pickup.weapon_id)
      
      item_node.queue_free()

func handle_player_died():
  if Globals.skip_cinematics():
    start_level(level_scenes[curr_level_num()])
    return
    
  Letterbox.in_cinematic = true
  
  for x in range(60):
    yield(get_tree(), "idle_frame")
    Player.Sprite.material.set_shader_param("white", min(1.0, x / 30.0))
    Player.Hand.material.set_shader_param("white", min(1.0, x / 30.0))
    Player.modulate.a = 1.0 - float(x) / 60.0
    
  yield(Letterbox.fade_to_black(120.0), "completed")

  start_level(level_scenes[curr_level_num()])
  
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
func _unhandled_input(event):
  if Input.is_action_just_pressed("pause"):
    add_child(PauseMenu.instance())
    
