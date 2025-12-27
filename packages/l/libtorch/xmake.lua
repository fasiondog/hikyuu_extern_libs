package("libtorch")

    set_homepage("https://pytorch.org/")
    set_description("Torch is a Python package that provides a GPU accelerated tensor library.")

    if is_plat("windows") then
        add_urls("https://download.pytorch.org/libtorch/cu128/libtorch-win-shared-with-deps-$(version)%2Bcu128.zip")
        add_versions("2.9.1", "e4688a0e16afcca9753743a977c4038179fa7d1583514333a68ab972d267e1db")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://download.pytorch.org/libtorch/cu128/libtorch-shared-with-deps-2.9.1%2Bcu128.zip")
        add_versions("2.9.1", "b052452965093db69f537b3cf376812d5acf6dca28819b20d28d7f0b171d7699")
    elseif is_plat("macosx") and is_arch("arm64.*") then
        add_urls("https://download.pytorch.org/libtorch/cpu/libtorch-macos-arm64-2.9.1.zip")
        add_versions("2.9.1", "c469e516b5d970eeda294aabd1f16d9a0368931c3eed30263746f7fba7cd9b96")
    end

    on_load(function (package)
        package:add("includedirs", "include", "include/torch/csrc/api/include")
        if package:is_plat("linux") then
            package:add("shflags", "-Wl,--no-as-needed -ltorch_cuda")
            package:add("ldflags", "-Wl,--no-as-needed -ltorch_cuda")
        end
    end)

    on_install("windows|x64", "linux|x86_64", "macosx|arm64", function (package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("share", package:installdir())
        if package:is_plat("windows") then
            os.cp("bin", package:installdir())
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto a = torch::ones(3);
                auto b = torch::tensor({1, 2, 3});
                auto c = torch::dot(a, b);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "torch/torch.h"}))
    end)