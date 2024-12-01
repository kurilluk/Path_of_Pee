extends Node

const SFX_DRINKING_BOTTLE_1 = preload("res://assets/sounds/sfx/SFX_DrinkingBottle1.wav")
const SFX_DRINKING_CAN_1 = preload("res://assets/sounds/sfx/SFX_DrinkingCan1.wav")
const SFX_WALL_CHANGE_1 = preload("res://assets/sounds/sfx/SFx_WallChange1.wav")
const UI_BUTTON_CLICK_1 = preload("res://assets/sounds/sfx/UI_ButtonClick1.wav")
const UI_BUTTON_HOOVER = preload("res://assets/sounds/sfx/UI_ButtonHoover.wav")
const UI_CLICK_1 = preload("res://assets/sounds/sfx/UI_Click1.mp3")
const UI_GAME_OVER = preload("res://assets/sounds/sfx/UI_GameOver.wav")
const UI_START_GAME = preload("res://assets/sounds/sfx/UI_StartGame.wav")

const FOLLEY_STEP_1 = preload("res://assets/sounds/sfx/Folley_Step1.mp3")
const FOLLEY_STEP_2 = preload("res://assets/sounds/sfx/Folley_Step2.mp3")
const FOLLEY_STEP_3 = preload("res://assets/sounds/sfx/Folley_Step3.mp3")
const FOLLEY_STEP_4 = preload("res://assets/sounds/sfx/Folley_Step4.mp3")
const FOLLEY_STEP_5 = preload("res://assets/sounds/sfx/Folley_Step5.mp3")

const SFX_VOC_ICANTHOLDDITLONGER = preload("res://assets/sounds/sfx/SFX_VOC_Icantholdditlonger.wav")
const SFX_VOC_INEEDTOPEE_1 = preload("res://assets/sounds/sfx/SFX_VOC_Ineedtopee1.wav")
const MUSIC_PART_1_LOOPED = preload("res://assets/sounds/Music/Music_Part1Looped.mp3")
const MUSIC_PART_2_LOOPED = preload("res://assets/sounds/Music/Music_Part2Looped.mp3")
const MUSIC_PART_3_LOOPED = preload("res://assets/sounds/Music/Music_Part3Looped.mp3")

func play_sound(soundPlayer: AudioStreamPlayer, stream: AudioStream) -> void:
	assert(stream != null, "stream shouldn't be null")
	assert(soundPlayer != null, "soundPlayer shouldn't be null")
	
	soundPlayer.stop()
	soundPlayer.stream = stream
	soundPlayer.play()

func play_button_click_sound(soundPlayer: AudioStreamPlayer) -> void:
	play_sound(soundPlayer, UI_BUTTON_CLICK_1)

func play_start_game(soundPlayer: AudioStreamPlayer) -> void:
	play_sound(soundPlayer, UI_START_GAME)
	
func play_game_over(soundPlayer: AudioStreamPlayer) -> void:
	play_sound(soundPlayer, UI_GAME_OVER)

func play_dink_sound(soundPlayer: AudioStreamPlayer) -> void:
	match randi_range(0, 2):
		0: play_sound(soundPlayer, SFX_DRINKING_BOTTLE_1)
		1: play_sound(soundPlayer, SFX_DRINKING_CAN_1)

func play_step_sound(soundPlayer: AudioStreamPlayer) -> void:
	match randi_range(0, 5):
		0: play_sound(soundPlayer, FOLLEY_STEP_1)
		1: play_sound(soundPlayer, FOLLEY_STEP_2)
		2: play_sound(soundPlayer, FOLLEY_STEP_3)
		3: play_sound(soundPlayer, FOLLEY_STEP_4)
		_: play_sound(soundPlayer, FOLLEY_STEP_5)

var _ambient_loop_number : int = 0
var _ambient_player: AudioStreamPlayer;

func start_ambient_loop(musicPlayer: AudioStreamPlayer):
	if _ambient_player != null:
		_ambient_player.finished.disconnect(next_ambient_phase)
	
	_ambient_player = musicPlayer
	_ambient_player.stop();
	_ambient_player.finished.connect(next_ambient_phase)
	_ambient_loop_number = 1;
	next_ambient_phase();

func transit_ambient_to_phase2():
	if _ambient_loop_number == 2:
		return
		
	_ambient_loop_number = 2;
	_ambient_player.stream = SFX_VOC_INEEDTOPEE_1
	_ambient_player.play()
	
func transit_ambient_to_phase3():
	if _ambient_loop_number == 3:
		return
	_ambient_loop_number = 3;
	_ambient_player.stream = SFX_VOC_ICANTHOLDDITLONGER
	_ambient_player.play()

func set_ambient_to_phase1():
	_ambient_loop_number = 1;
	next_ambient_phase()
	
func set_ambient_to_phase2():
	_ambient_loop_number = 2;
	next_ambient_phase()

func set_ambient_to_phase3():
	_ambient_loop_number = 3;
	next_ambient_phase()
	
func next_ambient_phase():
	match (_ambient_loop_number):
		2: play_sound(_ambient_player, MUSIC_PART_2_LOOPED)
		3: play_sound(_ambient_player, MUSIC_PART_3_LOOPED)
		_: play_sound(_ambient_player, MUSIC_PART_1_LOOPED)
	
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
