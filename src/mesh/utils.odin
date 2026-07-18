package mesh

@(private)
swap :: proc(a: ^$T, b: ^T) {
	tmp := a^
	a^ = b^
	b^ = tmp
}

