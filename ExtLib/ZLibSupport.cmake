# Adds install rules for zlib
function(AddZLibInstallRules)
  set(options)
  set(oneValueArgs LIB_DIR)
  set(multiValueArgs TYPES)
  cmake_parse_arguments(Z "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(INSTALL_DIR "lib")
  if(WIN32)
    set(INSTALL_DIR ".")
  endif()

  if(WIN32)
    set(ZLIB_LIB_DIR "${Z_LIB_DIR}/bin")
    set(ZLIB_LIB_TYPE "dll")
  else()
    set(ZLIB_LIB_DIR "${Z_LIB_DIR}/lib")
    set(ZLIB_LIB_TYPE "so")
  endif()

  foreach(TYPE ${Z_TYPES})
    string(TOUPPER ${TYPE} TYPE_UPPER)

    if(${TYPE_UPPER} STREQUAL "DEBUG")
      if(WIN32)
        set(ZLIB_NAME "zlibd1")
      else()
        set(ZLIB_NAME "libz")
      endif()
    else()
      if(WIN32)
        set(ZLIB_NAME "zlib1")
      else()
        set(ZLIB_NAME "libz")
      endif()
    endif()

    set(LIB_PATH "${ZLIB_LIB_DIR}/${ZLIB_NAME}.${ZLIB_LIB_TYPE}")
    install(FILES ${LIB_PATH} DESTINATION ${INSTALL_DIR} CONFIGURATIONS ${TYPE} COMPONENT Applications)
  endforeach()
endfunction()

# Adds copy custom target for zlib
function(AddZLibCopyRules)
  set(options)
  set(oneValueArgs NAME LIB_DIR)
  set(multiValueArgs TYPES)
  cmake_parse_arguments(Z "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(INTER_DIR ".")

  if(WIN32)
    set(ZLIB_LIB_DIR "${Z_LIB_DIR}/bin")
    set(ZLIB_LIB_TYPE "dll")
  else()
    set(ZLIB_LIB_DIR "${Z_LIB_DIR}/lib")
    set(ZLIB_LIB_TYPE "so")
  endif()

  foreach(TYPE ${Z_TYPES})
    string(TOUPPER ${TYPE} TYPE_UPPER)
    if(MSVC_IDE)
      set(INTER_DIR "${TYPE}")
    endif()

    if(${TYPE_UPPER} STREQUAL "DEBUG")
      if(WIN32)
        set(ZLIB_NAME "zlibd1")
      else()
        set(ZLIB_NAME "libz")
      endif()
    else()
      if(WIN32)
        set(ZLIB_NAME "zlib1")
      else()
        set(ZLIB_NAME "libz")
      endif()
    endif()

    set(LIB_PATH "${ZLIB_LIB_DIR}/${ZLIB_NAME}.${ZLIB_LIB_TYPE}")

    if(NOT TARGET ZZ_${Z_NAME}_DLL_${TYPE}-Copy)
      add_custom_target(ZZ_${Z_NAME}_DLL_${TYPE}-Copy ALL
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LIB_PATH}
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${INTER_DIR}/
      )
      set_target_properties(ZZ_${Z_NAME}_DLL_${TYPE}-Copy PROPERTIES FOLDER ZZ_COPY_FILES/${TYPE}/${Z_NAME})
    endif()
  endforeach()
endfunction()

# Adds copy targets and/or install rules for zlib
function(CMP_FindZLib)
  set(options COPY INSTALL)
  set(oneValueArgs LIB_DIR)
  set(multiValueArgs)
  cmake_parse_arguments(Z "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT APPLE)
    if(MSVC_IDE)
      set(BUILD_TYPES Debug Release)
    else()
      set(BUILD_TYPES "${CMAKE_BUILD_TYPE}")
      if("${BUILD_TYPES}" STREQUAL "")
          set(BUILD_TYPES "Debug")
      endif()
    endif()

    if(Z_COPY)
      AddZLibCopyRules(NAME "zlib" LIB_DIR ${Z_LIB_DIR} TYPES ${BUILD_TYPES})
    endif()

    if(Z_INSTALL)
      AddZLibInstallRules(LIB_DIR ${Z_LIB_DIR} TYPES ${BUILD_TYPES})
    endif()
  endif()
endfunction()
