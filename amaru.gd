extends CharacterBody2D


# ==========================================
# MOVIMIENTO
# ==========================================

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


# ==========================================
# VIDAS
# ==========================================

var vidas = 10
var puede_recibir_dano = true


# ==========================================
# ATAQUES
# ==========================================

var atacando = false
var puede_atacar = true


# ==========================================
# DEFENSA
# ==========================================

@export var duracion_defensa: float = 1.5
@export var cooldown_defensa: float = 1.5

var defendiendo = false
var en_defensa = false
var puede_usar_defensa = true

var tecla_d_anterior = false
var mostrando_impacto = false


# ==========================================
# SPRITE
# ==========================================

@onready var sprite = $AnimatedSprite2D


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	add_to_group("jugador")

	actualizar_hud()


# ==========================================
# FÍSICA
# ==========================================

func _physics_process(delta: float) -> void:

	# Gravedad
	if not is_on_floor():

		velocity += get_gravity() * delta


	# ======================================
	# TECLA D - DEFENSA
	# ======================================

	var tecla_d = Input.is_key_pressed(KEY_D)

	if tecla_d and not tecla_d_anterior:

		if puede_usar_defensa and not defendiendo:

			iniciar_defensa()

	tecla_d_anterior = tecla_d


	# ======================================
	# SI ESTÁ DEFENDIENDO
	# ======================================

	if defendiendo:

		velocity.x = 0

		move_and_slide()

		return


	# ======================================
	# ATAQUES NORMALES
	# ======================================

	if puede_atacar:

		if Input.is_key_pressed(KEY_Q):

			atacar("ataque1")

		elif Input.is_key_pressed(KEY_E):

			atacar("ataque2")

		elif Input.is_key_pressed(KEY_R):

			atacar("ataque3")

		elif Input.is_key_pressed(KEY_F):

			atacar("attack")


	# ======================================
	# SALTO
	# ======================================

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():

		velocity.y = JUMP_VELOCITY


	# ======================================
	# MOVIMIENTO
	# ======================================

	var direction := Input.get_axis(
		"ui_left",
		"ui_right"
	)


	if direction:

		velocity.x = direction * SPEED

	else:

		velocity.x = move_toward(
			velocity.x,
			0,
			SPEED
		)


	# ======================================
	# ANIMACIONES NORMALES
	# ======================================

	if not atacando:

		if not is_on_floor():

			sprite.play("jump")

		elif direction != 0:

			sprite.play("rum")

		else:

			sprite.play("idle")


	# ======================================
	# GIRAR
	# ======================================

	if direction < 0:

		sprite.flip_h = true

	elif direction > 0:

		sprite.flip_h = false


	move_and_slide()


# ==========================================
# ATAQUE DE AMARU
# ==========================================

func atacar(nombre_animacion: String) -> void:

	if atacando or defendiendo:

		return


	atacando = true
	puede_atacar = false

	print("AMARU ATACA: ", nombre_animacion)

	sprite.play(nombre_animacion)


	await get_tree().create_timer(0.2).timeout


	if not defendiendo:

		golpear_enemigo()


	await get_tree().create_timer(0.4).timeout


	atacando = false
	puede_atacar = true


# ==========================================
# GOLPEAR ENEMIGO
# ==========================================

func golpear_enemigo() -> void:

	var enemigos = get_tree().get_nodes_in_group("enemigo")

	var enemigo_cercano = null
	var distancia_menor = 180.0


	for enemigo in enemigos:

		if not is_instance_valid(enemigo):

			continue


		var distancia = global_position.distance_to(
			enemigo.global_position
		)


		if distancia <= distancia_menor:

			distancia_menor = distancia
			enemigo_cercano = enemigo


	if enemigo_cercano:

		print("Enemigo golpeado: ", enemigo_cercano.name)

		enemigo_cercano.take_damage(1)

	else:

		print("No hay enemigos cerca")


# ==========================================
# INICIAR DEFENSA
# ==========================================

