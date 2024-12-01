extends Node

const SFX_DINK = "drink"

const SOUNDS = {
	SFX_DINK: preload("res://assets/sounds/sfx/SFX_DrinkingBottle1.wav")
}

func play_sound(player: AudioStreamPlayer, key: String) -> void:
	if SOUNDS.has(key) == false:
		return
	player.stop()
	player.stream = SOUNDS[key]
	player.play()

func play_dink_sound(player: AudioStreamPlayer) -> void:
	play_sound(player,SFX_DINK)


#const AMBIENT_LOOP = [
	#preload("res://assets/sounds/ambient/loop/01_Amajor9_LOOP_seamless_MIXED.ogg"),
	#preload("res://assets/sounds/ambient/loop/02_Cmajor9_LOOP_seamless_MIXED.ogg"),
	#preload("res://assets/sounds/ambient/loop/03_G#maj9_LOOP_seamless_MIXED.ogg"),
	#preload("res://assets/sounds/ambient/loop/04_Aminor9_LOOP_seamless_MIXED.ogg")
#]


#var _ambient_phase : int = 0
#
#func next_ambient_phase():
	#_ambient_phase += 1
	#if _ambient_phase > AMBIENT_HIT.size()-1:
		#_ambient_phase = 0
#
#func play_initial_ambient_loop_only(loop: AudioStreamPlayer):
	#loop.stop()
	#loop.stream = AMBIENT_LOOP[3]
	#loop.play()
#
#func play_ambient_hit(loop: AudioStreamPlayer, hit: AudioStreamPlayer):
	#hit.stop()
	#hit.stream = AMBIENT_HIT[_ambient_phase]
	#hit.play()
	#
	#loop.stop()
	#loop.stream = AMBIENT_LOOP[_ambient_phase]
	#loop.play()
	#next_ambient_phase()
