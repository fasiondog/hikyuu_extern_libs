package("hku_rest")

    set_homepage("https://github.com/fasiondog/hku_rest.git")
    set_description("C++ http server Library of Hikyuu.")

    add_urls("https://github.com/fasiondog/hku_rest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fasiondog/hku_rest.git")    
    
    add_versions("1.2.0", "f81d8b2a8e047a4d638ae5d1da1a6aca56e7e39fe80af2f270b9375b5e18689e")
    add_versions("1.1.2", "6e660eb344cfafa270b939161a1750b77eb2236652bf82ec115d508e37d5bcd2") --nng

    add_configs("use_hikyuu", {description = "Use the hikyuu.", default = false, type = "boolean"})
    for _, name in ipairs({"mysql"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = true, type = "boolean"})
    end
    for _, name in ipairs({"sqlite", "stacktrace", "async_log", "mqtt"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = false, type = "boolean"})
    end

    on_load(function(package)
        package:add("deps", "openssl3", "tl_expected")
        if package:config("use_hikyuu") then
            package:add("deps", "hikyuu", {
                configs= {shared = true, 
                    mo = true,
                    http_client = true,
                    http_client_zip = true,
                    mysql = package:config("mysql"), 
                    sqlite = package:config("sqlite"),
                    stacktrace =package:config("stacktrace"),}})
        else
            package:add("deps", "hku_utils", {
                configs= {shared = true, 
                    mo = true,
                    http_client = true,
                    http_client_zip = true,
                    mysql = package:config("mysql"), 
                    sqlite = package:config("sqlite"),
                    stacktrace =package:config("stacktrace"),}})
        end
    
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "HKU_HTTPD_API=__declspec(dllimport)")
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        configs["use_hikyuu"] = package:config("use_hikyuu")
        for _, name in ipairs({"mysql", "sqlite", "stacktrace", "async_log"}) do
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
            {configs = {languages = "c++20"}
        }))
    end) 
