package main

import "core:fmt"

import glib "../gtk4m/glib"


//
// MAIN
//
main :: proc() {

  // 1. Initialize an empty list
  list : ^glib.SList = nil

  // 2. Add elements
  // Note: Most functions return the new start of the list
  first  :cstring = "First"
  second :cstring = "Second"
  zero  :cstring = "Zero"
  list = glib.slist_append(list, glib.pointer(first))
  list = glib.slist_append(list, glib.pointer(second))
  list = glib.slist_prepend(list, glib.pointer(zero))

  // 3. Traverse the list forward
  fmt.printf("Forward traversal:\n");
  for iter :^glib.SList = list; iter != nil; iter = iter.next {
    fmt.printf(" - %s\n", cast(cstring)iter.data)
  }

  // 4. Find an item
  found :^glib.SList = glib.slist_find(list, glib.pointer(second))
  if found != nil {
    fmt.printf("\nFound: %s\n",cast(cstring)found.data)
  }

  // 5. Free the list structure
  // If data was dynamically allocated (e.g., g_strdup), free data first
  glib.slist_free(list)

  //return 0
}