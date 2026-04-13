package gui

// Nuestra propia estructura de Rectángulo para no depender de Raylib en la lógica
Rect :: struct {
	x, y, w, h: f32,
}

// El contexto global de la UI (Estándar IMGUI)
UI_Context :: struct {
	hot_item:    string, // Sobre qué widget está el ratón
	active_item: string, // Qué widget se está haciendo clic

	mouse_pos:     [2]f32,
	mouse_down:    bool,
	mouse_pressed: bool,

	// Sistema de Layout Estático
	current_panel: Rect,
	cursor_y:      f32,  // Dónde se dibujará el siguiente widget
}

g_ui: UI_Context

// Se llama al inicio de cada frame
cr_begin_frame :: proc() {
	g_ui.hot_item = ""

	// Actualizamos el estado del ratón desde el backend
	g_ui.mouse_pos = gbe_get_mouse_pos()
	g_ui.mouse_down = gbe_is_mouse_down()
	g_ui.mouse_pressed = gbe_is_mouse_pressed()
}

// Se llama al final de cada frame
cr_end_frame :: proc() {
	// Si el usuario soltó el clic, limpiamos el elemento activo
	if !g_ui.mouse_down {
		g_ui.active_item = ""
	}
}

// Función auxiliar de colisión
cr_point_in_rect :: proc(p: [2]f32, r: Rect) -> bool {
	return p.x >= r.x && p.x <= r.x + r.w && p.y >= r.y && p.y <= r.y + r.h
}
