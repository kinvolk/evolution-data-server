# Evolution-Data-Server build script

cmake_minimum_required(VERSION 3.0)
cmake_policy(VERSION 3.0)

project(evolution-data-server
	VERSION 3.23.1
	LANGUAGES C CXX)

# Base Version: This is for API/version tracking for things like
# D-Bus server files. This should always be the major/minor of
# the stable version or stable version to be.
set(BASE_VERSION 3.24)

# This number is meaningless, but we're now stuck with it in our
# library names for backward compatibility.
set(API_VERSION 1.2)

set(GETTEXT_PACKAGE ${PROJECT_NAME}-${BASE_VERSION})

# ******************************
# D-Bus versioning
# ******************************
set(ADDRESS_BOOK_DBUS_SERVICE_NAME	"org.gnome.evolution.dataserver.AddressBook9")
set(CALENDAR_DBUS_SERVICE_NAME		"org.gnome.evolution.dataserver.Calendar7")
set(SOURCES_DBUS_SERVICE_NAME		"org.gnome.evolution.dataserver.Sources5")
set(USER_PROMPTER_DBUS_SERVICE_NAME	"org.gnome.evolution.dataserver.UserPrompter0")

# ******************************
# Library versioning
# ******************************
set(LIBCAMEL_CURRENT 59)
set(LIBCAMEL_REVISION 0)
set(LIBCAMEL_AGE 0)

set(LIBEBACKEND_CURRENT 10)
set(LIBEBACKEND_REVISION 0)
set(LIBEBACKEND_AGE 0)

set(LIBEDATASERVER_CURRENT 22)
set(LIBEDATASERVER_REVISION 0)
set(LIBEDATASERVER_AGE 0)

set(LIBEDATASERVERUI_CURRENT 1)
set(LIBEDATASERVERUI_REVISION 0)
set(LIBEDATASERVERUI_AGE 0)

set(LIBEBOOK_CURRENT 19)
set(LIBEBOOK_REVISION 1)
set(LIBEBOOK_AGE 3)

set(LIBEBOOK_CONTACTS_CURRENT 2)
set(LIBEBOOK_CONTACTS_REVISION 0)
set(LIBEBOOK_CONTACTS_AGE 0)

set(LIBEDATABOOK_CURRENT 25)
set(LIBEDATABOOK_REVISION 0)
set(LIBEDATABOOK_AGE 0)

set(LIBECAL_CURRENT 19)
set(LIBECAL_REVISION 0)
set(LIBECAL_AGE 0)

set(LIBEDATACAL_CURRENT 28)
set(LIBEDATACAL_REVISION 0)
set(LIBEDATACAL_AGE 0)

# Keep these two definitions in agreement.
set(glib_minimum_version 2.46)
set(glib_encoded_version GLIB_VERSION_2_46)

# Keep these two definitions in agreement.
set(gdk_minimum_version 3.10)
set(gdk_encoded_version GDK_VERSION_3_10)

# Keep these two definitions in agreement.
set(soup_minimum_version 2.42)
set(soup_encoded_version SOUP_VERSION_2_42)

# Warn about API usage that violates our minimum requirements.
add_definitions(-DGLIB_VERSION_MAX_ALLOWED=${glib_encoded_version})
add_definitions(-DGDK_VERSION_MAX_ALLOWED=${gdk_encoded_version})
add_definitions(-DSOUP_VERSION_MAX_ALLOWED=${soup_encoded_version})

# These will suppress warnings about newly-deprecated symbols. Ideally
# these settings should match our minimum requirements and we will clean
# up any new deprecation warnings after bumping our minimum requirements.
# But if the warnings get to be overwhelming, use fixed versions instead.
add_definitions(-DGLIB_VERSION_MIN_REQUIRED=${glib_encoded_version})
add_definitions(-DGDK_VERSION_MIN_REQUIRED=${gdk_encoded_version})
add_definitions(-DSOUP_VERSION_MIN_REQUIRED=${soup_encoded_version})

set(gcr_minimum_version 3.4)
set(libgdata_minimum_version 0.10)
set(libical_minimum_version 0.43)
set(libsecret_minimum_version 0.5)
set(libxml_minimum_version 2.0.0)
set(sqlite_minimum_version 3.7.17)

