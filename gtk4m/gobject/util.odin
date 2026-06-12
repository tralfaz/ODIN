#+build darwin amd64, darwin arm64, linux amd64, linux arm64, windows amd64
package gobject

/*
array_union_anon_0 :: struct #raw_union {
    v_int: glib.int_,
    v_uint: glib.uint_,
    v_long: glib.long,
    v_ulong: glib.ulong,
    v_int64: glib.int64,
    v_uint64: glib.uint64,
    v_float: glib.float,    v_double: glib.double,
    v_pointer: glib.pointer,
}
_GValue :: struct {
    g_type: Type,
    data: [2]array_union_anon_0,
}
*/
set_string_property :: proc(obj :^Object, name :cstring, value :cstring) {
  strPropVal := Value{g_type=TYPE_STRING}
  strPropVal.data[0].v_pointer = rawptr(value)
  strPropVal.data[1].v_pointer = nil
  object_set_property(obj, name, &strPropVal)
}

set_boolean_property :: proc(obj :^Object, name :cstring, value :b32) {
  boolPropVal := Value{g_type=TYPE_BOOLEAN}
  boolPropVal.data[0].v_int = i32(value)
  boolPropVal.data[1].v_pointer = nil
  object_set_property(obj, name, &boolPropVal)
}

set_int_property :: proc(obj :^Object, name :cstring, value :i32) {
  intPropVal := Value{g_type=TYPE_INT}
  intPropVal.data[0].v_int = value
  intPropVal.data[1].v_pointer = nil
  object_set_property(obj, name, &intPropVal)
}
