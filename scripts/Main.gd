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
export(Array) var level_scenes = ["res://levels/LevelTemplateAndrew.tscn", "res://levels/LevelTemplateMike.tscn"]
export(int) var curr_level_num = 0

var inventory = []
const ALL_SLOTS = ["weapons"]
var Level = null
const BASE_VIEWPORT_HEIGHT = 1280 # TODO this sucks
const WALL_THICKNESS = 10
var last_player_y = 0
var last_is_top_open = false
var is_transitioning = false

func add_to_inventory(item_name):
  inventory.append(item_name)
  Ui.display_items(inventory)


func start_level(level_num: int) -> void:
  Level = load(level_scenes[level_num]).instance()
  Levels.add_child(Level)
  Player.position = Level.spawn_point
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
  Ui.player = Player
  
  start_level(curr_level_num)

  if debug_already_has_sword:
    var equipment = load("res://components/Sword.tscn").instance()
    Player.equip(equipment, ALL_SLOTS[0])
    add_to_inventory("Sword")


func _process(delta):
  var max_cam = Level.bottom_wall - BASE_VIEWPORT_HEIGHT / 2
  max_cam = max(max_cam, Cam.position.y)
  var cam_pos = Player.position.y - camera_offset
  var player_moved_y = (Player.position.y - last_player_y)
  cam_pos = min(Cam.position.y + player_moved_y + max_camera_speed * delta, cam_pos)
  cam_pos = max(Cam.position.y + player_moved_y - max_camera_speed * delta, cam_pos)
  cam_pos = min(max_cam, cam_pos)
  if not Level.is_top_open and not is_transitioning:
    cam_pos = max(Level.top_wall + BASE_VIEWPORT_HEIGHT / 2, cam_pos)
  Cam.position.y = cam_pos
  
  if Player.position.y < load_y and not is_transitioning:
    load_new_level(curr_level_num + 1)

  if Player.position.y < teleport_y:
    var teleport_dist = TransitionBottom.position.y - TransitionTop.position.y
    Player.position.y += teleport_dist
    Cam.position.y += teleport_dist
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


func handle_item_body_entered(body: Node, item_node):
  if body == Player and not is_transitioning:
    add_to_inventory(item_node.name)
    var slot = ""
    for poss_slot in ALL_SLOTS:
      if item_node.is_in_group(poss_slot):
        slot = poss_slot
    if slot != "":
      var equipment = load(item_node.filename).instance()
      Player.equip(equipment, slot)
    item_node.queue_free()
