package xlsx

import "core:c"
import "core:c/libc"

foreign import write_lib {"build/" + XLSX_WRITE_LIB_NAME, "system:zip"}

Writer :: distinct rawptr

@(default_calling_convention = "c")
foreign write_lib {
//odinfmt: disable
@(link_name = "xlsxiowrite_get_version")            write_get_version :: proc(major, minor, micro: ^c.int)                      ---
@(link_name = "xlsxiowrite_get_version_string")     write_get_version_string :: proc() -> cstring                               ---

@(link_name = "xlsxiowrite_open")                   write_open :: proc(filename, sheet_name: cstring) -> Writer                 ---
@(link_name = "xlsxiowrite_close")                  write_close :: proc(handle: Writer) -> c.int                                ---

@(link_name = "xlsxiowrite_set_detection_rows")     write_set_detection_rows :: proc(handle: Writer, rows: c.size_t)            ---
@(link_name = "xlsxiowrite_set_row_height")         write_set_row_height :: proc(handle: Writer, height: c.size_t)              ---
@(link_name = "xlsxiowrite_next_row")               write_next_row :: proc(handle: Writer) ---

@(link_name = "xlsxiowrite_add_column")             write_add_column :: proc(handle: Writer, name: cstring, width: c.int)       ---

@(link_name = "xlsxiowrite_add_cell_string")        write_add_cell_string :: proc(handle: Writer, value: cstring)               ---
@(link_name = "xlsxiowrite_add_cell_int")           write_add_cell_int :: proc(handle: Writer, value: i64)                      ---
@(link_name = "xlsxiowrite_add_cell_float")         write_add_cell_float :: proc(handle: Writer, value: f64)                    ---
@(link_name = "xlsxiowrite_add_cell_datetime")      write_add_cell_datetime :: proc(handle: Writer, value: libc.time_t)         ---
//odinfmt: enable
}
