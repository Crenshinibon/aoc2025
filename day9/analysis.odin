package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Dim :: struct {
	base:  int,
	val_1: int,
	val_2: int,
}

INITIAL_VALUE :: -1

main :: proc() {
	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)


	lines := strings.split_lines(s)
	dims_x := make(map[int]Dim)
	defer delete(dims_x)
	dims_y := make(map[int]Dim)
	defer delete(dims_y)

	for l in lines {
		if len(l) == 0 do continue

		parts := strings.split(l, ",")
		x := strconv.parse_int(parts[0]) or_else os.exit(1)
		y := strconv.parse_int(parts[1]) or_else os.exit(1)

		d_x, found_x := &dims_x[x]
		if found_x {
			if d_x.val_2 != INITIAL_VALUE {
				fmt.println("somethings wrong with x", x, d_x, y)
			} else {
				d_x.val_2 = y
			}
		} else {
			dims_x[x] = Dim {
				base  = x,
				val_1 = y,
				val_2 = INITIAL_VALUE,
			}
		}

		d_y, found_y := &dims_y[y]
		if found_y {
			if d_y.val_2 != INITIAL_VALUE {
				fmt.println("somethings wrong with y", y, d_y, x)
			} else {
				d_y.val_2 = x
			}
		} else {
			dims_y[y] = Dim {
				base  = y,
				val_1 = x,
				val_2 = INITIAL_VALUE,
			}
		}
	}
}
