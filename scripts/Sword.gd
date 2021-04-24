extends Area2D

onready var AnimationPlayer = $AnimationPlayer
onready var swing_animation = AnimationPlayer.get_animation("Swing")
var damage = 1


func _ready() -> void:
    self.connect("body_entered", self, "on_enter")


func on_enter(other) -> void:
    if other.has_method("is_enemy") and other.is_enemy():
      other.damage(damage)


func set_in_use(in_use: bool) -> void:
  if in_use:
    if not AnimationPlayer.is_playing():
      swing_animation.loop = true
      AnimationPlayer.play("Swing")
  else:
    swing_animation.loop = false
    AnimationPlayer.clear_queue()
