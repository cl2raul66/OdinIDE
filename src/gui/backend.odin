package gui

import rl "vendor:raylib"
import "core:strings"

// --- Ciclo de vida ---
gbe_init_window :: proc(width, height: i32, title: cstring) {
	rl.InitWindow(width, height, title)
	rl.SetTargetFPS(64) // Un IDE debe ser ultra fluido 120
}

gbe_close_window :: proc() {
	rl.CloseWindow()
}

gbe_should_close :: proc() -> bool {
	return rl.WindowShouldClose()
}

gbe_begin_drawing :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.Color{27, 33, 44, 255}) // COLOR_BG_BASE
}

gbe_end_drawing :: proc() {
	rl.EndDrawing()
}

// --- Input ---

gbe_get_char_pressed :: proc() -> rune {
	return rl.GetCharPressed()
}

gbe_is_key_pressed :: proc(key: rl.KeyboardKey) -> bool {
	return rl.IsKeyPressed(key)
}

gbe_is_key_down :: proc(key: rl.KeyboardKey) -> bool {
	return rl.IsKeyDown(key)
}

gbe_get_mouse_pos :: proc() -> [2]f32 {
	pos := rl.GetMousePosition()
	return {pos.x, pos.y}
}

gbe_is_mouse_down :: proc() -> bool {
	return rl.IsMouseButtonDown(.LEFT)
}

gbe_is_mouse_pressed :: proc() -> bool {
	return rl.IsMouseButtonPressed(.LEFT)
}


gde_measure_text :: proc(text: string, font_size: i32) -> i32 {
	c_text := strings.clone_to_cstring(text, context.temp_allocator)
	return rl.MeasureText(c_text, font_size)
}

gbe_draw_rect :: proc(r: Rect, color: [4]u8) {
	rl.DrawRectangleRec(rl.Rectangle{r.x, r.y, r.w, r.h}, rl.Color{color.r, color.g, color.b, color.a})
}

gbe_draw_rect_lines :: proc(r: Rect, thickness: f32, color: [4]u8) {
	rl.DrawRectangleLinesEx(rl.Rectangle{r.x, r.y, r.w, r.h}, thickness, rl.Color{color[0], color[1], color[2], color[3]})
}

gbe_draw_text :: proc(text: string, x, y: i32, font_size: i32, color: [4]u8) {
	c_text := strings.clone_to_cstring(text, context.temp_allocator)
	rl.DrawText(c_text, x, y, font_size, rl.Color{color.r, color.g, color.b, color.a})
}
