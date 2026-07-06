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
/*
GList* g_list_alloc       (void);

void   g_list_free_1      (GList     *list);

GList* g_list_insert      (GList     *list,
                           gpointer   data,
                           gint       position);

GList* g_list_remove      (GList     *list,
                           gpointer   data);
                           
GList* g_list_remove_link (GList     *list,
                           GList     *link);

GList* g_list_reverse     (GList     *list);

GList* g_list_nth         (GList     *list,
                           gint       n);
                           
GList* g_list_find        (GList     *list,
                           gpointer   data);

GList* g_list_first       (GList     *list);

gint   g_list_length      (GList     *list);

void   g_list_foreach     (GList     *list,
                           GFunc      func,
                           gpointer   user_data);*/
}