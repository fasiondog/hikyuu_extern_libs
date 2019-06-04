target("sqlite3")
    set_kind("shared")

    add_defines("SQLITE_API=__declspec(dllexport)")
  
    add_headerfiles("*.h")
    add_files("sqlite3.c")