macro(build_so_lib_from_matlab files ${codegen_libraries})
  find_package(Matlab REQUIRED)

  catkin_package()
  
  include_directories(
    include ${Matlab_ROOT_DIR}/extern/include
  )

  set(library "")

  foreach(filename ${files})
    get_filename_component(filename_we ${filename} NAME_WE)
    list(APPEND library ${filename_we})

    execute_process(COMMAND matlab -nodisplay -nodesktop -r "run ${CMAKE_CURRENT_SOURCE_DIR}/m_files/build_lib_${filename_we}")
    
    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/m_files/codegen_files/${filename_we})
      execute_process(COMMAND bash -c "mkdir ${CMAKE_CURRENT_SOURCE_DIR}/m_files/${filename_we}")
      execute_process(COMMAND bash -c "mkdir ${CMAKE_CURRENT_SOURCE_DIR}/include/${filename_we}")
      execute_process(COMMAND bash -c "mkdir ${CMAKE_CURRENT_SOURCE_DIR}/src/${filename_we}")
    endif()
    
    execute_process(COMMAND bash -c "cp ${CMAKE_CURRENT_SOURCE_DIR}/m_files/codegen_files/* ${CMAKE_CURRENT_SOURCE_DIR}/m_files/${filename_we}")
    execute_process(COMMAND bash -c "cp -R ${CMAKE_CURRENT_SOURCE_DIR}/m_files/codegen_files/* ${CMAKE_CURRENT_SOURCE_DIR}/m_files/${filename_we}")
    execute_process(COMMAND bash -c "rm -rf ${CMAKE_CURRENT_SOURCE_DIR}/m_files/codegen_files")
    execute_process(COMMAND bash -c "cp ${CMAKE_CURRENT_SOURCE_DIR}/m_files/${filename_we}/*.cpp ${CMAKE_CURRENT_SOURCE_DIR}/src/${filename_we}")
    execute_process(COMMAND bash -c "cp ${CMAKE_CURRENT_SOURCE_DIR}/m_files/${filename_we}/*.h ${CMAKE_CURRENT_SOURCE_DIR}/include/${filename_we}")

    file(GLOB sources ${CMAKE_CURRENT_SOURCE_DIR}/src/${filename_we}/*.cpp)
    file(GLOB headers ${CMAKE_CURRENT_SOURCE_DIR}/include/${filename_we}/*.h)

    include_directories(
      include ${CMAKE_CURRENT_SOURCE_DIR}/include/${filename_we}
    )

    add_library(${filename_we}
      ${sources}
    )

    target_include_directories(${filename_we} PUBLIC include)

    install(TARGETS ${filename_we}
      ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
      LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
      RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
    )

  endforeach(filename ${files})

  set(codegen_libraries "${library}")
endmacro()