package display

import "core:log"
import "core:mem"
import sdl "vendor:sdl2"

@(private)
color_buffer: []u32 = nil

@(private)
color_buffer_texture: ^sdl.Texture = nil

get_color_buffer :: proc() -> []u32 {
	return color_buffer
}

@(private)
init_color_buffer :: proc() -> (success: bool) {
	when ODIN_DEBUG {
		log.info("Start color buffer initialization.")
	}

	err := create_buffer()
	ok := create_texture()
 
	success = err == nil && ok
	
	when ODIN_DEBUG {
		if success {
			log.info("Color buffer successfully initialized.")
		} else {
			log.error("Color buffer initialization failed.")
		}
	}

	return success
}

@(private)
create_buffer :: proc() -> (err: mem.Allocator_Error) {
	buffer_size := window_width * window_height
	color_buffer, err = make([]u32, buffer_size)

	when ODIN_DEBUG {
		if err != nil {
			log.fatal("Failed to create color buffer.")
		} else {
			size := size_of(color_buffer) * len(color_buffer)
			log.infof("Color buffer created. Size %d bytes.", size)
		}
	}

	return err
}

@(private)
destroy_color_buffer :: proc() {
	delete(color_buffer)

	when ODIN_DEBUG {
		log.info("Color buffer is destroyed.")
	}
}

@(private)
render_color_buffer_texture :: proc() {
	pitch := window_width * size_of(u32)
	sdl.UpdateTexture(color_buffer_texture, nil, raw_data(color_buffer), i32(pitch))
	sdl.RenderCopy(renderer, color_buffer_texture, nil, nil)
}

@(private)
clear_color_buffer :: proc(color: u32) {
	for &c in color_buffer {
		c = color
	}
}

set_pixel_color :: proc(p_index: int, color: u32) {
	buffer_len := len(color_buffer)
	if buffer_len == 0 {
		when ODIN_DEBUG {
			log.error("Can not change color buffer pixel. Color buffer is empty.")
		}
	}

	if p_index < 0 || p_index > buffer_len{
		when ODIN_DEBUG {
			log.error("Can not change color buffer pixel. Invalid p_index.")
		}

		return
	}

	color_buffer[p_index] = color
}

get_color_buffer_texture :: proc() -> ^sdl.Texture {
	return color_buffer_texture
}

@(private)
create_texture :: proc() -> bool {
	renderer := get_renderer()

	if renderer == nil {
		when ODIN_DEBUG {
			log.error("Failed to create color buffer texture, renderer is null")
		}

		return false
	}

	color_buffer_texture = sdl.CreateTexture(
		renderer,
		sdl.PixelFormatEnum.ARGB8888,
		sdl.TextureAccess.STREAMING,
		i32(window_width),
		i32(window_height),
	)

	if color_buffer_texture == nil {
		when ODIN_DEBUG {
			log.fatal("Failed to create color buffer texture.")
		}
		return false
	}

	log.info("Color buffer texture successfully created.")
	return true
}
