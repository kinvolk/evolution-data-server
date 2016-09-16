# SetupCompilerWarningFlags.cmake
#
# Setups compiler warning flags, skipping those which are not supported.

include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)

function(setup_compiler_warning_flags _maintainer_mode)
	list(APPEND proposed_warning_flags
		-Werror-implicit-function-declaration
		-Wformat
		-Wformat-security
		-Winit-self
		-Wmissing-declarations
		-Wmissing-include-dirs
		-Wmissing-noreturn
		-Wpointer-arith
		-Wredundant-decls
		-Wundef
		-Wwrite-strings
	)

	if(_maintainer_mode)
		list(APPEND proposed_warning_flags
			-Wall
			-Wextra
			-Wdeprecated-declarations
		)
	else(_maintainer_mode)
		list(APPEND proposed_warning_flags -Wno-deprecated-declarations)
	endif(_maintainer_mode)

	list(APPEND proposed_c_warning_flags
		${proposed_warning_flags}
		-Wdeclaration-after-statement
		-Wno-missing-field-initializers
		-Wno-sign-compare
		-Wno-unused-parameter
		-Wnested-externs
	)

	if("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
		list(APPEND proposed_c_warning_flags
			-Wno-parentheses-equality
			-Wno-format-nonliteral
		)
	endif("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")

	list(APPEND proposed_cxx_warning_flags
		${proposed_warning_flags}
		-Wabi
		-Wnoexcept
	)

	foreach(flag IN LISTS proposed_c_warning_flags)
		check_c_compiler_flag(${flag} _flag_supported)
		if(_flag_supported)
			set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${flag}")
		endif(_flag_supported)
		unset(_flag_supported)
	endforeach()

	foreach(flag IN LISTS proposed_cxx_warning_flags)
		check_cxx_compiler_flag(${flag} _flag_supported)
		if(_flag_supported)
			set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${flag}")
		endif(_flag_supported)
		unset(_flag_supported)
	endforeach()
endfunction()
