package render_math

import "core:math"

create_projection_matrix :: proc(fov, aspect, znear, zfar: f32) -> (pmatrix: Mat4) {
	// | (h/w)*1/tan(fov/2)             0              0                 0 |
	// |                  0  1/tan(fov/2)              0                 0 |
	// |                  0             0     zf/(zf-zn)  (-zf*zn)/(zf-zn) |
	// |                  0             0              1                 0 |

	pmatrix = get_zero_mat4()
	fov_factor := 1 / math.tan(fov / 2)
	pmatrix[0][0] = aspect * fov_factor
	pmatrix[1][1] = fov_factor
	pmatrix[2][2] = zfar / (zfar - znear)
	pmatrix[2][3] = (-zfar * znear) / (zfar - znear)
	pmatrix[3][2] = 1.0
	return pmatrix
}

project_vec4 :: proc(m: Mat4, v: Vec4) -> (pvec: Vec4) {
	pvec = mat4_multiply(m, v)

	if pvec.w != 0.0 {
		pvec.x /= pvec.w
		pvec.y /= pvec.w
		pvec.z /= pvec.w
	}

	return pvec
}

