package("clickhouse-cpp")

    set_homepage("https://github.com/ClickHouse/clickhouse-cpp")
    set_description("C++ client for ClickHouse.")
    set_license("Apache-2.0 license ")

    add_urls("https://github.com/ClickHouse/clickhouse-cpp/archive/refs/tags/v$(version).tar.gz")
    add_versions("2.6.0", "f694395ab49e7c2380297710761a40718278cefd86f4f692d3f8ce4293e1335f")

    add_deps("cmake", "zstd")

    if is_plat("windows") then 
        add_syslinks("ws2_32")
    end

    on_load(function(package)
        package:add("links", "clickhouse-cpp-lib", "lz4", "zstdstatic", "cityhash", "absl_int128")
    end)

    on_install("windows", "macosx", "linux", "mingw@windows", function (package)
        local configs = {"-DWITH_SYSTEM_ZSTD=ON"}
        import("package.tools.cmake").install(package, configs)
        os.cp("contrib/absl/absl", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            //#include <clickhouse/client.h>
            using namespace clickhouse;
            void test() {
                Client client(ClientOptions().SetHost("localhost"));
            }
        ]]}, {configs = {languages = "c++17"}, includes = "clickhouse/client.h"}))
    end)