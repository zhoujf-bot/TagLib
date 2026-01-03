if (NOT EXISTS "/Users/zhoujf/TagLib/build-xcframework/arm64/install_manifest.txt")
  message(FATAL_ERROR "Cannot find install manifest: \"/Users/zhoujf/TagLib/build-xcframework/arm64/install_manifest.txt\"")
endif()

file(READ "/Users/zhoujf/TagLib/build-xcframework/arm64/install_manifest.txt" files)
string(REGEX REPLACE "\n" ";" files "${files}")
foreach (file ${files})
  message(STATUS "Uninstalling \"$ENV{DESTDIR}${file}\"")
  if (EXISTS "$ENV{DESTDIR}${file}")
    execute_process(
      COMMAND /opt/homebrew/Cellar/cmake/3.20.5/bin/cmake -E remove "$ENV{DESTDIR}${file}"
      OUTPUT_VARIABLE rm_out
      RESULT_VARIABLE rm_retval
    )
    if(NOT ${rm_retval} EQUAL 0)
      message(FATAL_ERROR "Problem when removing \"$ENV{DESTDIR}${file}\"")
    endif ()
  else ()
    message(STATUS "File \"$ENV{DESTDIR}${file}\" does not exist.")
  endif ()
endforeach()
