package("async_mqtt")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/redboltz/async_mqtt")
    set_description("I/O independent (also known as Sans-I/O) MQTT protocol library for C++17. Asynchronous MQTT communication library using the MQTT protocol library and Boost.Asio.")
    set_license("BSL-1.0")

    add_urls("https://github.com/redboltz/async_mqtt/archive/$(version).tar.gz",
             "https://github.com/redboltz/async_mqtt.git")
    add_versions("10.3.0", "01daa741f970a04551c8375553bc96ce66a0bf542466a88a141863cc8c2a690c")

    add_configs("tls", {description = "Enable TLS support", default = false, type = "boolean"})
    add_configs("ws", {description = "Enable WebSocket support", default = false, type = "boolean"})
    add_configs("log", {description = "Enable logging support", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("boost >=1.82.0", {configs = {asio=true, log=true, beast=true, property_tree=true, serialization=true}})

    on_load(function (package)
        if package:config("tls") then
            package:add("defines", "ASYNC_MQTT_USE_TLS")
            package:add("deps", "openssl")
        end
        if package:config("ws") then
            package:add("defines", "ASYNC_MQTT_USE_WS")
        end
        if package:config("log") then
            package:add("defines", "ASYNC_MQTT_USE_LOG")
        end
        
        -- 添加 include/async_mqtt 到 include 路径
        package:add("includedirs", package:installdir("include/async_mqtt"))
    end)

    if is_plat("windows") then
        add_syslinks("ws2_32", "mswsock")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DASYNC_MQTT_BUILD_UNIT_TESTS=OFF",
            "-DASYNC_MQTT_BUILD_SYSTEM_TESTS=OFF",
            "-DASYNC_MQTT_BUILD_EXAMPLES=OFF",
            "-DASYNC_MQTT_BUILD_TOOLS=OFF",
            "-DASYNC_MQTT_BUILD_LIB=OFF",
            "-DASYNC_MQTT_PRINT_PAYLOAD=OFF",
            "-DASYNC_MQTT_USE_STR_CHECK=OFF",
            "-DASYNC_MQTT_USE_TLS=" .. (package:config("tls") and "ON" or "OFF"),
            "-DASYNC_MQTT_USE_WS=" .. (package:config("ws") and "ON" or "OFF"),
            "-DASYNC_MQTT_USE_LOG=" .. (package:config("log") and "ON" or "OFF"),
        }
        
        import("package.tools.cmake").install(package, configs)
        
        -- 拷贝 tool/include 目录下的内容到 include/async_mqtt
        if os.isdir("tool/include") then
            local dest_dir = package:installdir("include/async_mqtt")
            os.mkdir(dest_dir)
            for _, file in ipairs(os.files("tool/include/**")) do
                local relpath = file:sub(#"tool/include/" + 1)
                local dest = path.join(dest_dir, relpath)
                local destdir = path.directory(dest)
                if not os.isdir(destdir) then
                    os.mkdir(destdir)
                end
                os.cp(file, dest)
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <async_mqtt/all.hpp>
            void test() {
                // Just check if the header can be included
                // Actual usage requires Boost.Asio setup
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
