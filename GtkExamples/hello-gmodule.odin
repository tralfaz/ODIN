package main

import "core:os"

import glib "../gtk4m/glib"
import gmod "../gtk4m/gmodule"


//
// MAIN
//
main :: proc() {
    module: ^gmod.Module
    g_print_proc: #type proc "c" (format: cstring, #c_vararg var_args: ..any)

    PLUGIN_PATH :: "/opt/homebrew/lib/libglib-2.0.dylib"

    // Initialize the GModule system
    if !gmod.supported() {
        glib.printerr(
            "Dynamic module loading is not supported on this platform.\n",
        )
        os.exit(1)
    }

    // Load the shared library
    module = gmod.open(PLUGIN_PATH, .BIND_LAZY)
    if module == nil {
        glib.printerr("Failed to load module: %s\n", gmod.error())
        os.exit(1)
    }
    defer gmod.close(module)

    // Look up the "hello_plugin" function
    if !gmod.symbol(module, "g_print", cast(^glib.pointer)&g_print_proc) {
        glib.printerr(
            "Failed to find symbol 'hello_plugin': %s\n",
            gmod.error(),
        )
        os.exit(1)
    }

    // Call the function
    g_print_proc("hello from loaded module procedure: %d\n", 25)
}

