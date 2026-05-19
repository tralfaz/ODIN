package main

import "core:fmt"
import "core:time"

import glib "../../glib"


main :: proc() {
    context = glib.create_context()

    glib.set_print_handler(proc "c" (msg: cstring) {
        context = glib.create_context()
        fmt.printfln("[GLIB PRINT]: {}", msg)
    })
    glib.print("Hello g_print!\n")
    glib.printerr("Hello g_print_err!\n")

    environ := cast([^]cstring)glib.get_environ()
    defer glib.strfreev(environ)
    for i := 0; environ[i] != nil; i += 1 {
        glib.print("%d: %s", i, environ[i])
    }

    hello_thread := glib.thread_new(
        "hello thread",
        proc "c" (data: glib.pointer) -> glib.pointer {
            context = glib.create_context()
            for i in 0 ..< 10 {
                time.sleep(100 * time.Millisecond)
                glib.print("Hello from thread %d", i)
            }

            glib.thread_exit(nil)
            return nil
        },
        nil,
    )

    time.sleep(500 * time.Millisecond)
    glib.print("Hello from main")

    glib.thread_join(hello_thread)
}

