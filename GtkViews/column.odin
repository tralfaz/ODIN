package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


AppStartupCB :: proc "c" (app :^gtk.Application) {
  build := gtk.builder_new_from_file("./column.ui")
  win := cast(^gtk.Widget)gtk.builder_get_object(build, "win")
  directorylist := cast(^gtk.DirectoryList)gtk.builder_get_object(build,
                                                              "directorylist")
  gobj.object_unref(build)

  gtk.window_set_application (cast(^gtk.Window)win, app)

  file := gio.file_new_for_path(".")
  gtk.directory_list_set_file(directorylist, file)
  gobj.object_unref(file)
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()
  fmt.printf("AppActivateCB:\n")
  gtk.window_present(gtk.application_get_active_window(app))
}


/* functions (closures) for GtkBuilderListItemFactory */
@(export, link_name="get_icon_factory")
get_icon_factory :: proc "c" (item :^gtk.ListItem,
                              info :^gio.FileInfo) -> ^gio.Icon {
  icon :^gio.Icon = nil
  if info != nil {
    /* g_file_info_get_icon can return NULL */
    icon = gio.file_info_get_icon(info)
    if icon != nil {
      gobj.object_ref(icon)
      return icon
    }
  }
  return nil
}

@(export, link_name="get_file_name_factory")
get_file_name_factory :: proc "c" (item :^gtk.ListItem,
                                   info :^gio.FileInfo) -> cstring {
//  context = runtime.default_context()
//  fmt.printf("get_file_name_factury: item=%p info=%p\n", item, info)

  if info != nil {
//    fmt.printf("file_info_get_name: %s \n", gio.file_info_get_name(info))
    return glib.strdup(gio.file_info_get_name(info))
  }
  return nil
}

/* goffset is defined as gint64 */
/* It is used for file offsets. */
@(export, link_name="get_file_size_factory")
get_file_size_factory :: proc "c" (item :^gtk.ListItem,
                                   info :^gio.FileInfo) -> glib.offset {
  if info != nil {
    return gio.file_info_get_size(info)
    }
  return -1
}

@(export, link_name="get_file_time_modified_factory")
get_file_time_modified_factory :: proc "c" (item :^gtk.ListItem,
                                            info :^gio.FileInfo) -> cstring {
  dt :^glib.DateTime = nil
  if info != nil {
  /* g_file_info_get_modification_date_time can return NULL */
  dt := gio.file_info_get_modification_date_time(info)
    if dt != nil {
      return glib.date_time_format(dt, "%F")
    }
  }
  return nil
}

/* Functions (closures) for GtkSorter */
@(export, link_name="get_file_name")
get_file_name :: proc "c" (info :^gio.FileInfo) -> cstring {
  context = runtime.default_context()
  fmt.printf("get_file_name: info=%p\n", info)

  if info != nil {
    return glib.strdup(gio.file_info_get_name(info))
  }
  return nil
}

@(export, link_name="get_file_size")
get_file_size :: proc "c" (info :^gio.FileInfo) -> glib.offset {
  if info != nil {
    gio.file_info_get_size(info)
  }
  return -1
}

@(export, link_name="get_file_unixtime_modified")
get_file_unixtime_modified :: proc "c" (info :^gio.FileInfo) -> glib.int64 {
  dt :^glib.DateTime = nil
  if info != nil {
    dt := gio.file_info_get_modification_date_time(info)
    if dt != nil {
      return glib.date_time_to_unix(dt)
    }
  }
  return -1
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.github.ToshioCP.columnview",
                             gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
  gobj.signal_connect(app, "startup",
                      cast(gobj.Callback)AppStartupCB,
                      cast(glib.pointer)&cbArg)
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
