extends CharacterBody2D

@onready var anim = get_node("AnimatedSprite2D")
const SPEED = 3.0
const DETECTION_RANGE = 1000.0  # The range within which the enemy will detect and move toward the player
var health = 3 # Can take three hits from the protag's basic attack before fainting
var vel = null
var knockback = Vector2.ZERO
var player = null

func _ready():
	# Assuming the player is a node named "Player" in the same scene
	player = get_node("../Player")
	anim.play("Idle")

func _process(_delta):
	if health == 0:
		self.queue_free()

func _physics_process(_delta):
	vel = Vector2()
	player = get_node("../Player")
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= DETECTION_RANGE and !player.attacking:
			# Move toward the player
			var direction = (player.global_position - global_position).normalized()
			vel = direction * SPEED
		else:
			# Stop moving
			vel = Vector2.ZERO
	
	vel += knockback

	var collision = move_and_collide(vel)
	if vel.x < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
	if collision:
		on_collision(collision)
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)

func on_collision(collision):
	var collider = collision.get_collider()
	if (collider.name == "Player"):
		player.health -= 1
		player.knockback = global_position.direction_to(player.global_position) * 20.0
		
