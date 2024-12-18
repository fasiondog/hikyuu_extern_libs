package("ta-lib")
    set_homepage("https://github.com/p-ranav/tabulate")
    set_description("Technical Analysis Library for financial market trading applications")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/TA-Lib/ta-lib.git",
             "https://gitcode.com/KongDong/ta-lib.git")


    add_deps("cmake >=3.30")

    on_load(function (package)
        if package:config("shared") then
            package:add("defines", "TA_LIB_API=__declspec(dllimport)")
        end
    end)

    on_install(function (package)
        if package:config("shared") then
            io.replace("CMakeLists.txt", "install(TARGETS ta-lib ta-lib-static", "install(TARGETS ta-lib", {plain = true})
        else
            io.replace("CMakeLists.txt", "install(TARGETS ta-lib ta-lib-static", "install(TARGETS ta-lib-static", {plain = true})
        end
        local configs = {"-DBUILD_DEV_TOOLS=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                TA_Initialize();
                TA_Shutdown();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "ta-lib/ta_libc.h"}))
    end)