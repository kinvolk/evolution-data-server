set(extra_deps
	camel
	ebook
	ebook-contacts
	edata-book
	edbus-private
	etestserverutils
)

set(extra_defines
	-DSRCDIR=\"${CMAKE_CURRENT_SOURCE_DIR}\"
	-DINSTALLED_TEST_DIR=\"${INSTALLED_TESTS_EXEC_DIR}\"
	-DBACKENDDIR=\"${ebook_backenddir}\"
	-DDATADIR=\"${SHARE_INSTALL_PREFIX}\"
	-DBUILDDIR=\"${CAMKE_BINARY_DIR}\"
	-DCAMEL_PROVIDERDIR=\"${camel_providerdir}\"
)

set(extra_cflags
	${ADDRESSBOOK_CFLAGS}
	${CAMEL_CFLAGS}
	${GIO_UNIX_CFLAGS}
)

set(extra_incdirs
	${ADDRESSBOOK_INCLUDE_DIRS}
	${CAMEL_INCLUDE_DIRS}
	${GIO_UNIX_INCLUDE_DIRS}
)

set(extra_ldflags
	${ADDRESSBOOK_LDFLAGS}
	${CAMEL_LDFLAGS}
	${GIO_UNIX_LDFLAGS}
)

set(SOURCES
	data-test-utils.c
	data-test-utils.h
)

add_library(data-test-utils STATIC
	${SOURCES}
)

add_dependencies(data-test-utils
	edataserver
	${extra_deps}
)

target_compile_definitions(data-test-utils PRIVATE
	-DG_LOG_DOMAIN=\"data-test-utils\"
	${extra_defines}
)

target_compile_options(data-test-utils PUBLIC
	${BACKEND_CFLAGS}
	${DATA_SERVER_CFLAGS}
	${extra_cflags}
)

target_include_directories(data-test-utils PUBLIC
	${CMAKE_BINARY_DIR}
	${CMAKE_BINARY_DIR}/src
	${CMAKE_SOURCE_DIR}/src
	${BACKEND_INCLUDE_DIRS}
	${DATA_SERVER_INCLUDE_DIRS}
	${extra_incdirs}
)

target_link_libraries(data-test-utils
	edataserver
	${extra_deps}
	${BACKEND_LDFLAGS}
	${DATA_SERVER_LDFLAGS}
	${extra_ldflags}
)

set(extra_deps
	ebook
	ebook-contacts
	data-test-utils
)

set(extra_defines)

# Should be kept ordered approximately from least to most difficult/complex
#
# Note that these tests must be run in order:
#   test-sqlite-cursor-posix-initial,
#   test-sqlite-cursor-en-US-migrated,
#   test-sqlite-cursor-posix-migrated
#
# This is because each migrated test changes the
# locale and reloads the same addressbook of the previous test.
set(TESTS
	test-sqlite-get-contact
	test-sqlite-create-cursor
	test-sqlite-cursor-move-by-posix
	test-sqlite-cursor-move-by-en-US
	test-sqlite-cursor-move-by-fr-CA
	test-sqlite-cursor-move-by-de-DE
	test-sqlite-cursor-set-target
	test-sqlite-cursor-calculate
	test-sqlite-cursor-set-sexp
	test-sqlite-cursor-change-locale
)

foreach(_test ${TESTS})
	set(SOURCES ${_test}.c)

	add_installable_test(${_test}
		SOURCES
		extra_deps
		extra_defines
		extra_cflags
		extra_incdirs
		extra_ldflags
		"session-exclusive"
		"TEST_INSTALLED_SERVICES=1"
	)
endforeach(_test)

if(ENABLE_INSTALLED_TESTS)
	file(GLOB ${CMAKE_CURRENT_SOURCE_DIR}/data/vcards/*.vcf VCARDS)

	install(FILES ${VCARDS}
		DESTINATION ${INSTALLED_TESTS_EXEC_DIR}/vcards
	)
endif(ENABLE_INSTALLED_TESTS)
