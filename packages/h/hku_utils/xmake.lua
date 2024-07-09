package("hku_utils")

    set_homepage("http://192.168.100.203:7990/bitbucket/scm/hug_cpp/hku_utils.git")
    set_description("C++ Tools Library of Yihua.")

    add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/hikyuu/hku_utils-$(version).zip",
             "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/hikyuu/hku_utils-$(version).zip",
             "https://github.com/fasiondog/hku_utils.git",
             "https://gitee.com/fasiondog/hku_utils.git")    
    --add_versions("1.0.0", "cda2c7e7897140e5bbcc537cf11d9a2ab49d5b88088be5b95715fae121009b78")

    add_configs("log_name",  { description="默认log名称", default = "hikyuu"})
    add_configs("log_level",  { description="打印日志级别", default = "trace", values = {"trace", "debug", "info", "warn", "error", "fatal", "off"}})
    for _, name in ipairs({"datetime", "spend_time", "sqlite", "sqlcipher", "mysql", "ini_parser", "sql_trace"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = (name == "datetime"), type = "boolean"})
    end

    add_deps("fmt", "yas", "boost")

    on_load(function(package)
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
        if package:is_plat("windows") then
            package:add("defines", "NOMINMAX")
        end

        local name = package:config("log_name")
        package:add("defines", 'HKU_DEFAULT_LOG_NAME="' .. name .. '"')

        local level = package:config("log_level")
        if level == "trace" then
            package:add("defines", "HKU_LOGGER_ACTIVE_LEVEL=0")
        elseif level == "debug" then
            package:add("defines", "HKU_LOGGER_ACTIVE_LEVEL=1")
        elseif level == "info" then
            package:add("defines", "HKU_LOGGER_ACTIVE_LEVEL=2")
        elseif level == "warn" then
            package:add("defines", "HKU_LOGGER_ACTIVE_LEVEL=3")
        elseif level == "error" then
            package:add("defines", "HKU_LOGGER_ACTIVE_LEVEL=4")
        elseif level == "fatal" then
            package:add("defines", "HKU_LOGGER_ACTIVE_LEVEL=5")
        else
            package:add("defines", "HKU_LOGGER_ACTIVE_LEVEL=6")
        end

        if package:config("spend_time") then
            package:add("defines", "HKU_CLOSE_SPEND_TIME=0")
        end   

        if package:config("datetime") then
            package:add("defines", "HKU_SUPPORT_DATETIME")
            package:add("links", "boost_system", "boost_date_time", "hku_utils")
        end

        if package:config("sql_trace") then
            package:add("defines", "HKU_SQL_TRACE")
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        table.insert(configs, "--log_name=" .. package:config("log_name"))
        table.insert(configs, "--log_level=" .. package:config("log_level"))

        for _, name in ipairs({"datetime", "spend_time", "sqlcipher", "sqlite", "mysql", "ini_parser", "sql_trace"}) do
            configs[name] = package:config(name)
        end

        import("package.tools.xmake").install(package, configs)
    end)