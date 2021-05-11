extends RigidBody2D

var speed = 1600.0
var active = true

func _ready():
  contact_monitor = true
  contacts_reported = true

func _integrate_forces(state) -> void:
  if not active:
    return
  
  var dir = Vector2(cos(rotation), sin(rotation))
  
  state.linear_velocity = dir * speed

func destroy():
  for x in range(20):
    scale.x = 1.0 - float(x) / 20.0
    scale.y = 1.0 - float(x) / 20.0
    modulate.a = max(10.0 - float(x), 0.0) / 10.0
    
    yield(get_tree(), "idle_frame")
    
  queue_free()
    
    
func _on_Node2D_body_entered(body):
  if not active:
    return
  
  if body.has_method("is_hittable") and body.is_hittable():
    body.damage(1, self)
  
  active = false
  destroy()
