set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_VERSION 4.20)
set(CMAKE_SYSTEM_PROCESSOR ARM)

set(CMAKE_C_COMPILER arm-mingw32ce-gcc)
set(CMAKE_CXX_COMPILER arm-mingw32ce-g++)
set(CMAKE_RC_COMPILER arm-mingw32ce-windres)
set(CMAKE_AR arm-mingw32ce-ar)
set(CMAKE_RANLIB arm-mingw32ce-ranlib)

# Avoid CMake's compiler probes trying to execute or fully link a host-incompatible
# test application during cross configuration.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(WINCE_COMMON_FLAGS "-mcpu=xscale -mwin32 -D_WIN32_WCE=0x0420 -D_WIN32_IE=0x0420 -DWIN32_PLATFORM_PSPC=400 -DUNICODE -D_UNICODE")
set(CMAKE_C_FLAGS_INIT "${WINCE_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${WINCE_COMMON_FLAGS} -std=gnu++20")

set(CMAKE_FIND_ROOT_PATH /opt/cegcc-arm)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
