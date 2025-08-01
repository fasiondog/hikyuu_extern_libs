package("pybind11")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/pybind/pybind11")
    set_description("Seamless operability between C++11 and Python.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/pybind/pybind11/archive/$(version).zip",
             "https://github.com/pybind/pybind11.git")
    add_versions("v3.0.0", "dfe152af2f454a9d8cd771206c014aecb8c3977822b5756123f29fd488648334")
    add_versions("v2.11.1", "b011a730c8845bfc265f0f81ee4e5e9e1d354df390836d2a25880e123d021f89")
    add_versions("v2.13.1", "a3c9ea1225cb731b257f2759a0c12164db8409c207ea5cf851d4b95679dda072")             
    add_versions("v2.13.6", "d0a116e91f64a4a2d8fb7590c34242df92258a61ec644b79127951e821b47be6") 

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    -- on_test(function (package)
    --     assert(package:check_cxxsnippets({test = [[
    --         #include <pybind11/pybind11.h>
    --         int add(int i, int j) {
    --             return i + j;
    --         }
    --         PYBIND11_MODULE(example, m) {
    --             m.def("add", &add, "A function which adds two numbers");
    --         }
    --     ]]}, {configs = {languages = "c++11"}}))
    -- end)