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
