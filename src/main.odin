package main

import "core:fmt"
import "core:mem"
import te "text_engine"
import ui "gui"

main :: proc() {
	// 1. Rastreador de memoria (para evitar memory leaks)
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	// DEFER DEL REPORTE: Se ejecutará al final de todo, justo antes de destruir el tracker
	defer {
		if len(track.allocation_map) > 0 {
			fmt.eprintf("\n=== %v FUGAS DE MEMORIA DETECTADAS ===\n", len(track.allocation_map))
			for _, entry in track.allocation_map {
				fmt.eprintf("- %v bytes en %v\n", entry.size, entry.location)
			}
		} else {
			fmt.println("\nCierre limpio. 0 fugas de memoria.")
		}
		mem.tracking_allocator_destroy(&track)
	}

	// 2. Inicializar Backend (Motor de Texto)
	editor := te.ed_create_editor()
	defer te.ed_destroy_editor(&editor)

	// 3. Inicializar Frontend (Ventana y UI)
	ui.gbe_init_window(1024, 768, "Odin IDE - Fase 2 (IMGUI)")
	defer ui.gbe_close_window()

	fmt.println("IDE Iniciado. Escribe en la ventana...")

	// Variable para controlar el parpadeo del cursor
	frames_counter: int = 0

	// 4. BUCLE PRINCIPAL (Main Loop)
	for !ui.gbe_should_close() {
		frames_counter += 1

		// --- A. Procesar Entrada (Input del Editor) ---
		for {
			char := ui.gbe_get_char_pressed()
			if char == 0 { break }
			te.ed_insert_rune(&editor, char)
			frames_counter = 0 // Reiniciar parpadeo al escribir
		}

		if ui.gbe_is_key_pressed(.BACKSPACE) || ui.gbe_is_key_pressed(.DELETE) {
			te.ed_backspace(&editor)
			frames_counter = 0
		}
		if ui.gbe_is_key_pressed(.ENTER) {
			te.ed_insert_rune(&editor, '\n')
			frames_counter = 0
		}
		if ui.gbe_is_key_pressed(.LEFT) {
			te.ed_move_left(&editor)
			frames_counter = 0
		}
		if ui.gbe_is_key_pressed(.RIGHT) {
			te.ed_move_right(&editor)
			frames_counter = 0
		}

		// --- B. Renderizar y Lógica UI (Draw & IMGUI) ---
		ui.gbe_begin_drawing()
		ui.cr_begin_frame() // Inicia el estado de la UI en este frame

		// ==========================================
		// PANEL IZQUIERDO (Explorador)
		// ==========================================
		// --- Explorador de Archivos (Sidebar Izquierda) ---
		ui.wg_begin_panel({0, 40, 250, 655}, ui.COLOR_BG_SIDEBAR)
		ui.wg_label("OdinIDE", ui.COLOR_TEXT_DIM, 14)

		if ui.wg_tree_item("f_github", ".github", "folder", 0) {}
		if ui.wg_tree_item("f_vscode", ".vscode", "folder", 0) {}
		if ui.wg_tree_item("f_src", "src", "folder", 0, true) {}
		if ui.wg_tree_item("f_gui", "gui", "folder", 1) {}
		if ui.wg_tree_item("f_backend", "backend.odin", "file", 2) {}
		if ui.wg_tree_item("f_main", "main.odin", "file", 1) {}
		if ui.wg_tree_item("f_git", ".gitignore", "settings", 0) {}

		// ==========================================
		// PANEL DERECHO (Editor de Texto)
		// ==========================================
		// Empieza en X=250, Ancho: 1024-250 = 774px
		ui.wg_begin_panel(ui.Rect{250, 0, 1024 - 250, 768}, ui.COLOR_BG_EDITOR)

		// 1. Dibujar el texto del Gap Buffer
		text := te.ed_get_visible_text(&editor, context.temp_allocator)
		// Lo dibujamos con un margen dentro del panel derecho (X = 250 + 20 = 270)
		ui.gbe_draw_text(text, 270, 20, 20, ui.COLOR_TEXT_DIM)

		// 2. Lógica del Cursor Parpadeante
		cursor_index := te.ed_get_cursor_index(&editor)
		text_before_cursor := string(editor.buffer.data[:cursor_index])

		// Calculamos la posición X del cursor
		text_width := ui.gde_measure_text(text_before_cursor, 20)
		cursor_x := f32(270 + text_width)
		cursor_y := f32(20)

		// Parpadeo: Dibujar el cursor solo la mitad del tiempo
		if (frames_counter / 32) % 2 == 0 {
			ui.gbe_draw_rect(ui.Rect{cursor_x, cursor_y, 2, 20}, [4]u8{255, 255, 255, 255})
		}

		// --- Barra de Estado (Bottom) ---
		ui.wg_begin_panel({0, 695, 1280, 25}, ui.COLOR_BG_BASE)
		curr_x := f32(10)
		curr_x += ui.wg_status_item("sync", "", curr_x)
		curr_x += ui.wg_status_item("person", "", curr_x)
		curr_x += ui.wg_status_item("check", "Odin: OK", curr_x)

		ui.cr_end_frame() // Cierra la lógica IMGUI
		ui.gbe_end_drawing()

		// --- C. Limpieza ---
		free_all(context.temp_allocator)
	}
}
