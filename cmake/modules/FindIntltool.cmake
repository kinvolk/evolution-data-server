# FindIntltool.cmake
#
# Searches for intltool and gettext. It aborts, if anything cannot be found.
# Requires GETTEXT_PO_DIR to be set to full path of the po/ directory.
#
# Output is:
#   INTLTOOL_UPDATE  - an intltool-update executable path, as found
#   INTLTOOL_EXTRACT  - an intltool-extract executable path, as found
#   INTLTOOL_MERGE  - an intltool-merge executable path, as found
#
# and anything from the FindGettext module.
#
# The below provided macros require GETTEXT_PACKAGE to be set.
#
# intltool_add_pot_file_target()
#    Creates a new target pot-file, which generates ${GETTEXT_PACKAGE}.pot file into
#    the CMAKE_CURERNT_BINARY_DIR. This target is not part of ALL.
#    This can be called only inside GETTEXT_PO_DIR.
#
# intltool_process_po_files(_po_files_var)
#    Processes all files in the list variable _po_files_var, which are
#    located in CMAKE_CURRENT_SOURCE_DIR and generates .gmo files for them
#    in CMAKE_CURRENT_BINARY_DIR. These are added into a new target gmo-files.
#    It also installs them into proper location under LOCALE_INSTALL_DIR.
#    This can be called only inside GETTEXT_PO_DIR.
#
# intltool_merge(_in_filename _out_filename ...args)
#    Adds rule to call intltool-merge. The args are optional arguments.
#    This can be called in any folder, only the GETTEXT_PO_DIR should
#    be properly set, otherwise the call will fail.

include(FindGettext)

if(NOT GETTEXT_FOUND)
	message(FATAL_ERROR "gettext not found, please install at least 0.18.3 version")
endif(NOT GETTEXT_FOUND)

if(NOT GETTEXT_FOUND)
	message(FATAL_ERROR "gettext not found, please install at least 0.18.3 version")
endif(NOT GETTEXT_FOUND)

if(GETTEXT_VERSION_STRING VERSION_LESS "0.18.3")
	message(FATAL_ERROR "gettext version 0.18.3+ required, but version '${GETTEXT_VERSION_STRING}' found instead. Please update your gettext")
endif(GETTEXT_VERSION_STRING VERSION_LESS "0.18.3")

find_program(XGETTEXT xgettext)
if(NOT XGETTEXT)
	message(FATAL_ERROR "xgettext executable not found. Please install or update your gettext to at least 0.18.3 version")
endif(NOT XGETTEXT)

find_program(INTLTOOL_UPDATE intltool-update)
if(NOT INTLTOOL_UPDATE)
	message(FATAL_ERROR "intltool-update not found. Please install it (usually part of an 'intltool' package)")
endif(NOT INTLTOOL_UPDATE)

find_program(INTLTOOL_EXTRACT intltool-extract)
if(NOT INTLTOOL_EXTRACT)
	message(FATAL_ERROR "intltool-extract not found. Please install it (usually part of an 'intltool' package)")
endif(NOT INTLTOOL_EXTRACT)

find_program(INTLTOOL_MERGE intltool-merge)
if(NOT INTLTOOL_MERGE)
	message(FATAL_ERROR "intltool-merge not found. Please install it (usually part of an 'intltool' package)")
endif(NOT INTLTOOL_MERGE)

macro(intltool_add_pot_file_target)
	if(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL GETTEXT_PO_DIR)
		message(FATAL_ERROR "intltool_add_pot_file_target() can be called only inside GETTEXT_PO_DIR ('${GETTEXT_PO_DIR}'), but it is called inside '${CMAKE_CURRENT_SOURCE_DIR}' instead")
	endif(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL GETTEXT_PO_DIR)

	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${GETTEXT_PACKAGE}.pot
		COMMAND cmake -E env INTLTOOL_EXTRACT="${INTLTOOL_EXTRACT}" XGETTEXT="${XGETTEXT}" srcdir=${CMAKE_CURRENT_SOURCE_DIR} ${INTLTOOL_UPDATE} --gettext-package ${GETTEXT_PACKAGE} --pot
	)

	add_custom_target(pot-file
		DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${GETTEXT_PACKAGE}.pot
	)
endmacro(intltool_add_pot_file_target)

macro(intltool_process_po_files)
	if(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL GETTEXT_PO_DIR)
		message(FATAL_ERROR "intltool_process_po_files() can be called only inside GETTEXT_PO_DIR ('${GETTEXT_PO_DIR}'), but it is called inside '${CMAKE_CURRENT_SOURCE_DIR}' instead")
	endif(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL GETTEXT_PO_DIR)

	file(GLOB po_files ${GETTEXT_PO_DIR}/*.po)

	set(LINGUAS)
	set(LINGUAS_GMO)

	foreach(file IN LISTS po_files)
		get_filename_component(lang ${file} NAME_WE)
		list(APPEND LINGUAS ${lang})
		list(APPEND LINGUAS_GMO ${lang}.gmo)

		add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${lang}.gmo
			COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} -o ${CMAKE_CURRENT_BINARY_DIR}/${lang}.gmo ${CMAKE_CURRENT_SOURCE_DIR}/${lang}.po
			DEPENDS ${lang}.po
		)

		install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${lang}.gmo
			DESTINATION ${LOCALE_INSTALL_DIR}/${lang}/LC_MESSAGES/
			RENAME ${GETTEXT_PACKAGE}.mo
		)
		if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${lang}.gmo.m)
			install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${lang}.gmo.m
				DESTINATION ${LOCALE_INSTALL_DIR}/${lang}/LC_MESSAGES/
				RENAME ${GETTEXT_PACKAGE}.mo.m
			)
		endif(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${lang}.gmo.m)
	endforeach(file)

	add_custom_target(gmo-files ALL
		DEPENDS ${LINGUAS_GMO}
	)
endmacro(intltool_process_po_files)

macro(intltool_merge _in_filename _out_filename)
	get_filename_component(_path ${_in_filename} DIRECTORY)
	if(_path STREQUAL "")
		set(_in_filename "${CMAKE_CURRENT_SOURCE_DIR}/${_in_filename}")
	endif(_path STREQUAL "")

	get_filename_component(_path ${_out_filename} DIRECTORY)
	if(_path STREQUAL "")
		set(_out_filename "${CMAKE_CURRENT_BINARY_DIR}/${_out_filename}")
	endif(_path STREQUAL "")

	add_custom_command(OUTPUT ${_out_filename}
		COMMAND ${INTLTOOL_MERGE} ${ARGN} "${GETTEXT_PO_DIR}" "${_in_filename}" "${_out_filename}"
	)
endmacro(intltool_merge)
