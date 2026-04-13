package text_engine

import "core:fmt"
import "core:mem"

Gap_Buffer :: struct {
	data: [dynamic]u8,
	gap_start, gap_end: int,
}

gb_init :: proc(gb: ^Gap_Buffer, capacity: int) {
	gb.data = make([dynamic]u8, capacity)
	gb.gap_start = 0
	gb.gap_end = capacity
}

gb_insert :: proc(gb: ^Gap_Buffer, data: []u8) {
	if gb.gap_start + len(data) > gb.gap_end {
		fmt.println("Error: Gap Buffer overflow!")
		return
	}
	mem.copy(raw_data(gb.data[gb.gap_start:]), raw_data(data), len(data))
	gb.gap_start += len(data)
}

gb_insert_char :: proc(gb: ^Gap_Buffer, char: u8) {
	if gb.gap_start >= gb.gap_end {
		gb_resize(gb, len(gb.data) * 2)
		fmt.println("warning: Gap Buffer resized to accommodate more characters.")
	}
	gb.data[gb.gap_start] = char
	gb.gap_start += 1
}

gb_to_string :: proc(gb: ^Gap_Buffer, allocator := context.allocator) -> string {
	before := gb.data[:gb.gap_start]
	after := gb.data[gb.gap_end:]

	result := make([dynamic]u8, allocator)
	append(&result, ..before)
	append(&result, ..after)

	return string(result[:])
}

gb_move_left :: proc(gb: ^Gap_Buffer) {
	if gb.gap_start > 0 {
		gb.gap_start -= 1
		gb.gap_end -= 1
		gb.data[gb.gap_end] = gb.data[gb.gap_start]
	}
}

gb_move_right :: proc(gb: ^Gap_Buffer) {
	if gb.gap_end < len(gb.data) {
		gb.data[gb.gap_start] = gb.data[gb.gap_end]
		gb.gap_start += 1
		gb.gap_end += 1
	}
}

gb_move_gap_to :: proc(gb: ^Gap_Buffer, target_index: int) {
	text_length := len(gb.data) - (gb.gap_end - gb.gap_start)
	target := clamp(target_index, 0, text_length)

	if target == gb.gap_start { return }

	if target < gb.gap_start {
		distance := gb.gap_start - target
		mem.copy(
			&gb.data[gb.gap_end - distance],
			&gb.data[target],
			distance,
		)
		gb.gap_start -= distance
		gb.gap_end -= distance
	} else {
		distance := target - gb.gap_start
		mem.copy(
			&gb.data[gb.gap_start],
			&gb.data[gb.gap_end],
			distance,
		)
		gb.gap_start += distance
		gb.gap_end += distance
	}
}

gb_resize :: proc(gb: ^Gap_Buffer, new_capacity: int) {
	if new_capacity <= len(gb.data) { return }

	new_data := make([dynamic]u8, new_capacity)

	mem.copy(&new_data[0], &gb.data[0], gb.gap_start)

	after_gap_len := len(gb.data) - gb.gap_end
	new_gap_end := new_capacity - after_gap_len

	if after_gap_len > 0 {
		mem.copy(&new_data[new_gap_end], &gb.data[gb.gap_end], after_gap_len)
	}

	delete(gb.data)
	gb.data = new_data
	gb.gap_end = new_gap_end
}

gb_backspace :: proc(gb: ^Gap_Buffer) {
	if gb.gap_start > 0 {
		gb.gap_start -= 1
		// No necesitamos borrar el dato real, al mover el gap_start hacia atrás,
		// ese byte ahora es parte del "hueco" y será sobrescrito luego.
	}
}

gb_delete :: proc(gb: ^Gap_Buffer) {
	if gb.gap_end < len(gb.data) {
		gb.gap_end += 1
	}
}
