package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {


	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	ids := make(map[int]struct{})
	defer delete(ids)

	for line in strings.split_lines_iterator(&s) {
		if len(line) == 0 {break}

		parts := strings.split(line, "-")
		start := strconv.parse_int(parts[0]) or_else os.exit(1)
		end := strconv.parse_int(parts[1]) or_else os.exit(1)
		for i := start; i <= end; i += 1 {
			ids[i] = {}
		}
	}


	fmt.println("Result:", len(ids))
}
