extends RigidBody2D 

# TODO: hit walls
# TODO: hit enemies
# TODO: hit player
# TODO: Better bullet explosion
# TODO: With particle effects

# should be supplied by parent
var direction: Vector2
var speed = 400
var exploding = false

onready var Sprite = $Sprite

func _ready():
  contact_monitor = true
  contacts_reported = true
  
  connect("body_entered", self, "body_entered")

func bullet_explode_anim_co():
  if exploding: 
    return
    
  exploding = true
  
  # TODO - better anim
  Sprite.scale = Vector2(5, 5)
  for x in range(30):
    Sprite.scale = Vector2(1.0 + x / 30.0, 1.0 + x / 30.0)
    Sprite.modulate.a = (10.0 - float(x)) / 10.0

    yield(get_tree(), "idle_frame")

  queue_free()

# I DONT GET WHY THIS BULLET INSTANTLY HITS THE SHOOTER ENEMY< EVEN THO THEY ARENT TOUCHING IN THE SLIGHTEST
# GOD HELP ME

func body_entered(body):
  if body is Player:
    body.damage(1, self)
    bullet_explode_anim_co()
    
    return
  
  if body is StaticBody2D:
    if body.get_collision_layer_bit(1): # Wall
      bullet_explode_anim_co()
      
      return

func _integrate_forces(state):
  state.linear_velocity = direction * speed
