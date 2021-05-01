extends BaseHittableArea

var grassMaterial = null

func _init().():
  self.health = 1
  self.hit_sfx = "Bush"
  
func _ready():
  grassMaterial = $Sprite.material
  # $Sprite.material = grassMaterial.duplicate()
  var random_offset = float(rand_range(0.0, 2.0*PI))
  grassMaterial.set_shader_param("wind_magnitude", random_offset)
