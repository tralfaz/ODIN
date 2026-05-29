package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


ListBoxRowWithData :: proc(data :cstring) -> ^gtk.Widget {
  lbrow := gtk.list_box_row_new()
  label := gtk.label_new(data)
  gtk.list_box_row_set_child(cast(^gtk.ListBoxRow)lbrow, label)
  return lbrow
}

LB2SortFunc :: proc "c" (row1 :^gtk.ListBoxRow,
                         row2 :^gtk.ListBoxRow,
                         user_data: glib.pointer) -> i32 {
  context = runtime.default_context()
  r1kid := gtk.list_box_row_get_child(row1)
//  r1ilk := r1kid.get_type()
  r2kid := gtk.list_box_row_get_child(row2)
//  r2ilk := gtk.widget_get_type(r2kid)
//  return row_1.data.lower() > row_2.data.lower()
  fmt.printf("LB2SortFunc: r1kid %v [%T]\n", r1kid, r1kid)
  fmt.printf("           : r1kid.g_class %v [%T]\n", r1kid.parent_instance.g_type_instance.g_class, r1kid.parent_instance.g_type_instance.g_class)
  return 0
}

LB2FilterFunc :: proc "c" (row :^gtk.ListBoxRow,
                           user_data: glib.pointer) -> glib.boolean {
//        return row.data != "Fail"
  return true
}



OnRowActivatedCB :: proc "c" (listbox : ^gtk.ListBox, row :^gtk.ListBoxRow) {
//Button1ClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
//  appwin := cast(^gtk.Window)cbData
  fmt.printf("OnRowActivatedCB: listbox %p [%T]\n", listbox, listbox)
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "ListBox Example")
  gtk.window_set_default_size(appwin, 400, 250)

  // Main box of outer window
  box_outer := gtk.box_new(orientation=gtk.Orientation.VERTICAL,
                           spacing=24)
  gtk.widget_set_margin_start(box_outer,  margin=24)
  gtk.widget_set_margin_end(box_outer,    margin=24)
  gtk.widget_set_margin_top(box_outer,    margin=24)
  gtk.widget_set_margin_bottom(box_outer, margin=24)
  gtk.window_set_child(appwin, box_outer)

  // Let's create our first ListBox
  listbox := gtk.list_box_new()
  gtk.list_box_set_selection_mode(cast(^gtk.ListBox)listbox,
                                  gtk.SelectionMode.SELECTION_NONE)
  gtk.list_box_set_show_separators(cast(^gtk.ListBox)listbox, true)
  gtk.box_append(cast(^gtk.Box)box_outer, listbox)

  // Let's create our first ListBoxRow
  row := gtk.list_box_row_new()
  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=24)
  gtk.list_box_row_set_child(cast(^gtk.ListBoxRow)row, hbox)

  // We set the Box as the ListBoxRow child
  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=0)
  gtk.box_append(cast(^gtk.Box)hbox, vbox)
  label1 := gtk.label_new("Automatic Date & Time")
  gtk.label_set_xalign(cast(^gtk.Label)label1, 0)
  label2 := gtk.label_new("Requires internet access")
  gtk.label_set_xalign(cast(^gtk.Label)label2, 0)
  gtk.box_append(cast(^gtk.Box)vbox, label1)
  gtk.box_append(cast(^gtk.Box)vbox, label2)

  switchwgt := gtk.switch_new()
  gtk.widget_set_hexpand(switchwgt, expand=true) // make Switch expand to window width
  gtk.widget_set_halign(switchwgt, align=gtk.Align.END) // Horz aligned to end
  gtk.widget_set_valign(switchwgt, align=gtk.Align.CENTER) // Vert align to center
  gtk.box_append(cast(^gtk.Box)hbox, switchwgt)

  gtk.list_box_append(cast(^gtk.ListBox)listbox, row)

  // Our second row. We will omit the ListBoxRow and directly append a Box
  hbox = gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=24)
  label := gtk.label_new("Enable Automatic Update")
  gtk.label_set_xalign(cast(^gtk.Label)label, 0)
  check := gtk.check_button_new()
  gtk.widget_set_halign(check, align=gtk.Align.END)
  gtk.widget_set_hexpand(check, expand=true)
  gtk.box_append(cast(^gtk.Box)hbox, check)
  gtk.list_box_append(cast(^gtk.ListBox)listbox, hbox)// Add second row to list

  // Let's create a second ListBox
  listbox_2 := gtk.list_box_new()
  gtk.box_append(cast(^gtk.Box)box_outer, listbox_2)
  items := [?]cstring{"This", "is", "a", "sorted", "ListBox", "Fail"}

  // Populate the list
  for item in items {
    gtk.list_box_append(cast(^gtk.ListBox)listbox_2,
                        ListBoxRowWithData(item))
  }

  // Set sorting and filter functions
//        listbox_2.set_sort_func(self.sort_func)
  gtk.list_box_set_sort_func(cast(^gtk.ListBox)listbox_2, LB2SortFunc, nil, nil)
//                     user_data: glib.pointer, destroy: glib.DestroyNotify) ---
  gtk.list_box_set_filter_func(cast(^gtk.ListBox)listbox_2, LB2FilterFunc, nil, nil)
//                               user_data: glib.pointer, destroy: glib.DestroyNotify) ---
  // Connect to "row-activated" signal
  gobj.signal_connect(listbox_2, "row-activated",
                      cast(gobj.Callback)OnRowActivatedCB, nil)

  gtk.window_present(appwin)
}



//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.FontDialog",
                             gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
  gobj.signal_connect(app, "activate",
                      cast(gobj.Callback)AppActivateCB,
                      cast(glib.pointer)&cbArg)

  argv := make([]cstring, len(os.args))
  for &arg, idx in argv {
    arg = strings.clone_to_cstring(os.args[idx])
  }
  defer delete(argv)
  defer for arg in argv do delete(arg)
  argc := i32(len(argv))

  sts := gio.application_run(
             gobj.type_cast(gio.Application, app, gio.TYPE_APPLICATION()),
             argc, raw_data(argv))      
  gobj.object_unref(app)

  if sts != 0 {
    os.exit(int(sts))
  }
}      
