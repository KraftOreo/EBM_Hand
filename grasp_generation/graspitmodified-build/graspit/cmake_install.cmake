# Install script for directory: /home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified_lm/graspit

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/usr/local/bin/graspit_pose_refine" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/usr/local/bin/graspit_pose_refine")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/usr/local/bin/graspit_pose_refine"
         RPATH "")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/bin/graspit_pose_refine")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/bin" TYPE EXECUTABLE FILES "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/graspit_pose_refine")
  if(EXISTS "$ENV{DESTDIR}/usr/local/bin/graspit_pose_refine" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/usr/local/bin/graspit_pose_refine")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/usr/local/bin/graspit_pose_refine"
         OLD_RPATH "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit:/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/coin/install-custom/lib:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}/usr/local/bin/graspit_pose_refine")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/usr/local/lib/libgraspit.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/usr/local/lib/libgraspit.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/usr/local/lib/libgraspit.so"
         RPATH "")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/libgraspit.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/lib" TYPE SHARED_LIBRARY FILES "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/libgraspit.so")
  if(EXISTS "$ENV{DESTDIR}/usr/local/lib/libgraspit.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/usr/local/lib/libgraspit.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/usr/local/lib/libgraspit.so"
         OLD_RPATH "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/coin/install-custom/lib:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}/usr/local/lib/libgraspit.so")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/include//graspit/")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/include//graspit" TYPE DIRECTORY FILES "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified_lm/graspit/include/graspit/")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/include/graspit/ui/ui_mainWindow.h;/usr/local/include/graspit/ui/ui_about.h;/usr/local/include/graspit/ui/ui_archBuilderDlg.h;/usr/local/include/graspit/ui/ui_barrettHandDlg.h;/usr/local/include/graspit/ui/ui_bodyPropDlg.h;/usr/local/include/graspit/ui/ui_contactExaminerDlg.h;/usr/local/include/graspit/ui/ui_eigenGraspDlg.h;/usr/local/include/graspit/ui/ui_gfoDlg.h;/usr/local/include/graspit/ui/ui_gloveCalibrationDlg.h;/usr/local/include/graspit/ui/ui_graspCaptureDlg.h;/usr/local/include/graspit/ui/ui_gwsProjDlgBase.h;/usr/local/include/graspit/ui/ui_qmDlg.h;/usr/local/include/graspit/ui/ui_qualityIndicator.h;/usr/local/include/graspit/ui/ui_settingsDlg.h;/usr/local/include/graspit/ui/ui_plannerdlg.h;/usr/local/include/graspit/ui/ui_egPlannerDlg.h;/usr/local/include/graspit/ui/ui_compliantPlannerDlg.h;/usr/local/include/graspit/ui/ui_dbaseDlg.h;/usr/local/include/graspit/ui/ui_dbasePlannerDlg.h")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/include/graspit/ui" TYPE FILE FILES
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_mainWindow.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_about.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_archBuilderDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_barrettHandDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_bodyPropDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_contactExaminerDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_eigenGraspDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_gfoDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_gloveCalibrationDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_graspCaptureDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_gwsProjDlgBase.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_qmDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_qualityIndicator.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_settingsDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_plannerdlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_egPlannerDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_compliantPlannerDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_dbaseDlg.h"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/include/graspit/ui/ui_dbasePlannerDlg.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/usr/local/lib/libgraspit.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/usr/local/lib/libgraspit.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/usr/local/lib/libgraspit.so"
         RPATH "")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/libgraspit.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/lib" TYPE SHARED_LIBRARY PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ FILES "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/libgraspit.so")
  if(EXISTS "$ENV{DESTDIR}/usr/local/lib/libgraspit.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/usr/local/lib/libgraspit.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/usr/local/lib/libgraspit.so"
         OLD_RPATH "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/coin/install-custom/lib:"
         NEW_RPATH "")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}/usr/local/lib/libgraspit.so")
    endif()
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/usr/local/lib/cmake/graspit/graspitTargets.cmake")
    file(DIFFERENT EXPORT_FILE_CHANGED FILES
         "$ENV{DESTDIR}/usr/local/lib/cmake/graspit/graspitTargets.cmake"
         "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/CMakeFiles/Export/_usr/local/lib/cmake/graspit/graspitTargets.cmake")
    if(EXPORT_FILE_CHANGED)
      file(GLOB OLD_CONFIG_FILES "$ENV{DESTDIR}/usr/local/lib/cmake/graspit/graspitTargets-*.cmake")
      if(OLD_CONFIG_FILES)
        message(STATUS "Old export file \"$ENV{DESTDIR}/usr/local/lib/cmake/graspit/graspitTargets.cmake\" will be replaced.  Removing files [${OLD_CONFIG_FILES}].")
        file(REMOVE ${OLD_CONFIG_FILES})
      endif()
    endif()
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/cmake/graspit/graspitTargets.cmake")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/lib/cmake/graspit" TYPE FILE FILES "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/CMakeFiles/Export/_usr/local/lib/cmake/graspit/graspitTargets.cmake")
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "/usr/local/lib/cmake/graspit/graspitTargets-release.cmake")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "/usr/local/lib/cmake/graspit" TYPE FILE FILES "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/CMakeFiles/Export/_usr/local/lib/cmake/graspit/graspitTargets-release.cmake")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/cmake/graspit/graspitConfig.cmake;/usr/local/lib/cmake/graspit/graspitConfigVersion.cmake;/usr/local/lib/cmake/graspit/FindBULLET.cmake;/usr/local/lib/cmake/graspit/FindSoQt4.cmake")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/lib/cmake/graspit" TYPE FILE FILES
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/CMakeFiles/graspitConfig.cmake"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/graspitConfigVersion.cmake"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified_lm/graspit/CMakeMacros/FindBULLET.cmake"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified_lm/graspit/CMakeMacros/FindSoQt4.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/liujian/.graspit/worlds;/home/liujian/.graspit/models;/home/liujian/.graspit/images")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/home/liujian/.graspit" TYPE DIRECTORY FILES
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified_lm/graspit/worlds"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified_lm/graspit/models"
    "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified_lm/graspit/images"
    )
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified-build/graspit/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
