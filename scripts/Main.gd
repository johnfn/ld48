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

export(float) var max_camera_speed = 300
export(float) var camera_offset = 370
export(bool) var debug_already_has_sword = false

export(Array) var level_scenes = ["res://levels/LevelTemplateAndrew.tscn"]

export(int) var curr_level_num = 0

var inventory = []
var slots = {}
var saved_inventory = []
var saved_slots = {}
const ALL_SLOTS = ["weapons"]
var Level = null
const BASE_VIEWPORT_HEIGHT = 1280 # TODO this sucks
const WALL_THICKNESS = 10
var last_player_y = 0
var last_is_top_open = false
var is_transitioning = false
var bgs = [0, 1, 2, 3]

func add_to_inventory(item_name):
  inventory.append(item_name)
  Ui.display_items(inventory)


func checkpoint():
  saved_inventory = inventory.duplicate()
  saved_slots = slots.duplicate()


func start_level(level_num: int) -> void:
  if Level != null:
    Level.queue_free()
  Level = load(level_scenes[level_num]).instance()
  Levels.add_child(Level)
  
  Player.position.x = Level.spawn_point.x
  jump_view(Level.spawn_point.y - Player.position.y)
  Player.health = Player.max_health
  Player.reset_equipment()
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


func load_new_level(level_num: int) -> void:
  Level.queue_free()
  Level = load(level_scenes[level_num]).instance()
  Levels.add_child(Level)
  wire_item_signals() 
  TransitionBottom.position.y = Level.bottom_wall
  curr_level_num = level_num
  is_transitioning = true
  update_wall_positions()


func update_wall_positions() -> void:
  get_node("Walls/BottomWall/Box").position.y = Level.bottom_wall
  get_node("Walls/TopWall/Box").one_way_collision = Level.is_top_open
  get_node("Walls/TopWall/Box").position.y = Level.top_wall


func _ready():
  if debug_already_has_sword:
    saved_inventory.append("Sword", "res://components/Sword.tscn")
    
  Ui.player = Player
  Player.connect("died", self, "handle_player_died")
  start_level(curr_level_num)


func jump_view(dist):
  for bg in $Background.get_children():
    bg.get_node('Hitbox').disabled = true
  Player.position.y += dist
  Cam.position.y += dist
  for bg in $Background.get_children():
    bg.position.y += dist
    bg.get_node('Hitbox').disabled = false


func _process(delta):
  var max_cam = Level.bottom_wall - BASE_VIEWPORT_HEIGHT / 2
  max_cam = max(max_cam, Cam.position.y)
  var cam_pos = Player.position.y - camera_offset
  var player_moved_y = (Player.position.y - last_player_y)
  cam_pos = min(Cam.position.y + max(0, player_moved_y) + max_camera_speed * delta, cam_pos)
  cam_pos = max(Cam.position.y + min(0, player_moved_y) - max_camera_speed * delta, cam_pos)
  cam_pos = min(max_cam, cam_pos)
  if not Level.is_top_open and not is_transitioning:
    cam_pos = max(Level.top_wall + BASE_VIEWPORT_HEIGHT / 2, cam_pos)
  Cam.position.y = cam_pos
  
  if Player.position.y < load_y and not is_transitioning:
    load_new_level(curr_level_num + 1)

  if Player.position.y < teleport_y:
    var teleport_dist = TransitionBottom.position.y - TransitionTop.position.y
    jump_view(teleport_dist)
    is_transitioning = false
    
  last_player_y = Player.position.y
  

func _physics_process(delta):
  if last_is_top_open != Level.is_top_open:
    last_is_top_open = Level.is_top_open
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
  start_level(curr_level_num)


const BACKGROUND_HEIGHT = 2560
func _on_background_entered(body, i):
  if body.has_method("is_player") and body.is_player():
    print(bgs, ' ', i)
    if i == bgs[0]:
      var last = bgs.pop_back()
      bgs.push_front(last)
      $Background.get_child(last).position.y -= BACKGROUND_HEIGHT * len(bgs)
    elif i == bgs[len(bgs)-1]:
      var front = bgs.pop_front()
      bgs.push_back(front)
      $Background.get_child(front).position.y += BACKGROUND_HEIGHT * len(bgs)
