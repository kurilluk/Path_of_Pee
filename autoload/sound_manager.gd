extends Node

const SFX_DRINKING_BOTTLE_1 = preload("res://assets/sounds/sfx/SFX_DrinkingBottle1.wav")
const SFX_DRINKING_CAN_1 = preload("res://assets/sounds/sfx/SFX_DrinkingCan1.wav")
const SFX_VOC_ICANTHOLDDITLONGER = preload("res://assets/sounds/sfx/SFX_VOC_Icantholdditlonger.wav")
const SFX_VOC_INEEDTOPEE_1 = preload("res://assets/sounds/sfx/SFX_VOC_Ineedtopee1.wav")
const SFX_WALL_CHANGE_1 = preload("res://assets/sounds/sfx/SFx_WallChange1.wav")
const UI_BUTTON_CLICK_1 = preload("res://assets/sounds/sfx/UI_ButtonClick1.wav")
const UI_BUTTON_HOOVER = preload("res://assets/sounds/sfx/UI_ButtonHoover.wav")
const UI_CLICK_1 = preload("res://assets/sounds/sfx/UI_Click1.mp3")
const UI_GAME_OVER = preload("res://assets/sounds/sfx/UI_GameOver.wav")
const UI_START_GAME = preload("res://assets/sounds/sfx/UI_StartGame.wav")

func play_sound(soundPlayer: AudioStreamPlayer, stream: AudioStream) -> void:
	assert(stream != null, "stream shouldn't be null")
	assert(soundPlayer != null, "soundPlayer shouldn't be null")
	
	soundPlayer.stop()
	soundPlayer.stream = stream
	soundPlayer.play()

func play_dink_sound(soundPlayer: AudioStreamPlayer) -> void:
	play_sound(soundPlayer, SFX_DRINKING_BOTTLE_1)

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
