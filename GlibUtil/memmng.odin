package main

import "core:fmt"
import "core:slice"

import glib "../gtk4m/glib"


//
// MAIN
//
main :: proc() {

  mem := glib.malloc(1024)
  fmt.printf("glib.malloc: mem=%p [%T]\n", mem, mem)

  typed_ptr := (^u8)(mem)
  // Option A: Using core:slice (Safe/Idiomatic)
  u8_slice := slice.from_ptr(typed_ptr, 1024)
  fmt.printf("u8_slice[0]: %d [%T]\n", u8_slice[0], u8_slice[0])
  for idx :u8 = 0; idx < 16; idx += 1 {
    u8_slice[idx] = idx
  }
  fmt.printf("u8_slice[0:16]: %v\n", u8_slice[0:16])
  
  // Option B: Inline conversion
  u8_array := ([^]u8)(mem)[:1024]
  fmt.printf("u8_array: [%T]\n", u8_array)
  fmt.printf("u8_array[0:16]: %v\n", u8_array[0:16])

  glib.free(mem)

  mem0 := glib.malloc0(512)
  fmt.printf("glib.malloc0: mem0=%p [%T]\n", mem0, mem0)
  
  mem0 = glib.realloc(mem0, 1024)
  u8_arrayr := ([^]u8)(mem0)[:1024]
  u8_arrayr[1023] = 111
  fmt.printf("u8_arrayr[1023]: %v [%T]\n", u8_arrayr[1023], u8_arrayr[1023])

  glib.free(mem0)

/*
    void     g_mem_profile (void);
Dumps a profile of used memory, but requries that you add #define MEM_PROFILE to the top of glib/gmem.c and re-make and make install.

    void     g_mem_check   (gpointer  mem);
Checks that a memory location is valid. Requires you add #define MEM_CHECK to the top of gmem.c and re-make and make install.
*/
}
