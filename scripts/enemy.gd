extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var attackAreaLeft = $attackAreaLeft
@onready var attackAreaRight = $attackAreaRight
@onready var body = $body
@onready var life_bar = $life_bar
@onready var enemy_hit_sfx = $EnemyHit

enum AnimationState {IDLE, RUN, ATTACK, HIT, DIE}

const SPEED = 200.0
const DETECTION_RANGE = 450.0
const ATTACK_RANGE = 130.0
const ATTACK_COOLDOWN = 1.0
const ATTACK_DURATION = 0.6
const HIT_STUN_DURATION = 0.3
const KNOCKBACK_FORCE = 150.0
const ATTACK_DAMAGE = 1

var is_attacking = false
var is_hit = false
var is_dead = false
var attack_timer = 0.0
var attack_duration_timer = 0.0
var hit_timer = 0.0
var facing_right = true
var health = 5
var player = null
var has_dealt_damage = false

func _ready():
	attackAreaLeft.monitoring = false
	attackAreaRight.monitoring = false
	sprite.animation_finished.connect(_on_animation_finished)
	player = get_tree().get_first_node_in_group("Player")
	call_deferred("find_player")
	life_bar.max_value = health

func find_player():
	print("find player called.")
	player = get_tree().get_first_node_in_group("Player")
	if player:
		print("Player found: ", player)
	else:
		print("Player not found!")

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
	
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2)
		check_attack_hit()
		move_and_slide()
		update_animation()
		return
	
	if player:
		print("find found.")
		var distance = player.global_position.x - global_position.x
		var abs_distance = abs(distance)
		print("dist and range: ",abs_distance,' ',ATTACK_RANGE)
		if abs_distance <= ATTACK_RANGE and attack_timer <= 0:
			attack()
		elif abs_distance <= DETECTION_RANGE:
			facing_right = distance > 0
			velocity.x = SPEED if facing_right else -SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	update_animation()
	life_bar.value = health


func check_attack_hit():
	if has_dealt_damage or not player:
		return
	
	var attack_area = attackAreaRight if facing_right else attackAreaLeft
	var bodies = attack_area.get_overlapping_bodies()
	
	for body_node in bodies:
		if body_node.is_in_group("Player"):
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
			enemy_hit_sfx.play()
		return
	
	if is_attacking:
		if sprite.animation != "attack":
			sprite.play("attack")
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
	
	health -= damage
	
	if health <= 0:
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
	
	Config.souls += 1
	Config.coins += 10
	is_dead = true
	velocity = Vector2.ZERO
	body.set_deferred("disabled", true)
	update_animation()
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
