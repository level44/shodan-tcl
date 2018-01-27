set api_key <api_key>

set s_api [shodan_api new $api_key]
set s_stream_api [shodan_stream_api new $api_key]

#print out information about account linked to this api_key
puts [$s_api profile]

#print out information about the API plan
puts [$s_api apiInfo]

#count how many entries matches entered query
puts [$s_api count "country:PL freebsd city:Cracow" ""]

#search using entered query
set search_result [$s_api search "country:PL freebsd city:Cracow" ""]

#check if error was not reported
if {[lindex $search_result 0] >= 0} {
	set results [lindex $search_result 1]
	puts "Amount of the result [dict get $results total]"

	set index 0
	foreach line [dict get $results matches] {
		puts "Avilable keys in the response: line $index: [dict keys $line]"
		incr index
	}
}