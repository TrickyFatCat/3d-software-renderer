package color_buffer

import wm "../window_manager"
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
	buffer_size :: wm.WINDOW_WIDTH * wm.WINDOW_HEIGHT
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
	pitch :: wm.WINDOW_WIDTH * size_of(u32)
	sdl.UpdateTexture(color_buffer_texture, nil, raw_data(color_buffer), pitch)
	sdl.RenderCopy(wm.renderer, color_buffer_texture, nil, nil)
}

clear :: proc(color: u32) {
	for &c in color_buffer {
		c = color
	}
}

get_texture :: proc() -> ^sdl.Texture {
	return color_buffer_texture
}

@(private)
create_texture :: proc() -> bool {
	if wm.renderer == nil {
		when ODIN_DEBUG {
			log.error("Failed to create color buffer texture, renderer is null")
		}

		return false
	}

	color_buffer_texture = sdl.CreateTexture(
		wm.renderer,
		sdl.PixelFormatEnum.ARGB8888,
		sdl.TextureAccess.STREAMING,
		wm.WINDOW_WIDTH,
		wm.WINDOW_HEIGHT,
	)

	if ODIN_DEBUG && color_buffer_texture == nil {
		log.fatal("Failed to create color buffer texture.")
		return false
	}

	log.info("Color buffer texture successfully created.")
	return true
}
