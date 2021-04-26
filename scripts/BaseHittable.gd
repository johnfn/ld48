class_name BaseHittable
extends RigidBody2D

export(int) var health = 1

onready var sprite = $Sprite
onready var parent = get_node("../")

var heart_drop = load("res://components/HeartDrop.tscn")
var being_hit = false
var knockback_vector: Vector2 = Vector2.ZERO
var knockback: bool = false

func _ready() -> void:
  self.contact_monitor = true
  self.contacts_reported = true
  
  self.connect("body_entered", self, "on_enter")
  self.connect("body_exited", self, "on_exit")
  
  print("Ready up")

func on_enter(other) -> void:
  if other.has_method("is_player") and other.is_player():
    other.damage(1, self)

func on_exit(other) -> void:
  pass

func is_enemy() -> bool:
  return true

# can be overridden if u want custom behavior.
func on_die():
  if randi() % 5 == 0:
    var new_heart = heart_drop.instance()
    parent.add_child(new_heart)
    new_heart.position = position
  
  queue_free()

func damage(amount: int, source: Node2D) -> void:
  if being_hit:
    return

  being_hit = true
  health -= amount
  
  knockback_vector = position.direction_to(source.position) * 10000
  knockback = true

  if sprite is Sprite:
    yield(CombatHelpers.damage_anim_sprite(sprite), "completed")
  elif sprite is AnimatedSprite:
    yield(CombatHelpers.damage_anim_animated_sprite(sprite), "completed")
  else:
    print("unhandled sprite type in damage()")
  
  if health <= 0:
    on_die()
    
  being_hit = false
