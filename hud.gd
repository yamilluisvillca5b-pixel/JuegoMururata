extends CanvasLayer


func actualizar_vidas_amaru(vidas: int) -> void:
	var label = get_node_or_null("Vidasamaru")

	if label:
		label.text = "Amaru: " + "❤️".repeat(vidas)


func actualizar_vidas_sapo(vidas: int) -> void:
	var label = get_node_or_null("Vidassapo")

	if label:
		label.text = "Sapo: " + "❤️".repeat(vidas)
