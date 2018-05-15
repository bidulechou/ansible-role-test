#!/bin/bash

###############################################################
# Script file containing logging functions
###############################################################
#
# The goal of this set of functions is to standardize loggin
# features whatever could be the output format which actually
# are:
#
#   1. screen during the test with shell coloration
#   2. human readable text report file without color codes
#   3. Jenkins readable JUnit test result file
#
###############################################################

# define shell colors for screen tests result report
RED='\033[1;31m'   # light red
GREEN='\033[1;32m' # light green
NC='\033[0m'       # No Color

# define script's scope variables
report_header="\nTest Result Report for Ansible Roles Test\n"
xml_header="<?xml version="1.0" encoding="UTF-8"?>"

###############################################################
# Util's Functions
###############################################################

##
 # Function: init_report
 #   Initialize report content for the 3 possible output by putting in those there
 #   respective header string
 #
 # @parameter: String   text_report_name, the name of the textual report file
 # @parameter: String    xml_report_name, the name of the XML (Junit) report file
 #
init_report() {
  echo -e "${report_header}" >> ${1}
  echo "${xml_header}" >> ${2}
  echo "${report_header}"
}

##
 # Function: init_report_files
 #   Creates new report files with suppress older first
 #
init_report_files() {
  # first suppress old report files if needed...
  [ -f ${ROLESPEC_RUNTIME}/tests/result_report.txt ] && rm -f ${ROLESPEC_RUNTIME}/tests/result_report.txt
  [ -f ${ROLESPEC_RUNTIME}/tests/result_junit.xml ] && rm -f ${ROLESPEC_RUNTIME}/tests/result_junit.xml

  export res_file="${ROLESPEC_RUNTIME}/tests/result_report.txt"
  export junit_file="${ROLESPEC_RUNTIME}/tests/result_junit.xml"
  export junit_temp_file=$(mktemp)
}

##
 # Function: init_temp_files
 #   Creates new intermediate (temporary) report files
 #
init_temp_files() {
  export intermediate_res_file=$(mktemp)
  export intermediate_junit_file=$(mktemp)
  export intermediate_test_list=$(mktemp)
}

##
 # Function: init_temp_files
 #   Liberate intermediate (temporary) report files
 #
reset_temp_files() {
  unset intermediate_res_file
  unset intermediate_junit_file
  unset intermediate_test_list
}

##
 # Function: report_result
 #   Write content of text bloc sent as parameter into report file
 #
 # @parameter: String text_block ($1), a multi-lines string containing testsuite partial test report
 #
report_result() {
    echo -e "${1}" >> ${res_file}
}

##
 # Function: colored_result
 #   Interpret test script result and return colorized human readable result
 #
 # @parameter: Int    test_result ($1), the returned test value
 #
colored_result() {
    [[ "$1" -eq 0 ]] && retVal="${GREEN}OK${NC}" || retVal="${RED}KO${NC}"
    echo "${retVal}"
}

##
 # Function: no_color_result
 #   Interpret test script result and return human readable result
 #
 # @parameter: Int    test_result ($1), the returned test value
 #
no_color_result() {
    [[ "$1" -eq 0 ]] && retVal="OK" || retVal="KO"
    echo "${retVal}"
}

##
 # Function: number_chars
 #   Calculate and return remaining characters of standard 80 chars console line by subtracting
 #   number of chars contained in both strings sent as parameters
 #
 # @parameter: String string_1 ($1), a string of points delimiting test name and test status
 # @parameter: String string_2 ($2), the status of the test case
 #
