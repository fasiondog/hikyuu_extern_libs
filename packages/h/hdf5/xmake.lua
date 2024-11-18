package("hdf5")

    set_homepage("https://www.hdfgroup.org/solutions/hdf5/")
    set_description("High-performance data management and storage suite")
    set_license("BSD-3-Clause")

    if is_plat("windows") then
        add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/hdf5-$(version)-win-x64.zip",
            "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/hdf5-$(version)-win-x64.zip")
        add_versions("1.13.3", "b115ad9e1123c8c8ba45ec8e3fd3f24369e8b2a3fb6695ffbf7cdc245efe58e0")
        add_versions("1.12.2", "388d455c917b153f3410e8ca0c857ee37a575d859a70ecb6e16d4fb43b1d201c")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/hdf5-$(version)-linux-x64.zip",
            "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/hdf5-$(version)-linux-x64.zip")
        add_versions("1.12.2", "e0f4357ea7bfa0132c3edba9b517635736191f920ce7a3aeef5e89dbe5b2dd27")
    elseif is_plat("linux", "cross") and is_arch("aarch64", "arm64.*") then
        add_urls("https://github.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/hdf5-$(version)-linux-aarch64.zip",
                 "https://gitee.com/fasiondog/hikyuu_extern_libs/releases/download/1.0.0/hdf5-$(version)-linux-aarch64.zip")
        add_versions("1.12.2", "d73a880d9dfede0d5db1e30555fa251ca82efa437a0d93b46f5e64e87e71fc63")
    elseif is_plat("macosx") then
        add_urls("https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-$(version).tar.gz", {version = function (version)
            return format("%d.%d/hdf5-%s/src/hdf5-%s", version:major(), version:minor(), version, version)
        end})
        add_versions("1.12.2", "2a89af03d56ce7502dcae18232c241281ad1773561ec00c0f0e8ee2463910f14")
    end

    
    if is_plat("macosx") then
        add_deps("cmake")
    end

    on_load("windows", "linux", "cross", function (package)
        package:add("defines", "H5_BUILT_AS_DYNAMIC_LIB")
    end)

    on_install("windows", "linux", "cross", function (package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        if package:is_plat("windows") then
            os.cp("bin", package:installdir())
        end
    end)

    on_install("macosx", function (package)
        io.replace("CMakeLists.txt", 'set (HDF5_EXTERNAL_LIB_PREFIX "" CACHE STRING "Use prefix for custom library naming.")', 
                   'set (HDF5_EXTERNAL_LIB_PREFIX "hku_" CACHE STRING "Use prefix for custom library naming.")', {plain = true})
        local configs = {
            "-DHDF5_GENERATE_HEADERS=OFF",
            "-DBUILD_TESTING=OFF",
            "-DHDF5_BUILD_EXAMPLES=OFF",
            "-DHDF_PACKAGE_NAMESPACE:STRING=hdf5::",
            "-DHDF5_MSVC_NAMING_CONVENTION=OFF",
            "-DBUILD_SHARED_LIBS=ON",
            "-DONLY_SHARED_LIBS=ON",
            "-DBUILD_STATIC_LIBS=OFF",
            "-DHDF5_BUILD_CPP_LIB=ON",
            "-DALLOW_UNSUPPORTED=ON",
            "-DHDF5_ENABLE_THREADSAFE=ON"
        }
        import("package.tools.cmake").install(package, configs)
        package:addenv("HDF5_ROOT", path.join(package:installdir("cmake")))
        package:addenv("PATH", package:installdir("bin"))
    end)

    on_test("macosx", function (package)
        if package:config("shared") then
            os.vrun("h5diff-shared --version")
        else
            os.vrun("h5diff --version")
        end
        assert(package:has_cfuncs("H5open", {includes = "H5public.h"}))

        if package:config("cpplib") then
             assert(package:check_cxxsnippets({test = [[
                void test() {
                    H5::H5Library::open();
                }
            ]]}, {configs = {languages = "c++17"}, includes = {"H5Cpp.h"}}))
        end
    end)
