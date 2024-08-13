package("mysql")

    set_homepage("https://dev.mysql.com/doc/refman/5.7/en/")
    set_description("Open source relational database management system.")

    if is_plat("windows") then
        add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/mysql-$(version)-win-x64.zip",
                 "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/mysql-$(version)-win-x64.zip")
        add_versions("8.0.21", "de21694aa230a00b52b28babbce9bb150d990ba1f539edf8d193586dce3844ae")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/mysql-$(version)-linux-x86_64.zip",
                 "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/mysql-$(version)-linux-x86_64.zip")
        add_versions("8.0.31", "07268a4b02174dfb8ee30642cd6fd81a0115ed87560a51a42e7123eed0be5ad1")
    elseif is_plat("linux", "cross") and is_arch("aarch64", "arm64.*") then
        add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/mysql-$(version)-linux-aarch64.zip",
                 "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/mysql-$(version)-linux-aarch64.zip")
        add_versions("8.0.21", "385a7e280f86aa864f02ae7061c940a20f1ace358f906d330453992331b638c8")
    elseif is_plat("macosx") then
        add_extsources("brew::mysql-client")
    end

    on_install("windows", "linux", "cross", function (package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        if package:is_plat("windows") then
            os.cp("bin", package:installdir())
        end
    end)

    on_load("macosx", function(package)
        package:add("cxflags", "-I/usr/local/opt/mysql-client/include/mysql")
        package:add("cxflags", "-I/usr/local/opt/mysql-client/include")
        package:add("shflags", "-L/usr/local/opt/mysql-client/lib")
        package:add("ldflags", "-L/usr/local/opt/mysql-client/lib")
        package:add("rpathdirs", "/usr/local/opt/mysql-client/lib")
        package:add("links", "mysqlclient")
    end)

    on_install("macosx", function(package)
        package:addenv("PATH", "/usr/local/opt/mysql-client/bin")
    end)

