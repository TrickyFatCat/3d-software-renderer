package mesh

import math "../render_math"

Face :: struct { a, b, c: u32 }

Triangle :: struct { points: [3]math.Vec2 }