extends CharacterBody2D

enum State {
	LEFT,
	RIGHT,
	UP,
	DOWN
}

const SPEED = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var dead = false
var attacking = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimatedSprite2D")
@onready var attackUp = get_node("AttackUp/CollisionShape2D")
@onready var attackDown = get_node("AttackDown/CollisionShape2D")
@onready var attackRight = get_node("AttackRight/CollisionShape2D")
@onready var attackLeft = get_node("AttackLeft/CollisionShape2D")
var health = 10 # 10 hp for now lol
var prev_state = State.DOWN
var vel = null
var knockback = Vector2.ZERO

func _ready():
	anim.play("Idle Forward")	
	attackUp.set_deferred("disabled", true)
	attackDown.set_deferred("disabled", true)
	attackRight.set_deferred("disabled", true)
	attackLeft.set_deferred("disabled", true)
	
func _process(delta):
	print(health)
	if health == 0:
		dead = true
		anim.play("Death")
		await anim.animation_finished
		self.queue_free()

func prev_state_to_idle():
	match prev_state:
		State.LEFT:
			anim.play("Idle Sideways")
		State.RIGHT:
			anim.play("Idle Sideways")
		State.UP:
			anim.play("Idle Backwards")
		State.DOWN:
			anim.play("Idle Forward")
		
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			if attacking != true:
				attacking = true
				anim.play("Attack Backwards")
				attackUp.set_deferred("disabled", false)
				
		elif event.keycode == KEY_A:
			if attacking != true:
				attacking = true
				anim.flip_h = true
				anim.play("Attack Sideways")
				attackLeft.set_deferred("disabled", false)
		
		elif event.keycode == KEY_S:
			if attacking != true:
				attacking = true
				anim.play("Attack Forward")
				attackDown.set_deferred("disabled", false)

		elif event.keycode == KEY_D:
			if attacking != true:
				attacking = true
				anim.flip_h = false
				anim.play("Attack Sideways")
				attackRight.set_deferred("disabled", false)
			
func update_anim(directionX, directionY):
	if !directionX:
		if !directionY: # Not moving
			#print("IDLE")
			prev_state_to_idle()
		else:
			if directionY < 0: # Moving only in Y
				anim.play("Move Backwards")
				prev_state = State.UP
			else:
				anim.play("Move Forward")
				prev_state = State.DOWN
	else:
		if directionY: # Moving in both X and Y-> Just animate W.R.T y for now
			if directionY < 0:
				anim.play("Move Backwards")
				prev_state = State.UP
			else:
				anim.play("Move Forward")
				prev_state = State.DOWN
		else: # Moving only in X
			anim.play("Move Sideways")
			if directionX > 0:
				prev_state = State.LEFT
				anim.flip_h = false
			else:
				prev_state = State.LEFT
				anim.flip_h = true

func _physics_process(_delta):
	vel = Vector2.ZERO

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionX = Input.get_axis("ui_left", "ui_right")
	var directionY = Input.get_axis("ui_up", "ui_down")
	if directionX:
		vel.x = directionX * SPEED
	else:
		vel.x = move_toward(vel.x, 0, SPEED)
	
	if directionY:
		vel.y = directionY * SPEED
	else:
		vel.y = move_toward(vel.y, 0, SPEED)
		
	vel = vel + knockback
		
	if dead == false and attacking == false:
		update_anim(directionX, directionY)
	
		var collision = move_and_collide(vel)
		if collision:
			on_collision(collision)

	if attacking:
		await anim.animation_finished
		attacking = false
		attackUp.set_deferred("disabled", true)
		attackDown.set_deferred("disabled", true)
		attackRight.set_deferred("disabled", true)
		attackLeft.set_deferred("disabled", true)
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)


func on_collision(collision):
	var collider = collision.get_collider()
	print("Collided with: ", collider.name)
	# Handle collision response here


func _on_attack_right_body_entered(body):
	if body.name == "Slime":
		print("ATTACKED SLIME")
		body.health -= 1
		body.knockback = global_position.direction_to(body.global_position) * 20.0
