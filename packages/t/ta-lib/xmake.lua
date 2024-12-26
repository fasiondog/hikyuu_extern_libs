package("ta-lib")
    set_homepage("https://github.com/p-ranav/tabulate")
    set_description("Technical Analysis Library for financial market trading applications")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/TA-Lib/ta-lib/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/TA-Lib/ta-lib.git",
             "https://gitcode.com/KongDong/ta-lib.git")
    add_versions("0.6.2", "6b7c5e575bd3359d46b7103d11637a5d689b9efeae88103d145987a0e7f83316")

    add_deps("cmake >=3.30")

    on_install(function (package)
        io.replace("CMakeLists.txt", "if(NOT DEFINED ENV{SOURCE_DATE_EPOCH})", "if(DEFINED ENV{SOURCE_DATE_EPOCH})", {plain = true})
        io.replace("CMakeLists.txt", "install(TARGETS ta-lib ta-lib-static", "install(TARGETS ta-lib-static", {plain = true})
        io.replace("CMakeLists.txt", "DESTINATION include/ta-lib", "DESTINATION include", {plain = true})
        import("package.tools.cmake").install(package, {"-DBUILD_DEV_TOOLS=OFF"})   
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                TA_Initialize();
                TA_Shutdown();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "ta_libc.h"}))
    end)