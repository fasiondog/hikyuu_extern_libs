package("hwloc")

    set_homepage("https://www.open-mpi.org/projects/hwloc/")
    set_description("The Portable Hardware Locality (hwloc) software package provides a portable abstraction.")

    if is_plat("windows") then
        add_urls("https://download.open-mpi.org/release/hwloc/v2.13/hwloc-win64-build-$(version).zip")
        add_versions("2.13.0", "44309472b04f4a27b3a1ed2d9b70280d773a87604470099a954f90a0c1659df4")
    else
        add_urls("https://download.open-mpi.org/release/hwloc/v2.13/hwloc-$(version).tar.gz")
        add_versions("2.13.0", "1514a5253f0a5c23bc006d3bdd30a6f6125c9a8dc9b5fa4984913d1fff45315d")
    end

    on_install("linux", "macosx", function (package)
        if os.isfile("./configure") then
            local configs = {"--prefix=" .. package:installdir()}
            -- if package:config("shared") then
            --     table.insert(configs, "--enable-shared")
            --     table.insert(configs, "--disable-static")
            -- else
            --     table.insert(configs, "--enable-static")
            --     table.insert(configs, "--disable-shared")
            -- end
            -- 直接使用动态库
            table.insert(configs, "--enable-shared")
            table.insert(configs, "--disable-static")        
            os.exec("./configure " .. table.concat(configs, " "), {curdir = package:sourcedir()})
        end        
        import("package.tools.make").make(package, {})
        import("package.tools.make").make(package, {"install"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <hwloc.h>
        #include <iostream>
        void test() {
            hwloc_topology_t topology;
            int depth;
            unsigned int nobjs;

            if (hwloc_topology_init(&topology) < 0) {
                std::cerr << "Error: Failed to init topology" << std::endl;
                return;
            }

            if (hwloc_topology_load(topology) < 0) {
                std::cerr << "Error: Failed to load topology" << std::endl;
                hwloc_topology_destroy(topology);
                return;
            }

            nobjs = hwloc_get_nbobjs_by_type(topology, HWLOC_OBJ_PU);

            std::cout << "Available Logical CPUs: " << nobjs << std::endl;

            // 清理
            hwloc_topology_destroy(topology);
        }
        ]]}))
    end)