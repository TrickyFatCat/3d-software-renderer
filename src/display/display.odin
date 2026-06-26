package display

import sdl "vendor:sdl2"

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

draw_pixel :: proc(x: int, y: int, color: u32) {
	if (x < 0 && x > int(window_height) && y < 0 && y > int(window_height)) {
		return
	}

	pixel_index := int(window_width) * y + x
	set_pixel_color(pixel_index, color)
}