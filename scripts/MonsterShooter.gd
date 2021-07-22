# tool
extends BaseHittableArea

onready var Letterbox = $"/root/Main/Letterbox"
export(int) onready var damage = 1
export(int) onready var shoot_cooldown = 1
export(float) var invuln_time = 0.25
export(int) var bullet_speed = 400
export(Vector2) var direction_to_shoot = Vector2.RIGHT

onready var BulletScene = load("res://scenes/MonsterBullet.tscn")

func _init().():
  self.health = 3
  self.deals_damage = true

var shoot_cooldown_remaining = 1
var speed = 300.0
var player_in_contact = null
var invuln_time_left = 0.0

var dying = false

func _ready():
  ._ready()
  
  print("Hewo")
  if not Engine.editor_hint:
    $Sprite.material = load("res://assets/shaders/WindSwept.tres").duplicate()
    $Sprite.material.set_shader_param("wind_magnitude", 0) # shooters are unaffected by wind
  
  if direction_to_shoot.x > 0:
    self.sprite.flip_h = true
    
func _integrate_forces(state):
  state.linear_velocity = Vector2.ZERO
  
func _process(delta):
  if Engine.editor_hint:
    $Sprite.material = null
    
    if sprite != null:
      sprite.flip_h = direction_to_shoot.x > 0
    return
  
  if Letterbox.in_cinematic: return
    
  shoot_cooldown_remaining -= delta
  invuln_time_left -= delta
  
  if shoot_cooldown_remaining <= 0:
    shoot_cooldown_remaining = shoot_cooldown
    shoot()
    
  if player_in_contact != null:
    player_in_contact.damage(damage, self)

func shoot():
  if Engine.editor_hint:
    return
    
  var new_bullet = BulletScene.instance()
  new_bullet.position += direction_to_shoot * 100
  new_bullet.shooter = self
  new_bullet.speed = bullet_speed
  
  .add_child(new_bullet)
  new_bullet.direction = direction_to_shoot

func on_enter(other) -> void:
  .on_enter(other)
  
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other

func on_exit(other) -> void:
  .on_exit(other)
  
  if other == player_in_contact:
    player_in_contact = null
    
func is_enemy() -> bool:
  return true
