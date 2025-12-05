package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {


	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	Range :: struct {
		start, end: int,
	}

	result := 0
	fresh_ranges := [dynamic]Range{}
	defer delete(fresh_ranges)

	finding_ranges := true
	for line in strings.split_lines_iterator(&s) {
		if len(line) == 0 {finding_ranges = false; continue}

		if finding_ranges {
			parts := strings.split(line, "-")
			range := Range {
				start = strconv.parse_int(parts[0]) or_else os.exit(1),
				end   = strconv.parse_int(parts[1]) or_else os.exit(1),
			}

			append(&fresh_ranges, range)
		} else {
			id := strconv.parse_int(line) or_else os.exit(1)

			for r in fresh_ranges {
				if r.start <= id && id <= r.end {
					result += 1; break
				}
			}
		}
	}


	fmt.println("Result:", result)
}
