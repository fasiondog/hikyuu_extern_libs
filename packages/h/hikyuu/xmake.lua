package("hikyuu")

    set_homepage("http://hikyuu.org/")
    set_description("High Performance Quant Framework with C++/Python")
    set_license("MIT")

    add_urls("https://github.com/fasiondog/hikyuu/archive/refs/tags/$(version).tar.gz",
        "https://github.com/fasiondog/hikyuu.git")
    add_versions("2.7.2", "2fa8acaf71093f42f1bbad74e629225dc381ab72072f14dc154ef40f1ba94bdb")

    if is_plat("linux") then
        if is_arch("x64", "x86_64") then
            add_resources("2.7.2", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.2_linux_x86_64.zip", "fd92464871c8e635e0861b3f3753cef44179b012019ecd6eca52c2caa3d07e19")
        elseif is_arch("aarch64", "arm64") then
            add_resources("2.7.1", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.1_linux_aarch64.zip", "da305ba33e2942f3204f0305a5be4a84162e5cce5a6a58da8618564d604ddbff")
        end
    elseif is_plat("windows") then
        add_resources("2.7.1", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.1_windows_amd64.zip", "0b7babdeac5a990edf1b0d10a73794ddcd35f40cb737c2da5b01bfbb6da68e9d")
    elseif is_plat("macosx") then
        add_resources("2.7.2", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.2_macosx_arm64.zip", "c2e928bfeec1f615a834b7791caa2ed9ad66f765309bbecb0a040024aabe295b")
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


