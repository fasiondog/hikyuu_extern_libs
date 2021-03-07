 
option("mysql")

    -- show menu
    set_showmenu(true)

    -- set category
    set_category("package")

    -- set description
    set_description("The mysql package")

    -- set language: c99, c++11
    set_languages("c99", "cxx11")

    -- add links for checking
    add_links("libmysql")
    
    -- add link directories
    add_linkdirs("lib/$(mode)/$(plat)/$(arch)")

    -- add c includes for checking
    --add_cincludes("mysql.h")

    -- add include directories
    add_includedirs("inc/$(mode)/$(plat)/$(arch)", "inc")
    
    
