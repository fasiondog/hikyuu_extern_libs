package("hikyuu")

    set_homepage("http://hikyuu.org/")
    set_description("High Performance Quant Framework with C++/Python")
    set_license("MIT")

    add_urls("https://github.com/fasiondog/hikyuu/archive/refs/tags/$(version).tar.gz",
        "https://github.com/fasiondog/hikyuu.git")
    add_versions("2.7.5", "c097d277c1496cdaf924a17945253cd209a6404cacba3215b40e19d38cd9bff2")
    add_versions("2.7.3", "57b03fafed5bdc0fd33d3cf6cadea856f03eb1683ff2b587e87e6124ec4bb833")    

    if is_plat("linux") then
        if is_arch("x64", "x86_64") then
            add_resources("2.7.5", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.5_linux_x86_64.zip", "8bbe4a2f5996198cd943a59c1d3c6d3c64e6651365c2bc21128354fb81d9d447")
            add_resources("2.7.3", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.3_linux_x86_64.zip", "2b04fc31195376ed174e6b442126960cdc844920e1f8ef1a5ce78b991737fc9d")
        elseif is_arch("aarch64", "arm64") then
            add_resources("2.7.5", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.5_linux_aarch64.zip", "c76b3577418013c50b0414a8fe5ac9e79ae234bd051eefe78fc32c04c965c110")
            add_resources("2.7.3", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.3_linux_aarch64.zip", "d3f2c28cd9c8d99fbd0899f230e5f890d81e2a3c3b34715f1ea50f51632e37ac")
        end
    elseif is_plat("windows") then
        add_resources("2.7.5", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.5_windows_amd64.zip", "ef98dcc51a23ed5a73b71dfe0a25b6396e158ff3c828bf9cd45646b27b8e7105")
        add_resources("2.7.3", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.3_windows_amd64.zip", "fb90d99ec54142b0478599162486fc8ee955ee554bf57839532e102b096940da")
    elseif is_plat("macosx") then
        add_resources("2.7.5", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.5_macosx_arm64.zip", "3289371785eb18ac65d9a7e8d4ef546529db124f9db6c9db6d3b72718614f25f")
        add_resources("2.7.3", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.3_macosx_arm64.zip", "eee1893613c4b3930394ae238f159959bd41c3ff929118a5f975fe91a7c3dab3")
    end


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
    add_configs("serialize",  { description = "serialize support", default = false, type = "boolean"})
    add_configs("ta_lib",  { description = "Enable ta-lib support.", default = true, type = "boolean"})
    add_configs("arrow",  { description = "Enable arrow support.", default = false, type = "boolean"})

    -- 和 hku_utils 对齐
    add_configs("mo",  { description = "Enable the mo module.", default = false, type = "boolean"})
    add_configs("http_client_ssl",  { description = "Enable http client ssl.", default = false, type = "boolean"})
    add_configs("http_client_zip",  { description = "Enable http client zip.", default = false, type = "boolean"})

    on_load("windows", "linux", "macosx", function (package)
        local boost_config
        if is_plat("windows") then
            boost_config = {
                system = false,
                debug = is_mode("debug"),
                configs = {
                    shared = true,
                    runtimes = get_config("runtimes"),
                    multi = true,
                    date_time = true,
                    filesystem = false,
                    serialization = true,
                    system = true,
                    python = false,
                    cmake = false,
            }}
        else
            boost_config = {
                system = false,
                configs = {
                    shared = true, -- is_plat("windows"),
                    runtimes = get_config("runtimes"),
                    multi = true,
                    date_time = true,
                    filesystem = false,
                    serialization = true, --get_config("serialize"),
                    system = true,
                    python = false,
                    -- 以下为兼容 arrow 等其他组件
                    thread = true,   -- parquet need
                    chrono = true,   -- parquet need
                    charconv = true, -- parquet need
                    atomic = true,
                    container = true,
                    math = true,
                    locale = true,
                    icu = true,
                    regex = true,
                    random = true,
                    thread = true,
                    cmake = true,
            }}
        end   
        package:add("deps", "boost", boost_config)
        package:add("deps", "mimalloc", {system = false, configs = {shared = true}})

        package:add("deps", "fmt", {configs = {header_only = true}})
        package:add("deps", "spdlog", {configs = {header_only = true, fmt_external = true}})

        local flatbuffers_version = "v25.2.10"
        if package:is_plat("windows") then
            if is_mode("release") then
                package:add("deps", "flatbuffers", {system = false, version = flatbuffers_version, configs={runtimes="MD"}})
            else
                package:add("deps", "flatbuffers", {system = false, version = flatbuffers_version, configs={runtimes="MDd"}})
            end
        else
            package:add("deps", "flatbuffers", {system = false, version = flatbuffers_version})
        end        

        if package:config("mysql") then
            package:add("deps", "mysql")
        end

        if package:config("sqlite") or package:config("hdf5") then
            package:add("deps", "sqlite3", {configs = {shared = true, SQLITE_THREADSAFE = "2"}})
        end

        package:add("deps", "nng", {configs = {cxflags = "-fPIC"}})
        package:add("deps", "nlohmann_json", "xxhash")
   
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
            end
            package:add("cxflags", "-EHsc", "/Zc:__cplusplus", "/utf-8")
            package:add("links", "bcrypt", "hikyuu")
        else
            package:add("links", "hikyuu")
        end
             
        if package:config("ta_lib") then
            package:add("deps", "ta-lib")
        end

        if package:is_plat("macosx") then
            package:add("frameworks", "CoreFoundation")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("xmake.lua", [[includes("./hikyuu_pywrap")]], [[]], {plain = true})
        io.replace("xmake.lua", [[includes("./hikyuu_cpp/unit_test")]], [[]], {plain = true})
        io.replace("xmake.lua", [[includes("./hikyuu_cpp/demo")]], [[]], {plain = true})
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        table.insert(configs, "--serialize=" .. ((package:config("serialize") or package:is_plat("windows"))  and "true" or "false"))
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
        table.insert(configs, "--ta_lib=" .. (package:config("ta_lib") and "true" or "false"))
        if package:version() and package:version():lt("2.6.7") then
            table.insert(configs, "--mo=" .. (package:config("mo") and "true" or "false"))
        end
        table.insert(configs, "--http_client_ssl=" .. (package:config("http_client_ssl") and "true" or "false"))
        table.insert(configs, "--http_client_zip=" .. (package:config("http_client_zip") and "true" or "false"))

        import("package.tools.xmake").install(package, configs)

        local resourcedir = package:resourcedir("hku_plugin")
        if resourcedir then
            print("resourcedir: " .. resourcedir)
            if package:is_plat("windows") then
                os.cp(path.join(resourcedir, "*"), package:installdir("bin") .. "/plugin/")
            else
                os.cp(path.join(resourcedir, "*"), package:installdir("lib") .. "/plugin/")
            end
        end
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


