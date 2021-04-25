extends Area2D

onready var AnimationPlayer = $AnimationPlayer
onready var swing_animation = AnimationPlayer.get_animation("Swing")
onready var Hitbox = $Hitbox
onready var SwordSprite = $SwordSprite
onready var StickSprite = $StickSprite

var damage = 1
var player: Player
var swinging = false

func _ready() -> void:
    self.connect("body_entered", self, "on_enter")


func on_pick_up() -> void:
  Hitbox.set_disabled(true)
  $SwordSprite.visible = true
  $StickSprite.visible = false

func on_enter(other) -> void:
  if not swinging:
    return
    
  if other.has_method("is_enemy") and other.is_enemy():
    other.damage(damage, self)

func init(player: Player):
  self.player = player

func set_in_use(in_use: bool) -> void:
  if not in_use:
    return
    
  if swinging:
    return
    
  swinging = in_use

  # this is necessary so that we DEFINITELY trigger a body_entered when we start the swing (e.g. if the sword starts IN the enemy it will not trigger body_entered)
  Hitbox.set_disabled(false)
  SwordSprite.visible = true
  
  AnimationPlayer.play("Swing")

  yield(AnimationPlayer, "animation_finished")

  Hitbox.set_disabled(true)
  AnimationPlayer.clear_queue()
  SwordSprite.visible = false
  
  swinging = false
