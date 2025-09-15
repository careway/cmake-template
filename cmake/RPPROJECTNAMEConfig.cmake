cmake_minimum_required(VERSION 3.5)


set(RPPROJECTNAME_install_prefix_ "${CMAKE_CURRENT_LIST_DIR}/..")

if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.19")
    file(REAL_PATH "${RPPROJECTNAME_install_prefix_}" RPPROJECTNAME_install_prefix_)
else()
    get_filename_component(RPPROJECTNAME_install_prefix_ "${RPPROJECTNAME_install_prefix_}" ABSOLUTE)
endif()

# Place here your required packages
# Example: 
# find_package(Threads REQUIRED)


set(RPPROJECTNAME_known_comps static shared)
set(RPPROJECTNAME_comp_static NO)
set(RPPROJECTNAME_comp_shared NO)
foreach (RPPROJECTNAME_comp IN LISTS ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    if (RPPROJECTNAME_comp IN_LIST RPPROJECTNAME_known_comps)
        set(RPPROJECTNAME_comp_${RPPROJECTNAME_comp} YES)
    else ()
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
            "RPPROJECTNAME does not recognize component `${RPPROJECTNAME_comp}`.")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        return()
    endif ()
endforeach ()

if (RPPROJECTNAME_comp_static AND RPPROJECTNAME_comp_shared)
    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
        "RPPROJECTNAME `static` and `shared` components are mutually exclusive.")
    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    return()
endif ()

set(RPPROJECTNAME_static_targets "${CMAKE_CURRENT_LIST_DIR}/RPPROJECTNAME-static-targets.cmake")
set(RPPROJECTNAME_shared_targets "${CMAKE_CURRENT_LIST_DIR}/RPPROJECTNAME-shared-targets.cmake")

macro(RPPROJECTNAME_load_targets type)
    if (NOT EXISTS "${RPPROJECTNAME_${type}_targets}")
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE
            "RPPROJECTNAME `${type}` libraries were requested but not found.")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
        return()
    endif ()
    include("${RPPROJECTNAME_${type}_targets}")
endmacro()

if (RPPROJECTNAME_comp_static)
    RPPROJECTNAME_load_targets(static)
elseif (RPPROJECTNAME_comp_shared)
    RPPROJECTNAME_load_targets(shared)
elseif (DEFINED RPPROJECTNAME_SHARED_LIBS AND RPPROJECTNAME_SHARED_LIBS)
    RPPROJECTNAME_load_targets(shared)
elseif (DEFINED RPPROJECTNAME_SHARED_LIBS AND NOT RPPROJECTNAME_SHARED_LIBS)
    RPPROJECTNAME_load_targets(static)
elseif (BUILD_SHARED_LIBS)
    if (EXISTS "${RPPROJECTNAME_shared_targets}")
        RPPROJECTNAME_load_targets(shared)
    else ()
        RPPROJECTNAME_load_targets(static)
    endif ()
else ()
    if (EXISTS "${RPPROJECTNAME_static_targets}")
        RPPROJECTNAME_load_targets(static)
    else ()
        RPPROJECTNAME_load_targets(shared)
    endif ()
endif ()