$ where = f$environment("PROCEDURE")
$ where = f$parse(where,,, "DEVICE") + f$parse(where,,, "DIRECTORY")
$ set def 'where'
