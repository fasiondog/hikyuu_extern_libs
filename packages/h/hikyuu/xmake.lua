package("hikyuu")

    set_homepage("http://hikyuu.org/")
    set_description("High Performance Quant Framework with C++/Python")
    set_license("MIT")

    add_urls("https://github.com/fasiondog/hikyuu/archive/refs/tags/$(version).zip",
        "https://github.com/fasiondog/hikyuu.git")
    add_versions("2.7.0", "87c5ca76e5ad733540885fb313dbd459aedb5ea8448de4d855f1c5a24271829a")
    add_versions("2.6.9", "9c10c050254accea3fa3a0c0f4154920d694758dea118ad17e14f218ab7be50c")
    add_versions("2.6.8", "18952523d371d8bebd7bb7a273649a8200026badcc4a92915e36fd72f39fccc6")
    add_versions("2.6.7", "9f3c7665107489f048139ff7e052c9fa164cb6ddd0ec54f165fcdf1389cfcc2f")
    add_versions("2.6.6", "45eaf9f41014fe5f8c0c61c2d81c71a3ea5e7e2ce617d449e30dfc5637025e4b")
    add_versions("2.6.5", "dc1cf6f744aa07c915cde3f3718470eb3d7b3dd15b476cad0f5d54efe554b2e0")
    add_versions("2.6.3", "9acae6a7d57c65e9787206398373fa5fddee0b65b5b3862aef07a25079d6ff16")
    add_versions("2.5.3", "636638d93fb11ff602b22f578568795934a76a8679418d81147a55ac09228f1d")

    if is_plat("linux") then
        if is_arch("x64") then
            add_resources("2.7.0", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.0_linux_x86_64.zip", "11f5c2e7009ca677235fe150e16cdf032e7e6dce85d4c1214b72627fbd99b4a6")
            add_resources("2.6.9", "hku_plugin", "https://gitee.com/hikyuu-quant/hikyuu_plugin_download/releases/download/2.6.8/hku_plugin_2.6.9_linux_x64.zip", "ebaf2e35f548b22215407df9f6f495421c26e0962bd1cbc071f0fdfc778b822a")
            add_resources("2.6.8", "hku_plugin", "https://gitee.com/hikyuu-quant/hikyuu_plugin_download/releases/download/2.6.8/hku_plugin_2.6.8_linux_x64.zip", "f34608dd8c10fd63d27c887d021326d1e98261cef8076e6b2e85acaf4ab24d0b")
        elseif is_arch("aarch64", "arm64") then
            add_resources("2.7.0", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.0_linux_aarch64.zip", "194f00127c5621cde71c3c9480a21cb3aa82d3381b021058c911ca567c4d85cd")
            add_resources("2.6.9", "hku_plugin", "https://gitee.com/hikyuu-quant/hikyuu_plugin_download/releases/download/2.6.8/hku_plugin_2.6.9_linux_aarch64.zip", "22fec3570dc3794db3e7b57988dff3f986bca6671eaa494930f3acda6602b4c1")
            add_resources("2.6.8", "hku_plugin", "https://gitee.com/hikyuu-quant/hikyuu_plugin_download/releases/download/2.6.8/hku_plugin_2.6.8_linux_aarch64.zip", "3fc51cfc6fa0622c4f7b0cf7f51cb7b3227b1f719c112a6ef27f1861889cb1dc")
        end
    elseif is_plat("windows") then
        add_resources("2.7.0", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.0_windows_amd64.zip", "8a3a682747823fc0dbb5bebdf43f85a554f11a92b28005bcc4a4581196e19fae")
        add_resources("2.6.9", "hku_plugin", "https://gitee.com/hikyuu-quant/hikyuu_plugin_download/releases/download/2.6.8/hku_plugin_2.6.9_windows_x64.zip", "2b0c06ad3d69dadde5a9b4a4e12c02479b8fae5e0ed7f7f2eb923d000e26df19")
        add_resources("2.6.8", "hku_plugin", "https://gitee.com/hikyuu-quant/hikyuu_plugin_download/releases/download/2.6.8/hku_plugin_2.6.8_windows_x64.zip", "2f571b37c10eb0defee7dfee95903cae870a9ec664338f4b132bfd723ad72897")
    elseif is_plat("macosx") then
        add_resources("2.7.0", "hku_plugin", "https://github.com/fasiondog/hikyuu_extern_libs/releases/download/plugin/hikyuu_plugin_2.7.0_macosx_arm64.zip", "df6199762f38c10952871dd6792bf1f1e4d44dc0994418ab3d6eba930ee4bba2")
        add_resources("2.6.9", "hku_plugin", "https://gitee.com/hikyuu-quant/hikyuu_plugin_download/releases/download/2.6.9/hku_plugin_2.6.9_macosx_arm64.zip", "c7950b3fdaeb2438127582cef11868da2d3d5188a256ee94f25bb09103998764")
        add_resources("2.6.8", "hku_plugin", "https://gitee.com/hikyuu-quant/hikyuu_plugin_download/releases/download/2.6.8/hku_plugin_2.6.8_macosx_arm64.zip", "8df70732e185f5aceb54ce4d1368bb37e00ee8452c802f09ed6cb2ea5c7d679f")
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
                shared = true,
                runtimes = package:runtimes(),
                multi = true,
                date_time = true,
                filesystem = false,
                serialization = true,
                system = true,
                python = false,
                cmake = false,
            }
        else
            boost_config = {
                shared = true, -- is_plat("windows"),
                runtimes = package:runtimes(),
                multi = true,
                date_time = true,
                filesystem = false,
                serialization = true, --get_config("serialize"),
                system = true,
                python = false,
                thread = true,   -- parquet need
                chrono = true,   -- parquet need
                charconv = true, -- parquet need
                cmake = false,
            }
        end        
        package:add("deps", "boost", {configs = boost_config})

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


