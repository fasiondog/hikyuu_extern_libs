package("clickhouse-cpp")

    set_homepage("https://github.com/ClickHouse/clickhouse-cpp")
    set_description("C++ client for ClickHouse.")
    set_license("Apache-2.0 license ")

    add_urls("https://github.com/ClickHouse/clickhouse-cpp.git")
    add_versions("2025.06.24", "cae657a672ff09b715d7127b13eb25d63bea01d4")

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