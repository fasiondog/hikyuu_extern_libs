 
-- the hdf5 package
option("hdf5_D")

    -- show menu
    set_showmenu(true)

    -- set category
    set_category("package")

    -- set description
    set_description("The hdf5 package")

    -- set language: c99, c++11
    set_languages("c99", "cxx11")

    -- add link directories
    add_linkdirs("lib/$(mode)/$(plat)/$(arch)")

    add_defines("H5_BUILT_AS_DYNAMIC_LIB")
    
    -- add links for checking
    add_links("hku_hdf5_D")
    add_links("hku_hdf5_hl_D")
    add_links("hku_hdf5_cpp_D")
    add_links("hku_hdf5_hl_cpp_D")

    -- add c includes for checking
    --add_cincludes("H5Cpp.h")

    -- add include directories
    add_includedirs("inc/$(mode)/$(plat)/$(arch)", "inc")
