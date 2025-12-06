package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0
	current_pos := 50

	for line in strings.split_lines_iterator(&s) {

		num_string := line[1:]
		num := strconv.parse_int(num_string) or_else os.exit(1)
		dir := line[0]

		sum := current_pos
		if dir == 'R' {
			sum += num
		} else {
			sum -= num
			if sum <= 0 {
				result += 1
				sum = abs(sum)
			}
		}

		div := sum / 100
		rem := sum % 100

		fmt.println(dir, current_pos, num, sum, div, rem)

		result += div
		current_pos = rem
	}

	fmt.println(result)
}
