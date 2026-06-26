package main

import "core:fmt"
import "core:log"
import "core:mem"
import "display"
import sdl "vendor:sdl2"

is_running: bool = false

setup :: proc() -> (success: bool) {
	success = display.init()
	return success
}

cleanup :: proc() {
	display.deinit()
}

process_input :: proc() {
	event : sdl.Event
	sdl.PollEvent(&event)

	#partial switch event.type {
		case sdl.EventType.QUIT:
			is_running = false
			break

		case sdl.EventType.KEYDOWN:
			if event.key.keysym.sym == sdl.Keycode.ESCAPE {
				when ODIN_DEBUG {
					log.info("ESC key was pressed. Start program termination.")
				}

				is_running = false
			}
			break
	}
}

update :: proc() {

}


render :: proc() {

	display.draw_rec(200, 600, 200, 300, 0xFFFFFF00)
	display.draw_grid(10, 0xFFFF0000)

	display.finish_render()
}

main :: proc() {
	// Tracking allocator. Taken from www.odin-lang.com
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}

		context.logger = log.create_console_logger()
		defer log.destroy_console_logger(context.logger)
	}

	is_running = setup()
	defer cleanup()
	
	for is_running {
		process_input()
		update()
		render()
	}
}
