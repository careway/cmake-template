include(${CMAKE_CURRENT_LIST_DIR}/GitVersion.cmake)
get_version_from_git()

configure_file(${DOXYFILE_IN} ${DOXYFILE_OUT} @ONLY)
configure_file(${CMAKE_CURRENT_LIST_DIR}/templates/version.h.in ${CMAKE_SOURCE_DIR}/include/RPPROJECTNAME/version.h @ONLY)
