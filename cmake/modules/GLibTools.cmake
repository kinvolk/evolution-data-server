# GLibTools.cmake
#
# Provides functions to run glib tools.
#
# Functions:
# glib_mkenums(_output_filename_noext _enums_header _define_name)
#    runs glib-mkenums to generate enumtypes .h and .c files from _enums_header.
#    It searches for files in the current source directory and exports to the current
#    binary directory.
#
#    An example call is:
#        glib_mkenums(camel-enumtypes camel-enums.h CAMEL_ENUMTYPES_H)
#        which uses camel-enums.h as the source of known enums and generates
#        camel-enumtypes.h which will use the CAMEL_ENUMTYPES_H define
#        and also generates camel-enumtypes.c with the needed code.

find_program(GLIB_MKENUMS glib-mkenums)
if(NOT GLIB_MKENUMS)
	message(FATAL_ERROR "Cannot find glib-mkenums, which is required to build ${PROJECT_NAME}")
endif(NOT GLIB_MKENUMS)

function(glib_mkenums _output_filename_noext _enums_header _define_name)
	set(HEADER_TMPL "
/*** BEGIN file-header ***/
#ifndef ${_define_name}
#define ${_define_name}
/*** END file-header ***/

/*** BEGIN file-production ***/

#include <glib-object.h>

G_BEGIN_DECLS

/* Enumerations from \"@filename@\" */

/*** END file-production ***/

/*** BEGIN enumeration-production ***/
#define @ENUMPREFIX@_TYPE_@ENUMSHORT@	(@enum_name@_get_type())
GType @enum_name@_get_type	(void) G_GNUC_CONST;

/*** END enumeration-production ***/

/*** BEGIN file-tail ***/
G_END_DECLS

#endif /* ${_define_name} */
/*** END file-tail ***/")

	file(WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/enumtypes.h.template" "${HEADER_TMPL}\n")

	add_custom_command(
		OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_output_filename_noext}.h
		COMMAND ${GLIB_MKENUMS} --template "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/enumtypes.h.template" "${CMAKE_CURRENT_SOURCE_DIR}/${_enums_header}" >${CMAKE_CURRENT_BINARY_DIR}/${_output_filename_noext}.h
	)

set(SOURCE_TMPL "
/*** BEGIN file-header ***/
#include \"${_output_filename_noext}.h\"
/*** END file-header ***/

/*** BEGIN file-production ***/
/* enumerations from \"@filename@\" */
#include \"@filename@\"

/*** END file-production ***/

/*** BEGIN value-header ***/
GType
@enum_name@_get_type (void)
{
	static volatile gsize the_type__volatile = 0;

	if (g_once_init_enter (&the_type__volatile)) {
		static const G\@Type\@Value values[] = {
/*** END value-header ***/

/*** BEGIN value-production ***/
			{ \@VALUENAME\@,
			  \"@VALUENAME@\",
			  \"@valuenick@\" },
/*** END value-production ***/

/*** BEGIN value-tail ***/
			{ 0, NULL, NULL }
		};
		GType the_type = g_\@type\@_register_static (
			g_intern_static_string (\"@EnumName@\"),
			values);
		g_once_init_leave (&the_type__volatile, the_type);
	}
	return the_type__volatile;
}

/*** END value-tail ***/")

	file(WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/enumtypes.c.template" "${SOURCE_TMPL}\n")

	add_custom_command(
		OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_output_filename_noext}.c
		COMMAND ${GLIB_MKENUMS} --template "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/enumtypes.c.template" "${CMAKE_CURRENT_SOURCE_DIR}/${_enums_header}" >${CMAKE_CURRENT_BINARY_DIR}/${_output_filename_noext}.c
	)
endfunction()
