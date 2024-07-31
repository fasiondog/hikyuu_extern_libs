package("hku_rest")

    set_homepage("https://github.com/fasiondog/hku_rest.git")
    set_description("C++ http server Library of Hikyuu.")

    add_urls("https://github.com/fasiondog/hku_rest/archive/refs/tags/$(version).zip",
             "https://github.com/fasiondog/hku_rest.git")    
    add_versions("1.0.0", "a6b0a2858ce30bfddcfa3aae90d574848b2a74f98ef0210beef8e23ed94a0475")

    for _, name in ipairs({"mysql"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = true, type = "boolean"})
    end
    for _, name in ipairs({"sqlite", "stacktrace"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = false, type = "boolean"})
    end

    on_load(function(package)
        package:add("deps", "hku_utils", {
            configs= {shared = true, 
                mo = true,
                http_client = true,
                http_client_zip = true,
                mysql = package:config("mysql"), 
                sqlite = package:config("sqlite"),
                stacktrace =package:config("stacktrace"),}})
    
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "HKU_HTTPD_API=__declspec(dllimport)")
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        for _, name in ipairs({"mysql", "sqlite", "stacktrace"}) do
            configs[name] = package:config(name)
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test("windows", "linux", "macosx", function (package)
        assert(package:check_cxxsnippets({
            test = [[
            #include <hikyuu/utilities/Log.h>
            #include <hikyuu/httpd/HttpServer.h>
            using namespace hku;
            void test() {
                HttpServer server("http://*", 8080);
            }
            ]]},
            {configs = {languages = "c++17"}
        }))
    end) 
