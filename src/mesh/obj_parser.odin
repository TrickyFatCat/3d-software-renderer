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

load_mesh_from_obj_data :: proc(data: []u8) -> (new_mesh: ^Mesh, success: bool) {
	file_data := string(data)
	new_mesh, success = parse_obj_file(&file_data)
	return new_mesh, success
}

@(private)
parse_obj_file :: proc(file_data: ^string) -> (new_mesh: ^Mesh, success: bool) {
	if file_data == nil {
		success = false
		return
	}

	new_mesh = create()
	tex_coords := make([dynamic]Tex2)
	defer delete(tex_coords)

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

			vertex: math.Vec3 = {float_arr[0], float_arr[1], float_arr[2]}
			append(&new_mesh.vertices, vertex)
			break

		case "vt":
			line_data := strings.split(line[3:], " ")
			defer delete(line_data)
			vt: Tex2

			for &value, i in line_data {
				float_num, ok := strconv.parse_f32(value)

				if !ok {
					continue
				}

				if i == 0 {
					vt.u = float_num
				} else if i == 1 {
					vt.v = float_num
				}
			}

			append(&tex_coords, vt)
			break

		case "f ":
			line_data := strings.split(line[2:], " ")
			defer delete(line_data)
			vertex_indexes: [3]u32
			vt_indexes: [3]u32

			for &value, i in line_data {
				split_data, err := strings.split(value, "/")
				defer delete(split_data)

				v_index, _ := strconv.parse_uint(split_data[0])
				vt_index, _ := strconv.parse_uint(split_data[1])

				if err == nil {
					vertex_indexes[i] = u32(v_index - 1)
					vt_indexes[i] = u32(vt_index - 1)
				}
			}

			face: Face = {
				a    = vertex_indexes[0],
				b    = vertex_indexes[1],
				c    = vertex_indexes[2],
				a_uv = tex_coords[vt_indexes[0]],
				b_uv = tex_coords[vt_indexes[1]],
				c_uv = tex_coords[vt_indexes[2]],
			}
			append(&new_mesh.faces, face)
			break
		}
	}

	return new_mesh, success
}

