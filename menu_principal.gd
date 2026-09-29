extends Control


# ==========================================
# REFERENCIA A LA MÚSICA
# ==========================================

var musica


# ==========================================
# INICIO
# ==========================================

func _ready() -> void:

	# Obtener el reproductor del AudioManager
	musica = AudioManager.get_node("AudioStreamPlayer")

	# Iniciar música si no está sonando
	if not musica.playing:
		musica.play()

	# Conectar botones
	$Menu/Jugar.pressed.connect(_on_jugar_pressed)
	$Menu/Tutorial.pressed.connect(_on_tutorial_pressed)
	$Menu/Sonido.pressed.connect(_on_sonido_pressed)
	$Menu/Salir.pressed.connect(_on_salir_pressed)


# ==========================================
# BOTÓN JUGAR
# ==========================================

func _on_jugar_pressed() -> void:

	print("Iniciando juego...")

	get_tree().change_scene_to_file("res://mundo.tscn")


# ==========================================
# BOTÓN TUTORIAL
# ==========================================

func _on_tutorial_pressed() -> void:

	var dialogo := AcceptDialog.new()

	dialogo.title = "Tutorial"

	dialogo.dialog_text = "CONTROLES DE AMARU\n\n" \
		+ "Flecha izquierda / derecha: Moverse\n" \
		+ "Espacio: Saltar\n\n" \
		+ "Q: Ataque 1\n" \
		+ "E: Ataque 2\n" \
		+ "R: Ataque 3\n" \
		+ "F: Ataque especial\n\n" \
		+ "Objetivo:\n" \
		+ "Avanza por el mundo andino, enfrenta a las criaturas " \
		+ "y descubre el misterio del Mururata."

	add_child(dialogo)

	dialogo.popup_centered()


# ==========================================
# BOTÓN SONIDO
# ==========================================

func _on_sonido_pressed() -> void:

	if musica == null:
		return

	if musica.playing:

		musica.stop()

		$Menu/Sonido.text = "SONIDO: OFF"

	else:

		musica.play()

		$Menu/Sonido.text = "SONIDO: ON"


# ==========================================
# BOTÓN SALIR
# ==========================================

func _on_salir_pressed() -> void:

	print("Saliendo del juego...")

	get_tree().quit()
