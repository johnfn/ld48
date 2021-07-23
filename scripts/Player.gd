class_name Player
extends KinematicBody2D

signal died

const IDLE_FRAME = 1

var input_vec : Vector2 = Vector2(0, 0)
# Old max 600.0
export(float) var max_speed = 420.0
export(float) var invuln_time = 0.4
export(int) var max_health = 4

onready var Letterbox = $"/root/Main/Letterbox"
onready var Sprite: AnimatedSprite = $Sprite
onready var Hand = $Equipment/weapons/Hand
onready var Equipment = $Equipment
onready var Weapons = $Equipment/weapons
onready var health = max_health
onready var coins = 0
onready var hitbox: CollisionShape2D = $Hitbox

var is_invuln = false
var idleCounter = 0
var arrows = 10
var max_arrows = 20

var knockback = false
var knockback_source: Node2D = null
const KNOCKBACK_DECAY = 15000
var knockback_velocity = Vector2(0, 0)

var FOOTSTEP_RATE = 0.25
var FOOTSTEP_RANGE = 0.03
var footstep_target = 0.0
var SPAWN_INVULN = 1.0 # seconds
var spawn_invuln_left = SPAWN_INVULN
var arrow_scene = load("res://scenes/Arrow.tscn")
var WeaponName = preload("res://scripts/WeaponName.gd").WeaponName

onready var WeaponSprites = [
  null,
  $Equipment/weapons/Sword,
  $Equipment/weapons/Bow
]
var has_weapon = [true, false, false]
var active_weapon = 0

func _ready() -> void:
  for sprite in WeaponSprites:
    if sprite != null:
      sprite.visible = false
  
  # hitbox.connect()
  
  if Globals.debug_has_sword():
    get_weapon(WeaponName.Sword)
    set_active(WeaponName.Sword)
    
  if Globals.debug_has_bow():
    get_weapon(WeaponName.Bow)
    set_active(WeaponName.Bow)
    
func get_weapon(weapon):
  has_weapon[weapon] = true
  active_weapon = weapon

func set_active(weapon):
  active_weapon = weapon
  
  for sprite in WeaponSprites:
    if sprite != null:
      sprite.visible = false
  
  if WeaponSprites[weapon] != null:
    WeaponSprites[weapon].visible = true

func is_active(weapon):
  return active_weapon == weapon

func _process(_delta: float) -> void:  
  if Letterbox.in_cinematic:
    return
  
  if is_active(WeaponName.Sword):
    WeaponSprites[WeaponName.Sword].look_at(get_global_mouse_position())
  
  if is_active(WeaponName.Bow):
    WeaponSprites[WeaponName.Bow].look_at(get_global_mouse_position())
  
  if Input.is_key_pressed(KEY_F) and Globals.debug_f_die():
    damage(9999, self)
  
  if Input.is_key_pressed(KEY_G) and Globals.debug_g_give_money():
    coins += 1

  if Input.is_action_just_pressed("swap_weapon"):
    rotate_weapon()

func rotate_weapon():
  for i in range(active_weapon + 1, active_weapon + len(WeaponSprites) + 1):
    var weapon = i % len(WeaponSprites)
    
    if has_weapon[weapon]:
      set_active(weapon)
      return
      
      

func fire_arrow():
  if arrows <= 0:
    # TODO: Some sort of 'empty quiver' noise or something
    return
  
  arrows -= 1
  
  var new_arrow: Node2D = arrow_scene.instance()
  
  $"/root/Main".add_child(new_arrow)
  
  new_arrow.global_position = global_position
  new_arrow.look_at(get_global_mouse_position())
  
  # Go past player
  var dir = Vector2(cos(new_arrow.rotation), sin(new_arrow.rotation))
  new_arrow.global_position += dir * 100.0

func _physics_process(delta: float) -> void:
  if Letterbox.in_cinematic: 
    Sprite.stop()
    Sprite.frame = IDLE_FRAME
        
    return
  
  var is_running = Input.is_key_pressed(KEY_SHIFT)
  
  spawn_invuln_left -= delta
  var direction = input_vec.normalized() * max_speed * ((4.0 if Globals.debug_hyper_run() else 2.0) if is_running else 1.0)
  
  var knockback_strength = knockback_velocity.length()
  
  if knockback_strength > 0:
    knockback_velocity = knockback_velocity.normalized() * max(0, knockback_strength - KNOCKBACK_DECAY * delta)
    direction += knockback_velocity
  else:
    knockback = false
    knockback_source = null

  if input_vec.y < 0:
    if input_vec.x > 0:
      set_direction("upright")
    elif input_vec.x < 0:
      set_direction("upleft")
    else:
      set_direction("up")
  elif input_vec.y > 0:
    if input_vec.x > 0:
      set_direction("downright")
    elif input_vec.x < 0:
      set_direction("downleft")
    else:
      set_direction("down")
  elif input_vec.x > 0:
    set_direction("right")
  elif input_vec.x < 0:
    set_direction("left")


  if input_vec == Vector2(0, 0) and Sprite.is_playing():
    # IdleCounter smooths the stopping animation
    # Also reduces sliding
    idleCounter += 1
    if idleCounter > 3:
      Sprite.stop()
      Sprite.frame = IDLE_FRAME
      idleCounter = 0
    footstep_target = 0.0
  elif input_vec != Vector2(0, 0) and footstep_target >= 0.0:
    footstep_target -= delta
    if footstep_target < 0:
      footstep_target += FOOTSTEP_RATE + (randf() * 2 - 1) * FOOTSTEP_RANGE
      SoundManager.play_sound("Footstep")
    
  var _unused = move_and_slide(direction, Vector2(0, 0), false, 4, 0.785398, false)
  
  try_to_push_rocks(input_vec)

