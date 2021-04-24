extends RigidBody2D 

# TODO: hit walls
# TODO: hit enemies
# TODO: Hit player
# TODO: Explode

# should be supplied by parent
var direction: Vector2
var speed = 400

func _ready():
  contact_monitor = true
  contacts_reported = true
  
  connect("body_entered", self, "body_entered")

func bullet_explode_anim_co():
  # TODO
  
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
