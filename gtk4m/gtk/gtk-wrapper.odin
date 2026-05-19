#+build darwin arm64, linux amd64, linux arm64, windows amd64
package gtk

//import "../cairo"
//import "../glib"
//import "../gio"
//import "../graphene"
//import "../pango"
//import gdk "../gdk-pixbuf"
//import gobj "../gobject"

when ODIN_OS == .Darwin  do foreign import libgtk4 "../LIBS/libgtk-4.dylib"


@(default_calling_convention = "c")
foreign libgtk4 {
//    @(link_name = "gtk_application_window_new")
//    application_window_new :: proc(application :^Application) -> ^Widget ---

}