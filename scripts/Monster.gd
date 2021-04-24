extends RigidBody2D

export(int) onready var damage = 1
var noise = OpenSimplexNoise.new()
var count = 0
var speed = 300.0
var player_in_contact = null

# Called when the node enters the scene tree for the first time.
func _ready():
  noise.seed = randi()
  noise.octaves = 4
  noise.period = 300.0
  noise.persistence = 0.8
  connect("body_entered", self, "on_enter")
  connect("body_exited", self, "on_exit")


func _process(delta):
  if player_in_contact != null:
    player_in_contact.damage(damage)


func _integrate_forces(state):
  count += 1
  var x_vel = noise.get_noise_1d(count)
  var y_vel = noise.get_noise_1d(-count)
  var direction = Vector2(x_vel, y_vel).normalized()
  state.linear_velocity = direction * speed


func is_enemy() -> bool:
  return true


func damage(amount: int) -> void:
  queue_free()
    

func on_enter(other) -> void:
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other
    

func on_exit(other) -> void:
  if other == player_in_contact:
    player_in_contact = null
