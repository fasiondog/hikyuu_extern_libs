package("hku_utils")

    set_homepage("https://github.com/fasiondog/hku_utils.git")
    set_description("C++ Tools Library of Hikyuu.")

    add_urls("https://github.com/fasiondog/hku_utils/archive/refs/tags/$(version).tar.gz",
             "https://gitcode.com/KongDong/hku_utils.git",
             "https://github.com/fasiondog/hku_utils.git")

    add_versions("1.2.5", "a569c4f486ac8727dc03dc71bd528fa4d3f9ec598ad8b5f92760283ffd80341c")
    add_versions("1.2.4", "8b51794b64808bc233df3b680909eaf523fa9ce981444c7c9f23e323b837d471")
    add_versions("1.2.3", "7305bae82b055ba27e37a69b8797b8f7721c1c057fda186a57a902edc93b44e5")
    add_versions("1.2.2", "6459ed48e829355a0f53f1819293ab46998b91e2fa289712423d9d8e404bbb90")
    add_versions("1.2.1", "f3e8ea247b1337d847ca428365d846831fb6f6c4a0f376de8d0fc18857dd960f")
    add_versions("1.2.0", "6dcc3e8d9e49f6c4616bb0aee687be1168ceb0e2a2c98aafffd96511b6facca3")   
    add_versions("1.1.9", "8874e643817940492ddd99d0bdc7c5edb62dbbecc94bd0da0fe2af5417ccd7dd")
    add_versions("1.1.8", "3400aec0345d09e167aca8e54bdc222f79825ea3451183325be453851aff50c7")
    add_versions("1.1.7", "7392ca8540e422ea8178a88e2faadeb5019a6cc6100d32b845ba264f059ae131")
    add_versions("1.1.6", "8c628f4d15547889b9091c2dbaa79725529f37233029dff40e03fd35314f732d")
    add_versions("1.1.5", "b2c064b216ecabedf0464aaea48c22803fe111dd8d282fa88919c37f66a2734e")
    add_versions("1.1.4", "98c58bb2cc0ae16a0db929e3aee5ae4c2cbbe54063b6d0226d31752fc92be168")
    add_versions("1.1.3", "e5779a79279fbf44c6590d20da1e4925317b55cbb5889261bd5c637b9e65defb")
    add_versions("1.1.2", "c6de2352a70f151d4783198831e4ce698dd4813654ed534dd12cdc8354421370")
    add_versions("1.1.1", "1bd57b198b99940331795bb0fe7c1db62b74e2e1e5fbb0cb3849391ad24bfb5a")
    add_versions("1.1.0", "99789e604bb67120e01d78cb7ef6d9d89c377f85061928b198a9656d2ad304f6")
    add_versions("1.0.9", "0f73025b309ce7d792299ad8e1d674d797deb0803c9ac688ebe2503748af1d5d")             
    add_versions("1.0.8", "55f0e6ae84be574f221085fb527a306d303eefa371e5eb84ef650d4137f84b79")
    add_versions("1.0.7", "d1cbafd61904e4ae06dd6e389b35238fd3fc770543d4b87561aa31e2d974c779")
    add_versions("1.0.6", "3aee54833ec4ff60bc7d34ae5ac00d0fc0244280b3f9fbc3b21518aee07c5828")
    add_versions("1.0.5", "843427bb53c6a7dddfe792ede52b896e308f89cdb7d46cf7b2d774b089e445ac")
    add_versions("1.0.4", "1feffd5fd2b4b6247e9c62933cd37da06d386d969f9646c15b0b524085456c86")
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
                python = false,
                cmake = false,
            }})

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
