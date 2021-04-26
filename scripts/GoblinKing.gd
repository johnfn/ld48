extends KinematicBody2D

signal died

const MAX_HEALTH = 10
var health = MAX_HEALTH

export(int) onready var damage = 1
export(int) onready var shoot_cooldown = 1
export(Vector2) var starting_direction = Vector2.RIGHT

var shoot_cooldown_remaining = 1
var speed = 300.0
var player_in_contact = null
var is_invuln = false
var being_hit = false
var timer = Timer.new()
export(float) var pause_between_attacks = 1.0
var time_until_attack = pause_between_attacks
var curr_attack = 0
var player = null

enum Mode {
  WAITING,
  IDLE,
  SPEAR,
  JUMP,
  SUMMON,
  RETREAT
}

var curr_mode = Mode.WAITING
var dying = false

func _ready():
  pass
#  self.contact_monitor = true
#  self.contacts_reported = true
#
#  .connect("body_entered", self, "on_enter")
#  .connect("body_exited", self, "on_exit")


func _integrate_forces(state):
  if Letterbox.in_cinematic: 
    state.linear_velocity = Vector2.ZERO
    return


func on_enter(other) -> void:
  if other.has_method("is_player") and other.is_player():
    player_in_contact = other


func on_exit(other) -> void:
  if other == player_in_contact:
    player_in_contact = null


func is_enemy() -> bool:
  return true


func set_player(p):
  player = p

var holding_cinematic = false
func damage(amount: int, source: Node2D) -> void:
  if being_hit:
    return

  being_hit = true
  health -= amount
  curr_mode = Mode.RETREAT
  reset_spear()
  Letterbox.in_cinematic = true
  holding_cinematic = true

  # TODO also do this for hands and stuff
  yield(CombatHelpers.damage_anim_animated_sprite($Body), "completed")
  
  if health <= 0:
    if holding_cinematic:
      Letterbox.in_cinematic = false
      holding_cinematic = false
      emit_signal("died")
    for child in get_children():
      child.queue_free()
    
  being_hit = false


func _process(delta):
  if health <= 0: return
  match curr_mode:
    Mode.IDLE:
      time_until_attack -= delta
      if time_until_attack < 0:
        curr_mode = Mode.SPEAR + curr_attack
        curr_attack = (curr_attack + 1) % 1 # TODO once there are more attacks
        time_until_attack = pause_between_attacks
      if abs(position.x - player.position.x) > 200:
        enforce_flip(player.position.x > position.x)
    Mode.SPEAR:
      enforce_flip(player.position.x > position.x)
      spear_attack(delta)
    Mode.RETREAT:
      jump_to_corner(delta)


var JUMP_WINDUP = 0.5
var jump_windup = null
var jump_target = null
var jump_start = null
var jump_time = 0
var jump_speed = 1000
var poss_jump_targets = []
var jump_time_len = 0
func jump_to_corner(delta):
  if jump_target == null:
    var min_dist = null
    var worst_i = 0
    for i in range(len(poss_jump_targets)):
      var d = player.global_position.distance_to(poss_jump_targets[i]) 
      if min_dist == null or d < min_dist:
        min_dist = d
        worst_i = i
    var target_i = randi() % (len(poss_jump_targets) - 1)
    if worst_i <= target_i:
      target_i += 1
    jump_target = poss_jump_targets[target_i]
    jump_start = global_position
    jump_time = 0
    jump_time_len = (jump_target - jump_start).length() / jump_speed
    jump_windup = JUMP_WINDUP
  if jump_windup != null:
    if jump_windup < delta:
      jump_windup = null
    else:
      jump_windup -= delta
      return
  jump_time += delta
  global_position = jump_start.linear_interpolate(jump_target, min(1, jump_time / jump_time_len))
  
  if jump_time >= jump_time_len:
    Letterbox.in_cinematic = false
    holding_cinematic = false
    jump_target = null
    curr_mode = Mode.IDLE
    enforce_flip(player.position.x > position.x)
    time_until_attack = pause_between_attacks / 3


export(Array) var spear_lines = ["That's the spear-it!", "How about a game of catch?"]
var last_line = 0
const SPEAR_WAIT = 0.1
var spear_wait = 0.0
const SPEARS_THROWN = 5
var spears_thrown = 0
var spear = null
onready var SpearScene = load("res://scenes/Spear.tscn")
var spear_spawn = Vector2(-38, 194)
var arm_length = spear_spawn.length()
var THROW_ANIM = 0.4
var throw_anim = 0
const THROW_ANIM_SPEED = PI * 3
func spear_attack(delta):
  var flipped = player.position.x > position.x
  if throw_anim > 0:
    if throw_anim > 0.2:
      $Arm.rotation += delta * THROW_ANIM_SPEED * (1 if flipped else -1)
    throw_anim -= delta
    if throw_anim <= 0 and spears_thrown == SPEARS_THROWN:
      reset_spear()
      curr_mode = Mode.IDLE
    return
  
  if spear == null:
    if spears_thrown == 0:
      last_line = (last_line + 1) % len(spear_lines)
      play_line(spear_lines[last_line])
    spear = SpearScene.instance()
    spear.shooter = self
    spear.active = false
    spear.mode = 3
    spear.speed = 1000
    $Spears.add_child(spear)
    spear_wait = SPEAR_WAIT
  spear_wait -= delta
  
  var o = arm_length
  var h = $Arm.global_position.distance_to(player.global_position)
  var p_angle = asin(o / h)
  var c_angle = PI / 2 - p_angle
  var angle_to_p = $Arm.global_position.angle_to_point(player.global_position) - PI / 2
  if flipped:
    $Arm.rotation = angle_to_p + c_angle
  else:
    $Arm.rotation = angle_to_p - c_angle
  spear.global_position = $Arm/SpearPoint.global_position
  spear.direction = $Arm/Arm.global_position.direction_to(player.global_position)
  spear.rotation = spear.direction.angle() + PI / 2
  if spear_wait < 0:
    spear.active = true
    spear.mode = 2

    spear = null
    spears_thrown += 1
    throw_anim = THROW_ANIM


func reset_spear():
  $Arm.rotation = 0
  if spear != null:
    spear.queue_free()
    spear = null
  spears_thrown = 0


func enforce_flip(flipped):
  if $Body.flip_h != flipped:
    $Body.flip_h = flipped
    $Arm/Arm.flip_h = flipped
    $Arm.position.x *= -1
    for child in $Arm.get_children():
      child.position.x *= -1

var DialogScene = load("res://scenes/Dialog.tscn")
func play_line(line):
  var new_dialog = DialogScene.instance()
  new_dialog.auto_advance = true
  new_dialog.lifespan = 1.3
  new_dialog.display_text_sequence_co(self, [line])


func activate():
  if curr_mode == Mode.WAITING:
    curr_mode = Mode.IDLE
