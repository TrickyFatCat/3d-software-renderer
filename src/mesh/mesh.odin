package mesh

import math "../render_math"

mesh_to_render: ^Mesh = nil

Mesh :: struct {
    vertices: [dynamic]math.Vec3,
    faces: [dynamic]Face,
    rotation: math.Vec3
}

create :: proc() -> (new_mesh: ^Mesh) {
    new_mesh = new(Mesh)
    new_mesh.faces = make([dynamic]Face)
    new_mesh.vertices = make([dynamic]math.Vec3)
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
cube_vertices: [N_CUBE_VERTICES]math.Vec3 = {
	{x = -1, y = -1, z = -1}, // 1
	{x = -1, y =  1, z = -1}, // 2
	{x =  1, y =  1, z = -1}, // 3
	{x =  1, y = -1, z = -1}, // 4
	{x =  1, y =  1, z =  1}, // 5
	{x =  1, y = -1, z =  1}, // 6
	{x = -1, y =  1, z =  1}, // 7
	{x = -1, y = -1, z =  1}, // 8
}

N_CUBE_FACES :: 6 * 2
cube_faces: [N_CUBE_FACES]Face = {
    // front
    {a = 1, b = 2, c = 3},
    {a = 1, b = 3, c = 4},
    // right
    {a = 4, b = 3, c = 5},
    {a = 4, b = 3, c = 6},
    // back
    {a = 6, b = 5, c = 7},
    {a = 6, b = 7, c = 8},
    // left
    {a = 8, b = 7, c = 2},
    {a = 8, b = 2, c = 1},
    // top
    {a = 2, b = 7, c = 5},
    {a = 2, b = 5, c = 3},
    // bottom
    {a = 6, b = 8, c = 1},
    {a = 6, b = 1, c = 4},
}

load_cube_mesh_data :: proc() {
    for &vertex in cube_vertices {
        append(&mesh_to_render.vertices, vertex)
    }

    for &face in cube_faces {
        append(&mesh_to_render.faces, face)
    }
}