extends Node2D

onready var Player = $Player
onready var Cam = $Camera
onready var Ui = $UI
onready var Levels = $Levels.get_children()

export(bool) var debug_already_has_sword = false

var inventory = []
const ALL_SLOTS = ["weapons"]

func add_to_inventory(item_name):
  inventory.append(item_name)
  Ui.display_items(inventory)


func _ready():
  wire_item_signals()
  Ui.player = Player
  
  if debug_already_has_sword:
    var equipment = load("res://components/Sword.tscn").instance()
    Player.equip(equipment, ALL_SLOTS[0])

func _process(delta):
  Cam.position.y = Player.position.y - 370


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
        

func reset_to_level(level_num):
  var level = Levels[level_num]
  var level_bounds = level.get_child('Bounds') as Area2D
  
