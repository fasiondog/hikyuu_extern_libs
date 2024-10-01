package("hikyuu")

    set_homepage("http://hikyuu.org/")
    set_description("High Performance Quant Framework with C++/Python")
    set_license("MIT")

    add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/hikyuu/hikyuu-$(version).zip",
             "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/hikyuu/hikyuu-$(version).zip",
             "https://github.com/fasiondog/hikyuu.git",
             "https://gitee.com/fasiondog/hikyuu.git")
    add_versions("2.2.1", "8eaca2369b986b063ae72c4df09fa7119956dab3ed41cdbeb7a57bdca858dbd7")             

    add_configs("hdf5",  { description = "Enable hdf5 kdata engine.", default = true, type = "boolean"})
    add_configs("mysql",  { description = "Enable mysql kdata engine.", default = true, type = "boolean"})
    add_configs("sqlite",  { description = "Enable sqlite kdata engine.", default = true, type = "boolean"})
    add_configs("tdx",  { description = "Enable tdx kdata engine.", default = true, type = "boolean"})
    add_configs("stacktrace",  { description = "Enable check/assert with stack trace info.", default = false, type = "boolean"})
    add_configs("spend_time",  { description = "Enable spend time.", default = false, type = "boolean"})
    add_configs("feedback",  { description = "Enable send feedback.", default = true, type = "boolean"})
    add_configs("low_precision",  { description = "Enable send feedback.", default = false, type = "boolean"})
    add_configs("log_level",  { description="打印日志级别", default = 2, values = {1, 2, 3, 4, 5, 6}})

    on_load("windows", "linux", "macosx", function (package)
        package:add("deps", "boost", {
            configs= {shared = package:is_plat("windows"),
                runtimes = package:runtimes(),
                multi = true,
                date_time = true,
                filesystem = false,
                serialization = true,
                system = false,
                python = false,}})

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

        if package:config("sqlite") then
            package:add("deps", "sqlite3", {configs = {shared = true, cxflags = "-fPIC"}})
        end

        package:add("deps", "nng", {configs = {cxflags = "-fPIC"}})
        package:add("deps", "nlohmann_json")
        package:add("deps", "zlib")
   
        if package:config("hdf5") then
            if is_plat("windows") and is_mode("debug") then
                package:add("deps", "hdf5_D")
            else
                package:add("deps", "hdf5")
            end
        end

        if package:config("spend_time") then
            package:add("defines", "HKU_CLOSE_SPEND_TIME=0")
        end

        package:add("defines", "SPDLOG_DISABLE_DEFAULT_LOGGER")
        package:add("defines", "LOG_ACTIVE_LEVEL=0", "USE_SPDLOG_LOGGER=1", "USE_SPDLOG_ASYNC_LOGGER=0")
        package:add("defines", "CHECK_ACCESS_BOUND=1")
        if package:is_plat("macosx") then
            package:add("defines", "SUPPORT_SERIALIZATION=0")
        elseif is_mode("relase") then
            package:add("defines", "SUPPORT_SERIALIZATION=1")
        else
            package:add("defines", "SUPPORT_SERIALIZATION=0")
        end
        package:add("defines", "SUPPORT_TEXT_ARCHIVE=0", "SUPPORT_XML_ARCHIVE=1", "SUPPORT_BINARY_ARCHIVE=1")
        package:add("defines", "HKU_DISABLE_ASSERT=0", "ENABLE_MSVC_LEAK_DETECT=0")
        package:add("defines", "HKU_ENABLE_SEND_FEEDBACK=1")
        package:add("defines", "HKU_ENABLE_HDF5_KDATA=" .. (package:config("hdf5") and 1 or 0))
        package:add("defines", "HKU_ENABLE_MYSQL_KDATA=" .. (package:config("mysql") and 1 or 0))
        package:add("defines", "HKU_ENABLE_SQLITE_KDATA=" .. (package:config("sqlite") and 1 or 0))
        package:add("defines", "HKU_ENABLE_TDX_KDATA=" .. (package:config("tdx") and 1 or 0))
        if package:is_plat("windows") then
            package:add("defines", "NOCRYPT", "NOGDI", "WIN32_LEAN_AND_MEAN")
            if package:config("shared") then 
                package:add("defines", "HKU_API=__declspec(dllimport)")
                package:add("defines", "BOOST_ALL_DYN_LINK") 
            end
            package:add("cxflags", "-EHsc", "/Zc:__cplusplus", "/utf-8")
            package:add("links", "bcrypt", "hikyuu")
        end        
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        table.insert(configs, "--hdf5=" .. (package:config("hdf5") and "true" or "false"))
        table.insert(configs, "--mysql=" .. (package:config("mysql") and "true" or "false"))
        table.insert(configs, "--sqlite=" .. (package:config("sqlite") and "true" or "false"))
        table.insert(configs, "--tdx=" .. (package:config("tdx") and "true" or "false"))
        table.insert(configs, "--stacktrace=" .. (package:config("stacktrace") and "true" or "false"))
        table.insert(configs, "--spend_time=" .. (package:config("spend_time") and "true" or "false"))
        table.insert(configs, "--feedback=" .. (package:config("feedback") and "true" or "false"))
        table.insert(configs, "--low_precision=" .. (package:config("low_precision") and "true" or "false"))

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


