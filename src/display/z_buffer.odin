package display

import "core:log"
import "core:mem"

@(private)
z_buffer: []f32 = nil

set_z_buffer_value :: proc(p_index: u32, depth: f32) {
	buffer_len := len(z_buffer)

	if buffer_len == 0 {
		when ODIN_DEBUG {
			log.error("Can NOT change z buffer value. Z buffer is empty.")
		}
	}

	if p_index < 0 || p_index >= u32(buffer_len) {
		return
	}

	z_buffer[p_index] = depth
}

get_z_buffer_value :: proc(p_index: u32) -> (depth: f32 = 0.0) {

	buffer_len := len(z_buffer)

	if buffer_len == 0 {
		when ODIN_DEBUG {
			log.error("Can NOT get z buffer value. Z buffer is empty.")
		}
	}

	if p_index < 0 || p_index >= u32(buffer_len) {
		return depth
	}

	depth = z_buffer[p_index]
	return depth
}

@(private)
create_z_buffer :: proc() -> (err: mem.Allocator_Error) {
	buffer_size := window_width * window_height
	z_buffer, err = make([]f32, buffer_size)

	when ODIN_DEBUG {
		if err != nil {
			log.fatalf("Failed to create z buffer. Reason: %s", err)
		} else {
			size := size_of(z_buffer) * len(z_buffer)
			log.infof("Z buffer created. Size %d bytes.", size)
		}
	}

	return err
}

@(private)
destroy_z_buffer :: proc() {
	delete(z_buffer)

	when ODIN_DEBUG {
		log.info("Z buffer is destroyed.")
	}
}

@(private)
clear_z_buffer :: proc() {
	for &depth in z_buffer {
		depth = 1.0
	}
}

