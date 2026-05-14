package("hku_rest")

    set_homepage("https://github.com/fasiondog/hku_rest.git")
    set_description("C++ http server Library of Hikyuu.")

    add_urls("https://github.com/fasiondog/hku_rest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fasiondog/hku_rest.git")    
    
    add_versions("1.2.2", "ed0b061f5505f5252f77e9dd3b00fe57b10dd4687b5f5851fcbe95551d06aabb")
    add_versions("1.2.1", "9dc72a11083792276ac929832c469fe1021b4b642478ae7ea493bd7813458bb5")
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

        -- local boost_config = {
        --         system = false,
        --         configs = {
        --             shared = is_plat("windows"),
        --             runtimes = get_config("runtimes"),
        --             multi = true,
        --             date_time = true,
        --             filesystem = false,
        --             serialization = true, --get_config("serialize"),
        --             system = true,
        --             python = false,
        --             -- 以下为兼容 arrow 等其他组件
        --             thread = true,   -- parquet need
        --             chrono = true,   -- parquet need
        --             charconv = true, -- parquet need
        --             atomic = true,
        --             container = true,
        --             math = true,
        --             regex = true,
        --             random = true,
        --             thread = true,
        --             asio = true,  
        --             beast = true,
        --             mysql = true,
        --             cmake = false,
        --     }}

        -- package:add("deps", "boost", {configs = boost_config})
        -- package:add("requireconfs", "**.boost", {override = true, configs = boost_config}) 
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
