extends RigidBody2D

export(int) onready var damage = 1
export(int) onready var shoot_cooldown = 1
export(float) var invuln_time = 0.25
export(Vector2) var direction_to_shoot = Vector2.RIGHT

onready var BulletScene = load("res://scenes/MonsterBullet.tscn")

onready var Sprite = $Sprite

var shoot_cooldown_remaining = 1
var speed = 300.0
var player_in_contact = null
var health = 2
var invuln_time_left = 0.0

var dying = false

func _ready():
  connect("body_entered", self, "on_enter")
  connect("body_exited", self, "on_exit")

func _process(delta):
  shoot_cooldown_remaining -= delta
  invuln_time_left -= delta
  
  if shoot_cooldown_remaining <= 0:
    shoot_cooldown_remaining = shoot_cooldown
    shoot()
    
  if player_in_contact != null:
    player_in_contact.damage(damage, self)

func is_enemy() -> bool:
  return true

func shoot():
  var new_bullet = BulletScene.instance()
  new_bullet.position += direction_to_shoot * 100
  
  add_child(new_bullet)
  new_bullet.direction = direction_to_shoot


func damage(amount: int, source: Node2D) -> void:
  if invuln_time_left > 0:
    return
    
  health -= amount
  
  if health <= 0 and not dying:
    dying = true
    yield(CombatHelpers.damage_anim_sprite(Sprite), "completed")
    queue_free()
    
    return      

  invuln_time_left = invuln_time
  
  CombatHelpers.damage_anim_sprite(Sprite)

func on_enter(other) -> void:
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other
    

func on_exit(other) -> void:
  if other == player_in_contact:
    player_in_contact = null
