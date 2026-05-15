package("hku_utils")

    set_homepage("https://github.com/fasiondog/hku_utils.git")
    set_description("C++ Tools Library of Hikyuu.")

    add_urls("https://github.com/fasiondog/hku_utils/archive/refs/tags/$(version).tar.gz",
             "https://gitcode.com/KongDong/hku_utils.git",
             "https://github.com/fasiondog/hku_utils.git")

    add_versions("1.4.0", "aa10b4c28a7426f3a62fa0e0013b4f0cc4dd646a6da87a4b3cb14b3dcebdcdc9")
    add_versions("1.3.9", "811dc5c17391b137b0d6717086a07f48158e53bdf712766f92ee1b95b8b70051")
    add_versions("1.3.8", "2a33b1c1262138c57fc55ecddb5fe5d179b29a9aebb60e5ba0bd9e6f6dc46fe9")
    add_versions("1.3.7", "478d4c5f44e159daf3c000f4db25161a732f03ac48e4a55e5d8aebc6a7ac37ef")

    add_configs("log_level",  { description="打印日志级别", default = 2, values = {0, 1, 2, 3, 4, 5, 6}})
    for _, name in ipairs({"datetime", "spend_time", "sqlite", "ini_parser", "http_client", "node"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = true, type = "boolean"})
    end
    for _, name in ipairs({"arrow", "async_log", "mo", "mysql", "sqlcipher", "sql_trace", "stacktrace", "http_client_ssl", "http_client_zip", "duckdb"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = false, type = "boolean"})
    end
    
    add_configs("disable_libmysqlclient", {description = "Disable use libmysqlclient", default = false, type = "boolean"})

    on_load(function(package)
        package:add("deps", "boost", {
            system = false,
            configs= {
                shared = package:is_plat("windows"),
                runtimes = package:runtimes(),
                multi = true,
                date_time = package:config("datetime"),
                filesystem = false,
                serialization = false,
                system = true,
                python = false,
                asio = true,
                beast = true,
                openssl = package:config("mysql"),
                mysql = package:config("mysql"),
                charconv = package:config("mysql"),  -- boost.mysql 需要 charconv                
                cmake = false,
            }})

        package:add("defines", "DBOOST_ASIO_DISABLE_DEPRECATED=1")
        
        package:add("deps", "yas", "tl_expected")
        package:add("deps", "fmt", {configs={header_only = true}})
        package:add("deps", "spdlog", {configs={header_only = true, fmt_external = true}})
    
        if package:config("mysql") then 
            if package:version():lt("1.4.0") then
                package:add("deps", "mysql")
            elseif not package:config("disable_libmysqlclient") then
                package:add("deps", "mysql")
            end
            package:add("deps", "openssl3", {system = false, configs = {shared = true}})
        end

        if package:config("sqlcipher") then
            if package:is_plat("iphoneos") then
                package:add("deps", "sqlcipher")
            else 
                package:add("deps", "sqlcipher", {system = false, configs = {shared = true, tiny = true, SQLITE_THREADSAFE="1"}})
            end        
        elseif package:config("sqlite") then
            package:add("deps", "sqlite3", {configs = {shared= true, tiny = true, SQLITE_THREADSAFE="2"}})
        end

        if package:config("http_client") or package:config("node") then
            package:add("deps", "nlohmann_json")
            if package:config("shared") then
                package:add("deps", "nng", {configs = {NNG_ENABLE_TLS = package:config("http_client_ssl"), cxflags = "-fPIC"}})
            else
                package:add("deps", "nng", {configs = {NNG_ENABLE_TLS = package:config("http_client_ssl")}})
            end
        end

        if package:config("http_client") then
            if package:config("http_client_ssl") then
                package:add("deps", "openssl3", {system = false, configs = {shared = true}})
            end
            if package:config("http_client_zip") then
                package:add("deps", "gzip-hpp")
            end
        end


        package:add("defines", "SPDLOG_ACTIVE_LEVEL=" .. package:config("log_level"))

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "HKU_UTILS_API=__declspec(dllimport)")
        end

        if package:is_plat("macosx") then
            package:add("frameworks", "CoreFoundation")
        end

        package:add("links", "hku_utils")
    end)

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        table.insert(configs, "--log_level=" .. package:config("log_level"))

        for _, name in ipairs({"datetime", "spend_time", "sqlite", "ini_parser", "http_client", 
                               "node", "async_log", "mysql", "sqlcipher", "sql_trace", "stacktrace", 
                               "http_client_ssl", "http_client_zip", "duckdb", 
                               "disable_libmysqlclient"}) do
            configs[name] = package:config(name)
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test("windows", "linux", "macosx", function (package)
        assert(package:check_cxxsnippets({
            test = [[
            #include <hikyuu/utilities/Log.h>
            using namespace hku;
            void test() {
                HKU_INFO("test");
            }
            ]]},
            {configs = {languages = "c++17"}
        }))
    end) 
