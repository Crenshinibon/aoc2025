package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

main :: proc() {

	OPS_LINE_INDEX :: 4

	construct_numbers :: proc(prob: [OPS_LINE_INDEX]string) -> []int {
		fmt.println("prob", prob)

		num_length := len(prob[0])
		collector := make([dynamic][OPS_LINE_INDEX]rune, num_length)
		defer delete(collector)

		for n, i in prob {
			j := num_length - 1
			for c in n {
				collector[j][i] = c
				j -= 1
			}
		}
		fmt.println("collector", collector, num_length)

		result := make([dynamic]int, num_length)
		for i := 0; i < len(collector); i += 1 {
			nums := collector[i]
			str := utf8.runes_to_string(nums[:])
			tr_str := strings.trim_space(str)
			num := strconv.parse_int(tr_str) or_else os.exit(1)
			result[i] = num
		}

		fmt.println("result", result)

		//return [1]int{}
		return result[:]
	}


	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)

	lines := strings.split_lines(s)
	ops_line := lines[OPS_LINE_INDEX]
	ops_fields := strings.fields(ops_line)
	prob_idc := [dynamic]int{}
	defer delete(prob_idc)

	for r, i in ops_line {
		if r != ' ' {
			append(&prob_idc, i)
		}
	}
	fmt.println("ops fields", ops_fields, prob_idc)

	//read in the probs

	probs := make([dynamic][OPS_LINE_INDEX]string, len(ops_fields))

	for i := 0; i < len(prob_idc); i += 1 {
		s_idx := prob_idc[i]
		e_idx: int
		//when last prbolem, use end of line		
		if i == len(prob_idc) - 1 {
			for j := 0; j < OPS_LINE_INDEX; j += 1 {
				probs[i][j] = lines[j][s_idx:]
			}

		} else {
			e_idx = prob_idc[i + 1] - 1
			for j := 0; j < OPS_LINE_INDEX; j += 1 {
				probs[i][j] = lines[j][s_idx:e_idx]
			}
		}
	}

	fmt.println("probs", probs)


	// construct correct numbers
	nums := make([dynamic][OPS_LINE_INDEX]int, len(ops_fields))
	defer delete(nums)


	result := 0
	for p, i in probs {
		prob := construct_numbers(p)
		op := ops_fields[i]

		p_res := 0
		if op == "+" {
			for j := 0; j < len(prob); j += 1 {
				p_res += prob[j]
			}
		} else if op == "*" {
			p_res = 1
			for j := 0; j < len(prob); j += 1 {
				p_res *= prob[j]
			}
		}

		fmt.println("p_res", p_res)
		result += p_res
	}


	fmt.println("Result:", result)
}
