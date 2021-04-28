extends KinematicBody2D

signal died

const MAX_HEALTH = 8
var health = MAX_HEALTH

onready var Letterbox = $"/root/Main/Letterbox"
export(int) onready var damage = 1
export(int) onready var shoot_cooldown = 1
export(Vector2) var starting_direction = Vector2.RIGHT

var shoot_cooldown_remaining = 1
var speed = 300.0
var player_in_contact = null
var is_invuln = false
var being_hit = false
var timer = Timer.new()
export(float) var pause_between_attacks = 2.5
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

func damage(amount: int, source: Node2D) -> void:
  if being_hit or is_invuln:
    return

  being_hit = true
  health -= amount
  curr_mode = Mode.RETREAT
  reset_jump()
  reset_spear()
  SoundManager.play_sound("GoblinKingGrunt")

  # TODO also do this for hands and stuff
  yield(CombatHelpers.damage_anim_animated_sprite($Body), "completed")
  
  if health <= 0:
    emit_signal("died")
    for child in get_children():
      child.queue_free()
    
  being_hit = false


var particle_time = 0
func _process(delta):
  if particle_time > 0:
    particle_time -= delta
    if particle_time <= 0:
      $ShockwaveCenter/Particles2D.emitting = false
  if health <= 0: return
  if colliding_player != null and not Letterbox.in_cinematic and not is_invuln and not colliding_player.is_invuln and colliding_player.health > 0 and not has_damaged_player:
    colliding_player.damage(1, self)
    has_damaged_player = true
  match curr_mode:
    Mode.IDLE:
      time_until_attack -= delta
      if time_until_attack < 0:
        curr_mode = Mode.SPEAR + curr_attack
        curr_attack = (curr_attack + 1) % 2 # TODO once there are more attacks
        time_until_attack = pause_between_attacks
      if abs(position.x - player.position.x) > 200:
        enforce_flip(player.position.x > position.x)
    Mode.SPEAR:
      enforce_flip(player.position.x > position.x)
      spear_attack(delta)
    Mode.JUMP:
      enforce_flip(player.position.x > position.x)
      jump_attack(delta)
    Mode.RETREAT:
      jump_to_corner(delta)


export(Array) var jump_lines = ["What goes up-!", "Sky's the limit!", "Let's see you dodge this!"]
var last_jump_line = 0
var JUMP_WINDUP = 0.3
var jump_windup = null
var jump_target = null
var jump_start = null
var jump_time = 0
var jump_speed = 1000
var poss_jump_targets = []
var jump_time_len = 0
var downforce = 3000
var jump_v = 0
var jump_v_acc = 0
var min_shadow = 0.7
var jump_max_height = 0
onready var shadow_base_scale = $Shadow.scale
onready var shadow_base_position = $Shadow.position
func jump_to_corner(delta):
  if jump_target == null:
    var distant_targets = []
    for i in range(len(poss_jump_targets)):
      var d = abs(global_position.y - poss_jump_targets[i].y) 
      if d > 600:
        distant_targets.append(poss_jump_targets[i])
    var target_i = randi() % (len(distant_targets))
    init_jump(distant_targets[target_i], jump_speed)
  jump(delta, false)


const JUMP_AUDIO_PADDING = 0.7
const JUMPS_DONE = 2
var jumps_done = 0
var jump_attack_speed = 0
var jump_attack_time = 1.5
var shockwave_radius = 550
var max_shockwave_power = 1200
var min_shockwave_power = 800
var damage_radius = 200
var jump_has_played_landing_sound = false
func jump_attack(delta):
  if jump_target == null:
    if jumps_done == JUMPS_DONE:
      reset_jump()
      curr_mode = Mode.IDLE
      return
    if jumps_done == 0:
      SoundManager.play_sound("GoblinKingJumpAttack")
    jumps_done += 1
    last_jump_line = (last_jump_line + 1) % len(jump_lines)
    play_line(jump_lines[last_jump_line])
    init_jump(player.global_position, (global_position - player.global_position).length() / jump_attack_time)
  jump(delta, true)


func init_jump(target, speed):
  jump_target = target
  jump_start = global_position
  jump_time = 0
  jump_time_len = (jump_target - jump_start).length() / speed
  jump_windup = JUMP_WINDUP
  jump_v = jump_time_len / 2 * downforce
  jump_v_acc = 0
  jump_max_height = jump_v * jump_v / 2 / downforce
  jump_has_played_landing_sound = false
  SoundManager.play_sound("GoblinKingJump")


func reset_jump():
  jump_target = null
  jumps_done = 0


func jump(delta, is_attack):
  if jump_windup != null:
    if jump_windup < delta:
      jump_windup = null
    else:
      jump_windup -= delta
      return
  is_invuln = is_attack
  jump_time += delta
  jump_v -= delta * downforce
  jump_v_acc += jump_v * delta
  global_position = jump_start.linear_interpolate(jump_target, min(1, jump_time / jump_time_len)) - Vector2(0, jump_v_acc)
  $Shadow.position = shadow_base_position + Vector2(0, jump_v_acc)
  
  var sca = 1 - (1 - min_shadow) * (jump_v_acc / jump_max_height)
  $Shadow.scale = shadow_base_scale * sca
  
  handle_jump_completion(is_attack)


func handle_jump_completion(is_attack):
  if jump_time >= jump_time_len - JUMP_AUDIO_PADDING and not jump_has_played_landing_sound and is_attack:
    SoundManager.play_sound("GoblinKingLand", 20)
    jump_has_played_landing_sound = true
    
  if jump_time >= jump_time_len:
    jump_target = null
    if not is_attack:
      curr_mode = Mode.IDLE
    enforce_flip(player.position.x > position.x)
    time_until_attack = pause_between_attacks / 3
    $Shadow.scale = shadow_base_scale
    $Shadow.position = shadow_base_position
    is_invuln = false
    
    if is_attack:
      var p_dist = player.global_position.distance_to($ShockwaveCenter.global_position)
      if p_dist < shockwave_radius:
        var damage = 0 if p_dist > damage_radius else 1
        var power = min_shockwave_power + (max_shockwave_power - min_shockwave_power) * min(1, (shockwave_radius - p_dist) / (shockwave_radius - damage_radius))
        player.damage(damage, $ShockwaveCenter, power)
      particle_time = 0.2
      $ShockwaveCenter/Particles2D.emitting = true      


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
      SoundManager.play_sound("GoblinKingSpearAttack")
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


var colliding_player = null
var has_damaged_player = false
func _on_Area2D_body_entered(body):
  if body.has_method("is_player") and body.is_player():
    colliding_player = body
    has_damaged_player = false


func _on_Area2D_body_exited(body):
  if colliding_player == body:
    colliding_player = null
    has_damaged_player = false
