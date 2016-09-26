set(extra_deps)
set(sources
	module-ubuntu-online-accounts.c
	uoa-utils.c
	uoa-utils.h
)
set(extra_defines)
set(extra_cflags
	${LIBACCOUNTS_GLIB_CFLAGS}
	${LIBSIGNON_GLIB_CFLAGS}
	${JSON_GLIB_CFLAGS}
	${REST_CFLAGS}
)
set(extra_incdirs
	${LIBACCOUNTS_GLIB_INCLUDE_DIRS}
	${LIBSIGNON_GLIB_INCLUDE_DIRS}
	${JSON_GLIB_INCLUDE_DIRS}
	${REST_INCLUDE_DIRS}
)
set(extra_ldflags
	${LIBACCOUNTS_GLIB_LDFLAGS}
	${LIBSIGNON_GLIB_LDFLAGS}
	${JSON_GLIB_LDFLAGS}
	${REST_LDFLAGS}
)

add_source_registry_module(module-ubuntu-online-accounts
	sources
	extra_deps
	extra_defines
	extra_cflags
	extra_incdirs
	extra_ldflags
)

# ******************************
# Credentials module
# ******************************

set(sources
	module-credentials-uoa.c
	e-signon-session-password.c
	e-signon-session-password.h
)

add_credentials_module(module-credentials-uoa
	sources
	extra_deps
	extra_defines
	extra_cflags
	extra_incdirs
	extra_ldflags
)

# ******************************
# Data files
# ******************************

set(servicetype_files)
set(servicetype_files_gen)
list(APPEND servicetype_files
	mail.service-type
	calendar.service-type
	contacts.service-type
)

set(service_files)
set(service_files_gen)
list(APPEND service_files
	google-gmail.service
	google-calendar.service
	google-contacts.service
	windows-live-mail.service
	yahoo-mail.service
	yahoo-calendar.service
)

intltool_merge(evolution-data-server.application.in evolution-data-server.application --no-translations --xml-style  --utf8)
intltool_merge(evolution-data-server-uoa.desktop.in evolution-data-server-uoa.desktop --desktop-style --utf8)

foreach(_file IN LISTS servicetype_files)
	intltool_merge(${_file}.in ${_file} --no-translations -x -u)
	list(APPEND servicetype_files_gen ${CMAKE_CURRENT_BINARY_DIR}/${_file})
endforeach(_file)

foreach(_file IN LISTS service_files)
	intltool_merge(${_file}.in ${_file} --no-translations -x -u)
	list(APPEND service_files_gen ${CMAKE_CURRENT_BINARY_DIR}/${_file})
endforeach(_file)

desktopdir = ${SHARE_INSTALL_DIR}/applications
pkg_check_variable(applicationdir libaccounts-glib applicationfilesdir)
pkg_check_variable(servicetypedir libaccounts-glib servicetypefilesdir)
pkg_check_variable(servicedir libaccounts-glib servicefilesdir)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/evolution-data-server.application
	DESTINATION ${applicationdir}
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/evolution-data-server-uoa.desktop
	DESTINATION ${desktopdir}
)

install(FILES ${servicetype_files_gen}
	DESTINATION ${servicetypedir}
)

install(FILES ${service_files_gen}
	DESTINATION ${servicedir}
)
