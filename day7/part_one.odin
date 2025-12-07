package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {

	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0

	lines := strings.split_lines(s)
	beams := make(map[int]struct{}, len(lines[0]))

	for c, i in lines[0] {
		if c == 'S' {beams[i] = {}}
	}

	for l in lines[1:] {
		for c, i in l {
			if c == '^' {
				_, hasBeam := beams[i]
				if hasBeam {
					result += 1
					delete_key(&beams, i)

					beams[i - 1] = {}
					beams[i + 1] = {}
				}
			}
		}
	}


	fmt.println("Result:", result)
}
