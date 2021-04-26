extends BaseHittable

func _init().():
  self.health = 3

export(int) onready var damage = 1
export(int) onready var shoot_cooldown = 1
export(Vector2) var starting_direction = Vector2.RIGHT

var shoot_cooldown_remaining = 1
var speed = 300.0
var player_in_contact = null
var is_invuln = false
var current_movement_direction: Vector2

var dying = false

func _ready():
  self.contact_monitor = true
  self.contacts_reported = true
  
  current_movement_direction = starting_direction
  
  .connect("body_entered", self, "on_enter")
  .connect("body_exited", self, "on_exit")

func _integrate_forces(state):
  if Letterbox.in_cinematic: 
    state.linear_velocity = Vector2.ZERO
    return
  
  state.linear_velocity = current_movement_direction * speed
  if current_movement_direction.x != 0:
    self.sprite.flip_h = current_movement_direction.x > 0

func on_enter(other) -> void:
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other
  else:
    current_movement_direction *= -1

func on_exit(other) -> void:
  if other == player_in_contact:
    player_in_contact = null
