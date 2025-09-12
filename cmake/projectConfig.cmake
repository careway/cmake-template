cmake_minimum_required(VERSION 3.5)


set(example_install_prefix_ "${CMAKE_CURRENT_LIST_DIR}/..")

if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.19")
    file(REAL_PATH "${example_install_prefix_}" example_install_prefix_)
else()
    get_filename_component(example_install_prefix_ "${example_install_prefix_}" ABSOLUTE)
endif()

# Place here your required packages
# Example: 
# find_package(Threads REQUIRED)


set(example_known_comps static shared)
set(example_comp_static NO)
set(example_comp_shared NO)
foreach (example_comp IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (example_comp IN_LIST example_known_comps)
        set(example_comp_${example_comp} YES)
    else ()
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
            "example does not recognize component `${example_comp}`.")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        return()
    endif ()
endforeach ()

if (example_comp_static AND example_comp_shared)
    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
        "example `static` and `shared` components are mutually exclusive.")
    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    return()
endif ()

set(example_static_targets "${CMAKE_CURRENT_LIST_DIR}/example-static-targets.cmake")
set(example_shared_targets "${CMAKE_CURRENT_LIST_DIR}/example-shared-targets.cmake")

macro(example_load_targets type)
    if (NOT EXISTS "${example_${type}_targets}")
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
            "example `${type}` libraries were requested but not found.")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        return()
    endif ()
    include("${example_${type}_targets}")
endmacro()

if (example_comp_static)
    example_load_targets(static)
elseif (example_comp_shared)
    example_load_targets(shared)
elseif (DEFINED example_SHARED_LIBS AND example_SHARED_LIBS)
    example_load_targets(shared)
elseif (DEFINED example_SHARED_LIBS AND NOT example_SHARED_LIBS)
    example_load_targets(static)
elseif (BUILD_SHARED_LIBS)
    if (EXISTS "${example_shared_targets}")
        example_load_targets(shared)
    else ()
        example_load_targets(static)
    endif ()
else ()
    if (EXISTS "${example_static_targets}")
        example_load_targets(static)
    else ()
        example_load_targets(shared)
    endif ()
endif ()