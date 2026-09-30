package("hikyuu")

    set_homepage("http://hikyuu.org/")
    set_description("High Performance Quant Framework with C++/Python")
    set_license("MIT")

    add_urls("https://github.com/fasiondog/hikyuu/archive/refs/tags/$(version).tar.gz",
        "https://github.com/fasiondog/hikyuu.git")
    add_versions("2.8.3", "a4f7b347328f5db5b83c1b974840495fb59a1b303dc42a965ce22848c38aad4a")    
    -- add_versions("2.7.9", "507127fdd010b5a455e811916afc7eb0670ca106f242f0453001f4426fad5598")        
    -- add_versions("2.7.8", "b9c3d75889e0f1c64a803844f10d314373d411cf8d2278f76daf3adf7a474b52")

    if is_plat("linux") then
        if is_arch("x64", "x86_64") then
            add_resources("2.8.3", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.8.3_linux_x86_64.zip", "dbe88e4091af20444ff0aece787ae201ceb6c013ddba8e6ead1779a58d4ba447")
            add_resources("2.7.8", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.8_linux_x86_64.zip", "c860fe90dfbc47f4090c7b3b915d2a6d67f7bee071e561ac3ef6247d07fa2b7c")
        elseif is_arch("aarch64", "arm64") then
            add_resources("2.8.3", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.8.3_linux_aarch64.zip", "de4ff19d10cf0ff6db066605f8d863d114f758344a047c615c384864e1caa87e")
            add_resources("2.7.8", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.8_linux_aarch64.zip", "65ba31d88e7a28f081ddf1881d76a23585af1a9d3d17389e79cbbc72854bc4c4")
        end
    elseif is_plat("windows") then
        add_resources("2.8.3", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.8.3_windows_amd64.zip", "32c6c568d04db1c040885c80b686770b65df8e265f9c145577ce0e6d7d3d5441")
        add_resources("2.7.8", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.8_windows_amd64.zip", "261ab655757e26aa465ab096c644a6a76bcc6ae204cbc1d58045c4e7891ac60b")
    elseif is_plat("macosx") then
        add_resources("2.8.3", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.8.3_macosx_arm64.zip", "9862614e630c5e3f7736c1530d6b841ca4da65aab6f70c552d871452d8afb174")
        add_resources("2.7.8", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.8_macosx_arm64.zip", "16547ffcfa8897bd9cbab067fc9b81237c976723afe61a97971b9cd906e48b88")
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
    add_configs("http_client_ssl",  { description = "Enable http client ssl.", default = false, type = "boolean"})
    add_configs("http_client_zip",  { description = "Enable http client zip.", default = false, type = "boolean"})
    add_configs("local",  { description = "Enable local vectorized compilation.", default = false, type = "boolean"})

    on_load("windows", "linux", "macosx", function (package)
        local boost_config = {
                version = ">=1.92",
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
                    charconv = true, -- parquet, boost.mysql need
                    atomic = true,
                    container = true,
                    math = true,
                    locale = true,
                    icu = true,
                    regex = true,
                    random = true,
                    thread = true,
                    -- asio = true,
                    openssl = has_config("mysql"),
                    mysql = has_config("mysql"),            
                    cmake = false,
            }}
        package:add("deps", "boost", boost_config)

        if package:is_plat("windows", "linux", "cross") then
            package:add("deps", "mimalloc", {system = false, configs = {shared = true}})
        end

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
        package:add("deps", "nlohmann_json", "xxhash", "tl_expected")
   
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
        if package:config("http_client_ssl") then
            package:add("deps", "openssl3")
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
        table.insert(configs, "--http_client_ssl=" .. (package:config("http_client_ssl") and "true" or "false"))
        table.insert(configs, "--http_client_zip=" .. (package:config("http_client_zip") and "true" or "false"))
        table.insert(configs, "--local=" .. (package:config("local") and "true" or "false"))

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
            {configs = {languages = "c++20"}
        }))
    end)    


