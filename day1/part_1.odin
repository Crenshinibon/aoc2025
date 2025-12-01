package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	data := os.read_entire_file("input_small") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0

	current_pos := 50
	for line in strings.split_lines_iterator(&s) {
		if len(line) == 0 {continue}

		num_string := line[1:]
		num := strconv.parse_int(num_string) or_else os.exit(1)

		if line[0] == 'R' {
			current_pos = current_pos + num
			for current_pos > 99 {
				current_pos = current_pos - 100
			}
		} else {
			current_pos = current_pos - num
			for current_pos < 0 {
				current_pos = current_pos + 100
			}
		}

		if current_pos == 0 {
			result = result + 1
		}
	}

	fmt.println(result)
}
