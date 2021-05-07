extends Label

func _ready():
  var text_size = get_font("font").get_wordwrap_string_size("If there's anything scary out there, we'll handle it for sure!", 350)
  
  print("Test:", text_size, get_parent().name)
  
