cmake_minimum_required(VERSION 3.5)


project(example LANGUAGES CXX)
# Enable testing
enable_testing()


# ============================================================================
# Cppcheck Configuration
# ============================================================================

if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 14)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

option(${PROJECT_NAME}_SHARED_LIBS "Build shared libraries" OFF)
if(DEFINED BUILD_SHARED_LIBS)
    set(${PROJECT_NAME}_SHARED_LIBS ${BUILD_SHARED_LIBS})
endif()




# Sets outputs directories to binary_dir/
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")



# ============================================================================
# Cppcheck Configuration
# ============================================================================
# Used for coding warnings
find_program(cppcheck_program NAMES cppcheck)
if(cppcheck_program)
    list(
        APPEND CMAKE_CXX_CPPCHECK ${cppcheck_program}
        "--enable=warning"
        "--inconclusive"
        "--force"
        "--inline-suppr"
        "--suppressions-list=${CMAKE_CURRENT_SOURCE_DIR}/CppCheckSuppressions.txt"
    )

    message(STATUS "Found CppCheck")
else()
    message(STATUS "Could NOT find CppCheck")
endif()



# ============================================================================
# Project Configuration
# ============================================================================



# Compile submodule dependencies
add_subdirectory(thirdparty)

##############################
# Add project subdirectories #
##############################
set(example_source_dir ${CMAKE_CURRENT_SOURCE_DIR})
set(example_include_dir ${example_source_dir}/include)

add_subdirectory(src)

find_package(Threads REQUIRED)

message(STATUS "Composing libraries: ${build_libraries}")

add_library(${PROJECT_NAME}
    ### Whatever is in the library
)
target_include_directories(${PROJECT_NAME}
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PUBLIC $<INSTALL_INTERFACE:include>)

add_library(ALIAS::example ALIAS ${PROJECT_NAME})


target_link_libraries(${PROJECT_NAME} PUBLIC
    ### Libraries
)


# Library/Archive output directory
set_target_properties(${PROJECT_NAME} PROPERTIES
    PREFIX lib
    OUTPUT_NAME example
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)


option(BUILD_TESTING "Build the testing tree." OFF)
if(BUILD_TESTING)
    message(STATUS "Building tests")
    add_subdirectory(test)
else()
    message(STATUS "Not building tests")
endif()

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
    COMPONENT ${PROJECT_NAME}
)




# ============================================================================
# Install Configuration
# ============================================================================

# We generate different targets files depending on the type of library we 
# are generating shared or static 

if(${PROJECT_NAME}_SHARED_LIBS)
    set(type shared)
else()
    set(type static)
endif()

# Install prefix for searching for dependencies is library origin
set(CMAKE_INSTALL_RPATH $ORIGIN)
install(EXPORT ${PROJECT_NAME}Targets
    FILE example-${type}-targets.cmake
    NAMESPACE ALIAS::
    DESTINATION lib/cmake/example
    COMPONENT ${PROJECT_NAME}
)

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/exampleConfig.cmake"
    DESTINATION lib/cmake/example
    COMPONENT ${PROJECT_NAME})




# ============================================================================
# Parse Version from GIT TAG 
# ============================================================================


include(cmake/GitVersion.cmake)
get_version_from_git()

# ============================================================================
# Doxygen Configuration
# ============================================================================

find_package(Doxygen)
option(BUILD_DOCUMENTATION "Create and install the HTML based API        
documentation (requires Doxygen)"    ${DOXYGEN_FOUND})

if(${BUILD_DOCUMENTATION})


    add_custom_target(docs ALL
        COMMAND ${DOXYGEN_EXECUTABLE} -d preprocessor ${CMAKE_CURRENT_SOURCE_DIR}/doc/Doxyfile > /dev/null 2>&1
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Generating API documentation with Doxygen"
        BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}doc/html ${CMAKE_CURRENT_SOURCE_DIR}doc/latex
        DEPENDS doc/Doxyfile
        VERBATIM
    )
    file(CONFIGURE OUTPUT doc/Doxyfile CONTENT ${CMAKE_CURRENT_SOURCE_DIR}/cmake/templates/Doxyfile.in @ONLY)
    set_target_properties(docs PROPERTIES CMAKE_CONFIGURE_DEPENDS)
    add_custom_command(TARGET docs POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_CURRENT_SOURCE_DIR}/config
        ${CMAKE_CURRENT_SOURCE_DIR}/doc/html/config
        COMMENT "Copying config directory to Doxygen HTML output"
    )
endif()

# ============================================================================
# Versioning Configuration
# ============================================================================


configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/templates/version.h.in include/example/version.h @ONLY)


# ============================================================================
# CPack Configuration
# ============================================================================

# --- Basic Package Metadata ---
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "RPCPACKDESCRIPTION")
set(CPACK_PACKAGE_VENDOR "RPCPACKVENDOR")
set(CPACK_PACKAGE_CONTACT "RPCPACKCONTACT")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")


# --- Component Setup ---
# This matches the COMPONENT arguments in install()
set(CPACK_COMPONENTS_GROUPING ALL_COMPONENTS_IN_ONE)
# set(CPACK_COMPONENT_${PROJECT_NAME}_DISPLAY_NAME "Development Files")
# set(CPACK_COMPONENT_${PROJECT_NAME}_DESCRIPTION "Headers and static libraries for developing applications with MyAwesomeLib.")

# --- Generator-Specific Settings ---

# For ZIP/TGZ (archive generators)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)

# For DEB generator (Debian/Ubuntu)
set(CPACK_DEB_COMPONENT_INSTALL ON)
set(CPACK_DEB_PACKAGE_MAINTAINER "${CPACK_PACKAGE_CONTACT}")

# For RPM generator (Fedora/CentOS)
set(CPACK_RPM_COMPONENT_INSTALL ON)
set(CPACK_RPM_PACKAGE_RELEASE 1)
set(CPACK_RPM_PACKAGE_LICENSE "RPLICENSERPM") # Use a standard license identifier (e.g., MIT, BSD, GPLv3)

# --- Include CPack at the end ---
include(CPack)
