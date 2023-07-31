module main

import term { clear }
import os { input, exists, read_file, write_file, ls, is_dir }

__global (
	current_directory string
	current_file string
)

fn replace_line(action string, body string) int {
	mut file := read_file("${current_directory}/${current_file}") or {
		print("!!! File: '${current_file}' could not be found'\n")
		return 1
	}
	mut file_array := file.split('\n')
	file_array[action.replace('[', '').replace(']', '').int()] = body

	file = file_array.join('\n')

	write_file("${current_directory}/${current_file}", file) or {
		print("!!! File: '${current_file}' could not be found'\n")
		return 1
	}

	return 0
}

fn choose_file(file string) int {
	if current_directory == '' {
		print("No workspace was selected\n")
		return 1
	}
	if exists("${current_directory}/${file}") {
		if !is_dir("${current_directory}/${file}") {
			current_file = file
			return 0
		}
		print("Only files are available for the 'cf' command\n")
		return 1
	}else {
		print("!!! File: '${file}' could not be found'\n")
		return 1
	}

	return 0
}

fn show_current_session() int {
	print("Workspace: ${current_directory}\n")
	print("Active file: ${current_file}\n")
	print("Route: ${current_directory}/${current_file}\n")
	return 1
}

fn show_lines(action string) int {
	if current_file == '' {
		print("Choose a file\n")
		return 1
	}
	file := read_file("${current_directory}/${current_file}") or {
		print("!!! File: '${current_file}' could not be found'\n")
		return 1
	}
	file_array := file.split('\n')

	action_split := action.replace('s', '').replace('[', '').replace(']', '').split('-')
	if action_split.len == 1 {
		print("${action_split[0]}: ${file_array[action_split[0].int()]}\n")
		return 1
	}else {
		if action_split.len > 2 {
			print("The editor only allows a range between two numbers to display rows\n")
			return 1
		}
		for i in action_split[0].int() .. action_split[1].int() {

			if i >= file_array.len {
				print("The file '${current_file}' has only '${file_array.len}' lines")
				return 1
			}
			print("${i}: ${file_array[i]}\n")
		}
	}

	return 1
}

fn choose_workspace(body string) int {
	current_directory = body
	return 0
}

fn show_tree() int {
	if current_directory == '' {
		print("No workspace was selected\n")
		return 1
	}
	dir := ls("${current_directory}") or {
		panic('Could not get the contents of the workspace')
		return 1
	}
	print("Workspace: ${current_directory}/\n")
	for d in dir {
		mut str := "F...\t${d}"
		if is_dir("${current_directory}/${d}"){
			str = "D...\t${d}"
		}
		print("${str}\n")
	}
	return 1
}

fn search_in_file(search string) int {
	file := read_file("${current_directory}/${current_file}") or {
		print("!!! File: '${current_file}' could not be found'\n")
		return 1
	}
	file_array := file.split('\n')

	for i, line in file_array {
		if line.contains(search) {
			print("${i}: ${line}\n")
		}
	}
	return 1
}

fn show_full_file() int{
	file := read_file("${current_directory}/${current_file}") or {
		print("!!! File: '${current_file}' could not be found'\n")
		return 1
	}
	file_array := file.split('\n')

	for i, line in file_array {
		print("${i}: ${line}\n")
	}
	return 1
}

fn append_empty_line() int {
	mut file := read_file("${current_directory}/${current_file}") or {
		print("!!! File: '${current_file}' could not be found'\n")
		return 1
	}
	mut file_array := file.split('\n')
	file_array << ''

	file = file_array.join('\n')

	write_file("${current_directory}/${current_file}", file) or {
		print("!!! File: '${current_file}' could not be found'\n")
		return 1
	}
	return 0
}

fn choose_operation(mut operation []string) int {
	clear()
	actions_only := { 'scs': show_current_session, 'tree': show_tree, 'sf': show_full_file, 'al': append_empty_line }
	body_only := { 'cd': choose_workspace, 'cf': choose_file, 'l': search_in_file }

	action := operation[0].to_lower()
	operation.delete(0)
	body := operation.join(' ')

	if action.contains('s') && action.contains('[') && action.contains(']') { return show_lines(action) }

	if actions_only.keys().contains(action) {
		return actions_only[action]()
	}

	if action.contains('[') && action.contains(']') { return replace_line(action, body) }

	if body_only.keys().contains(action) {
		return body_only[action](body)
	}

	return 0
}

fn main() {
	clear()
	for {
		mut operation := input('\n> ').split(' ')

		if operation[0].to_lower() == 'e' { break }
		result := choose_operation(mut operation)
		if result == 0 { clear() }
	}
}
