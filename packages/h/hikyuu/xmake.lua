package("hikyuu")

    set_homepage("http://hikyuu.org/")
    set_description("High Performance Quant Framework with C++/Python")
    set_license("MIT")

    add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/hikyuu/hikyuu-$(version).zip",
             "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/hikyuu/hikyuu-$(version).zip",
             "https://github.com/fasiondog/hikyuu.git",
             "https://gitee.com/fasiondog/hikyuu.git")
    add_versions("2.2.1", "49d4849a3b8ed881f935efdd83c6a81bfef8338e9da8681fb00e75cdb3209664")             

    add_configs("hdf5",  { description = "Enable hdf5 kdata engine.", default = true, type = "boolean"})
    add_configs("mysql",  { description = "Enable mysql kdata engine.", default = true, type = "boolean"})
    add_configs("sqlite",  { description = "Enable sqlite kdata engine.", default = true, type = "boolean"})
    add_configs("tdx",  { description = "Enable tdx kdata engine.", default = true, type = "boolean"})
    add_configs("stacktrace",  { description = "Enable check/assert with stack trace info.", default = false, type = "boolean"})
    add_configs("spend_time",  { description = "Enable spend time.", default = false, type = "boolean"})
    add_configs("feedback",  { description = "Enable send feedback.", default = true, type = "boolean"})
    add_configs("low_precision",  { description = "Enable send feedback.", default = false, type = "boolean"})
    add_configs("async_log",  { description = "Use asyn log.", default = false, type = "boolean"})
    add_configs("log_level",  { description="打印日志级别", default = 2, values = {0, 1, 2, 3, 4, 5, 6}})

    -- 和 hku_utils 对齐
    add_configs("mo",  { description = "Enable the mo module.", default = false, type = "boolean"})
    add_configs("http_client_ssl",  { description = "Enable http client ssl.", default = false, type = "boolean"})
    add_configs("http_client_zip",  { description = "Enable http client zip.", default = false, type = "boolean"})

    on_load("windows", "linux", "macosx", function (package)
        package:add("deps", "boost", {
            configs= {shared = package:is_plat("windows"),
                runtimes = package:runtimes(),
                multi = true,
                date_time = true,
                filesystem = false,
                serialization = true,
                system = false,
                python = false,
                cmake = false,
            }})

        package:add("deps", "fmt", {configs = {header_only = true}})
        package:add("deps", "spdlog", {configs = {header_only = true, fmt_external = true}})
        -- package:add("deps", "flatbuffers", {configs={runtimes=package:runtimes()}})
        if package:is_plat("windows") then
            if is_mode("release") then
                package:add("deps", "flatbuffers", {system = false, configs={runtimes="MD"}})
            else
                package:add("deps", "flatbuffers", {system = false, configs={runtimes="MDd"}})
            end
        else
            package:add("deps", "flatbuffers", {system = false})
        end        

        if package:config("mysql") then
            package:add("deps", "mysql")
        end

        if package:config("sqlite") or package:config("hdf5") then
            package:add("deps", "sqlite3", {configs = {shared = true, SQLITE_THREADSAFE = "2"}})
        end

        package:add("deps", "nng", {configs = {cxflags = "-fPIC"}})
        package:add("deps", "nlohmann_json")
   
        if package:config("hdf5") then
            if is_plat("windows") and is_mode("debug") then
                package:add("deps", "hdf5_D")
            else
                package:add("deps", "hdf5")
            end
        end

        if package:config("shared") then
            package:add("deps", "nng", {configs = {NNG_ENABLE_TLS = package:config("http_client_ssl"), cxflags = "-fPIC"}})
        else
            package:add("deps", "nng", {configs = {NNG_ENABLE_TLS = package:config("http_client_ssl")}})
        end
        if package:config("http_client_zip") then
            package:add("deps", "gzip-hpp")
        end

        package:add("defines", "SPDLOG_ACTIVE_LEVEL=" .. package:config("log_level"))

        if package:is_plat("windows") then
            package:add("defines", "NOCRYPT", "NOGDI", "WIN32_LEAN_AND_MEAN")
            if package:config("shared") then 
                package:add("defines", "HKU_API=__declspec(dllimport)")
                package:add("defines", "HKU_UTILS_API=__declspec(dllimport)")
                package:add("defines", "BOOST_ALL_DYN_LINK") 
            end
            package:add("cxflags", "-EHsc", "/Zc:__cplusplus", "/utf-8")
            package:add("links", "bcrypt", "hikyuu")
        else
            package:add("links", "hikyuu")
        end
                
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        table.insert(configs, "--log_level=" .. package:config("log_level"))
        table.insert(configs, "--hdf5=" .. (package:config("hdf5") and "true" or "false"))
        table.insert(configs, "--mysql=" .. (package:config("mysql") and "true" or "false"))
        table.insert(configs, "--sqlite=" .. (package:config("sqlite") and "true" or "false"))
        table.insert(configs, "--tdx=" .. (package:config("tdx") and "true" or "false"))
        table.insert(configs, "--stacktrace=" .. (package:config("stacktrace") and "true" or "false"))
        table.insert(configs, "--spend_time=" .. (package:config("spend_time") and "true" or "false"))
        table.insert(configs, "--feedback=" .. (package:config("feedback") and "true" or "false"))
        table.insert(configs, "--low_precision=" .. (package:config("low_precision") and "true" or "false"))
        table.insert(configs, "--async_log=" .. (package:config("async_log") and "true" or "false"))
        table.insert(configs, "--mo=" .. (package:config("mo") and "true" or "false"))
        table.insert(configs, "--http_client_ssl=" .. (package:config("http_client_ssl") and "true" or "false"))
        table.insert(configs, "--http_client_zip=" .. (package:config("http_client_zip") and "true" or "false"))

        import("package.tools.xmake").install(package, configs)
    end)

    on_test("windows", "linux", "macosx", function (package)
        assert(package:check_cxxsnippets({
            test = [[
            #include <hikyuu/hikyuu.h>
            using namespace hku;
            void test() {
                StockManager& sm = StockManager::instance();
            }
            ]]},
            {configs = {languages = "c++17"}
        }))
    end)    


