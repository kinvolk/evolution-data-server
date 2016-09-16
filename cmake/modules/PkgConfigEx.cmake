# PkgConfigEx.cmake
#
# Extends CMake's PkgConfig module with commands:
#
# pkg_check_modules_for_option(_option_name _option_description _prefix _module0)
#
#    which calls `pkg_check_modules(_prefix _module0)` and if <_prefix>_FOUND is False,
#    then prints an error with a hint to disaable the _option_name if needed.
#
# pkg_check_exists(_output_name _pkg)
#
#    calls pkg-config --exists for _pkg and stores the result to _output_name.
#
# pkg_check_variable(_output_name _pkg _name)
#
#    gets a variable named _name from package _pkg and stores the result into _output_name

find_package(PkgConfig REQUIRED)

macro(pkg_check_modules_for_option _option_name _option_description _prefix _module0)
	pkg_check_modules(${_prefix} ${_module0})

	if(NOT ${_prefix}_FOUND)
		message(FATAL_ERROR "Necessary libraries not or not enough version. If you want to disable ${_option_description}, please use -D${_option_name}=OFF argument to cmake command.")
	endif(NOT ${_prefix}_FOUND)
endmacro()

macro(pkg_check_exists _output_name _pkg)
	execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --exists ${_pkg}
			RESULT_VARIABLE ${_output_name})

	# Negate the result, because 0 means 'found'
	if(${_output_name})
		set(${_output_name} OFF)
	else(${_output_name})
		set(${_output_name} ON)
	endif(${_output_name})
endmacro()

function(pkg_check_variable _output_name _pkg _name)
    execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=${_name} ${_pkg}
                    OUTPUT_VARIABLE _pkg_result
                    OUTPUT_STRIP_TRAILING_WHITESPACE)

    set("${_output_name}" "${_pkg_result}" CACHE STRING "pkg-config variable ${_name} of ${_pkg}")
endfunction()
