add_subdirectory(eds)
add_subdirectory(camel)

if(WITH_PRIVATE_DOCS)
	add_subdirectory(private)
endif(WITH_PRIVATE_DOCS)
