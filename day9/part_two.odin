package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {

	data := os.read_entire_file("input_small") or_else os.exit(1)
	defer delete(data)
	s := string(data)


	lines := strings.split_lines(s)
	reds := make([dynamic][2]int, len(lines) - 1)
	defer delete(reds)


	for l, i in lines {
		if len(l) == 0 do break
		parts := strings.split(l, ",")
		x := strconv.parse_int(parts[0]) or_else os.exit(1)
		y := strconv.parse_int(parts[1]) or_else os.exit(1)

		reds[i] = {x, y}
	}

	//finding "greens" => reds that are connected on straight lines
	Field :: struct {
		reds: [][2]int,
	}

	fields := make([dynamic]Field, 0)
	defer delete(fields)

	//reds_to_remove := make([dynamic][2]int)
	//defer delete(reds_to_remove)

	for len(reds) > 0 {
		current_f := new(Field)
		current_red := pop(&reds)

		//find next red by following in all directions (same row / column)
		// look in same row


	}


	/*
	Area :: struct {
		c_1:    [2]int,
		dist_x: int,
		c_2:    [2]int,
		dist_y: int,
		area:   int,
	}

	areas := make([dynamic]Area, 0, len(reds) * len(reds))

	for p_1, i in reds {
		for j := i + 1; j < len(reds); j += 1 {
			p_2 := reds[j]

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

  */

	fmt.println("Result:")
}
