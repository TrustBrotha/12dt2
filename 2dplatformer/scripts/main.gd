extends Node2D
@export var boid_scene: PackedScene
var screen_size
var numofboids = 15
var boidscreated = []
var boidonscreen = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	boidonscreen = len(boidscreated)
	if boidonscreen < numofboids:
		var boid = boid_scene.instantiate()
#		var boid_spawn_x = randf_range(margin, (screen_size.x - margin))
#		var boid_spawn_y = randf_range(margin, (screen_size.y - margin))
		var boid_spawn_x = $player.position.x
		var boid_spawn_y = $player.position.y
		boid.position.x = boid_spawn_x
		boid.position.y = boid_spawn_y
		boid.rotation = randf_range(0,2*PI)
		add_child(boid)
		boidonscreen += 1
		boidscreated.append(boid)
	elif boidonscreen > numofboids:
		if len(boidscreated) > 0:
			var lastboid = boidscreated.pop_back()
			lastboid.queue_free()
