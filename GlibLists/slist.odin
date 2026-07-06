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
/*
GSList* g_slist_alloc       (void);

void    g_slist_free_1      (GSList   *list);

GSList* g_slist_insert      (GSList   *list,
                             gpointer  data,
                             gint      position);
                             
GSList* g_slist_remove      (GSList   *list,
                             gpointer  data);
                             
GSList* g_slist_remove_link (GSList   *list,
                             GSList   *link);
                             
GSList* g_slist_reverse     (GSList   *list);

GSList* g_slist_nth         (GSList   *list,
                             gint      n);
                             
GSList* g_slist_last        (GSList   *list);

gint    g_slist_length      (GSList   *list);

void    g_slist_foreach     (GSList   *list,
                             GFunc     func,
                             gpointer  user_data);
*/
}