var rock_push_tick = {}

func try_to_push_rocks(input_vec: Vector2):
  var collided_rocks = []
  
  for i in get_slide_count():
    var collision = get_slide_collision(i)
    var collider = collision.collider
    
    if collider.has_method("is_pushable"):
      collided_rocks.append(collider)
  
  # Update amount of time we've been pushing each rock
  
  var new_rock_push_tick = {}
  
  for rock in collided_rocks:
    if rock in rock_push_tick:
      new_rock_push_tick[rock] = rock_push_tick[rock] + 1
    else:
      new_rock_push_tick[rock] = 1
  
  rock_push_tick = new_rock_push_tick
  
  for rock in rock_push_tick:
    if rock_push_tick[rock] > 20:
      
      # Actually push the rock
      
      rock_push_tick[rock] = 0
      
      var self_center = self.get_node("Center").global_position
      var rock_center = rock.get_node("Center").global_position
      
      var dx = self_center.x - rock_center.x
      var dy = self_center.y - rock_center.y
      
      
      if (input_vec.x != 0) != (input_vec.y != 0):
        # if only one directional key is pressed, it's pretty easy
        if input_vec.x < 0:
          rock.attempt_push(2) # left
        elif input_vec.x > 0:
          rock.attempt_push(0) # right
        elif input_vec.y > 0:
          rock.attempt_push(1) # down
        elif input_vec.y < 0:
          rock.attempt_push(3) # up
      else:
        # if they're pushing diagonally, try to figure out which direction is more sensible

        if abs(dx) > abs(dy):
          if dx > 0:
            rock.attempt_push(2) # left
          elif dx < 0:
            rock.attempt_push(0) # right
        else:
          if dy < 0:
            rock.attempt_push(1) # down
          elif dy > 0:
            rock.attempt_push(3) # up
      
#      var dir_map = {
#        move_left = 2,
#        move_up = 3,
#        move_right = 0,
#        move_down = 1
#      }

func _unhandled_input(_event: InputEvent) -> void:  
  if Input.is_action_just_pressed("move_down"):
    input_vec.y = 1
  elif Input.is_action_just_pressed("move_up"):
    input_vec.y = -1
  elif not Input.is_action_pressed("move_down") and not Input.is_action_pressed("move_up"):
    input_vec.y = 0
    
  if Input.is_action_just_pressed("move_right"):
    input_vec.x = 1
  elif Input.is_action_just_pressed("move_left"):
    input_vec.x = -1
  elif not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
    input_vec.x = 0
  
  if Weapons.get_child_count() > 0:
    if Input.is_action_just_pressed("interact"):
      if is_active(WeaponName.Sword):
        WeaponSprites[WeaponName.Sword].set_in_use(true)
        
      if is_active(WeaponName.Bow):
        fire_arrow()
        
    elif Input.is_action_just_released("interact"):
      if is_active(WeaponName.Sword):
        WeaponSprites[WeaponName.Sword].set_in_use(false)

func set_direction(dir_name):
  if Sprite.animation != dir_name or not Sprite.playing:
    Sprite.play(dir_name)
  
  if dir_name.find("up") >= 0 or dir_name == "left":
    Weapons.z_index = 0
  else:
    Weapons.z_index = 0
  
  match dir_name:
    "up":
      Weapons.position = $Equipment/rh_up.position
    "down":
      Weapons.position = $Equipment/rh_down.position
    "left":
      Weapons.position = $Equipment/rh_left.position
    "right":
      Weapons.position = $Equipment/rh_right.position
    "upleft":
      Weapons.position = $Equipment/rh_upleft.position
    "downleft":
      Weapons.position = $Equipment/rh_downleft.position
    "upright":
      Weapons.position = $Equipment/rh_upright.position
    "downright":
      Weapons.position = $Equipment/rh_downright.position

func get_coin(amount: int) -> void:
  coins += amount

func get_health(amount: int) -> void:
  health += amount
  
  if health > max_health:
    health = max_health


func get_arrows(amount: int) -> void:
  arrows += amount
  
  if arrows > max_arrows:
    arrows = max_arrows
    
func damage(amount: int, source: Node2D, strength = 500) -> void:
  # returns whether damage was actually taken
  if not is_invuln and health > 0 and not Letterbox.in_cinematic and spawn_invuln_left <= 0.0:
    # take damage
    
    if not Globals.debug_invincible():
      health -= amount
      
    SoundManager.play_sound("Hit")
    
    if health <= 0:
      emit_signal("died")
      is_invuln = false
      Sprite.stop()
      Sprite.frame = IDLE_FRAME
      Input.action_press("interact")
      for child in get_children():
        if "Dialog" in child.name:
          child.queue_free()
      return
    
    # bump player back a little
    
    knockback_velocity += strength * (global_position - source.global_position).normalized()

    if amount > 0:
      is_invuln = true
      yield(CombatHelpers.damage_anim_animated_sprite(Sprite), "completed")
      is_invuln = false


func reset():
  Sprite.animation = "up"
  Sprite.stop()
  Sprite.frame = IDLE_FRAME
  health = max_health
  spawn_invuln_left = SPAWN_INVULN

func is_player() -> bool:
  return true

func height() -> bool:
    return $Sprite.frames.get_frame("down", 0).get_height()
