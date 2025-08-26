#

SET(LEMON_DEP "")

if( NOT LEMON_BIN )
   SET(LEMON_BIN $<TARGET_FILE:lemon>)
else()
   SET(LEMON_DEP lemon)
endif()

MACRO(ADD_LEMON_FILES _source _generated)
    set(_lemonpardir ${CMAKE_SOURCE_DIR}/tools/lemon)
    FOREACH (_current_FILE ${ARGN})
      GET_FILENAME_COMPONENT(_in ${_current_FILE} ABSOLUTE)
      GET_FILENAME_COMPONENT(_basename ${_current_FILE} NAME_WE)

find_program(LEMON_EXECUTABLE lemon)

      ADD_CUSTOM_COMMAND(
         OUTPUT
          ${_out}.c
          # These files are generated as side-effect
          ${_out}.h
          ${_out}.out
         COMMAND "${LEMON_BIN}"
           -T${_lemonpardir}/lempar.c
           -d.
           ${_in}
         DEPENDS
           ${_in}
           ${LEMON_DEP}
           ${_lemonpardir}/lempar.c
      )

macro(ADD_LEMON_FILES _source _generated)

	foreach (_current_FILE ${ARGN})
		get_filename_component(_in ${_current_FILE} ABSOLUTE)
		get_filename_component(_basename ${_current_FILE} NAME_WE)

		set(_out ${CMAKE_CURRENT_BINARY_DIR}/${_basename})

		generate_lemon_file(${_out} ${_in})

		list(APPEND ${_source} ${_in})
		list(APPEND ${_generated} ${_out}.c)

		# Our Lemon generated code has unused parameters. Turn that warning off.
		if(CMAKE_C_COMPILER_ID MATCHES "MSVC")
			set_source_files_properties(${_out}.c PROPERTIES COMPILE_OPTIONS "/wd4100")
		elseif(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
			set_source_files_properties(${_out}.c PROPERTIES COMPILE_OPTIONS "-Wno-unused-parameter")
		else()
			# Build with some warnings for lemon generated code
		endif()
	endforeach(_current_FILE)
endmacro(ADD_LEMON_FILES)
