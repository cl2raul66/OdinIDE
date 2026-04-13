package gui

import "core:strings"
// Colores basados en el diseño Image 2.html
COLOR_BG_BASE    :: [4]u8{27, 33, 44, 255}
COLOR_BG_SIDEBAR :: [4]u8{35, 41, 53, 255}
COLOR_BG_EDITOR  :: [4]u8{40, 44, 52, 255}
COLOR_BORDER     :: [4]u8{51, 59, 71, 255}
COLOR_ACCENT     :: [4]u8{97, 175, 239, 255}
COLOR_TEXT_MAIN  :: [4]u8{208, 214, 224, 255}
COLOR_TEXT_DIM   :: [4]u8{152, 162, 179, 255}
COLOR_SYNTAX_KW  :: [4]u8{224, 108, 117, 255}
COLOR_SYNTAX_STR :: [4]u8{152, 195, 121, 255}

// --- Layout & Panels ---

wg_begin_panel :: proc(r: Rect, bg_color: [4]u8) {
	g_ui.current_panel = r
	g_ui.cursor_y = r.y + 10
	gbe_draw_rect(r, bg_color)
}

wg_separator :: proc() {
	line_rect := Rect{g_ui.current_panel.x, g_ui.cursor_y, g_ui.current_panel.w, 1}
	gbe_draw_rect(line_rect, COLOR_BORDER)
	g_ui.cursor_y += 5
}

// --- Basic Widgets ---

wg_label :: proc(text: string, color: [4]u8 = COLOR_TEXT_MAIN, font_size: i32 = 18) {
	gbe_draw_text(text, i32(g_ui.current_panel.x + 10), i32(g_ui.cursor_y), font_size, color)
	g_ui.cursor_y += f32(font_size) + 5
}

wg_button :: proc(id: string, text: string) -> bool {
	bounds := Rect{
		x = g_ui.current_panel.x + 10,
		y = g_ui.cursor_y,
		w = g_ui.current_panel.w - 20,
		h = 30,
	}
	g_ui.cursor_y += bounds.h + 5

	if cr_point_in_rect(g_ui.mouse_pos, bounds) {
		g_ui.hot_item = id
		if g_ui.active_item == "" && g_ui.mouse_pressed {
			g_ui.active_item = id
		}
	}

	clicked := false
	if !g_ui.mouse_down && g_ui.hot_item == id && g_ui.active_item == id {
		clicked = true
	}

	color := [4]u8{60, 60, 65, 255}
	if g_ui.hot_item == id { color = [4]u8{80, 80, 85, 255} }
	if g_ui.active_item == id { color = [4]u8{40, 40, 45, 255} }

	gbe_draw_rect(bounds, color)
	gbe_draw_text(text, i32(bounds.x + 10), i32(bounds.y + 5), 20, COLOR_TEXT_MAIN)

	return clicked
}

// --- IDE Specific Widgets ---

// Elemento del explorador de archivos (Tree Item)
wg_tree_item :: proc(id: string, label: string, icon: string, depth: i32, is_expanded: bool = false) -> (clicked: bool) {
	bounds := Rect{
		x = g_ui.current_panel.x,
		y = g_ui.cursor_y,
		w = g_ui.current_panel.w,
		h = 24,
	}
	g_ui.cursor_y += bounds.h

	if cr_point_in_rect(g_ui.mouse_pos, bounds) {
		g_ui.hot_item = id
		if g_ui.active_item == "" && g_ui.mouse_pressed {
			g_ui.active_item = id
		}
	}

	if !g_ui.mouse_down && g_ui.hot_item == id && g_ui.active_item == id {
		clicked = true
	}

	if g_ui.hot_item == id {
		gbe_draw_rect(bounds, [4]u8{45, 51, 64, 255})
	}

	indent := f32(depth) * 16.0 + 10.0

	// Flecha de expansión (si aplica)
	arrow := is_expanded ? "v" : ">"
	if icon == "folder" {
		gbe_draw_text(arrow, i32(bounds.x + indent - 12), i32(bounds.y + 4), 16, COLOR_TEXT_DIM)
	}

	// Icono y Texto
	gbe_draw_text(icon, i32(bounds.x + indent), i32(bounds.y + 4), 16, COLOR_ACCENT)
	gbe_draw_text(label, i32(bounds.x + indent + 20), i32(bounds.y + 4), 16, COLOR_TEXT_MAIN)

	return clicked
}

// Pestaña (Tab) para el editor o terminal
wg_tab :: proc(id: string, label: string, is_active: bool) -> bool {
	text_w := gde_measure_text(label, 16)
	bounds := Rect{
		x = g_ui.current_panel.x, // Esto asume un layout horizontal que manejaremos en main
		y = g_ui.current_panel.y,
		w = f32(text_w) + 40,
		h = 36,
	}
	// El cursor_y no se mueve aquí porque las pestañas suelen ser horizontales

	if cr_point_in_rect(g_ui.mouse_pos, bounds) {
		g_ui.hot_item = id
		if g_ui.active_item == "" && g_ui.mouse_pressed {
			g_ui.active_item = id
		}
	}

	clicked := false
	if !g_ui.mouse_down && g_ui.hot_item == id && g_ui.active_item == id {
		clicked = true
	}

	bg_color := is_active ? COLOR_BG_EDITOR : COLOR_BG_SIDEBAR
	gbe_draw_rect(bounds, bg_color)

	if is_active {
		// Línea de acento superior
		gbe_draw_rect(Rect{bounds.x, bounds.y, bounds.w, 2}, COLOR_ACCENT)
	}

	gbe_draw_text(label, i32(bounds.x + 20), i32(bounds.y + 10), 16, is_active ? COLOR_TEXT_MAIN : COLOR_TEXT_DIM)

	return clicked
}

// Botón de icono pequeño (para barras de herramientas)
wg_icon_button :: proc(id: string, icon: string, x, y: f32) -> bool {
	bounds := Rect{x, y, 24, 24}

	if cr_point_in_rect(g_ui.mouse_pos, bounds) {
		g_ui.hot_item = id
		if g_ui.active_item == "" && g_ui.mouse_pressed {
			g_ui.active_item = id
		}
	}

	clicked := false
	if !g_ui.mouse_down && g_ui.hot_item == id && g_ui.active_item == id {
		clicked = true
	}

	if g_ui.hot_item == id {
		gbe_draw_rect(bounds, [4]u8{255, 255, 255, 20})
	}

	gbe_draw_text(icon, i32(x + 4), i32(y + 4), 18, COLOR_TEXT_DIM)

	return clicked
}

// Item de la barra de estado inferior
wg_status_item :: proc(icon: string, label: string, x: f32) -> f32 {
	text_w := gde_measure_text(label, 14)
	total_w := f32(text_w) + 30

	gbe_draw_text(icon, i32(x + 5), i32(g_ui.current_panel.y + 4), 14, COLOR_TEXT_DIM)
	gbe_draw_text(label, i32(x + 25), i32(g_ui.current_panel.y + 4), 14, COLOR_TEXT_DIM)

	return total_w
}

// Línea de salida de la terminal
wg_terminal_line :: proc(text: string, type: string = "INFO") {
	color := COLOR_TEXT_DIM
	if strings.contains(text, "Ejecutando") || strings.contains(text, "Iniciado") {
		color = COLOR_TEXT_MAIN
	}

	gbe_draw_text(text, i32(g_ui.current_panel.x + 10), i32(g_ui.cursor_y), 14, color)
	g_ui.cursor_y += 18
}
