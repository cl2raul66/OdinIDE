package text_engine

import "core:unicode/utf8"

// El Editor envuelve al Gap Buffer y maneja el estado de alto nivel
Editor :: struct {
	buffer: Gap_Buffer,
	// Aquí luego agregaremos la Line_Table, posición del cursor X/Y, etc.
}

ed_create_editor :: proc() -> Editor {
	e := Editor{}
	gb_init(&e.buffer, 1024) // Empezamos con 1KB
	return e
}

ed_destroy_editor :: proc(e: ^Editor) {
	delete(e.buffer.data)
}

// Inserta un rune (Unicode) convirtiéndolo a bytes (UTF-8)
ed_insert_rune :: proc(e: ^Editor, r: rune) {
	bytes, size := utf8.encode_rune(r)
	for i in 0..<size {
		gb_insert_char(&e.buffer, bytes[i])
	}
}

ed_backspace :: proc(e: ^Editor) {
	gb_backspace(&e.buffer)
}

// Extrae el texto usando el asignador que le pasemos (usaremos el temp_allocator)
ed_get_visible_text :: proc(e: ^Editor, allocator := context.allocator) -> string {
	return gb_to_string(&e.buffer, allocator)
}

ed_move_left :: proc(e: ^Editor) {
	gb_move_left(&e.buffer)
}

ed_move_right :: proc(e: ^Editor) {
	gb_move_right(&e.buffer)
}

// Necesitamos saber exactamente dónde está el cursor (el inicio del gap)
// para poder dibujarlo en la pantalla.
ed_get_cursor_index :: proc(e: ^Editor) -> int {
	return e.buffer.gap_start
}
