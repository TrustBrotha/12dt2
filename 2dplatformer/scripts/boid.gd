extends Area2D
#changing_var.speed = 1000
var speed = 1.5
var BoidsCanSee = []
@onready var rayfolder := $rayfolder.get_children()

var vel := Vector2(randf_range(-1,1), randf_range(-1,1))
var matchingfactor = 0.025
var centeringfactor = 0.007
var avoidingfactor = 0.01
var turnfactor = 0.002
var randomnessenabled = 1
var randomnessfactor = 0.05
var collisionfactor = 0.006

var leftmargin = 300
var rightmargin = 2260
var topmargin = 300
var bottommargin = 1140
var border = 1
var margin = 400
var target = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().move_child(self,1)
	$AnimatedSprite2D.play("default")
	$GPUParticles2D.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	get_variables()
	boid_calc()
	collision()
	move()
	#change colour
	colour()

func get_variables():
	leftmargin = get_parent().get_node("player").position.x - 40
	rightmargin = get_parent().get_node("player").position.x + 40
	topmargin = get_parent().get_node("player").position.y - 100
	bottommargin = get_parent().get_node("player").position.y - 20
	target = get_parent().get_node("player").get_node("boid_target").global_position

func boid_calc():
	if len(BoidsCanSee) <= 0:
		vel.x += randf_range(-randomnessfactor,randomnessfactor)
		vel.y += randf_range(-randomnessfactor,randomnessfactor)
		

	else:
		var numofboids = len(BoidsCanSee)
		var avgVel = Vector2.ZERO
		var avgPos = Vector2.ZERO
		var steerAway = Vector2.ZERO
		for boid in BoidsCanSee:
			avgVel += boid.vel
			avgPos += boid.position
			steerAway -= (boid.global_position - global_position) * (48/( global_position- boid.global_position).length())
		avgVel /= numofboids
		vel += (avgVel - vel) * matchingfactor
		
		avgPos /= numofboids
		vel += (avgPos-position) * centeringfactor
		
		steerAway /= numofboids
		vel += (steerAway) * avoidingfactor
		
		#add randomness
		vel.x += randf_range(-randomnessfactor,randomnessfactor)
		vel.y += randf_range(-randomnessfactor,randomnessfactor)
			
func collision():
	
	for ray in rayfolder:
		var r : RayCast2D = ray
		if r.is_colliding():
			if r.get_collider().is_in_group("tile"):
				var magi := (100/(r.get_collision_point() - global_position).length_squared())
				vel -= (r.target_position.rotated(rotation) * magi) * collisionfactor
		pass

func move():
#	vel += (target-global_position) * turnfactor
#	if global_position.x < leftmargin:
#		vel.x = vel.x + turnfactor
#	if global_position.x > rightmargin:
#		vel.x = vel.x - turnfactor
#	if global_position.y > bottommargin:
#		vel.y = vel.y - turnfactor
#	if global_position.y < topmargin:
#		vel.y = vel.y + turnfactor
	$AnimatedSprite2D.global_rotation = 0
	vel = vel.normalized() * speed
	rotation = vel.angle() 
	global_position += vel

func colour():
	pass
#	$sprite.modulate.r = Global.redvalue
#	$sprite.modulate.g = Global.greenvalue
#	$sprite.modulate.b = Global.bluevalue

func _on_vision_area_entered(area):
	#collect information on boid that enters vision
	if area != self and area.has_meta("boid"):
		BoidsCanSee.append(area)

func _on_vision_area_exited(area):
	#removes information of boid if that boid leaves vision
	if area != self and area.has_meta("boid"):
		BoidsCanSee.erase(area)

