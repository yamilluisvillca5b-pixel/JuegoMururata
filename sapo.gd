extends CharacterBody2D


# ==========================================
# CONFIGURACIÓN
# ==========================================

@export var vidas: int = 3
@export var velocidad: float = 100.0
@export var distancia_ataque: float = 50.0


# ==========================================
# ESTADOS
# ==========================================

var puede_recibir_dano = true
var atacando = false
var muriendo = false


# ==========================================
# GRAVEDAD
# ==========================================

var gravity = ProjectSettings.get_setting(
	"physics/2d/default_gravity"
)


# ==========================================
# SPRITE
# ==========================================

@onready var anim = $AnimatedSprite2D


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	add_to_group("enemigo")
	add_to_group("sapo")

	actualizar_hud()


# ==========================================
# FÍSICA
# ==========================================

func _physics_process(delta: float) -> void:

	if muriendo:
		return


	# Gravedad

	if not is_on_floor():

		velocity.y += gravity * delta

	else:

		velocity.y = 0


	# Buscar Amaru

	var amaru = get_tree().get_first_node_in_group("jugador")


	if amaru:

		var distancia_x = abs(
			amaru.global_position.x - global_position.x
		)


		# ==================================
		# PERSEGUIR
		# ==================================

		if distancia_x > distancia_ataque:

			var direccion = sign(
				amaru.global_position.x - global_position.x
			)

			velocity.x = direccion * velocidad

			anim.play("jump")


			if velocity.x > 0:

				anim.flip_h = false

			elif velocity.x < 0:

				anim.flip_h = true


		# ==================================
		# ATACAR
		# ==================================

		else:

			velocity.x = 0

			if not atacando:

				atacar(amaru)


	else:

		velocity.x = 0
		anim.stop()


	move_and_slide()


# ==========================================
# ATAQUE DEL SAPO
# ==========================================

func atacar(amaru) -> void:

	atacando = true

	anim.play("Attack")


	# Esperar al momento del golpe

	await get_tree().create_timer(0.35).timeout


	if not muriendo and is_instance_valid(amaru):

		var distancia_x = abs(
			amaru.global_position.x - global_position.x
		)


		if distancia_x <= distancia_ataque:

			print("🐸 EL SAPO ATACA A AMARU")

			amaru.recibir_ataque(self, 1)


	# Pausa entre ataques

	await get_tree().create_timer(1.2).timeout

	atacando = false


# ==========================================
# RECIBIR DAÑO
# ==========================================

func take_damage(cantidad: int) -> void:

	if not puede_recibir_dano:
		return

	if muriendo:
		return


	vidas -= cantidad

	print("¡EL SAPO RECIBIÓ DAÑO!")
	print("Vidas del sapo: ", vidas)

	actualizar_hud()


	puede_recibir_dano = false


	await get_tree().create_timer(0.5).timeout

	puede_recibir_dano = true


	if vidas <= 0:

		morir()


# ==========================================
# HUD
# ==========================================

func actualizar_hud() -> void:

	var hud = get_tree().get_first_node_in_group("hud")

	if hud:

		hud.actualizar_vidas_sapo(vidas)


# ==========================================
# MUERTE
# ==========================================

func morir() -> void:

	if muriendo:
		return


	muriendo = true

	velocity = Vector2.ZERO

	print("¡EL SAPO HA MUERTO!")

	anim.play("Die")


	await get_tree().create_timer(1.0).timeout

	queue_free()
