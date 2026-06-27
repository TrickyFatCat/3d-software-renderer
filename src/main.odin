package main

import "core:fmt"
import "core:log"
import "core:mem"
import "display"
import math "render_math"
import sdl "vendor:sdl2"

N_POINTS :: 9 * 9 * 9
cube_points : [N_POINTS]math.vec3
projecteds_points : [N_POINTS]math.vec2
fov_factor :f32: 640
camera_pos: math.vec3 = { x = 0.0, y = 0.0, z = -5.0}

is_running: bool = false

setup :: proc() -> (success: bool) {
	success = display.init()

	if success {
		point_index: int
		for x: f32 = -1; x <= 1; x += 0.25 {
			for y: f32 = -1; y <= 1; y += 0.25 {
				for z: f32 = -1; z <= 1; z += 0.25 {
					new_point: math.vec3 = {x, y, z}
					cube_points[point_index] = new_point
					point_index += 1
				}
			}
		}
	}

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

project :: proc (point: ^math.vec3) -> (projected_point: math.vec2) {
	 projected_point.x = (point.x * fov_factor) / point.z
	 projected_point.y = (point.y * fov_factor) / point.z
	 return projected_point
}

update :: proc() {
	for point, i in cube_points {
		point := point
		point.z -= camera_pos.z
		projected_point := project(&point)
		projecteds_points[i] = projected_point
	}
}

render :: proc() {

	// display.draw_rec(200, 600, 200, 300, 0xFFFFFF00)
	display.draw_grid(10, 0xFFFF0000)

	w, h := display.get_window_middle()

	for &point, i in projecteds_points {
		display.draw_rec(i32(point.x) + i32(w), i32(point.y) + i32(h), 4, 4, 0xFFFFFF00)
	}

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
