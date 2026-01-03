# Install script for directory: /Users/zhoujf/TagLib/taglib/taglib

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/Users/zhoujf/TagLib/build-xcframework/install/x86_64")
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

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/Users/zhoujf/TagLib/build-xcframework/x86_64/taglib/libtag.a")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libtag.a" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libtag.a")
    execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libtag.a")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/taglib" TYPE FILE FILES
    "/Users/zhoujf/TagLib/taglib/taglib/tag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/fileref.h"
    "/Users/zhoujf/TagLib/taglib/taglib/audioproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/taglib_export.h"
    "/Users/zhoujf/TagLib/build-xcframework/x86_64/taglib/../taglib_config.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/taglib.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tstring.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tlist.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tlist.tcc"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tstringlist.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tbytevector.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tbytevectorlist.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tvariant.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tbytevectorstream.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tiostream.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tfilestream.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tmap.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tmap.tcc"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tpicturetype.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tpropertymap.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tdebuglistener.h"
    "/Users/zhoujf/TagLib/taglib/taglib/toolkit/tversionnumber.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/mpegfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/mpegproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/mpegheader.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/xingheader.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v1/id3v1tag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v1/id3v1genres.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/id3v2.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/id3v2extendedheader.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/id3v2frame.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/id3v2header.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/id3v2synchdata.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/id3v2footer.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/id3v2framefactory.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/id3v2tag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/attachedpictureframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/commentsframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/eventtimingcodesframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/generalencapsulatedobjectframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/ownershipframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/popularimeterframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/privateframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/relativevolumeframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/synchronizedlyricsframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/textidentificationframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/uniquefileidentifierframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/unknownframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/unsynchronizedlyricsframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/urllinkframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/chapterframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/tableofcontentsframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpeg/id3v2/frames/podcastframe.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/oggfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/oggpage.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/oggpageheader.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/xiphcomment.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/vorbis/vorbisfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/vorbis/vorbisproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/flac/oggflacfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/speex/speexfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/speex/speexproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/opus/opusfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ogg/opus/opusproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/flac/flacfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/flac/flacpicture.h"
    "/Users/zhoujf/TagLib/taglib/taglib/flac/flacproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/flac/flacmetadatablock.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ape/apefile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ape/apeproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ape/apetag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ape/apefooter.h"
    "/Users/zhoujf/TagLib/taglib/taglib/ape/apeitem.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpc/mpcfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mpc/mpcproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/wavpack/wavpackfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/wavpack/wavpackproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/trueaudio/trueaudiofile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/trueaudio/trueaudioproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/riff/rifffile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/riff/aiff/aifffile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/riff/aiff/aiffproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/riff/wav/wavfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/riff/wav/wavproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/riff/wav/infotag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/asf/asffile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/asf/asfproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/asf/asftag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/asf/asfattribute.h"
    "/Users/zhoujf/TagLib/taglib/taglib/asf/asfpicture.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mp4/mp4file.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mp4/mp4atom.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mp4/mp4tag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mp4/mp4item.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mp4/mp4properties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mp4/mp4coverart.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mp4/mp4itemfactory.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mod/modfilebase.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mod/modfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mod/modtag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/mod/modproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/it/itfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/it/itproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/s3m/s3mfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/s3m/s3mproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/xm/xmfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/xm/xmproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/dsf/dsffile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/dsf/dsfproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/dsdiff/dsdifffile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/dsdiff/dsdiffproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/dsdiff/dsdiffdiintag.h"
    "/Users/zhoujf/TagLib/taglib/taglib/shorten/shortenfile.h"
    "/Users/zhoujf/TagLib/taglib/taglib/shorten/shortenproperties.h"
    "/Users/zhoujf/TagLib/taglib/taglib/shorten/shortentag.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/taglib/taglib-targets.cmake")
    file(DIFFERENT EXPORT_FILE_CHANGED FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/taglib/taglib-targets.cmake"
         "/Users/zhoujf/TagLib/build-xcframework/x86_64/taglib/CMakeFiles/Export/lib/cmake/taglib/taglib-targets.cmake")
    if(EXPORT_FILE_CHANGED)
      file(GLOB OLD_CONFIG_FILES "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/taglib/taglib-targets-*.cmake")
      if(OLD_CONFIG_FILES)
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/taglib/taglib-targets.cmake\" will be replaced.  Removing files [${OLD_CONFIG_FILES}].")
        file(REMOVE ${OLD_CONFIG_FILES})
      endif()
    endif()
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/taglib" TYPE FILE FILES "/Users/zhoujf/TagLib/build-xcframework/x86_64/taglib/CMakeFiles/Export/lib/cmake/taglib/taglib-targets.cmake")
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/taglib" TYPE FILE FILES "/Users/zhoujf/TagLib/build-xcframework/x86_64/taglib/CMakeFiles/Export/lib/cmake/taglib/taglib-targets-release.cmake")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/taglib" TYPE FILE FILES
    "/Users/zhoujf/TagLib/build-xcframework/x86_64/taglib-config.cmake"
    "/Users/zhoujf/TagLib/build-xcframework/x86_64/taglib-config-version.cmake"
    )
endif()

