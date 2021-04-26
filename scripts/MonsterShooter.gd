tool
extends BaseHittable

export(int) onready var damage = 1
export(int) onready var shoot_cooldown = 1
export(float) var invuln_time = 0.25
export(int) var bullet_speed = 400
export(Vector2) var direction_to_shoot = Vector2.RIGHT

onready var BulletScene = load("res://scenes/MonsterBullet.tscn")

func _init().():
  self.health = 3

var shoot_cooldown_remaining = 1
var speed = 300.0
var player_in_contact = null
var invuln_time_left = 0.0

var dying = false

func _ready():
  .connect("body_entered", self, "on_enter")
  .connect("body_exited", self, "on_exit")
  if direction_to_shoot.x > 0:
    self.sprite.flip_h = true

func _process(delta):
  if Engine.editor_hint:
    if self.sprite != null:
      self.sprite.flip_h = direction_to_shoot.x > 0
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
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other
    

func on_exit(other) -> void:
  if other == player_in_contact:
    player_in_contact = null
