package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {

	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	lines := strings.split_lines(s)
	beams := make([dynamic]int, len(lines[0]))

	for c, i in lines[0] {
		if c == 'S' {beams[i] = 1}
	}

	for l in lines[1:] {
		for c, i in l {
			if c == '^' {
				c_val := beams[i]

				beams[i - 1] += c_val
				beams[i + 1] += c_val

				beams[i] = 0
			}
		}

	}

	result := 0
	for b in beams {
		result += b
	}

	fmt.println("Result:", result, beams)
}
