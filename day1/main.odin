package main

import "core:os"
main :: proc() {
	data := os.read_entire_file("input") or_else os.exit(1)
	defer delete(data)
	s := string(data)


}
