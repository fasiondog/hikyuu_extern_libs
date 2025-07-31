package("hku_rest")

    set_homepage("https://github.com/fasiondog/hku_rest.git")
    set_description("C++ http server Library of Hikyuu.")

    add_urls("https://github.com/fasiondog/hku_rest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fasiondog/hku_rest.git")    
    
    add_versions("1.0.9", "6a28a486e716236a1c8eefec5663744a195f08e646be0bab787b6e304772db1a")
    add_versions("1.0.8", "168e4ded1046e31a8bd5195c3eebdf2bf11deeb1528f73671983a473ebd0b80e")
    add_versions("1.0.7", "29dbc80548b8c0d91494423fa72d10ba4bf4f147ebf4b91de8978741636e8196")
    add_versions("1.0.6", "2a3a42f5cea07c8601480bb8ea50cabdfa6cbd966d2260639bd92e5e6264dd3c")
    add_versions("1.0.5", "08a77dc0a494bff93ce797f6cd562d3b1ff5d73701db1bfe50ae9a6739f114ff")
    add_versions("1.0.3", "5f439fb1fe51fdce212cc21cccfc0b003a7aa1a2b5fffd7901b51277f9b7070e")
    add_versions("1.0.2", "4222b7a36a47005c5d951e84e650f8c629ba200b0d87487b3ae83ae0e374a6e0")
    add_versions("1.0.1", "caa916125d28e7044c2ea513bdf31af7c39677fef7d296c5094abb2f4909c046")
    add_versions("1.0.0", "1fd1f85a8eabf72bdad0dff11560e6da07d3b3cd61151469faf8ee4d83dd28ae")

    add_configs("use_hikyuu", {description = "Use the hikyuu.", default = false, type = "boolean"})
    for _, name in ipairs({"mysql"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = true, type = "boolean"})
    end
    for _, name in ipairs({"sqlite", "stacktrace", "async_log"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = false, type = "boolean"})
    end

    on_load(function(package)
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
            {configs = {languages = "c++17"}
        }))
    end) 
