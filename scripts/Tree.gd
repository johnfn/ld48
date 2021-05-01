extends Node2D

export(bool) var solid_leaves = true
const MAX_OPACITY = 0.6

func _ready():
  if solid_leaves:
    $TreeTrunk/TrunkHitbox.queue_free()
    $LeafArea.queue_free()
  else:
    $Tree/FullHitbox.queue_free()
    $LeafArea.connect("body_entered", self, "_on_body_entered")
    $LeafArea.connect("body_exited", self, "_on_body_exited")



func _on_body_entered(body):
  if body.has_method("is_player") and body.is_player():
    $Tween.interpolate_property($Leaves, "modulate", Color.white, Color(1, 1, 1, MAX_OPACITY), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    $Tween.start()


func _on_body_exited(body):
  if body.has_method("is_player") and body.is_player():
    $Tween.interpolate_property($Leaves, "modulate", Color(1, 1, 1, MAX_OPACITY), Color.white, 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    $Tween.start()
