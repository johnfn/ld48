extends RigidBody2D

export(int) onready var damage = 1
export(float) var invuln_time = 0.25

onready var BulletScene = load("res://scenes/MonsterBullet.tscn")

onready var Sprite = $Sprite

var noise = OpenSimplexNoise.new()
var count = 0
var speed = 300.0
var player_in_contact = null
var health = 2
var invuln_time_left = 0.0

var dying = false

func _ready():
  connect("body_entered", self, "on_enter")
  connect("body_exited", self, "on_exit")
  
  var inst = BulletScene.instance()
  add_child(inst)
  
  inst.position.x = 50
  inst.position.y = 50

func _process(delta):
  invuln_time_left -= delta
  
  if player_in_contact != null:
    player_in_contact.damage(damage, self)

func is_enemy() -> bool:
  return true

func damage(amount: int, source: Node2D) -> void:
  if invuln_time_left > 0:
    return
    
  health -= amount
  
  if health <= 0 and not dying:
    dying = true
    yield(CombatHelpers.damage_anim(Sprite), "completed")
    queue_free()
    
    return      

  invuln_time_left = invuln_time
  
  CombatHelpers.damage_anim(Sprite)

func on_enter(other) -> void:
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other
    

func on_exit(other) -> void:
  if other == player_in_contact:
    player_in_contact = null
