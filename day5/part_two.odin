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

	fresh_ranges := [dynamic]Range{}
	defer delete(fresh_ranges)

	for line in strings.split_lines_iterator(&s) {
		if len(line) == 0 {break}

		parts := strings.split(line, "-")
		range := Range {
			start = strconv.parse_int(parts[0]) or_else os.exit(1),
			end   = strconv.parse_int(parts[1]) or_else os.exit(1),
		}

		append(&fresh_ranges, range)
	}

	//merging ranges
	still_merging := true
	for still_merging {
		still_merging = false

		for &target, i in fresh_ranges {
			for j := i + 1; j < len(fresh_ranges); j += 1 {
				source := fresh_ranges[j]

				if source.start <= target.end && source.end >= target.start {
					if source.end > target.end {
						target.end = source.end
					}
					if source.start < target.start {
						target.start = source.start
					}

					still_merging = true
					ordered_remove(&fresh_ranges, j)
				}
			}
		}
		fmt.println(fresh_ranges)
	}


	//counting ids count in merged_ranges
	result := 0
	for mr in fresh_ranges {
		result += mr.end - mr.start + 1
	}
	fmt.println("Result:", result)
}
