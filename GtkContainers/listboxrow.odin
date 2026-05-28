package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


RowButtonClickedCB :: proc "c" (button :^gtk.Button,
                                cbData :glib.pointer)
{
  context = runtime.default_context()
  fmt.printf("RowButtonClickedCB: button %p [%T]\n", button, button)
  row := cast(^gtk.ListBoxRow)cbData
  fmt.printf("                  : row %p [%T]\n", row, row)
}

// Callback when a row is selected or clicked (activated)
OnRowActivatedCB :: proc "c" (list :^gtk.ListBox,
                              row :^gtk.ListBoxRow,
                              cbData :glib.pointer)
{
  context = runtime.default_context()
  fmt.printf("OnRowActivatedCB: list %p [%T]\n", list, list)
  fmt.printf("                : row %p [%T]\n", row, row)
  fmt.printf("                : row index %d\n",
             gtk.list_box_row_get_index(row))
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "GtkListBox Example")
  gtk.window_set_default_size(appwin, 300, 200)

  // Create the ListBox
  list_box := gtk.list_box_new()
  gtk.list_box_set_selection_mode(cast(^gtk.ListBox)list_box,
                                  gtk.SelectionMode.SELECTION_SINGLE)
    
  // Connect activation signal
  gobj.signal_connect(list_box, "row-activated",
                      cast(gobj.Callback)OnRowActivatedCB, nil)

  // Example 1: Appending a simple widget (GTK wraps it in a GtkListBoxRow automatically)
  label := gtk.label_new("Simple Label Row");
  gtk.list_box_append(cast(^gtk.ListBox)list_box, label)

  // Example 2: Creating a custom complex row manually
  row := gtk.list_box_row_new()
  box := gtk.box_new(gtk.Orientation.HORIZONTAL, 10)
  row_label := gtk.label_new("Complex Row:")
  button := gtk.button_new_with_label("Click Me")
  gobj.signal_connect(button, "clicked",
                      cast(gobj.Callback)RowButtonClickedCB, row)
    
  gtk.box_append(cast(^gtk.Box)box, row_label)
  gtk.box_append(cast(^gtk.Box)box, button)
  gtk.list_box_row_set_child(cast(^gtk.ListBoxRow)row, box)
  gtk.list_box_append(cast(^gtk.ListBox)list_box, row)

  // Add list to a scrolled window and then to the main window
  scrolled := gtk.scrolled_window_new()
  gtk.scrolled_window_set_child(cast(^gtk.ScrolledWindow)scrolled, list_box)
  gtk.window_set_child(appwin, scrolled)

  gtk.window_present(appwin)
}



//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.listboxrow",
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
