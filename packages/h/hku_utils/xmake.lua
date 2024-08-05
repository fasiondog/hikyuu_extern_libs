package("hku_utils")

    set_homepage("https://github.com/fasiondog/hku_utils.git")
    set_description("C++ Tools Library of Hikyuu.")

    add_urls("https://github.com/fasiondog/hku_utils/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fasiondog/hku_utils.git")    
    add_versions("1.0.2", "25232d44e87eccbb89a4a3500eec7eba025f0dafbe5631370648f6f2b512252d")
    add_versions("1.0.3", "4e8df7ceeb20dae8853fe3e401f1cbce54ce90e41515140076114bab45fb8ccb")

    add_configs("log_level",  { description="打印日志级别", default = 2, values = {0, 1, 2, 3, 4, 5, 6}})
    for _, name in ipairs({"datetime", "spend_time", "sqlite", "ini_parser", "http_client", "node"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = true, type = "boolean"})
    end
    for _, name in ipairs({"async_log", "mo", "mysql", "sqlcipher", "sql_trace", "stacktrace", "http_client_ssl", "http_client_zip"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = false, type = "boolean"})
    end

    on_load(function(package)
        package:add("deps", "boost", {
            configs= {shared = package:is_plat("windows"),
                runtimes = package:runtimes(),
                multi = true,
                date_time = package:config("datetime"),
                filesystem = false,
                serialization = false,
                system = false,
                python = false,}})

        package:add("deps", "yas")
        package:add("deps", "fmt", {configs={header_only = true}})
        package:add("deps", "spdlog", {configs={header_only = true, fmt_external = true}})
    
        if package:config("mysql") then
            package:add("deps", "mysql")
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
            if package:config("http_client_zip") then
                package:add("deps", "gzip-hpp")
            end
        end

        package:add("defines", "SPDLOG_ACTIVE_LEVEL=" .. package:config("log_level"))

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "HKU_UTILS_API=__declspec(dllimport)")
        end

        package:add("links", "hku_utils")
    end)

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        table.insert(configs, "--log_level=" .. package:config("log_level"))

        for _, name in ipairs({"datetime", "spend_time", "sqlite", "ini_parser", "http_client", "node",  
                               "async_log", "mo", "mysql", "sqlcipher", "sql_trace", "stacktrace", 
                               "http_client_ssl", "http_client_zip"}) do
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
