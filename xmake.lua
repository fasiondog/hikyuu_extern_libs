-- set warning all as error
set_warnings("all", "error")
--set_warnings("all")

-- set language: C99, c++ standard
-- must set c99, other sqlite3 will not generate .lib
set_languages("C99", "cxx17")

-- disable some compiler errors
add_cxflags("-Wno-error=deprecated-declarations", "-fno-strict-aliasing")
add_mxflags("-Wno-error=deprecated-declarations", "-fno-strict-aliasing")

set_objectdir("$(buildir)/$(mode)/$(plat)/$(arch)/.objs")
set_targetdir("$(buildir)/$(mode)/$(plat)/$(arch)/lib")
set_headerdir("$(buildir)/$(mode)/$(plat)/$(arch)/inc")

--add_includedirs("$(env BOOST_ROOT)")
--add_linkdirs("$(env BOOST_LIB)")

if is_mode("debug") then
    set_symbols("debug")
    set_optimize("none")
end

-- is release now
if is_mode("release") then
    set_symbols("hidden")
    set_optimize("fastest")
    set_strip("all")
end

-- for the windows platform (msvc)
if is_plat("windows") then 

    -- add some defines only for windows
    add_defines("NOCRYPT", "NOGDI")

    add_cxflags("-EHsc")
    
    if is_mode("release") then
        add_cxflags("-MD") 
    elseif is_mode("debug") then
        add_cxflags("-Gs", "-RTC1") 
        add_cxflags("-MDd") 
    end
end

add_vectorexts("sse", "sse2", "sse3", "ssse3", "mmx", "neon", "avx", "avx2")

add_subdirs("./src/sqlite3")