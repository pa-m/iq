module main

import os

fn test_get() ? {
	contents := os.read_file('fixtures/test.ini')?
	assert iq_exec('.section2.k2', contents)? == 'v2.2'
}

fn test_set_existing() ? {
	contents := os.read_file('fixtures/test.ini')?
	out := iq_exec('.section2.k2=v2.2.1', contents)?
	assert out == '[section1]
k1=v1
k2=v2

[section2]
;comment
#comment2
k1=v2.1
k2=v2.2.1 # comment3'
}

fn test_set_new() ? {
	contents := os.read_file('fixtures/test.ini')?
	actual := iq_exec('.section1.k3=v1.2.1', contents)?
	expected := '[section1]
k1=v1
k2=v2
k3=v1.2.1

[section2]
;comment
#comment2
k1=v2.1
k2=v2.2 # comment3'
	e := expected.split_into_lines()
	a := actual.split_into_lines()
	assert a == e
}

fn test_set_new2() ? {
	contents := os.read_file('fixtures/test.ini')?

	actual := iq_exec('.section2.k3=v1.2.1', contents)?
	expected := '[section1]
k1=v1
k2=v2

[section2]
;comment
#comment2
k1=v2.1
k2=v2.2 # comment3
k3=v1.2.1'
	e := expected.split_into_lines()
	a := actual.split_into_lines()
	assert a == e
}

fn test_set_new3() ? {
	contents := os.read_file('fixtures/test.ini')?
	actual := iq_exec('.section3.k3=v1.2.1', contents)?
	expected := '[section1]
k1=v1
k2=v2

[section2]
;comment
#comment2
k1=v2.1
k2=v2.2 # comment3

[section3]
k3=v1.2.1'
	e := expected.split_into_lines()
	a := actual.split_into_lines()
	assert a == e
}

fn test_inplace() ? {
	contents := os.read_file('fixtures/test.ini')?
	os.write_file('/tmp/test_iq.ini', contents)?
	assert 0 == os.system('v run . -i -e .section3.k3=v1.2.1 /tmp/test_iq.ini')
	expected := '[section1]
k1=v1
k2=v2

[section2]
;comment
#comment2
k1=v2.1
k2=v2.2 # comment3

[section3]
k3=v1.2.1'
	actual := os.read_file('/tmp/test_iq.ini')?
	e := expected.split_into_lines()
	a := actual.split_into_lines()
	assert a == e
	os.rm('/tmp/test_iq.ini')?
}
