extends Node2D

onready var Player = $Player
onready var Cam = $Camera
onready var Ui = $UI
onready var Levels = $Levels

export(float) var max_camera_speed = 300
export(float) var camera_offset = 370
export(bool) var debug_already_has_sword = false
export(Array) var level_scenes = ["res://levels/LevelTemplate.tscn"]

var inventory = []
const ALL_SLOTS = ["weapons"]
var Level = null
const BASE_VIEWPORT_HEIGHT = 1280 # TODO this sucks
var last_player_y = 0

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

func _ready():
  Ui.player = Player
  
  start_level(0)

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
  if not Level.is_top_open:
    cam_pos = max(Level.top_wall + BASE_VIEWPORT_HEIGHT / 2, cam_pos)
  Cam.position.y = cam_pos
  last_player_y = Player.position.y


func wire_item_signals():
  var items = get_tree().get_nodes_in_group("items")
  for item_node in items:
    item_node.connect("body_entered", self, "handle_item_body_entered", [item_node])


func handle_item_body_entered(body: Node, item_node):
  if body == Player:
    add_to_inventory(item_node.name)
    var slot = ""
    for poss_slot in ALL_SLOTS:
      if item_node.is_in_group(poss_slot):
        slot = poss_slot
    if slot != "":
      var equipment = load(item_node.filename).instance()
      Player.equip(equipment, slot)
    item_node.queue_free()
