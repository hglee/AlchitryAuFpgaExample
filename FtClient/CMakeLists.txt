cmake_minimum_required (VERSION 3.10)
project (FtClient)

set (CMAKE_C_STANDARD 99)
set (CMAKE_CXX_STANDARD 20)

set (CMAKE_EXPORT_COMPILE_COMMANDS 1)

if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE "Release")
endif (NOT CMAKE_BUILD_TYPE)

# compiler flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set (CMAKE_C_FLAGS "/W2 /DFTD3XX_STATIC")
  set (CMAKE_C_FLAGS_DEBUG "/Od")
  set (CMAKE_C_FLAGS_RELEASE "/O2")

  set (CMAKE_CXX_FLAGS "/W2 /DFTD3XX_STATIC /EHsc")
  set (CMAKE_CXX_FLAGS_DEBUG "/Od")
  set (CMAKE_CXX_FLAGS_RELEASE "/O2")
else ()
  set (CMAKE_C_FLAGS "-Wall")
  set (CMAKE_C_FLAGS_DEBUG "-g -O0")
  set (CMAKE_C_FLAGS_RELEASE "-O2 -march=native -DNDEBUG")

  set (CMAKE_CXX_FLAGS "-Wall -Wextra")
  set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
  set (CMAKE_CXX_FLAGS_RELEASE "-O2 -march=native -DNDEBUG")
endif ()

# platform definitions
set (target_bit x86)
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
  set (target_bit x64)
endif()

set (target_platform Linux)
set (target_lib ftd3xx-static pthread rt m)
if (WIN32)
  set (target_platform Windows)
  set (target_lib FTD3XX)
endif()

# TestWrite
add_executable (TestWrite
  src/Ftd3xxWrapper.cpp
  src/StatisticsReport.cpp
  src/TestWrite.cpp
  )

target_link_directories (TestWrite PUBLIC
  ftd3xx/${target_platform}/lib/${target_bit})

target_link_libraries (TestWrite
  ${target_lib}
  )

target_include_directories (TestWrite PUBLIC
  src
  ftd3xx/${target_platform}/include
  )

# TestRead
add_executable (TestRead
  src/Ftd3xxWrapper.cpp
  src/StatisticsReport.cpp
  src/TestRead.cpp
  )

target_link_directories (TestRead PUBLIC
  ftd3xx/${target_platform}/lib/${target_bit})

target_link_libraries (TestRead
  ${target_lib}
  )

target_include_directories (TestRead PUBLIC
  src
  ftd3xx/${target_platform}/include
  )
