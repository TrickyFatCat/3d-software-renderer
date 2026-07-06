package display

import "core:log"
import "core:math"
import "core:reflect"
import sdl "vendor:sdl2"

FPS :: 30
FRAME_TARGET_TIME :: 1000 / FPS

CullingMethod :: enum u8 {
	CullNone,
	CullBackface,
}

@(private)
culling_method: CullingMethod = .CullBackface

change_culling_method :: proc(new_method: CullingMethod) {
	if new_method == culling_method {
		return
	}

	culling_method = new_method

	when ODIN_DEBUG {
		method_name: string = reflect.enum_string(new_method)
		log.infof("Culling method was changed to %s", method_name)
	}
}

get_culling_method :: proc() -> CullingMethod {
	return culling_method
}

is_culling_method :: proc(method: CullingMethod) -> bool {
	return culling_method == method
}

DebugRenderOption :: enum u8 {
	Vertex,
	Edge,
	Triangle,
}

DebugRenderOptions :: bit_set[DebugRenderOption]

@(private)
debug_render_options: DebugRenderOptions = {.Vertex, .Edge, .Triangle}

toggle_render_option :: proc(option: DebugRenderOption) {
	if option in debug_render_options {
		debug_render_options -= {option}

	} else {
		debug_render_options += {option}
	}

	when ODIN_DEBUG {
		result: string = "ENABLED" if option in debug_render_options else "DISABLED"
		option_name: string = reflect.enum_string(option)
		log.infof("%s render is %s.", option_name, result)
	}
}

is_debug_option_enabled :: proc(option: DebugRenderOption) -> bool {
	return option in debug_render_options
}

init :: proc() -> (success: bool) {
	success = init_window()

	if success {
		success = init_color_buffer()
	}

	return success
}

deinit :: proc() {
	destroy_color_buffer()
	destroy_window()
}

finish_render :: proc(clear_color: u32 = 0xFF000000) {
	render_color_buffer_texture()
	clear_color_buffer(clear_color)
	sdl.RenderPresent(renderer)
}

draw_grid :: proc(step: int, color: u32) {
	for y: int; y < int(window_height); y += step {
		for x: int; x < int(window_width); x += step {
			if y == 0 || x == 0 {
				continue
			}

			draw_pixel(x, y, color)
		}
	}
}

draw_rec :: proc(x: i32, y: i32, width: i32, height: i32, color: u32) {
	for cur_y := y; cur_y < y + height; cur_y += 1 {
		for cur_x := x; cur_x < x + width; cur_x += 1 {
			draw_pixel(int(cur_x), int(cur_y), color)
		}
	}
}

draw_line :: proc(x0: i32, y0: i32, x1: i32, y1: i32, color: u32) {
	delta_x := x1 - x0
	delta_y := y1 - y0

	longest_side_length := abs(delta_x) if abs(delta_x) >= abs(delta_y) else abs(delta_y)

	x_inc: f32 = f32(delta_x) / f32(longest_side_length)
	y_inc: f32 = f32(delta_y) / f32(longest_side_length)

	current_x: f32 = f32(x0)
	current_y: f32 = f32(y0)

	for i in 0 ..= longest_side_length {
		draw_pixel(int(math.round(current_x)), int(math.round(current_y)), color)
		current_x += x_inc
		current_y += y_inc
	}
}

draw_pixel :: proc(x: int, y: int, color: u32) {
	if (x < 0 && x > int(window_height) && y < 0 && y > int(window_height)) {
		return
	}

	pixel_index := int(window_width) * y + x
	set_pixel_color(pixel_index, color)
}

