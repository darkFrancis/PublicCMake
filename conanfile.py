from conans import ConanFile, CMake, tools

class CommonQtCMakeConan(ConanFile):
    name = "CommonQtCMake"
    version = "0.1"
    license = "Copyright Dark Francis"
    author = "DarkFrancis dark.francis.dod@gmail.com"
    description = "Basic Qt CMake files"
    exports_sources = "*.cmake"
    no_copy_source = True

    def package(self):
        self.copy("*.cmake")

