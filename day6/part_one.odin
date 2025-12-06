package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {

	OPS_LINE_INDEX :: 4
	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	lines := strings.split_lines(s)
	ops_fields := strings.fields(lines[OPS_LINE_INDEX])
	fmt.println("ops fields", ops_fields)

	nums := make([dynamic][OPS_LINE_INDEX]int, len(ops_fields))
	defer delete(nums)

	for i := 0; i < OPS_LINE_INDEX; i += 1 {
		line := lines[i]
		fields := strings.fields(line)
		for f_string, j in fields {
			f := strconv.parse_int(f_string) or_else os.exit(1)
			fmt.println(f)
			nums[j][i] = f
		}
	}


	result := 0
	for i := 0; i < len(ops_fields); i += 1 {
		op := ops_fields[i]
		prob := nums[i]

		p_res := prob[0]
		if op == "+" {
			for j := 1; j < OPS_LINE_INDEX; j += 1 {
				p_res += prob[j]
			}
		} else if op == "*" {
			for j := 1; j < OPS_LINE_INDEX; j += 1 {
				p_res *= prob[j]
			}
		}
		result += p_res
	}

	fmt.println("Result:", result)
}
