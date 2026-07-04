package mesh

import math "../render_math"
import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"

load_mesh_from_obj :: proc {
	load_mesh_from_obj_data,
	load_mesh_from_obj_file,
}

load_mesh_from_obj_file :: proc(file_path: string) -> (new_mesh: ^Mesh, success: bool) {
	when ODIN_DEBUG {
		log.infof("Try to load a new model from %s", file_path)
	}

	data, err := os.read_entire_file(file_path, context.temp_allocator)

	if err != nil {
		when ODIN_DEBUG {
			log.errorf("Failed reading data from %s. Reason %v", file_path, err)
		}

		return nil, false
	}

	defer delete(data, context.temp_allocator)

	file_data := string(data)
	new_mesh, success = parse_obj_file(&file_data)
	return new_mesh, success
}

load_mesh_from_obj_data :: proc(data: []u8) -> (loaded_mesh: ^Mesh, success: bool) {
	file_data := string(data)
	return parse_obj_file(&file_data)
}

@(private)
parse_obj_file :: proc(file_data: ^string) -> (new_mesh: ^Mesh, success: bool) {
	if file_data == nil {
		success = false
		return
	}

	new_mesh = create()

	for line in strings.split_lines_iterator(file_data) {
		if len(line) < 2 {
			continue
		}

		data_type := line[:2]

		switch data_type {
		case "v ":
			line_data := strings.split(line[2:], " ")
			defer delete(line_data)
			float_arr: [3]f32

			for &value, i in line_data {
				float_num, ok := strconv.parse_f32(value)

				if ok {
					float_arr[i] = float_num
				}
			}

			vertex: math.Vec3 = {
				x = float_arr[0],
				y = float_arr[1],
				z = float_arr[2],
			}
			append(&new_mesh.vertices, vertex)
			break

		case "f ":
			line_data := strings.split(line[2:], " ")
			defer delete(line_data)
			int_arr: [3]u32

			for &value, i in line_data {
				point_data := value[:strings.index_rune(value, '/')]
				int_num, ok := strconv.parse_uint(point_data)

				if ok {
					int_arr[i] = u32(int_num)
				}
			}

			face: Face = {
				a = int_arr[0],
				b = int_arr[1],
				c = int_arr[2],
			}
			append(&new_mesh.faces, face)
			break
		}
	}

	return new_mesh, success
}

