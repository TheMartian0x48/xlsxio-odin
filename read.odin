package xlsx

import "core:c"
import "core:c/libc"

foreign import read_lib {"build/" + XLSX_READ_LIB_NAME, "system:expat", "system:zip"}

Reader :: distinct rawptr
Sheet_List :: distinct rawptr
Sheet :: distinct rawptr

Skip_Flag :: enum c.uint {
	Empty_Rows  = 0, // skip empty rows (cells may look empty yet contain data)
	Empty_Cells = 1, // skip empty cells
	Extra_Cells = 2, // skip cells right of the rightmost header cell
	Hidden_Rows = 3, // skip hidden rows
}
Skip_Flags :: bit_set[Skip_Flag;c.uint]

SKIP_NONE :: Skip_Flags{}
SKIP_ALL_EMPTY :: Skip_Flags{.Empty_Rows, .Empty_Cells}

List_Sheets_Callback :: #type proc "c" (name: cstring, user_data: rawptr) -> c.int
Cell_Callback :: #type proc "c" (row, col: c.size_t, value: cstring, user_data: rawptr) -> c.int
Row_Callback :: #type proc "c" (row, max_col: c.size_t, user_data: rawptr) -> c.int

@(default_calling_convention = "c")
foreign read_lib {
    //odinfmt: disable
@(link_name="xlsxioread_get_version")                   get_version                         :: proc(major, minor, micro: ^c.int) ---
@(link_name="xlsxioread_get_version_string")            get_version_string                  :: proc() -> cstring ---

@(link_name="xlsxioread_open")                          open                                :: proc(filename: cstring) -> Reader ---
@(link_name="xlsxioread_open_filehandle")               open_filehandle                     :: proc(filehandle: c.int) -> Reader ---
@(link_name="xlsxioread_open_memory")                   open_memory                         :: proc(data: rawptr, data_len: u64, free_data: c.int) -> Reader ---
@(link_name="xlsxioread_close")                         close                               :: proc(handle: Reader) ---

@(link_name="xlsxioread_list_sheets")                   list_sheets                         :: proc(handle: Reader, callback: List_Sheets_Callback, user_data: rawptr) ---

@(link_name="xlsxioread_process")                       process                             :: proc(handle: Reader, sheet_name: cstring, flags: Skip_Flags, cell_callback: Cell_Callback, row_callback: Row_Callback, user_data: rawptr) -> c.int ---

@(link_name="xlsxioread_sheetlist_open")                sheetlist_open                      :: proc(handle: Reader) -> Sheet_List ---
@(link_name="xlsxioread_sheetlist_close")               sheetlist_close                     :: proc(list: Sheet_List) ---
@(link_name="xlsxioread_sheetlist_next")                sheetlist_next                      :: proc(list: Sheet_List) -> cstring ---

@(link_name="xlsxioread_sheet_last_row_index")          sheet_last_row_index                :: proc(sheet: Sheet) -> c.size_t ---
@(link_name="xlsxioread_sheet_last_column_index")       sheet_last_column_index             :: proc(sheet: Sheet) -> c.size_t ---
@(link_name="xlsxioread_sheet_flags")                   sheet_flags                         :: proc(sheet: Sheet) -> Skip_Flags ---

@(link_name="xlsxioread_sheet_open")                    sheet_open                          :: proc(handle: Reader, sheet_name: cstring, flags: Skip_Flags) -> Sheet ---
@(link_name="xlsxioread_sheet_close")                   sheet_close                         :: proc(sheet: Sheet) ---
@(link_name="xlsxioread_sheet_next_row")                sheet_next_row                      :: proc(sheet: Sheet) -> c.int ---

@(link_name="xlsxioread_sheet_next_cell")               sheet_next_cell                     :: proc(sheet: Sheet) -> cstring ---
@(link_name="xlsxioread_free")                          free_cell                           :: proc(data: cstring) ---

@(link_name="xlsxioread_sheet_next_cell_string")        sheet_next_cell_string              :: proc(sheet: Sheet, value: ^cstring) -> c.int ---
@(link_name="xlsxioread_sheet_next_cell_int")           sheet_next_cell_int                 :: proc(sheet: Sheet, value: ^i64) -> c.int ---
@(link_name="xlsxioread_sheet_next_cell_float")         sheet_next_cell_float               :: proc(sheet: Sheet, value: ^f64) -> c.int ---
@(link_name="xlsxioread_sheet_next_cell_datetime")      sheet_next_cell_datetime            :: proc(sheet: Sheet, value: ^libc.time_t) -> c.int ---

    //odinfmt: enable
}
