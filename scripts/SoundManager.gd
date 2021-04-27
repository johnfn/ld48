extends Node

var volume = 100
var muted = false


func set_volume(val):
  volume = val
  var old_mute = muted
  if volume <= 5:
    muted = true
  else:
    muted = false
  for song in get_tree().get_nodes_in_group("song"):
    song.volume_db = get_db()
    if muted != old_mute and old_mute == song.stream_paused:
      song.stream_paused = muted


func get_db():
  return -25 + volume / 4


func play_sound(sound, volume = 1.0):
  var main_audio = $"/root/Main/Audio"
  var sounds = main_audio.get_node(sound).get_children()
  var unused = []
  for s in sounds:
    if not s.playing:
      unused.append(s)
  if len(unused) > 0:
    unused[randi() % len(unused)].playing = true


func set_river_volume(vol):
  return
  var river_audio = $"/root/Main/Audio/River/River"
  if vol <= 0.1:
    river_audio.playing = false
  else:
    if not river_audio.playing:
      river_audio.playing = true
    river_audio.volume_db = -25 + volume * vol / 4

var rivers = []
func update_possible_rivers():
  rivers = []
  for river in get_tree().get_nodes_in_group("river"):
    rivers.append(river.global_position.y)
  
func update_river_volume(y):
  var dist = null
  for river in rivers:
    if dist == null or abs(y - river) < dist:
      dist = abs(y - river)
  set_river_volume(max(0, min(1, 1.5 - (dist / 800))) if dist != null else 0)
