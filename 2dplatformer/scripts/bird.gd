extends Area2D

@onready var rayfolder := $rayfolder.get_children()
var vel := Vector2(randf_range(-1,1), randf_range(-1,1))

var BoidsCanSee = []
var boidstooclose = []

var steerAway = Vector2.ZERO

var avgVel = Vector2.ZERO
var avgPos = Vector2.ZERO

var speed = 2

var matchingfactor = 0.06#0.06 for job
var centeringfactor = 0.0005 #0.0005
var avoidingfactor = 0.01 #0.01
var turnfactor = 0.25 # 0.25
var randomnessfactor = 0.01
var collisionfactor = 0.03
var avoid_radius = 25 #25


# Called when the node enters the scene tree for the first time.
func _ready():
	$sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(BoidsCanSee) <= 0:
		pass
		vel.x += randf_range(-randomnessfactor,randomnessfactor)
		vel.y += randf_range(-randomnessfactor,randomnessfactor)
	else:
		# set variables
		steerAway = Vector2.ZERO
		avgVel = Vector2.ZERO
		avgPos = Vector2.ZERO
		
		# adds data for each boid in vision
		for boid in BoidsCanSee:
			avgVel += boid.vel
			avgPos += boid.position
			
			# checks the distance to boids in vision
			# if below avoid radius adds to boids too close 
			if position.distance_to(boid.position)<avoid_radius:
				# adds to list if not already there
				if boid not in boidstooclose:
					boidstooclose.append(boid)
				
				if len(boidstooclose) >0:
					for i in boidstooclose:
						steerAway += (i.position/len(boidstooclose))
			
			# if distance is more than the avoid radius remove from list
			elif position.distance_to(boid.position)>avoid_radius:
				boidstooclose.erase(boid)
		
		# if previous removal doesn't work then if an item is in 
		# the boids too close list but not in vision, removes boid from boidtooclose
		for boid in boidstooclose:
			if boid not in BoidsCanSee:
				boidstooclose.erase(boid)
		
		avgVel /= len(BoidsCanSee)
		vel += (avgVel - vel) * matchingfactor
		
		avgPos /= len(BoidsCanSee)
		vel += (avgPos-position) * centeringfactor
		
		if len(boidstooclose) >0:
			steerAway /= len(boidstooclose)
			vel += (position-steerAway)*avoidingfactor
		
		# add randomness
		vel.x += randf_range(-randomnessfactor,randomnessfactor)
		vel.y += randf_range(-randomnessfactor,randomnessfactor)
	
	# controls how the birds react when they see a wall
	for ray in rayfolder:
		var r : RayCast2D = ray
		if r.is_colliding():
			if r.get_collider().is_in_group("tile"):
				var magi := (150/(r.get_collision_point() - global_position).length_squared())
				vel -= (r.target_position.rotated(rotation) * magi) * collisionfactor
		pass
	
	# controls the sprite position
	if rotation > PI/2 or rotation < -PI/2:
		$sprite.scale.y = -1
	if rotation < PI/2 and rotation > -PI/2:
		$sprite.scale.y = 1
	
	rotation = vel.angle() 
	
	# applies movement
	vel = vel.normalized() * speed
	global_position += vel


# if boid adds to data points, if spell makes the birds run away
func _on_area_entered(area):
	if area != self and area.is_in_group("boid"):
		BoidsCanSee.append(area)
	elif area.is_in_group("stream_collision") or area.is_in_group("burst_collision"):
		var position_difference = global_position - area.global_position
		vel += position_difference


# takes boids out of analysed data
func _on_area_exited(area):
	if area != self and area.is_in_group("boid"):
		BoidsCanSee.erase(area)
