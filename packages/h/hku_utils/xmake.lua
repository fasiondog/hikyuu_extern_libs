package("hku_utils")

    set_homepage("http://192.168.100.203:7990/bitbucket/scm/hug_cpp/hku_utils.git")
    set_description("C++ Tools Library of Yihua.")

    add_urls("https://github.com/fasiondog/hku_utils/archive/$(version).zip",
             "https://github.com/fasiondog/hku_utils.git",
             "https://gitee.com/fasiondog/hku_utils.git")    
    add_versions("1.0.0", "73f584f8c3188e21bb97058488ac8b31ef456abf3ccad763f32aa3d51b18af0a")

    add_configs("log_name",  { description="默认log名称", default = "hikyuu"})
    add_configs("log_level",  { description="打印日志级别", default = "trace", values = {"trace", "debug", "info", "warn", "error", "fatal", "off"}})
    for _, name in ipairs({"datetime", "spend_time", "sqlite", "ini_parser"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = true, type = "boolean"})
    end
    for _, name in ipairs({"mysql", "sqlcipher", "sql_trace", "stacktrace"}) do
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

        package:add("deps", "fmt", "yas")
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
            if is_plat("windows", "android", "cross") then 
                package:add("deps", "sqlite3", {configs = {shared= true, tiny = true, SQLITE_THREADSAFE="2"}})
            elseif not package:config('shared') then
                package:add("links", "sqlite3")
            end
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "HKU_UTILS_API=__declspec(dllimport)")
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        table.insert(configs, "--log_name=" .. package:config("log_name"))
        table.insert(configs, "--log_level=" .. package:config("log_level"))

        for _, name in ipairs({"datetime", "spend_time", "sqlite", "ini_parser", "mysql", "sqlcipher", "sql_trace", "stacktrace"}) do
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
