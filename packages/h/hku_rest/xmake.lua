package("hku_rest")

    set_homepage("https://github.com/fasiondog/hku_rest.git")
    set_description("C++ http server Library of Hikyuu.")

    add_urls("https://github.com/fasiondog/hku_rest/archive/refs/tags/$(version).zip",
             "https://github.com/fasiondog/hku_rest.git")    
    add_versions("1.0.0", "14c783f4e51d550c4590b03c03bad62cf0462e6e9447522e2d1591fcdfe87e45")

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
                http_client = false,
                mysql = has_config("mysql"), 
                sqlite = has_config("sqlite"),
                stacktrace = has_config("stacktrace"),}})
    
        if package:config("mysql") then
            package:add("deps", "mysql")
        end

        if package:config("sqlite") then
            if is_plat("windows", "android", "cross") then 
                package:add("deps", "sqlite3", {configs = {shared= true, tiny = true, SQLITE_THREADSAFE="2"}})
            elseif not package:config('shared') then
                package:add("links", "sqlite3")
            end
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
