extends RigidBody2D 


# should be supplied by parent
var direction: Vector2
var speed = 400
var exploding = false
var shooter = null
var damage = 1
var active = true

onready var animation = $AnimationPlayer
onready var sprite = $Sprite

func _ready():
  contact_monitor = true
  contacts_reported = true
  
  connect("body_entered", self, "body_entered")

func explode():
  if exploding or not active: 
    return
    
  exploding = true
  
  animation.play("Hit")
  
  yield(animation, "animation_finished")

  queue_free()

# I DONT GET WHY THIS BULLET INSTANTLY HITS THE SHOOTER ENEMY< EVEN THO THEY ARENT TOUCHING IN THE SLIGHTEST
# GOD HELP ME

func body_entered(body):
  if body is Player:
    body.damage(damage, self)
    explode()
  elif body != shooter:
    explode()

func _integrate_forces(state):
  if exploding: 
    state.linear_velocity = Vector2.ZERO
    return
    
  if active:
    state.linear_velocity = direction * speed

  var bounds = Rect2(global_position - Vector2(5, 5), Vector2(10, 10))
  
  if not Globals.cam_extents().intersects(bounds):
    queue_free()
