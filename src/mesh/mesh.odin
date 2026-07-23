package mesh

import rmath "../render_math"

mesh_to_render: ^Mesh = nil

Mesh :: struct {
	vertices:    [dynamic]rmath.Vec3,
	faces:       [dynamic]Face,
	rotation:    rmath.Vec3,
	scale:       rmath.Vec3,
	translation: rmath.Vec3,
}

create :: proc() -> (new_mesh: ^Mesh) {
	new_mesh = new(Mesh)
	new_mesh.faces = make([dynamic]Face)
	new_mesh.vertices = make([dynamic]rmath.Vec3)
	new_mesh.scale = rmath.vec3_one
	return new_mesh
}

destroy :: proc(m: ^Mesh) -> bool {
	if m == nil {
		return false
	}

	delete(m.vertices)
	delete(m.faces)
	free(m)
	return true
}

N_CUBE_VERTICES :: 8
cube_vertices: [N_CUBE_VERTICES]rmath.Vec3 = {
	{-1, -1, -1}, // 1
	{-1, 1, -1}, // 2
	{1, 1, -1}, // 3
	{1, -1, -1}, // 4
	{1, 1, 1}, // 5
	{1, -1, 1}, // 6
	{-1, 1, 1}, // 7
	{-1, -1, 1}, // 8
}

N_CUBE_FACES :: 6 * 2
cube_faces: [N_CUBE_FACES]Face = {
	// front
	{a = 1, b = 2, c = 3, a_uv = {0, 1}, b_uv = {0, 0}, c_uv = {1, 0}, color = 0xFFFFFFFF},
	{a = 1, b = 3, c = 4, a_uv = {0, 1}, b_uv = {1, 0}, c_uv = {1, 1}, color = 0xFFFFFFFF},
	// right
	{a = 4, b = 3, c = 5, a_uv = {0, 1}, b_uv = {0, 0}, c_uv = {1, 0}, color = 0xFFFFFFFF},
	{a = 4, b = 5, c = 6, a_uv = {0, 1}, b_uv = {1, 0}, c_uv = {1, 1}, color = 0xFFFFFFFF},
	// back
	{a = 6, b = 5, c = 7, a_uv = {0, 1}, b_uv = {0, 0}, c_uv = {1, 0}, color = 0xFFFFFFFF},
	{a = 6, b = 7, c = 8, a_uv = {0, 1}, b_uv = {1, 0}, c_uv = {1, 1}, color = 0xFFFFFFFF},
	// left
	{a = 8, b = 7, c = 2, a_uv = {0, 1}, b_uv = {0, 0}, c_uv = {1, 0}, color = 0xFFFFFFFF},
	{a = 8, b = 2, c = 1, a_uv = {0, 1}, b_uv = {1, 0}, c_uv = {1, 1}, color = 0xFFFFFFFF},
	// top
	{a = 2, b = 7, c = 5, a_uv = {0, 1}, b_uv = {0, 0}, c_uv = {1, 0}, color = 0xFFFFFFFF},
	{a = 2, b = 5, c = 3, a_uv = {0, 1}, b_uv = {1, 0}, c_uv = {1, 1}, color = 0xFFFFFFFF},
	// bottom
	{a = 6, b = 8, c = 1, a_uv = {0, 1}, b_uv = {0, 0}, c_uv = {1, 0}, color = 0xFFFFFFFF},
	{a = 6, b = 1, c = 4, a_uv = {0, 1}, b_uv = {1, 0}, c_uv = {1, 1}, color = 0xFFFFFFFF},
}

load_cube_mesh_data :: proc() {
	for &vertex in cube_vertices {
		append(&mesh_to_render.vertices, vertex)
	}

	for &face in cube_faces {
		append(&mesh_to_render.faces, face)
	}
}

