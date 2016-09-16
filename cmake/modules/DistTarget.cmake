# DistTarget.cmake
#
# Defines a custom target 'dist', which generates the dist tarball from a git clone
# It requires to have populated 'PROJECT_NAME' and 'PROJECT_VERSION' variables,
# possibly through the project() command

# Filenames for tarball
set(ARCHIVE_BASE_NAME ${PROJECT_NAME}-${PROJECT_VERSION})
set(ARCHIVE_FULL_NAME ${ARCHIVE_BASE_NAME}.tar.xz)

add_custom_target(
	dist
	COMMAND git archive --prefix=${ARCHIVE_BASE_NAME}/ HEAD | xz -z > ${CMAKE_BINARY_DIR}/${ARCHIVE_FULL_NAME}
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)
