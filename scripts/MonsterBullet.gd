extends RigidBody2D 


# should be supplied by parent
var direction: Vector2
var speed = 400
var exploding = false
var shooter = null
var damage = 1
var active = true

onready var sprite = $Sprite

func _ready():
  contact_monitor = true
  contacts_reported = true
  
  connect("body_entered", self, "body_entered")

func bullet_explode_anim_co():
  if exploding or not active: 
    return
    
  exploding = true
  
  # TODO - better anim
  self.sprite.scale = Vector2(5, 5)
  for x in range(30):
    self.sprite.scale = Vector2(1.0 + x / 30.0, 1.0 + x / 30.0)
    self.sprite.modulate.a = (10.0 - float(x)) / 10.0

    yield(get_tree(), "idle_frame")

  queue_free()

# I DONT GET WHY THIS BULLET INSTANTLY HITS THE SHOOTER ENEMY< EVEN THO THEY ARENT TOUCHING IN THE SLIGHTEST
# GOD HELP ME

func body_entered(body):
  if body is Player:
    body.damage(damage, self)
    bullet_explode_anim_co()
  elif body != shooter:
    print(body.name)
    bullet_explode_anim_co()

func _integrate_forces(state):
  if active:
    state.linear_velocity = direction * speed
