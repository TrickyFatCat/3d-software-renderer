package color_buffer

import "../window"
import "core:log"
import "core:mem"
import sdl "vendor:sdl2"

@(private)
color_buffer: []u32 = nil

@(private)
color_buffer_texture: ^sdl.Texture = nil

get :: proc() -> []u32 {
	return color_buffer
}

init :: proc() -> (success: bool) {
	when ODIN_DEBUG {
		log.info("Start color buffer initialization.")
	}

	err := create_buffer()
	ok := create_texture()
 
	success = err == nil && ok
	
	if ODIN_DEBUG {
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
	width, height := window.get_dimentions()
	buffer_size := width * height
	color_buffer, err = make([]u32, buffer_size)

	if ODIN_DEBUG {
		if err != nil {
			log.fatal("Failed to create color buffer.")
		} else {
			size := size_of(color_buffer)
			log.infof("Color buffer created. Size %d bytes.", size)
		}
	}

	return err
}

destroy :: proc() {
	delete(color_buffer)

	when ODIN_DEBUG {
		log.info("Color buffer is destroyed.")
	}
}

render :: proc() {
	width, _ := window.get_dimentions()
	pitch := width * size_of(u32)
	sdl.UpdateTexture(color_buffer_texture, nil, raw_data(color_buffer), i32(pitch))
	sdl.RenderCopy(window.get_renderer(), color_buffer_texture, nil, nil)
}

clear :: proc(color: u32) {
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
get_texture :: proc() -> ^sdl.Texture {
	return color_buffer_texture
}

@(private)
create_texture :: proc() -> bool {
	renderer := window.get_renderer()

	if renderer == nil {
		when ODIN_DEBUG {
			log.error("Failed to create color buffer texture, renderer is null")
		}

		return false
	}

	width, height := window.get_dimentions()
	color_buffer_texture = sdl.CreateTexture(
		renderer,
		sdl.PixelFormatEnum.ARGB8888,
		sdl.TextureAccess.STREAMING,
		i32(width),
		i32(height),
	)

	if ODIN_DEBUG && color_buffer_texture == nil {
		log.fatal("Failed to create color buffer texture.")
		return false
	}

	log.info("Color buffer texture successfully created.")
	return true
}
