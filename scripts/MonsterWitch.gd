extends BaseHittable

func _init().():
  self.health = 3

export(int) onready var damage = 1
export(int) onready var shoot_cooldown = 1
export(Vector2) var starting_direction = Vector2.RIGHT
onready var Letterbox = $"/root/Main/Letterbox"

var shoot_cooldown_remaining = 1
var speed = 300.0
var player_in_contact = null
var is_invuln = false
var current_movement_direction: Vector2
var knockback_confuse_tick = 0

var dying = false

func _ready():
  current_movement_direction = starting_direction
  
  ._ready()

func _integrate_forces(state):
  if Letterbox.in_cinematic: 
    state.linear_velocity = Vector2.ZERO
    return
  
  knockback_confuse_tick -= 1.0
  
  if knockback_confuse_tick < 0:
    state.linear_velocity = current_movement_direction * speed
    if current_movement_direction.x != 0:
      self.sprite.flip_h = current_movement_direction.x > 0
  else:
    if state.linear_velocity.length() < 1.0:
      state.linear_velocity = Vector2.ZERO
    else:
      state.linear_velocity -= Vector2(sign(state.linear_velocity.x) * 20, sign(state.linear_velocity.y) * 20)
  
  if knockback:
    knockback = false
    state.linear_velocity += knockback_vector / 10
    knockback_confuse_tick = 5.0
    knockback_vector = Vector2.ZERO

func on_enter(other) -> void:
  .on_enter(other)
  
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other
  else:
    current_movement_direction *= -1

func on_exit(other) -> void:
  .on_exit(other)
  
  if other == player_in_contact:
    player_in_contact = null

func is_enemy() -> bool:
  return true
