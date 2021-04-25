extends RigidBody2D

export(int) onready var damage = 1
export(int) onready var shoot_cooldown = 1
export(float) var invuln_time = 0.25
export(Vector2) var starting_direction = Vector2.RIGHT

onready var Sprite = $Sprite

var shoot_cooldown_remaining = 1
var speed = 300.0
var player_in_contact = null
var health = 2
var is_invuln = false
var current_movement_direction: Vector2

var dying = false

func _ready():
  contact_monitor = true
  contacts_reported = true
  current_movement_direction = starting_direction
  
  connect("body_entered", self, "on_enter")
  connect("body_exited", self, "on_exit")

func _integrate_forces(state):
  state.linear_velocity = current_movement_direction * speed

func is_enemy() -> bool:
  return true

func damage(amount: int, source: Node2D) -> void:
  if is_invuln:
    return
    
  is_invuln = true
  health -= amount
  
  if health <= 0 and not dying:
    dying = true
    yield(CombatHelpers.damage_anim(Sprite), "completed")
    queue_free()
    
    return
  
  yield(CombatHelpers.damage_anim(Sprite), "completed")
  
  is_invuln = false

func on_enter(other) -> void:
  if other is StaticBody2D:
    if other.get_collision_layer_bit(1): # Wall
      current_movement_direction *= -1
  
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other

func on_exit(other) -> void:
  if other == player_in_contact:
    player_in_contact = null
