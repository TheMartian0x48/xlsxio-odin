package xlsx

import "core:strconv"
import "core:strings"

// A cell value with a type guessed from its text.
//
// xlsxio doesn't expose the cell's real type, only its text. The typed C
// calls (sheet_next_cell_int/_float) each consume the cell and silently return
// 0 on a parse failure, so they can't be used to "try int, then float".
// Instead we read the text once and classify it here.
//
// Caveat: a text cell containing "123" is indistinguishable from a number.
Cell :: union {
	i64,
	f64,
	string, // owned by the allocator passed to next_cell; free with delete
}

// Classify cell text. The returned string (if any) is a clone.
parse_cell :: proc(text: string, allocator := context.allocator) -> Cell {
	if len(text) == 0 do return nil

	// Only try numbers when the text starts like one; this keeps strings such
	// as "nan" or "inf" (which strconv accepts as floats) as strings.
	switch text[0] {
	case '0' ..= '9', '-', '+', '.':
		if i, ok := strconv.parse_i64_of_base(text, 10); ok do return i
		if f, ok := strconv.parse_f64(text); ok do return f
	}
	return strings.clone(text, allocator)
}

// Read the next cell of the current row as a typed value.
// ok is false when the row has no more cells (an empty cell gives ok = true, value = nil).
next_cell :: proc(sheet: Sheet, allocator := context.allocator) -> (value: Cell, ok: bool) {
	raw := sheet_next_cell(sheet)
	if raw == nil do return nil, false
	defer free_cell(raw) // the C side malloc'd it

	return parse_cell(string(raw), allocator), true
}
