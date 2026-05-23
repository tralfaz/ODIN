package main

import "core:fmt"

import glib "../gtk4m/glib"


//
// MAIN
//
main :: proc() {

  // 1. Initialize an empty list
  list : ^glib.List = nil

  // 2. Add elements (always reassign 'list' to the returned pointer)
  first  :cstring = "First"
  second :cstring = "Second"
  zero  :cstring = "Zero"
  list = glib.list_append(list, glib.pointer(first))
  list = glib.list_append(list, glib.pointer(second))
  list = glib.list_prepend(list, glib.pointer(zero))

  // 3. Traverse the list forward
  fmt.printf("Forward traversal:\n");
  for iter :^glib.List = list; iter != nil; iter = iter.next {
    fmt.printf(" - %s\n", cast(cstring)iter.data)
  }

  // 4. Access the last element and traverse backward
  fmt.printf("Backward traversal:\n");
  last := glib.list_last(list)
  for iter :^glib.List = last; iter != nil; iter = iter.prev {
    fmt.printf(" - %s\n", cast(cstring)iter.data)
  }

  // 5. Free the memory used by the list
  glib.list_free(list)

  //return 0
}