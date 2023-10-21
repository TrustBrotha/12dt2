extends Node

var forest_music = load("res://assets/music/Thunderbird.mp3")
var menu_music = load(
	"res://assets/music/Korok Forest (Night) - The Legend of Zelda_ Tears of the Kingdom OST.mp3"
)
var boss_music = load("res://assets/music/切爾諾伯格.mp3")

var fade_in = false
var fade_out = false


# makes volume the same as everything else
# Called when the node enters the scene tree for the first time.
func _ready():
	$music.volume_db = GlobalVar.music_volume


# controls sound of music
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fade_in == true:
		$music.volume_db = lerpf($music.volume_db,GlobalVar.music_volume,0.1)
		if $music.volume_db >= (GlobalVar.music_volume - 1):
			print("hi")
			$music.volume_db = GlobalVar.music_volume
			fade_in = false
		
	elif fade_out == true:
		$music.volume_db = lerpf($music.volume_db,-30,0.1)
		if $music.volume_db <= -29:
			play_forest_music()
			fade_out = false
	
	elif fade_in == false and fade_out == false:
		$music.volume_db = GlobalVar.music_volume
	pass


# funcs called when different music is wanted to be played
func play_boss_music():
	$music.volume_db = -30
	fade_in = true
	$music.stream = boss_music
	$music.play()


func play_forest_music():
	$music.stream = forest_music
	$music.play()


func play_menu_music():
	$music.stream = menu_music
	$music.play()


# loops music
func _on_music_finished():
	$music.play()
