extends RigidBody2D

export(int) onready var damage = 1
export(float) var invuln_time = 0.25

onready var Sprite = $Sprite

var noise = OpenSimplexNoise.new()
var count = 0
var speed = 300.0
var player_in_contact = null
var health = 2
var invuln_time_left = 0.0

var knockback = false
var knockback_vector: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
  noise.seed = randi()
  noise.octaves = 4
  noise.period = 300.0
  noise.persistence = 0.8
  connect("body_entered", self, "on_enter")
  connect("body_exited", self, "on_exit")

func damage_anim():
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  
  Sprite.material.set_shader_param("white", 1.0)

  yield(get_tree().create_timer(0.1), "timeout")
  
  Sprite.material.set_shader_param("white", 0.0)

func _process(delta):
  invuln_time_left -= delta
  
  if player_in_contact != null:
    player_in_contact.damage(damage, self)


func _integrate_forces(state):
  count += 1
  var x_vel = noise.get_noise_1d(count)
  var y_vel = noise.get_noise_1d(-count)
  var direction = Vector2(x_vel, y_vel).normalized()
  state.linear_velocity = direction * speed
  
  if knockback:
    knockback = false
    state.linear_velocity += knockback_vector
    knockback_vector = Vector2.ZERO

func is_enemy() -> bool:
  return true

func damage(amount: int, source: Node2D) -> void:
  if invuln_time_left > 0:
    return
    
  health -= amount
  
  if health <= 0:
    animate_and_die()
    return      

  invuln_time_left = invuln_time
  
  knockback_vector = position.direction_to(source.position) * 10000
  knockback = true
  
  damage_anim()

func animate_and_die():
  yield(damage_anim(), "completed")
  queue_free()

func on_enter(other) -> void:
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other
    

func on_exit(other) -> void:
  if other == player_in_contact:
    player_in_contact = null
