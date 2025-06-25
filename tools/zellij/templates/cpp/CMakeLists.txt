cmake_minimum_required(VERSION 3.24)

# Project structure
project(myapp
        VERSION 0.1.0
        LANGUAGES CXX)
add_executable(myapp src/main.cpp)

# Dependencies
find_package(fmt REQUIRED)
target_link_libraries(myapp PRIVATE fmt::fmt)

# Installation
install(TARGETS myapp DESTINATION bin)
