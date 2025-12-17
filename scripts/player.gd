extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var attackAreaLeft = $attackAreaLeft
@onready var attackAreaRight = $attackAreaRight
@onready var body = $body

@onready var jump_sfx: AudioStreamPlayer = $sfx/jump_sfx
@onready var attack_sfx: AudioStreamPlayer = $sfx/attack_sfx
@onready var hit_sfx: AudioStreamPlayer = $sfx/hit_sfx




enum AnimationState {IDLE, RUN, ATTACK, HIT, JUMP, DIE}

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const ATTACK_COOLDOWN = 0.5
const ATTACK_DURATION = 0.4
const HIT_STUN_DURATION = 0.3
const KNOCKBACK_FORCE = 200.0
const ATTACK_DAMAGE = 1

var is_attacking = false
var is_hit = false
var is_dead = false
var attack_timer = 0.0
var attack_duration_timer = 0.0
var hit_timer = 0.0
var facing_right = true
var has_dealt_damage = false

func _ready():
	attackAreaLeft.monitoring = false
	attackAreaRight.monitoring = false
	sprite.animation_finished.connect(_on_animation_finished)
	self.add_to_group("Player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if attack_timer > 0:
		attack_timer -= delta
	if hit_timer > 0:
		hit_timer -= delta
		if hit_timer <= 0:
			is_hit = false
	if attack_duration_timer > 0:
		attack_duration_timer -= delta
		if attack_duration_timer <= 0:
			end_attack()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_hit:
		move_and_slide()
		update_animation()
		return
	
	if Input.is_key_pressed(KEY_A) or Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking and attack_timer <= 0:
		attack()
		return
	
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2)
		check_attack_hit()
		move_and_slide()
		update_animation()
		return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		facing_right = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	update_animation()

func check_attack_hit():
	if has_dealt_damage:
		return
	
	var attack_area = attackAreaRight if facing_right else attackAreaLeft
	var bodies = attack_area.get_overlapping_bodies()
	print("bodies: ", bodies)
	for body_node in bodies:
		if body_node.name.contains("enemy"):
			var knockback = Vector2(1 if facing_right else -1, -0.5)
			body_node.hit(ATTACK_DAMAGE, knockback)
			has_dealt_damage = true
			break

func update_animation():
	sprite.flip_h = not facing_right
	
	if is_dead:
		if sprite.animation != "die":
			sprite.play("die")
		return
	
	if is_hit:
		if sprite.animation != "hit":
			sprite.play("hit")
			hit_sfx.play()
		return
	
	if is_attacking:
		if sprite.animation != "attack":
			sprite.play("attack")
			attack_sfx.play()
		return
	
	if not is_on_floor():
		if sprite.animation != "jump":
			sprite.play("jump")
			jump_sfx.play()
		return
	
	if abs(velocity.x) > 10:
		if sprite.animation != "run":
			sprite.play("run")
		return
	
	if sprite.animation != "idle":
		sprite.play("idle")

func hit(damage: int = 1, knockback_direction: Vector2 = Vector2.ZERO):
	if is_dead or is_hit:
		return
	if(Config.shield>0): Config.shield-= damage
	else: Config.life -= damage
	
	if Config.life <= 0:
		die()
		return
	
	is_hit = true
	hit_timer = HIT_STUN_DURATION
	
	if knockback_direction != Vector2.ZERO:
		velocity = knockback_direction.normalized() * KNOCKBACK_FORCE
	
	update_animation()

func attack():
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	attack_duration_timer = ATTACK_DURATION
	has_dealt_damage = false
	velocity.x = 0

	if facing_right:
		attackAreaRight.monitoring = true
		attackAreaLeft.monitoring = false
	else:
		attackAreaLeft.monitoring = true
		attackAreaRight.monitoring = false
	
	update_animation()

func end_attack():
	attackAreaLeft.monitoring = false
	attackAreaRight.monitoring = false
	is_attacking = false
	attack_duration_timer = 0.0
	has_dealt_damage = false

func _on_animation_finished():
	if sprite.animation == "attack":
		end_attack()

func die():
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector2.ZERO
	body.set_deferred("disabled", true)
	update_animation()
	Engine.time_scale = 0.5
	await get_tree().create_timer(1).timeout
	Engine.time_scale = 1
	Config.reset_player_stats()
	get_tree().reload_current_scene()

func heal(amount: int):
	if not is_dead:
		Config.life = min(Config.life + amount, 100)

func take_damage(amount: int):
	hit(amount)
