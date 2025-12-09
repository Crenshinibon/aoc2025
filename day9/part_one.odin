package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {

	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)


	lines := strings.split_lines(s)
	points := make([][2]int, len(lines) - 1)
	defer delete(points)


	for l, i in lines {
		if len(l) == 0 do break
		parts := strings.split(l, ",")
		x := strconv.parse_int(parts[0]) or_else os.exit(1)
		y := strconv.parse_int(parts[1]) or_else os.exit(1)

		points[i] = {x, y}
	}

	Area :: struct {
		c_1:    [2]int,
		dist_x: int,
		c_2:    [2]int,
		dist_y: int,
		area:   int,
	}

	areas := make([dynamic]Area, 0, len(points) * len(points))

	for p_1, i in points {
		for j := i + 1; j < len(points); j += 1 {
			p_2 := points[j]

			dist_x := abs(p_1[0] - p_2[0]) + 1
			dist_y := abs(p_1[1] - p_2[1]) + 1

			append(
				&areas,
				Area {
					c_1 = p_1,
					c_2 = p_2,
					dist_x = dist_x,
					dist_y = dist_y,
					area = dist_x * dist_y,
				},
			)
		}
	}

	slice.sort_by(areas[:], proc(a, b: Area) -> bool {
		return a.area > b.area
	})


	fmt.println("Result:", areas[0])
}
