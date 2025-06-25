cmake_minimum_required(VERSION 3.24)

# Project structure
project(myapp
        VERSION 0.1.0
        LANGUAGES C)
add_executable(myapp src/main.c)

# Installation
install(TARGETS myapp DESTINATION bin)
