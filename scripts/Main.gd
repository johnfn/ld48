class_name Main
extends Node2D

onready var Player = $Player
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

export(float) var max_camera_speed = 300
export(float) var camera_offset = 370
export(bool) var debug_already_has_sword = false

export(Array) var level_scenes = ["res://levels/Level0Mock.tscn", "res://levels/Level1Mock.tscn", "res://levels/Level2Mock.tscn", "res://levels/Level3Mock.tscn", "res://levels/Level4Mock.tscn", "res://levels/Level5Mock.tscn"]

export(int) var curr_level_num = 0

var center_camera = false
var inventory = []
var slots = {}
var saved_inventory = []
var saved_slots = {}
const ALL_SLOTS = ["weapons"]
var Level = null
var OldLevel = null
var level_height = null
const BASE_VIEWPORT_HEIGHT = 1280 # TODO this sucks
const WALL_THICKNESS = 10
const TRANSITION_LEN = 380
var last_player_y = 0
var is_transitioning = false
var bgs = [0, 1, 2, 3]

func add_to_inventory(item_name):
  inventory.append(item_name)
  Ui.display_items(inventory)


func checkpoint():
  saved_inventory = inventory.duplicate()
  saved_slots = slots.duplicate()


func load_level(level_name: String):
  Level = load(level_name).instance()
  assert(Level.get_node("Markers/LevelBottom") != null)
  assert(Level.get_node("Markers/LevelTop") != null)
  level_height = Level.get_node("Markers/LevelBottom").position.y - Level.get_node("Markers/LevelTop").position.y
  if Level.has_method('set_player'):
    Level.set_player(Player)
  if Level.has_method('set_camera'):
    Level.set_camera(Cam)


func start_level(level_num: int) -> void:
  if Level != null:
    Level.queue_free()
  if OldLevel != null:
    OldLevel.queue_free()
    
  load_level(level_scenes[level_num])
  Levels.add_child(Level)
  
  Player.position.x = Level.spawn_point.x
  jump_view(Level.spawn_point.y - Player.position.y)
  Player.reset()
  Cam.current = true
  inventory = saved_inventory.duplicate()
  slots = saved_slots.duplicate()
  for slot in saved_slots.keys():
    equip_to_slot(slot, saved_slots[slot])
  
  wire_item_signals() 
  Cam.position.y = Level.bottom_wall - BASE_VIEWPORT_HEIGHT / 2
  last_player_y = Player.position.y
  TransitionBottom.position.y = Level.bottom_wall
  curr_level_num = level_num
  TransitionBottom.position.y = Level.bottom_wall
  update_wall_positions()
  is_transitioning = false


func load_new_level(level_num: int) -> void:
  OldLevel = Level
  load_level(level_scenes[level_num])
  assert(Level.get_node("Markers/LevelBottom") != null)
  Level.position.y = get_node("Levels/TransitionTop").position.y - Level.get_node("Markers/LevelBottom").position.y
  Levels.add_child(Level)
  wire_item_signals() 
  update_wall_positions()


func update_wall_positions() -> void:
  var walled_level = OldLevel if is_transitioning else Level
  get_node("Walls/BottomWall/Box").position.y = walled_level.bottom_wall + walled_level.position.y
  get_node("Walls/TopWall/Box").one_way_collision = walled_level.is_top_open
  get_node("Walls/TopWall/Box").position.y = walled_level.top_wall + walled_level.position.y
  walled_level.dirty = false


func _ready():
  if debug_already_has_sword:
    saved_inventory.append("Sword")
    saved_slots["weapons"] = "res://components/Sword.tscn"
    
  Ui.player = Player
  Player.connect("died", self, "handle_player_died")
  start_level(curr_level_num)
  CloudSpawner.initial_cloud_spawn()
  Letterbox.setup()


func jump_view(dist):
  for bg in $Background.get_children():
    bg.get_node('Hitbox').disabled = true
  Player.position.y += dist
  Cam.position.y += dist
  for bg in $Background.get_children():
    bg.position.y += dist
    bg.get_node('Hitbox').disabled = false


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
  
  return cam_pos


func _process(delta: float):
  if not Letterbox.in_cinematic and Cam.current:
    # In this case, the letterbox takes care of camera location 
    Cam.position.y = get_desired_cam_position(delta)
  
  if Player.position.y < load_y and not is_transitioning:
    is_transitioning = true
    load_new_level(curr_level_num + 1)
  if Player.position.y < teleport_y:
    var bottom = get_node("Levels/TransitionBottom")
    var top = get_node("Levels/TransitionTop")
    bottom.position.y = top.position.y
    top.position.y -= TRANSITION_LEN + level_height
    teleport_y = $Levels/TransitionTop/Markers/TeleportPoint.position.y + top.position.y
    load_y = $Levels/TransitionTop/Markers/LoadPoint.position.y + top.position.y
    despawn_y = $Levels/TransitionBottom/Markers/DespawnPoint.position.y + bottom.position.y
    curr_level_num += 1
    is_transitioning = false
  if Player.position.y < despawn_y and OldLevel != null and not is_transitioning:
    OldLevel.queue_free()
    OldLevel = null
    
  last_player_y = Player.position.y


func _physics_process(delta):
  if (is_transitioning and OldLevel.dirty) or (Level.dirty and not is_transitioning):
    update_wall_positions()


func wire_item_signals():
  var items = get_tree().get_nodes_in_group("items")
  for item_node in items:
    item_node.connect("body_entered", self, "handle_item_body_entered", [item_node])


func equip_to_slot(slot, equipment_filename):
  var equipment: Node2D = load(equipment_filename).instance()
  slots[slot] = equipment_filename
  Player.equip(equipment, slot)
  if equipment.has_method("on_pick_up"):
    equipment.call_deferred("on_pick_up") # need to wait for the children to load in, etc


func process_item(item_node):
    add_to_inventory(item_node.name)
    var slot = ""
    for poss_slot in ALL_SLOTS:
      if item_node.is_in_group(poss_slot):
        slot = poss_slot
    if slot != "":
      equip_to_slot(slot, item_node.filename)


func handle_item_body_entered(body: Node, item_node):
  if body == Player and not is_transitioning:
    process_item(item_node)
    item_node.queue_free()


func handle_player_died():
  Letterbox.in_cinematic = true
  
  print(Player.modulate.a)
  
  for x in range(60):
    yield(get_tree(), "idle_frame")
    Player.Sprite.material.set_shader_param("white", min(1.0, x / 30.0))
    Player.Hand.material.set_shader_param("white", min(1.0, x / 30.0))
    Player.modulate.a = 1.0 - float(x) / 60.0
    
  yield(Letterbox.fade_to_black(120.0), "completed")

  start_level(curr_level_num)
  
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
    print("pausing")
    add_child(PauseMenu.instance())
    
