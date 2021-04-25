extends Area2D

onready var AnimationPlayer = $AnimationPlayer
onready var swing_animation = AnimationPlayer.get_animation("Swing")
onready var Hitbox = $Hitbox

var damage = 1
var player: Player
var is_in_use = false

func _ready() -> void:
    self.connect("body_entered", self, "on_enter")


func on_pick_up() -> void:
  Hitbox.set_disabled(true)
  $SwordSprite.visible = true
  $StickSprite.visible = false

func on_enter(other) -> void:
  if not is_in_use:
    return
    
  if other.has_method("is_enemy") and other.is_enemy():
    other.damage(damage, self)

func init(player: Player):
  self.player = player

func set_in_use(in_use: bool) -> void:
  self.is_in_use = in_use
  
  if in_use:
    # this is necessary so that we DEFINITELY trigger a body_entered when we start the swing (e.g. if the sword starts IN the enemy it will not trigger body_entered)
    Hitbox.set_disabled(false)

    if not AnimationPlayer.is_playing():
      swing_animation.loop = true
      AnimationPlayer.play("Swing")
  else:
    Hitbox.set_disabled(true)
    swing_animation.loop = false
    AnimationPlayer.clear_queue()