func iniciar_defensa() -> void:

	if not puede_usar_defensa:

		return

	if defendiendo:

		return


	# Activar estados
	defendiendo = true
	en_defensa = false
	puede_usar_defensa = false

	# Cancelar movimiento
	velocity.x = 0

	# Cancelar ataque de Amaru
	atacando = false
	puede_atacar = true


	print("⚡ AMARU SE CUBRE")


	# ======================================
	# FRAME 1
	# ======================================

	sprite.animation = "contra"

	sprite.frame = 0

	sprite.pause()


	# Esperar un poco mientras se cubre
	await get_tree().create_timer(0.20).timeout


	# ======================================
	# FRAME 2
	# ======================================

	if not defendiendo:

		return


	sprite.animation = "contra"

	sprite.frame = 1

	sprite.pause()

	en_defensa = true

	print("⚡ DEFENSA ACTIVA")


	# ======================================
	# MANTENER DEFENSA
	# ======================================

	await get_tree().create_timer(
		duracion_defensa
	).timeout


	# ======================================
	# TERMINAR DEFENSA
	# ======================================

	en_defensa = false
	defendiendo = false
	mostrando_impacto = false

	sprite.play("idle")


	print("DEFENSA TERMINADA")


	# ======================================
	# COOLDOWN
	# ======================================

	await get_tree().create_timer(
		cooldown_defensa
	).timeout


	puede_usar_defensa = true

	print("⚡ DEFENSA DISPONIBLE")


# ==========================================
# ATAQUE ENEMIGO CONTRA AMARU
# ==========================================

func recibir_ataque(atacante, cantidad: int) -> void:

	# ======================================
	# DEFENSA ACTIVA
	# ======================================

	if en_defensa:

		print("⚡⚡ ¡ATAQUE BLOQUEADO!")


		# Mostrar tercer frame
		mostrar_impacto_defensa()


		# ==================================
		# GOLEM
		# ==================================

		if atacante.is_in_group("golem"):

			print("🗿 ¡GOLEM ATURDIDO!")

			atacante.aturdir()


		# ==================================
		# SAPO
		# ==================================

		elif atacante.is_in_group("sapo"):

			print("🐸 ¡SAPO RECIBE DAÑO!")

			atacante.take_damage(1)


		# IMPORTANTE:
		# Amaru NO recibe daño
		return


	# ======================================
	# SIN DEFENSA
	# ======================================

	take_damage(cantidad)


# ==========================================
# TERCER FRAME DE LA DEFENSA
# ==========================================

func mostrar_impacto_defensa() -> void:

	if mostrando_impacto:
		return


	if not en_defensa:
		return


	mostrando_impacto = true


	# TERCER FRAME
	sprite.animation = "contra"
	sprite.frame = 2
	sprite.pause()


	print("⚡💥 ¡CONTRA EL ATAQUE!")


	# Mantener el brillo un momento
	await get_tree().create_timer(0.25).timeout


	# Volver al segundo frame
	if en_defensa:

		sprite.animation = "contra"
		sprite.frame = 1
		sprite.pause()


	mostrando_impacto = false


# ==========================================
# RECIBIR DAÑO
# ==========================================

func take_damage(cantidad: int) -> void:

	if not puede_recibir_dano:
		return


	vidas -= cantidad

	print("¡AMARU RECIBIÓ DAÑO!")
	print("Vidas de Amaru: ", vidas)


	actualizar_hud()


	puede_recibir_dano = false


	await get_tree().create_timer(1.0).timeout


	puede_recibir_dano = true


	if vidas <= 0:

		morir()


# ==========================================
# HUD
# ==========================================

func actualizar_hud() -> void:

	var hud = get_tree().get_first_node_in_group("hud")

	if hud:

		hud.actualizar_vidas_amaru(vidas)


# ==========================================
# MORIR
# ==========================================

func morir() -> void:

	print("¡AMARU HA MUERTO!")


	velocity = Vector2.ZERO

	sprite.stop()


	await get_tree().create_timer(1.0).timeout


	queue_free()
