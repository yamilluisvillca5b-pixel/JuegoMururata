extends CharacterBody2D


# ==========================================
# CONFIGURACIÓN
# ==========================================

@export var vidas: int = 5

# Velocidad para caminar hacia Amaru
@export var velocidad: float = 80.0

# Distancia para comenzar el ataque
@export var distancia_ataque: float = 60.0

# Velocidad de las animaciones
@export var velocidad_animacion: float = 0.6

# Tiempo desde que empieza el ataque
# hasta que hace el daño
@export var tiempo_antes_del_golpe: float = 0.45

# Tiempo entre un ataque y otro
@export var tiempo_entre_ataques: float = 1.5

# Tiempo que queda quieto cuando Amaru
# bloquea su ataque con la defensa
@export var duracion_aturdido: float = 2.5


# ==========================================
# ESTADOS
# ==========================================

var atacando = false
var muriendo = false
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
	add_to_group("mururata")

	anim.speed_scale = 1.0


# ==========================================
# FÍSICA
# ==========================================

func _physics_process(delta: float) -> void:

	if muriendo:
		return


	# ======================================
	# ATURDIDO
	# ======================================

	if aturdido:

		velocity.x = 0

		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0

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
	# DISTANCIA A AMARU
	# ======================================

	var distancia_x = abs(
		amaru.global_position.x - global_position.x
	)


	# ======================================
	# ATAQUE
	# ======================================

	if distancia_x <= distancia_ataque:

		velocity.x = 0

		if not atacando:

			atacar(amaru)


	# ======================================
	# CAMINAR
	# ======================================

	else:

		if not atacando:

			var direccion = sign(
				amaru.global_position.x - global_position.x
			)

			velocity.x = direccion * velocidad

			anim.speed_scale = velocidad_animacion
			anim.play("caminar")


			# Girar hacia Amaru

			if velocity.x > 0:

				anim.flip_h = false

			elif velocity.x < 0:

				anim.flip_h = true


	move_and_slide()


# ==========================================
# ATAQUE
# ==========================================

func atacar(amaru) -> void:

	atacando = true

	velocity.x = 0

	anim.speed_scale = velocidad_animacion

	anim.play("atake")


	print("👹 MURURATA PREPARA ATAQUE")


	# Esperar antes de golpear

	await get_tree().create_timer(
		tiempo_antes_del_golpe
	).timeout


	# ======================================
	# HACER DAÑO
	# ======================================

	if not muriendo and not aturdido:

		if is_instance_valid(amaru):

			var distancia_x = abs(
				amaru.global_position.x - global_position.x
			)


			if distancia_x <= distancia_ataque:

				print("👹 MURURATA ATACA A AMARU")

				amaru.recibir_ataque(self, 1)


	# ======================================
	# PAUSA ENTRE ATAQUES
	# ======================================

	await get_tree().create_timer(
		tiempo_entre_ataques
	).timeout


	atacando = false

	anim.speed_scale = 1.0


# ==========================================
# ATURDIR POR DEFENSA
# ==========================================

func aturdir(duracion: float = -1.0) -> void:

	if muriendo:
		return

	if aturdido:
		return


	aturdido = true
	atacando = false
	velocity = Vector2.ZERO


	if duracion < 0:

		duracion = duracion_aturdido


	print("⚡ ¡MURURATA FUE BLOQUEADO!")
	print("Duración: ", duracion, " segundos")


	# Mantenerlo quieto
	velocity = Vector2.ZERO


	await get_tree().create_timer(
		duracion
	).timeout


	if not muriendo:

		aturdido = false

		print("👹 Mururata vuelve a moverse")


# ==========================================
# RECIBIR DAÑO
# ==========================================

func take_damage(cantidad: int) -> void:

	if muriendo:
		return


	vidas -= cantidad

	print("👹 ¡MURURATA RECIBIÓ DAÑO!")
	print("Vidas de Mururata: ", vidas)


	if vidas <= 0:

		morir()


# ==========================================
# MORIR
# ==========================================

func morir() -> void:

	if muriendo:
		return


	muriendo = true

	velocity = Vector2.ZERO

	print("👹 ¡MURURATA HA MUERTO!")


	anim.speed_scale = 1.0

	anim.play("morir")


	await get_tree().create_timer(1.0).timeout


	queue_free()
