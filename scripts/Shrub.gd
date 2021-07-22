extends BaseHittable

var screen_shake_on_hit = false

func _init().():
  self.health = 1
  self.hit_sfx = "Bush"  
  
func _ready():
  $Sprite.material = load("res://assets/shaders/WindSwept.tres").duplicate()
  
  material.set_shader_param("global_xy", global_position)