# Optional Packages
set(goa_minimum_version 3.8)
set(gweather_minimum_version 3.10)
set(libaccounts_glib_minimum_version 1.4)
set(libsignon_glib_minimum_version 1.8)
set(json_glib_minimum_version 1.0.4)
set(webkit2gtk_minimum_version 2.11.91)

# Load modules from the source tree
set(CMAKE_MODULE_PATH $CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# CMake modules
include(CheckCCompilerFlag)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckFunctionExists)
include(CheckIncludeFile)

# Project custom modules
include(PrintableOptions)

add_printable_variable(LIB_SUFFIX "Library directory suffix, usually defined to '64' for x86_64 systems" "")
add_printable_variable_bare(CMAKE_INSTALL_PREFIX)
add_printable_variable_path(INCLUDE_INSTALL_DIR "Install directory for header files, defaults to CMAKE_INSTALL_PREFIX/include" ${CMAKE_INSTALL_PREFIX}/include)
add_printable_variable_path(LIB_INSTALL_DIR "Install directory for library files, defaults to CMAKE_INSTALL_PREFIX/lib{LIB_SUFFIX}" ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX})
add_printable_variable_path(LIBEXEC_INSTALL_DIR "Install directory for library executable files, defaults to CMAKE_INSTALL_PREFIX/libexec" ${CMAKE_INSTALL_PREFIX}/libexec)
add_printable_variable_path(SHARE_INSTALL_PREFIX "Install directory for shared files, defaults to CMAKE_INSTALL_PREFIX/share" ${CMAKE_INSTALL_PREFIX}/share)
add_printable_variable_path(SYSCONF_INSTALL_DIR "Install directory for system configuration files, defaults to CMAKE_INSTALL_PREFIX/etc" ${CMAKE_INSTALL_PREFIX}/etc)

include(CodeCoverageGCOV)
include(DistTarget)
include(PkgConfigEx)
include(SetupBuildFlags)
include(UninstallTarget)

include(FindKRB5)
include(FindPhonenumber)
include(FindSMIME)

add_printable_option(ENABLE_MAINTAINER_MODE "Enable maintainer mode" OFF)

# Setup compiler/linker flags
setup_build_flags(${ENABLE_MAINTAINER_MODE})

check_c_compiler_flag(-fno-strict-aliasing _flag_supported)
if(_flag_supported)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-strict-aliasing")
endif(_flag_supported)
unset(_flag_supported)

CHECK_INCLUDE_FILE(sys/wait.h HAVE_SYS_WAIT_H)
CHECK_INCLUDE_FILE(wspiapi.h HAVE_WSPIAPI_H)
CHECK_FUNCTION_EXISTS(fsync HAVE_FSYNC)
CHECK_FUNCTION_EXISTS(strptime HAVE_STRPTIME)
CHECK_FUNCTION_EXISTS(nl_langinfo HAVE_NL_LANGINFO)

pkg_check_modules(GNOME_PLATFORM
	gio-2.0>=${glib_minimum_version}
	gmodule-2.0>=${glib_minimum_version}
	libxml-2.0>=${libxml_minimum_version}
	libsoup-2.4>=${soup_minimum_version}
)

if(WIN32)
	pkg_check_modules(GIO_UNIX gio-windows-2.0)
else(WIN32)
	pkg_check_modules(GIO_UNIX gio-unix-2.0)
endif(WIN32)

# ******************************
# Check for libphonenumber
# ******************************

# *******************
# Check for ICU
# *******************
#
# ICU started shipping pkg-config files but it's not present
# on many systems, if we don't find the pkg-config
# file then let's fallback on a manual check
pkg_check_modules(ICU icu-i18n)

