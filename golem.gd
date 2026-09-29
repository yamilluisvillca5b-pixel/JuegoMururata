extends CharacterBody2D


# ==========================================
# CONFIGURACIÓN DEL GOLEM
# ==========================================

@export var vidas: int = 7
@export var velocidad: float = 60.0

# Ataque cuerpo a cuerpo
@export var distancia_ataque: float = 80.0

# Ataque con roca
@export var distancia_ataque_largo: float = 155.0

# Tiempo entre ataques
@export var tiempo_entre_ataques: float = 1.2

# Tiempo que queda aturdido
@export var duracion_aturdido: float = 7.0

# Velocidad de las animaciones de ataque
# 1.0 = velocidad normal
# 0.5 = mitad de velocidad
# 0.3 = muy lento
@export var velocidad_animacion_ataque: float = 0.5


# ==========================================
# ESTADOS
# ==========================================

var muriendo = false
var atacando = false
var aturdido = false


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
	add_to_group("golem")

	# Velocidad normal para caminar
	anim.speed_scale = 1.0


# ==========================================
# FÍSICA
# ==========================================

func _physics_process(delta: float) -> void:

	if muriendo:
		return


	# ======================================
	# GOLEM ATURDIDO
	# ======================================

	if aturdido:

		velocity.x = 0

		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0

		anim.speed_scale = 1.0
		anim.play("Aturdido")

		move_and_slide()

		return


	# ======================================
	# GRAVEDAD
	# ======================================

	if not is_on_floor():

		velocity.y += gravity * delta

	else:

		velocity.y = 0


	# ======================================
	# BUSCAR A AMARU
	# ======================================

	var amaru = get_tree().get_first_node_in_group("jugador")


	if amaru == null:

		velocity.x = 0
		anim.speed_scale = 1.0
		anim.stop()

		move_and_slide()

		return


	# ======================================
	# DISTANCIA
	# ======================================

	var distancia_x = abs(
		amaru.global_position.x - global_position.x
	)


	# ======================================
	# ATAQUE CORTO
	# ======================================

	if distancia_x <= distancia_ataque:

		velocity.x = 0

		if not atacando:

			atacar_corto(amaru)


	# ======================================
	# ATAQUE LARGO
	# ======================================

	elif distancia_x <= distancia_ataque_largo:

		velocity.x = 0

		if not atacando:

			atacar_largo(amaru)


	# ======================================
	# PERSEGUIR
	# ======================================

	else:

		if not atacando:

			var direccion = sign(
				amaru.global_position.x - global_position.x
			)

			velocity.x = direccion * velocidad

			anim.speed_scale = 1.0
			anim.play("caminar")


			# Girar
			if velocity.x > 0:

				anim.flip_h = false

			elif velocity.x < 0:

				anim.flip_h = true


	move_and_slide()


# ==========================================
# ATAQUE CORTO
# ==========================================

func atacar_corto(amaru) -> void:

	atacando = true

	velocity.x = 0


	# Hacer animación más lenta
	anim.speed_scale = velocidad_animacion_ataque

	anim.play("AtakeC")


	# Esperar un poco más por la animación lenta
	await get_tree().create_timer(0.55).timeout


	if not muriendo and not aturdido:

		if is_instance_valid(amaru):

			var distancia_x = abs(
				amaru.global_position.x - global_position.x
			)


			if distancia_x <= distancia_ataque:

				print("🗿 GOLEM ATACA A AMARU")

				amaru.recibir_ataque(self, 1)


	# Volver a velocidad normal
	anim.speed_scale = 1.0


	# Pausa
	await get_tree().create_timer(
		tiempo_entre_ataques
	).timeout


	atacando = false


# ==========================================
# ATAQUE LARGO
# ==========================================

func atacar_largo(amaru) -> void:

	atacando = true

	velocity.x = 0


	# Animación lenta
	anim.speed_scale = velocidad_animacion_ataque

	anim.play("AtakeL")

	print("🗿 GOLEM LANZÓ UNA ROCA")


	# Tiempo hasta que sale la roca
	await get_tree().create_timer(0.7).timeout


	if not muriendo and not aturdido:

		if is_instance_valid(amaru):

			var distancia_x = abs(
				amaru.global_position.x - global_position.x
			)

			var distancia_y = abs(
				amaru.global_position.y - global_position.y
			)


			if distancia_x <= distancia_ataque_largo and distancia_y <= 100:

				print("🪨 ROCA DEL GOLEM GOLPEA A AMARU")

				amaru.recibir_ataque(self, 1)

			else:

				print("La roca no alcanzó a Amaru.")


	# Velocidad normal
	anim.speed_scale = 1.0


	# Pausa
	await get_tree().create_timer(
		tiempo_entre_ataques
	).timeout


	atacando = false


# ==========================================
# ATURDIR
# ==========================================

func aturdir() -> void:

	if muriendo:
		return

	if aturdido:
		return


	aturdido = true
	atacando = false
	velocity = Vector2.ZERO

	print("🗿 ¡GOLEM ATURDIDO!")
	print("Duración: ", duracion_aturdido, " segundos")


	anim.speed_scale = 1.0
	anim.play("Aturdido")


	# Esperar la duración configurable
	await get_tree().create_timer(
		duracion_aturdido
	).timeout


	if not muriendo:

		aturdido = false

		print("🗿 El Golem vuelve a moverse")


# ==========================================
# RECIBIR DAÑO
# ==========================================

func take_damage(cantidad: int) -> void:

	if muriendo:
		return

	if aturdido:
		return


	vidas -= cantidad

	print("¡EL GOLEM RECIBIÓ DAÑO!")
	print("Vidas del Golem: ", vidas)


	if vidas <= 0:

		morir()


# ==========================================
# MUERTE
# ==========================================

func morir() -> void:

	if muriendo:
		return


	muriendo = true

	velocity = Vector2.ZERO

	print("¡EL GOLEM HA MUERTO!")


	anim.speed_scale = 1.0
	anim.play("muerte")


	await get_tree().create_timer(1.0).timeout


	queue_free()
