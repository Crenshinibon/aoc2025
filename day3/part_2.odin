package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

main :: proc() {

	NUMBERS :: "987654321"

	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	result := 0

	for line in strings.split_lines_iterator(&s) {

		target := [12]rune{}
		target_index := 11

		offset := 0
		target_index_loop: for target_index >= 0 {
			relevant_slice := line[offset:len(line) - target_index]
			for n in NUMBERS {
				for c, i in relevant_slice {
					if c == n {

						target[target_index] = c
						offset += i + 1

						target_index -= 1
						continue target_index_loop
					}
				}
			}
		}

		reversed := [12]rune{}
		index := 0
		for i := 11; i >= 0; i -= 1 {
			reversed[index] = target[i]
			index += 1
		}
		jolt_string := utf8.runes_to_string(reversed[:])
		jolt := strconv.parse_int(jolt_string) or_else os.exit(1)

		result += jolt
	}

	fmt.println("Result:", result)
}
