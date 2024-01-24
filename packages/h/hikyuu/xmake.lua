package("hikyuu")

    set_homepage("http://hikyuu.org/")
    set_description("High Performance Quant Framework with C++/Python")
    set_license("MIT")

    add_urls("https://gitee.com/fasiondog/hikyuu.git")

    add_configs("hdf5",  { description = "Enable hdf5 kdata engine.", default = true, type = "boolean"})
    add_configs("mysql",  { description = "Enable mysql kdata engine.", default = true, type = "boolean"})
    add_configs("sqlite",  { description = "Enable sqlite kdata engine.", default = true, type = "boolean"})
    add_configs("tdx",  { description = "Enable tdx kdata engine.", default = true, type = "boolean"})
    add_configs("stacktrace",  { description = "Enable check/assert with stack trace info.", default = true, type = "boolean"})

    add_deps("boost", "spdlog", "fmt", "flatbuffers")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        table.insert(configs, "--hdf5=" .. (package:config("hdf5") and "true" or "false"))
        table.insert(configs, "--mysql=" .. (package:config("mysql") and "true" or "false"))
        table.insert(configs, "--sqlite=" .. (package:config("sqlite") and "true" or "false"))
        table.insert(configs, "--tdx=" .. (package:config("tdx") and "true" or "false"))
        table.insert(configs, "--stacktrace=" .. (package:config("stacktrace") and "true" or "false"))

        import("package.tools.xmake").install(package, configs)
    end)

    -- on_test("windows", "linux", "macosx", function (package)
    --     assert(package:check_cxxsnippets({
    --         test = [[
    --         #include <hikyuu/hikyuu.h>
    --         void test() {
    --             StockManager& sm = StockManager::instance();
    --         }
    --         ]]},
    --         {configs = {languages = "c++17"}
    --     }))
    -- end)    


