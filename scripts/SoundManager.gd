extends Node

var volume = 10
var muted = false
var curr_song = null
onready var river_audio = $River/River

func set_volume(val):
  if Globals.mute_sound: return
  
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

func update_song(next_song = null):
  if Globals.mute_sound: return
  
#  if next_song == null:
#    next_song = Level.get_song() if Level.has_method("get_song") else "Chapter1Song"
    
  if curr_song != next_song:
    var to_shut_down = null
    var og_volume = null
    var fade_out_len = 3
  
    if curr_song != null and next_song == null:
      fade_out_len = 3
    
    # Fade out old song
    
    if curr_song != null:
      og_volume = get_node(curr_song).volume_db
      to_shut_down = get_node(curr_song)
      $OutTween.interpolate_property(to_shut_down, "volume_db", og_volume, og_volume-30, fade_out_len, Tween.TRANS_CUBIC, Tween.EASE_OUT)
      $OutTween.start()
    
    # Fade in next song
    
    if next_song != null:
      var curr_node = get_node(next_song)
      if to_shut_down != null:
        var volume = get_node(next_song).volume_db
        
        curr_node.volume_db = volume-30
        $InTween.interpolate_property(curr_node, "volume_db", volume-30, volume, 5.0, Tween.TRANS_CUBIC, Tween.EASE_IN)
        $InTween.start()
        yield(get_tree().create_timer(0.1), "timeout")
      
      curr_node.playing = SoundManager.volume > 5
      curr_song = next_song
    
    if to_shut_down != null:
      yield(get_tree().create_timer(fade_out_len), "timeout")
      to_shut_down.volume_db = og_volume
      to_shut_down.playing = false


func get_db(vol_boost=0.0):
  return -25 + (volume + vol_boost) / 4


func play_sound(sound, vol_boost=0.0):
  if volume < 5: return
  if Globals.mute_sfx: return
  
  var sounds = get_node(sound).get_children()
  var unused = []
  
  for s in sounds:
    if not s.playing:
      unused.append(s)
  
  if len(unused) > 0:
    unused[randi() % len(unused)].playing = true
    unused[randi() % len(unused)].volume_db = get_db(vol_boost)

func set_river_volume(vol):
  if Globals.mute_sound: return
  
  if vol <= 0.05:
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
