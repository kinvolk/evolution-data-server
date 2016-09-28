# GtkDoc.cmake

include(PrintableOptions)

add_printable_option(ENABLE_GTK_DOC "Use gtk-doc to build documentation" OFF)

if(NOT ENABLE_GTK_DOC)
	return()
endif(NOT ENABLE_GTK_DOC)

find_program(GTKDOC_SCAN gtkdoc-scan)
find_program(GTKDOC_MKDB gtkdoc-mkdb)
find_program(GTKDOC_MKHTML gtkdoc-mkhtml)
find_program(GTKDOC_FIXXREF gtkdoc-fixxref)

if(NOT (GTKDOC_SCAN AND GTKDOC_MKDB AND GTKDOC_MKHTML AND GTKDOC_FIXXREF))
	message(FATAL_ERROR "Cannot find all gtk-doc binaries, install them or use -DENABLE_GTK_DOC=OFF instead")
	return()
endif()

# To regenerate libical-glib-docs.xml.in from current sources use these steps:
#   a) delete ${CMAKE_CURRENT_BINARY_DIR}/libical-glib-docs.xml
#   b) go to ${CMAKE_CURRENT_BINARY_DIR} and run command:
#      gtkdoc-scan --module=libical-glib --source-dir=../../../src/libical-glib/
#                  --deprecated-guards="LIBICAL_GLIB_DISABLE_DEPRECATED"
#                  --ignore-headers=libical-glib-private.h --rebuild-sections --rebuild-types
#   c) generate the libical-glib-docs.xml file with command:
#      gtkdoc-mkdb --module=libical-glib --output-format=xml
#                  --source-dir=../../../src/libical-glib/ --xml-mode --name-space=i-cal
#   d) copy the newly created libical-glib-docs.xml
#      to ${CURRENT_SOURCE_DIR}/libical-glib-docs.xml.in
#   e) compare the changes in the file and return back what should be left,
#      like the replacement of the "[Insert title here]" and the <bookinfo/> content

if(NOT TARGET gtkdoc)
	add_custom_target(gtkdocs ALL)
endif(NOT TARGET gtkdoc)

# add_gtkdoc_rules
#    Add rules to build developer documentation using gtk-doc for some part.
#    Arguments:
#       _module - the module name, like 'camel'; it expects ${_part}-docs.sgml.in in the CMAKE_CURRENT_SOURCE_DIR
#       _namespace - namespace for symbols
#       _deprecated_guards - define name, which guards deprecated symbols
#       _srcdirsvar - variable with dirs where the source files are located
#       _depsvar - a variable with dependencies (targets)
#       _ignoreheadersvar - a variable with a set of header files to ignore

macro(add_gtkdoc _module _namespace _deprecated_guards _srcdirsvar _depsvar _ignoreheadersvar)
	configure_file(
		${CMAKE_CURRENT_SOURCE_DIR}/${_module}-docs.sgml.in
		${CMAKE_CURRENT_BINARY_DIR}/${_module}-docs.sgml
		@ONLY
	)

	set(OUTPUT_DOCDIR ${SHARE_INSTALL_DIR}/gtk-doc/html/${_module})

	set(_ignore_headers)
	foreach(_header ${${_ignoreheadersvar}})
		set(_ignore_headers "${_ignore_headers} ${_header}")
	endforeach(_header)

	set(_filedeps)
	set(_srcdirs)
	foreach(_srcdir ${${_srcdirsvar}})
		set(_srcdirs ${_srcdirs} --source-dir="${_srcdir}")
		file(GLOB _files ${_srcdir}/*.h* ${_srcdir}/*.c*)
		list(APPEND _filedeps ${_files})
	endforeach(_srcdir)

	set(_mkhtml_prefix "")
	if(APPLE)
		set(_mkhtml_prefix "cmake -E env XML_CATALOG_FILES=\"/usr/local/etc/xml/catalog\"")
	endif(APPLE)

	add_custom_command(OUTPUT html/index.html
		COMMAND ${GTKDOC_SCAN}
			--module=${_module}
			--deprecated-guards="${_deprecated_guards}"
			--ignore-headers="${_ignore_headers}"
			--rebuild-sections
			--rebuild-types
			${_srcdirs}

		COMMAND ${GTKDOC_MKDB}
			--module=${_module}
			--name-space=${_namespace}
			--main-sgml-file="${CMAKE_CURRENT_BINARY_DIR}/${_module}-docs.sgml"
			--sgml-mode
			--output-format=xml
			${_srcdirs}

		COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/html"

		COMMAND ${CMAKE_COMMAND} -E chdir "${CMAKE_CURRENT_BINARY_DIR}/html" ${_mkhtml_prefix} ${GTKDOC_MKHTML} --path=.. ${_module} ../${_module}-docs.sgml

		COMMAND ${GTKDOC_FIXXREF}
			--module=${_module}
			--module-dir=.
			--extra-dir=..
			--html-dir="${OUTPUT_DOCDIR}"

		DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${_module}-docs.sgml"
			${_filedeps}
		COMMENT "Generating ${_module} documentation"
	)

	add_custom_target(${_module}-gtkdoc
		DEPENDS html/index.html
	)

	if(${_depsvar})
		add_dependencies(${_module}-gtkdoc ${${_depsvar}})
	endif(${_depsvar})

	add_dependencies(gtkdocs ${_module}-gtkdoc)

	install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/html/
		DESTINATION ${OUTPUT_DOCDIR}
	)
endmacro(add_gtkdoc)
