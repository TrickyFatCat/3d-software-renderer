package render_math

// Odin has its own matrix type, but this one created for learning experience
Mat4 :: distinct [4][4]f32

get_identity_mat4 :: proc() -> (identity_mat4: Mat4) {
	// | 1 0 0 0 |
	// | 0 1 0 0 |
	// | 0 0 1 0 |
	// | 0 0 0 1 |
	identity_mat4 = {
		{1, 0, 0, 0}, //
		{0, 1, 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	}
	return identity_mat4
}

@(private)
make_scale_mat4_xyz :: proc(sx, sy, sz: f32) -> (scale_mat4: Mat4) {
	// | sx  0  0 0 |
	// |  0 sy  0 0 |
	// |  0  0 sz 0 |
	// |  0  0  0 1 |
	scale_mat4 = get_identity_mat4()
	scale_mat4[0][0] = sx
	scale_mat4[1][1] = sy
	scale_mat4[2][2] = sz
	return scale_mat4
}

@(private)
make_scale_mat4_vec3 :: proc(vec: Vec3) -> (scale_mat4: Mat4) {
	// | sx  0  0 0 |
	// |  0 sy  0 0 |
	// |  0  0 sz 0 |
	// |  0  0  0 1 |
	scale_mat4 = get_identity_mat4()
	scale_mat4[0][0] = vec.x
	scale_mat4[1][1] = vec.y
	scale_mat4[2][2] = vec.z
	return scale_mat4
}

make_scale_mat4 :: proc {
	make_scale_mat4_xyz,
	make_scale_mat4_vec3,
}


@(private)
mat4_mul_vec4 :: proc(m: Mat4, v: Vec4) -> (new_vec: Vec4) {
	new_vec.x = (m[0][0] * v.x) + (m[0][1] + v.y) + (m[0][2] * v.z) + (m[0][3] * v.w)
	new_vec.y = (m[1][0] * v.x) + (m[1][1] + v.y) + (m[1][2] * v.z) + (m[1][3] * v.w)
	new_vec.z = (m[2][0] * v.x) + (m[2][1] + v.y) + (m[2][2] * v.z) + (m[2][3] * v.w)
	return new_vec
}


mat4_multiply :: proc {
	mat4_mul_vec4,
}

