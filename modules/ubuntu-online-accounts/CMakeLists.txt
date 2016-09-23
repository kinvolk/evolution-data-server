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

set(servicetype_files
	mail.service-type
	calendar.service-type
	contacts.service-type
)

set(service_files
	google-gmail.service
	google-calendar.service
	google-contacts.service
	windows-live-mail.service
	yahoo-mail.service
	yahoo-calendar.service
)

# TODO | FIXME
#%.application: %.application.in
#	$(AM_V_GEN) $(INTLTOOL_MERGE) --no-translations -x -u $< $@
#
#%.service-type: %.service-type.in
#	$(AM_V_GEN) $(INTLTOOL_MERGE) --no-translations -x -u $< $@
#
#%.service: %.service.in
#	$(AM_V_GEN) $(INTLTOOL_MERGE) --no-translations -x -u $< $@

desktopdir = ${SHARE_INSTALL_DIR}/applications
pkg_check_variable(applicationdir libaccounts-glib applicationfilesdir)
pkg_check_variable(servicetypedir libaccounts-glib servicetypefilesdir)
pkg_check_variable(servicedir libaccounts-glib servicefilesdir)

install(FILES evolution-data-server-uoa.desktop
	DESTINATION ${desktopdir}
)

install(FILES evolution-data-server.application
	DESTINATION ${applicationdir}
)

install(FILES ${servicetype_files}
	DESTINATION ${servicetypedir}
)

install(FILES ${service_files}
	DESTINATION ${servicedir}
)
