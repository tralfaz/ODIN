package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


CopyTextCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  entbuf := gtk.entry_get_buffer(V_entry)
  enttxt := gtk.entry_buffer_get_text(entbuf)
  gtk.gdk_clipboard_set_text(V_clipboard, enttxt)
}

PasteTextCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
gtk.gdk_clipboard_read_text_async(V_clipboard, nil, ClipboardPasteTextCB, nil)
}

ClipboardPasteTextCB :: proc "c" (srcobj :^gobj.Object, ares :[^]gio.AsyncResult,
                                 cbData :glib.pointer) {
  errptr :^glib.Error = nil
  text := gtk.gdk_clipboard_read_text_finish(V_clipboard, ares, &errptr)
  if text != nil {
    entbuf := gtk.entry_get_buffer(V_entry)
    txtlen := i32(len(string(text)))
    gtk.entry_buffer_set_text(entbuf, text, txtlen)
  }  
}

CopyImageCB  :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  texture := gtk.picture_get_paintable(cast(^gtk.Picture)V_picture)
  gbytes := gtk.gdk_texture_save_to_png_bytes(cast(^gtk.Texture)texture)
  content := gtk.gdk_content_provider_new_for_bytes("image/png", gbytes)// -> ^ContentProvider
  status := gtk.gdk_clipboard_set_content(V_clipboard, content)
}

PasteImageCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  gtk.gdk_clipboard_read_texture_async(V_clipboard, nil,
                                       ClipboardPasteImageCB, nil)
}

ClipboardPasteImageCB :: proc "c" (srcobj :^gobj.Object,
                                   ares :[^]gio.AsyncResult,
                                   cbData :glib.pointer) {
  errptr :^glib.Error = nil
  texture := gtk.gdk_clipboard_read_texture_finish(V_clipboard, ares, &errptr)
  if texture != nil {
    gtk.picture_set_paintable(cast(^gtk.Picture)V_picture, cast(^gtk.Paintable)texture)
  }
}


V_clipboard :^gtk.Clipboard = nil
V_entry     :^gtk.Entry = nil
V_picture   :^gtk.Widget = nil

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Clipboard Example")
  gtk.window_set_default_size(appwin, 500, 150)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=12)
  gtk.window_set_child(appwin, vbox)

  dfltdsp := gtk.gdk_display_get_default()
  V_clipboard = gtk.gdk_display_get_clipboard(dfltdsp)

  text_box := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.box_set_homogeneous(cast(^gtk.Box)text_box, true)
  gtk.box_append(cast(^gtk.Box)vbox, text_box)

  entwgt := gtk.entry_new()
  V_entry = cast(^gtk.Entry)entwgt
  entbuf := gtk.entry_get_buffer(V_entry)
  buftxt :cstring = "Some text you can copy"
  txtlen := i32(len(string(buftxt)))
  gtk.entry_buffer_set_text(entbuf, buftxt, txtlen)

  button_copy_text := gtk.button_new_with_label("Copy Text")
  gobj.signal_connect(button_copy_text, "clicked",
                     cast(gobj.Callback)CopyTextCB, appwin)

  button_paste_text := gtk.button_new_with_label("Paste Text")
  gobj.signal_connect(button_paste_text, "clicked",
                     cast(gobj.Callback)PasteTextCB, appwin)

  gtk.box_append(cast(^gtk.Box)text_box, entwgt)
  gtk.box_append(cast(^gtk.Box)text_box, button_copy_text)
  gtk.box_append(cast(^gtk.Box)text_box, button_paste_text)

  image_box := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.box_append(cast(^gtk.Box)vbox, image_box)

  V_picture = gtk.picture_new_for_filename("application.png")
  V_picture = gtk.picture_new_for_filename("gossamer.jpg")
  gtk.widget_set_hexpand(V_picture, true)

  button_copy_image := gtk.button_new_with_label("Copy Image")
  gtk.widget_set_valign(button_copy_image, gtk.Align.CENTER)
  gobj.signal_connect(button_copy_image, "clicked",
                     cast(gobj.Callback)CopyImageCB, nil)

  button_paste_image := gtk.button_new_with_label("Paste Image")
  gtk.widget_set_valign(button_paste_image, gtk.Align.CENTER)
  gobj.signal_connect(button_paste_image, "clicked",
                     cast(gobj.Callback)PasteImageCB, nil)

  gtk.box_append(cast(^gtk.Box)image_box, V_picture)
  gtk.box_append(cast(^gtk.Box)image_box, button_copy_image)
  gtk.box_append(cast(^gtk.Box)image_box, button_paste_image)

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

