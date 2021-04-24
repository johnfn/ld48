extends RigidBody2D 

# TODO: hit walls
# TODO: hit enemies
# TODO: Hit player

# should be supplied by parent
var direction: Vector2
var speed = 400

func _integrate_forces(state):
  state.linear_velocity = direction * speed
