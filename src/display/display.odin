package display

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
    
draw_grid :: proc(step: int, color: u32) {
	for y: int; y < int(window_height); y += step {
		for x: int; x < int(window_width); x += step {
			if y == 0 || x == 0 {
				continue
			}		
			
			pixel_i := (int(window_width) * y) + x
			set_pixel_color(pixel_i, color)
		}
	}
}

draw_rec :: proc(x: i32, y: i32, width: i32, height: i32, color: u32) {
	for cur_y := y; cur_y < y + height; cur_y += 1 {
		for cur_x := x; cur_x < x + width; cur_x += 1 {
			pixel_i := int(i32(window_width) * cur_y + cur_x)	
			set_pixel_color(pixel_i, color)
		}
	}

}