if(NOT ICU_FOUND)
	CHECK_INCLUDE_FILE(unicode/ucol.h HAVE_UNICODE_UCOL_H)
	if(NOT HAVE_UNICODE_UCOL_H)
		message(FATAL_ERROR "ICU unicode/ucol.h not found; icu-i18n is required")
	endif(HAVE_UNICODE_UCOL_H)

	set(CMAKE_REQUIRED_LIBRARIES "-licui18n -licuuc -licudata")
	CHECK_C_SOURCE_COMPILES("#include <unicode/ucol.h>
				int main(void) { ucol_open (\"\", NULL); return 0; }" HAVE_UCOL_OPEN)
	unset(CMAKE_REQUIRED_LIBRARIES)

	if(HAVE_UCOL_OPEN)
		set(ICU_CFLAGS -D_REENTRANT)
		set(ICU_LIBS "-licui18n -licuuc -licudata")
	else(HAVE_UCOL_OPEN)
		message(FATAL_ERROR "Failed to find icu-i18n, install its development files or build them first")
	endif(HAVE_UCOL_OPEN)
endif(NOT ICU_FOUND)

# *************************
# Check for GTK+
# *************************

add_printable_option(ENABLE_GTK "Enable gtk+ support" ON)

if(ENABLE_GTK)
	pkg_check_modules_for_option(ENABLE_GTK "GTK+ support" GTK gtk+-3.0>=${gdk_minimum_version})
	pkg_check_modules_for_option(ENABLE_GTK "GTK+ support" GCR gcr-3>=${gcr_minimum_version})

	set(HAVE_GTK 1)
endif(ENABLE_GTK)

# ***************************************************
# Check for WebKitGTK+ and json-glib for google auth
# ***************************************************

add_printable_option(ENABLE_GOOGLE_AUTH "Enable built-in Google authentication" ON)

if(ENABLE_GOOGLE_AUTH)
	pkg_check_modules_for_option(ENABLE_GOOGLE_AUTH "Google authentication support" GOOGLE_AUTH
		webkit2gtk-4.0>=${webkit2gtk_minimum_version}
		json-glib-1.0>=${json_glib_minimum_version}
	)

	add_printable_variable(WITH_GOOGLE_CLIENT_ID "Google OAuth 2.0 client id" "")
	add_printable_variable(WITH_GOOGLE_CLIENT_SECRET "Google OAuth 2.0 client secret" "")

	if(WITH_GOOGLE_CLIENT_ID STREQUAL "")
		set(WITH_GOOGLE_CLIENT_ID "590402290962-2i0b7rqma8b9nmtfrcp7fa06g6cf7g74.apps.googleusercontent.com")
	endif(WITH_GOOGLE_CLIENT_ID STREQUAL "")

	if(WITH_GOOGLE_CLIENT_SECRET STREQUAL "")
		set(WITH_GOOGLE_CLIENT_SECRET "mtfUe5W8Aal9DcgVipOY1T9G")
	endif(WITH_GOOGLE_CLIENT_SECRET STREQUAL "")
endif(ENABLE_GOOGLE_AUTH)

# ******************************************
# Check whether to build examples/demos
# ******************************************

add_printable_option(ENABLE_EXAMPLES "Enable the build of examples" ON)

if(ENABLE_EXAMPLES)
	pkg_check_modules_for_option(ENABLE_EXAMPLES "build the example program(s)" EXAMPLES
		gtk+-3.0>=3.10
		glib-2.0>=2.38
	)

	set(BUILD_EXAMPLES 1)
endif(ENABLE_EXAMPLES)

# *******************************
# Check for GNOME Online Accounts
# *******************************

add_printable_option(ENABLE_GOA "Enable GNOME Online Accounts support" ON)

if(ENABLE_GOA)
	pkg_check_modules_for_option(ENABLE_GOA "GNOME Online Accounts support" GOA goa-1.0>=${goa_minimum_version})

	set(HAVE_GOA 1)
endif(ENABLE_GOA)

# ********************************
# Check for Ubuntu Online Accounts
# ********************************

add_printable_option(ENABLE_UOA "Enable Ubuntu Online Accounts support" ON)

if(ENABLE_UOA)
	pkg_check_modules_for_option(ENABLE_UOA "Ubuntu Online Accounts support" LIBACCOUNTS_GLIB libaccounts-glib>=${libaccounts_glib_minimum_version})
	pkg_check_modules_for_option(ENABLE_UOA "Ubuntu Online Accounts support" LIBSIGNON_GLIB libsignon-glib>=${libsignon_glib_minimum_version})
	pkg_check_modules_for_option(ENABLE_UOA "Ubuntu Online Accounts support" JSON_GLIB json-glib-1.0)
	pkg_check_modules_for_option(ENABLE_UOA "Ubuntu Online Accounts support" REST rest-0.7)

	set(HAVE_UOA 1)
endif(ENABLE_UOA)

# **********************************************
# Check if backend per process should be enabled
# **********************************************

add_printable_option(ENABLE_BACKEND_PER_PROCESS "Enable backend per process support" ON)

# ***********************************
# Check for libsecret and gcr-base
# ***********************************

if(NOT WIN32)
	pkg_check_modules(LIBSECRET REQUIRED libsecret-unstable>=${libsecret_minimum_version})
	pkg_check_modules(GCR_BASE REQUIRED gcr-base-3>=${gcr_minimum_version})
endif(NOT WIN32)

# ******************************
# libdb checking
# ******************************
add_printable_variable(WITH_LIBDB "Prefix where libdb is installed" "")

if(NOT ("${WITH_LIBDB}" STREQUAL "NO"))
	if(NOT (("${WITH_LIBDB}" STREQUAL "") OR ("${WITH_LIBDB}" STREQUAL "YES")))
		set(LIBDB_CFLAGS "-I${WITH_LIBDB}/include")
		set(LIBDB_LIBS "-L${WITH_LIBDB}/lib -ldb")
	else(NOT (("${WITH_LIBDB}" STREQUAL "") OR ("${WITH_LIBDB}" STREQUAL "YES")))
		if(("$ENV{DB_CFLAGS}" STREQUAL "") AND ("$ENV{DB_LIBS}" STREQUAL ""))
			set(LIBDB_CFLAGS "")
			set(LIBDB_LIBS "-ldb")
		else(("$ENV{DB_CFLAGS}" STREQUAL "") AND ("$ENV{DB_LIBS}" STREQUAL ""))
			set(LIBDB_CFLAGS $ENV{DB_CFLAGS})
			set(LIBDB_LIBS $ENV{DB_LIBS})
		endif(("$ENV{DB_CFLAGS}" STREQUAL "") AND ("$ENV{DB_LIBS}" STREQUAL ""))
	endif(NOT (("${WITH_LIBDB}" STREQUAL "") OR ("${WITH_LIBDB}" STREQUAL "YES")))

	set(CMAKE_REQUIRED_FLAGS ${LIBDB_CFLAGS})
	set(CMAKE_REQUIRED_LIBRARIES ${LIBDB_LIBS})
	CHECK_C_SOURCE_COMPILES("#include <db.h>
				int main(void) { db_create(NULL, NULL, 0); return 0; }" HAVE_LIBDB)
	unset(CMAKE_REQUIRED_FLAGS)
	unset(CMAKE_REQUIRED_LIBRARIES)
endif(NOT ("${WITH_LIBDB}" STREQUAL "NO"))

# ******************************
# iconv checking
# ******************************

set(CMAKE_REQUIRED_LIBRARIES "-liconv")
CHECK_C_SOURCE_COMPILES("#include <iconv.h>
			#include <stdlib.h>
			int main(void) { iconv_t cd; cd = iconv_open (\"UTF-8\", \"ISO-8859-1\"); return 0; }" HAVE_LIBICONV)
unset(CMAKE_REQUIRED_LIBRARIES)

if(HAVE_LIBICONV)
	set(ICONV_LIBS "-liconv")
	set(HAVE_ICONV ON)
else(HAVE_LIBICONV)
	set(ICONV_LIBS "")
	CHECK_FUNCTION_EXISTS(iconv HAVE_ICONV)
endif(HAVE_LIBICONV)

if(NOT HAVE_ICONV)
	message(FATAL_ERROR "You need to install a working iconv implementation, such as ftp://ftp.gnu.org/pub/gnu/libiconv")
endif(NOT HAVE_ICONV)

set(CMAKE_REQUIRED_LIBRARIES ${ICONV_LIBS})
CHECK_C_SOURCE_RUNS("#include \"${CMAKE_SOURCE_DIR}/iconv-detect.c\"" _correct_iconv)
unset(CMAKE_REQUIRED_LIBRARIES)

if(NOT _correct_iconv)
	message(FATAL_ERROR "You need to install a working iconv implementation, such as ftp://ftp.gnu.org/pub/gnu/libiconv")
endif(NOT _correct_iconv)

# ******************************
# Backtraces for debugging
# ******************************

add_printable_option(ENABLE_BACKTRACES "Enable backtraces for camel_pointer_tracker" OFF)

if(ENABLE_BACKTRACES)
	CHECK_C_SOURCE_COMPILES("#include <execinfo.h>
				int main(void) { void *bt[1]; backtrace_symbols (bt, backtrace(bt, 1)); return 0; }" _have_bsf)

	if(_have_bsf)
		set(CMAKE_REQUIRED_LIBRARIES -ldw)
		CHECK_C_SOURCE_COMPILES("#include <elfutils/libdwfl.h>
					int main(void) {
						Dwfl *dwfl;
						Dwfl_Module *module;
						Dwarf_Addr module_low_addr;
						Dwfl_Line *line;

						dwfl_standard_find_debuginfo;
						dwfl_linux_proc_find_elf;
						dwfl_begin (NULL);
						dwfl_linux_proc_report (NULL, 1);
						dwfl_report_end (NULL, NULL, NULL);
						dwfl_end (NULL);
						dwfl_module_addrname (NULL, NULL);
						dwfl_module_getsrc (NULL, NULL);
						dwfl_lineinfo (NULL, NULL, NULL, NULL, NULL, NULL);
						DWARF_CB_ABORT; DWARF_CB_OK;
						dwfl_getmodules (NULL, NULL, NULL, 0);
						return 0; }" _have_elfdwlf)
		unset(CMAKE_REQUIRED_LIBRARIES)

		if(_have_elfdwlf)
			set(HAVE_ELFUTILS_LIBDWFL ON)
			set(LIBDWFL_LIBS "-ldw")
		endif(_have_elfdwlf)
	endif(_have_bsf)
endif(ENABLE_BACKTRACES)

# ******************************
# Check for nl_langinfo features
# ******************************

CHECK_C_SOURCE_COMPILES("#include <langinfo.h>
			int main(void) { char *detail = nl_langinfo (CODESET); return 0; }" HAVE_CODESET)

CHECK_C_SOURCE_COMPILES("#include <langinfo.h>
			int main(void) { char *detail = nl_langinfo (_NL_ADDRESS_COUNTRY_AB2); return 0; }" HAVE__NL_ADDRESS_COUNTRY_AB2)

# *******************************************************
# Check to see if strftime supports the use of %l and %k
# *******************************************************

CHECK_C_SOURCE_RUNS("
	#include <stdlib.h>
	#include <string.h>
	#include <time.h>
	int main(int argc, char **argv)	{
	char buf[10];
	time_t rawtime;
	struct tm *timeinfo;

	time(&rawtime);
	timeinfo=localtime(&rawtime);
	buf[0] = 0;
	strftime(buf, 10, \"%lx%k\", timeinfo);

	if (!buf[0] || buf[0] == 'x' || strstr(buf, \"l\") || strstr(buf, \"k\"))
		return 1;
	return 0;
	}" HAVE_LKSTRFTIME)

# ******************************
# system mail stuff
# ******************************

find_program(SENDMAIL_PATH sendmail /usr/sbin /usr/lib)
find_path(SYSTEM_MAIL_DIR /var/mail /var/spool/mail)

# ******************************
# Timezone checks
# ******************************

CHECK_C_SOURCE_COMPILES("#include <time.h>
			int main(void) { struct tm tm; tm.tm_gmtoff = 1; return 0; }" HAVE_TM_GMTOFF)

CHECK_C_SOURCE_COMPILES("#include <time.h>
			int main(void) { timezone = 1; return 0; }" HAVE_TIMEZONE)

CHECK_C_SOURCE_COMPILES("#include <time.h>
			int main(void) { altzone = 1; return 0; }" HAVE_ALTZONE)

if((NOT HAVE_TM_GMTOFF) AND (NOT HAVE_TIMEZONE))
	message(FATAL_ERROR "Unable to find a way to determine timezone")
endif((NOT HAVE_TM_GMTOFF) AND (NOT HAVE_TIMEZONE))

# ******************************
# gethostbyaddr_r prototype
# ******************************

CHECK_C_SOURCE_COMPILES("#include <sys/types.h>
			#include <sys/socket.h>
			#include <netinet/in.h>
			#include <netdb.h>
			#define BUFSIZE (sizeof(struct hostent)+10)

			int main(void) {
				struct hostent hent;
				char buffer[BUFSIZE];
				int bufsize=BUFSIZE;
				int h_errno;
				(void)gethostbyaddr_r (\"www.ximian.com\", 14, AF_INET, &hent, buffer, bufsize, &h_errno);
				return 0;
			}" GETHOSTBYADDR_R_SEVEN_ARGS)

# ******************************
# gethostbyname_r prototype
# ******************************

CHECK_C_SOURCE_COMPILES("#include <sys/types.h>
			#include <sys/socket.h>
			#include <netinet/in.h>
			#include <netdb.h>
			#define BUFSIZE (sizeof(struct hostent)+10)

			int main(void) {
				struct hostent hent;
				char buffer[BUFSIZE];
				int bufsize=BUFSIZE;
				int h_errno;
				(void)gethostbyname_r (\"www.ximian.com\", &hent, buffer, bufsize, &h_errno);
				return 0;
			}" GETHOSTBYNAME_R_FIVE_ARGS)

# ******************************
# IPv6 support and getaddrinfo calls
# ******************************

add_printable_option(ENABLE_IPV6 "Enable IPv6 support" ON)

CHECK_C_SOURCE_COMPILES("#include <sys/types.h>
			#include <sys/socket.h>
			#include <netinet/in.h>
			#include <netdb.h>
			#include <stddef.h>

			int main(void) {
				#ifndef NI_MAXHOST
				#define NI_MAXHOST	1025
				#endif

				#ifndef NI_MAXSERV
				#define NI_MAXSERV	32
				#endif

				struct addrinfo hints, *res;
				struct sockaddr_in6 sin6;
				int af = AF_INET6;
				char host[NI_MAXHOST];
				char serv[NI_MAXSERV];

				getaddrinfo (\"www.ximian.com\", NULL, &hints, &res);
				freeaddrinfo (res);
				getnameinfo((struct sockaddr *)&sin6, sizeof(sin6), host, sizeof(host), serv, sizeof(serv), 0);
				return 0;
			}" have_addrinfo)

if(NOT have_addrinfo)
	set(NEED_ADDRINFO ON)
	if(ENABLE_IPV6)
		message(FATAL_ERROR "System doesn't support necessary interfaces for IPv6 support. Use -DENABLE_IPV6=OFF to disable IPv6 support.")
	endif(ENABLE_IPV6)
else(NOT have_addrinfo)
	if(ENABLE_IPV6)
		CHECK_C_SOURCE_COMPILES("#include <sys/types.h>
					#include <sys/socket.h>
					#include <netinet/in.h>
					#include <netdb.h>

					int main(void) {
						struct addrinfo hints;
						hints.ai_flags = AI_ADDRCONFIG;
						return 0;
					}" HAVE_AI_ADDRCONFIG)
	endif(ENABLE_IPV6)
endif(NOT have_addrinfo)

# **********************************
# Weather calendar backend support
# **********************************

add_printable_option(ENABLE_WEATHER "Build the weather calendar backend" ON)

if(ENABLE_WEATHER)
	pkg_check_modules_for_option(ENABLE_WEATHER "weather calendar backend" LIBGWEATHER gweather-3.0>=${gweather_minimum_version})
endif(ENABLE_WEATHER)

# ******************************
# File locking
# ******************************

add_printable_option(ENABLE_DOT_LOCKING "Enable support for locking mail files with dot locking" ON)

if(WIN32 AND ENABLE_DOT_LOCKING)
	message(WARNING "Auto-disabling dot locking for mail files for this platform")
	set(ENABLE_DOT_LOCKING OFF)
	set(USE_DOT_LOCKING OFF)
else(WIN32 AND ENABLE_DOT_LOCKING)
	set(USE_DOT_LOCKING ENABLE_DOT_LOCKING)
endif(WIN32 AND ENABLE_DOT_LOCKING)

add_printable_variable(ENABLE_FILE_LOCKING "Enable support for locking mail files with file locking (one of fcntl/flock/no)" "fcntl")

if(NOT WIN32)
	if (${ENABLE_FILE_LOCKING} STREQUAL "fcntl")
		set(USE_FCNTL_LOCKING ON)
	elseif(${ENABLE_FILE_LOCKING} STREQUAL "flock")
		set(USE_FLOCK_LOCKING ON)
	endif()
endif(NOT WIN32)

# ******************************
# sendmail operation
# ******************************

set(defval OFF)
if(CMAKE_SYSTEM_NAME STREQUAL "SunOs")
	set(defval ON)
endif(CMAKE_SYSTEM_NAME STREQUAL "SunOs")

add_printable_option(ENABLE_BROKEN_SPOOL "Use SunOS/Solaris sendmail which has a broken spool format" ${defval})

unset(defval)

# Generate the config.h file
CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_BINARY_DIR}/config.h)

add_definitions(-DHAVE_CONFIG_H=1)

print_build_options()
