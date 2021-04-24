extends Node2D

onready var Player = $Player
onready var Cam = $Camera
onready var Ui = $UI

var inventory = {}
const ALL_SLOTS = ["weapons"]

func _ready():
  wire_item_signals()
  Ui.player = Player


func _process(delta):
  Cam.position.y = Player.position.y - 370


func wire_item_signals():
  var items = get_tree().get_nodes_in_group("items")
  for item_node in items:
    item_node.connect("body_entered", self, "handle_item_body_entered", [item_node])


func handle_item_body_entered(body: Node, item_node):
  if body == Player:
    if item_node.visible:
      item_node.visible = false
      inventory[item_node.name] = item_node.filename
      var slot = ""
      for poss_slot in ALL_SLOTS:
        if item_node.is_in_group(poss_slot):
          slot = poss_slot
      if slot != "":
        var equipment = load(item_node.filename).instance()
        Player.equip(equipment, slot)
        