number_chars() {
    char_len=$(expr ${#1} + ${#2} + 19)
    char_len=$(expr 80 - ${char_len})
    echo "${char_len}"
}

##
 # Function: number_lines
 #   Return counted number of lines contained in a text block
 #
 # @parameter: String text_block ($1), a multi-lines string containing testsuite partial test report
 #
number_lines() {
    retVal=`wc -l ${1} | cut -d' ' -f1`
    echo "${retVal}"
}

##
 # Function: number_tests
 #   Count then number of test cases in a testsuite
 #
 # @parameter: String test_head ($1), a string containing the number of test cases
 #
number_tests() {
    retVal=`cat ${1} | grep 'number of unit tests' | cut -d':' -f2 | tr -d '[:space:]'`
    echo "$retVal"
}

##
 # Function: point_string
 #   Return a line containing 'max_value' number of points
 #
 # @parameter: Int    max_value ($1), the number of desired points
 #
point_string() {
    retVal=''
    for ((i=1; i<=$((${1})); i++))
    do
	retVal+='.'
    done
    echo "$retVal"
}

##
 # Function: count_num_tests
 #   Count number of tests to execute
 #
 # @parameter: String test_folder ($1), a string containing the root path of tests
 #
count_num_tests() {
  echo $(ls -l ${1} | grep -c ^d)
}

##
 # Function: extract_test_list
 #   Return test case name from intermediate (temporary) test names' file
 #
 # @parameter: Int    test_order ($1), the order number of test case in testsuite
 #
extract_test_list() {
  line_index=1
  while read line
  do
    if [[ "${1}" == "$line_index" ]]; then
      echo "$line"
      break
    fi
    (( line_index++ ))
  done < ${intermediate_test_list}
}

###############################################################
# Logging Functions
###############################################################
#
#  Cause of the principal of exit on fail in shell tests
#  only passed tests can be logged during test execution
#  if a test fails it must be reported after the end of the
#  test and then if remains test(s) they will be marked as
#  skipped during the same reporting process.
#
###############################################################

##
 # Function: log_test
 #   Write test report line into temporary report file
 #
 # @parameter: String test_name ($1), the name of the current test case
 # @parameter: Int    num_test ($2), the order number of the test case
 # @parameter: String point_line ($3), a string of points delimiting test name and test status
 # @parameter: String test_status ($4), the status of the test case
 #
log_test() {
  echo "    test case ${2}: ${1} ${3} ${4}" >> ${intermediate_res_file}
}

##
 # Function: log_test
 #   Write test case name list into temporary test names' file
 #
 # @parameter: String test_names ($1), a string containing '\n' separated test case names
 #
log_test_list() {
  echo -e "${1}" >> ${intermediate_test_list}
}

##
 # Function: log_text_pass
 #   Proceed test 'PASS' logging report in both xml and text files
 #
 # @parameter: String test_name ($1), the name of the current test case
 # @parameter: Int    num_test ($2), the order number of the test case
 #
log_test_pass() {
  status="PASS"
  num_char=$(number_chars ${1} ${status})
  point_line=$(point_string ${num_char})
  log_test "${1}" "${2}" "${point_line}" "${status}"
  log_xml_pass "${role_name}" "${1}" "${2}"
}

##
 # Function: log_text_failed
 #   Proceed test 'FAILED' logging report in both xml and text files
 #
 # @parameter: String test_name, the name of the current test case
 # @parameter: Int    num_test, the order number of the test case
 #
log_test_failed() {
  status="FAILED"
  num_char=$(number_chars ${1} ${status})
  point_line=$(point_string ${num_char})
  log_test "${1}" "${2}" "${point_line}" "${status}"
  log_xml_failed "${role_name}" "${1}" "${2}"
}

##
 # Function: log_text_skipped
 #   Proceed test 'SKIPPED' logging report in both xml and text files
 #
 # @parameter: String test_name, the name of the current test case
 # @parameter: Int    num_test, the order number of the test case
 #
log_test_skipped() {
  status="SKIPPED"
  num_char=$(number_chars ${1} ${status})
  point_line=$(point_string ${num_char})
  log_test "${1}" "${2}" "${point_line}" "${status}"
  log_xml_skipped "${role_name}" "${1}" "${2}"
}

##
 # Function: log_prepare
 #   Write informative report line into intermediate report file to prepare testsuite report
 #
 # @parameter: Int   num_testcases, the number of the test cases in testsuite
 #
log_prepare() {
  num_test_cases=${1}
  echo "    number of unit tests: ${num_test_cases}" >> ${intermediate_res_file}
}



###############################################################
# XML logging functions
###############################################################

##
 # Function: flush_intermediate_xml
 #   Write content of intermediate report file into temporary report file
 #
flush_intermediate_xml() {
  cat ${intermediate_junit_file} >> ${junit_temp_file}
}

##
 # Function: flush_xml_temp
 #   Write content of temporary report file into junit report file
 #
flush_xml_temp() {
  cat ${junit_temp_file} >> ${junit_file}
}

##
 # Function: open_document
 #   Open XML document 'testsuites' element and write it into junit report file
 #
 # @parameter: Int   num_errors, the number of errors
 # @parameter: Int   num_failures, the number of failures
 # @parameter: Int   num_tests, the number of testsuite tests
 # @parameter: Int   enlapsed_time, the total execution time of all tests
 #
open_document() {
  echo "<testsuites errors=\"${1}\" failures=\"${2}\" tests=\"${3}\" time=\"${4}\">" >> ${junit_file}
}

##
 # Function: close_document
 #   Close XML document 'testsuites' element and write it into junit report file
 #
close_document() {
  echo "</testsuites>" >> ${junit_file}
}

##
 # Function: xml_open_element
 #   Open 'testsuite' element and write it into temporary report file
 #
 # @parameter: String test_name, the name of the current test case
 # @parameter: Int    num_tests, the number of test cases in testsuite
 # @parameter: Int    num_pass, the number of passed test cases
 # @parameter: Int    num_failed, the number of failed test cases
 # @parameter: Int    num_skipped, the number of skipped test cases
 #
xml_open_element() {
  echo "  <testsuite role_name=\"${1}\" tests=\"${2}\" errors=\"${4}\" pass=\"${3}\" failed=\"${4}\" skipped=\"${5}\">" >> ${junit_temp_file}
}

##
 # Function: xml_close_element
 #   Close 'testsuite' element and write it into temporary report file
 #
xml_close_element() {
  echo "  </testsuite>" >> ${junit_temp_file}
}

##
 # Function: xml_closed_element
 #   Write closed 'testsuite' element into temporary report file
 #
 # @parameter: String test_name, the name of the current test case
 # @parameter: Int    num_tests, the number of test cases in testsuite
 # @parameter: Int    num_pass, the number of passed test cases
 # @parameter: Int    num_failed, the number of failed test cases
 # @parameter: Int    num_skipped, the number of skipped test cases
 #
xml_closed_element() {
    echo "  <testsuite role_name=\"${1}\" tests=\"${2}\" errors=\"${3}\" pass=\"${4}\" failed=\"${3}\" skipped=\"${5}\"/>" >> ${junit_temp_file}
}

##
 # Function: log_xml_element
 #   Proceed logging xml element and automatically use opened or closed xml element
 #   regarding if child elements are needed or not
 #
 # @parameter: String test_name, the name of the current test case
 # @parameter: Int    num_tests, the number of test cases in testsuite
 # @parameter: Int    num_pass, the number of passed test cases
 # @parameter: Int    num_failed, the number of failed test cases
 # @parameter: Int    num_skipped, the number of skipped test cases
 #
log_xml_element() {
  if [[ "${2}" == "0" ]]; then
    xml_closed_element "${1}" "${2}" "${3}" "${4}" "${5}"
  else
    xml_open_element "${1}" "${2}" "${3}" "${4}" "${5}"
  fi
}

##
 # Function: log_xml_element
 #   Proceed logging 'testsuite' for junit report output
 #   fetch child elements and close parent element if needed
 #
 # @parameter: String test_name, the name of the current test case
 # @parameter: Int    num_tests, the number of test cases in testsuite
 # @parameter: Int    num_pass, the number of passed test cases
 # @parameter: Int    num_failed, the number of failed test cases
 # @parameter: Int    num_skipped, the number of skipped test cases
 #
log_xml_testsuite() {
  log_xml_element "${1}" "${2}" "${3}" "${4}" "${5}"
  if [[ "${2}" != "0" ]]; then
    flush_intermediate_xml
    xml_close_element
  fi
}

##
 # Function: log_xml_pass
 #   Write 'pass' test case element into intermediate junit report file
 #
 # @parameter: String role_name, the name of the current testsuite
 # @parameter: String test_name, the name of the current test case in the testsuite
 # @parameter: Int    num_pass, the order number of the current test case
 #
log_xml_pass() {
  echo "    <testcase role_name=\"${1}\" test_name=\"${2}\" test_number=\"${3}\" time=\"0\">" >> ${intermediate_junit_file}
  echo "      <status>PASS</status>" >> ${intermediate_junit_file}
  echo "    </testcase>" >> ${intermediate_junit_file}
}

##
 # Function: log_xml_failed
 #   Write 'failed' test case element into intermediate junit report file
 #
 # @parameter: String role_name, the name of the current testsuite
 # @parameter: String test_name, the name of the current test case in the testsuite
 # @parameter: Int    num_pass, the order number of the current test case
 #
log_xml_failed() {
  echo "    <testcase role_name=\"${1}\" test_name=\"${2}\" test_number=\"${3}\" time=\"0\">" >> ${intermediate_junit_file}
  echo "      <failure message='test failure'>Assertion failed</failure>" >> ${intermediate_junit_file}
  echo "    </testcase>" >> ${intermediate_junit_file}
}

##
 # Function: log_xml_skipped
 #   Write 'skipped' test case element into intermediate report file
 #
 # @parameter: String role_name, the name of the current testsuite
 # @parameter: String test_name, the name of the current test case in the testsuite
 # @parameter: Int    num_pass, the order number of the current test case
 #
log_xml_skipped() {
  echo "    <testcase role_name=\"${1}\" test_name=\"${2}\" test_number=\"${3}\" time=\"0\">" >> ${intermediate_junit_file}
  echo "      <tatus>SKIPPED</status>" >> ${intermediate_junit_file}
  echo "    </testcase>" >> ${intermediate_junit_file}
}


###############################################################
# Process Functions
###############################################################
#
#  Cause of shell exit on fail principal it is needed to interpret
#  existing result which have been pushed in temporary file
#  during test execution.
#
###############################################################

##
 # Function: process_text_block
 #   Proceed intermediate temporary report file which has been filled during test execution
 #
 # @parameter: String text_block, the name of the current test case
 #
process_text_block() {
    failed=0
    skipped=0
    num_lines=$(number_lines ${1})
    if [[ $num_lines -gt 0 ]]; then
        real_num=$(expr $num_lines - 1)
        num_tests=$(number_tests ${1})
    else
        real_num=0
        num_tests=0
    fi
    max=$(expr $num_tests - $real_num)
    if [ "${num_tests}" != "0" ]; then ## no process to do if no unit tests
	    #if [ "${real_num}" != "${num_tests}" ] && [ ! $((real_num)) -lt 0 ]; then ## if values are different test report must be completed
	    if [ "${real_num}" != "${num_tests}" ]; then ## if values are different test report must be completed
	        i=1
	        while [ $i -le $max ]; do
                test_name=$(extract_test_list "$((i + real_num))")
		        if [ "${i}" == "1" ]; then ## if '$max = 1' only last test has failed, no skipped tests
		            log_test_failed "${test_name}" "$((i + real_num))"
		            failed=1
		        else ## else all remaining tests after failure are skipped
		            log_test_skipped "${test_name}" "$((i + real_num))"
		            (( skipped++ ))
		        fi
		        (( i++ ))
	        done
	    fi
        # prepare xml element for JUnit report file
        log_xml_testsuite "${role_name}" "${num_tests}" "${real_num}" "${failed}" "${skipped}"
    else
        # report no test cases...
        echo "    no unit test cases for that test suite." >> ${intermediate_res_file}
        # prepare xml element for JUnit report file
        log_xml_testsuite "${role_name}" "${num_tests}" 0 0 0
    fi
}
