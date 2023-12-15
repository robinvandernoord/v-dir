module dir

import arrays

struct Example {
	property int
}

fn (e Example) method_zero() {}

fn (e Example) method_one(argument string) int
fn (e &Example) method_two() {}

fn (mut e Example) method_three() {}

fn test_struct() {
	example := Example{}

	required := ['method_one', 'method_three', 'method_two', 'method_zero', 'property']
	dir_output := dir(example)
	assert dir_output == required

	mut combined := arrays.merge(properties(example), methods(example))
	combined.sort()

	assert combined == dir_output
}

fn test_builtins() {
	assert dir('string').len > 0
	assert dir(123).len > 0
	assert dir(123.456).len > 0
	assert dir(true).len > 0
}

fn test_array() {
	dynamic := []string{}
	assert dir(dynamic).len > 0

	fixed := [3]int{}
	assert dir(fixed).len > 0

	assert dir(dynamic) != dir(fixed)
}

fn test_map() {
	my_map := map[int]string{}
	assert dir(my_map).len > 0
}

fn test_function() {
	assert dir(test_function).len == 0
}

enum TestEnum {
	first
}

fn test_enum() {
	assert dir(TestEnum.first).len == 0
}

type NewType = string

fn test_alias() {
	aliased := NewType('hi')

	assert 'len' in dir(aliased)
}

interface MyInterface {
	public string
}

fn (i MyInterface) first_method()

struct Impl {
	public string
	extra  int
}

fn (i Impl) second_method()

fn test_interface() {
	mut list_of_interface := []MyInterface{}

	list_of_interface << Impl{'something', 123}

	list := dir(list_of_interface[0])

	assert 'public' in list
	assert 'first_method' in list
	assert 'extra' !in list
	assert 'second_method' !in list
}

struct SumFirst {
	first  int
	second int
}

fn (s SumFirst) matches()
fn (s SumFirst) doesnt()

struct SumSecond {
	first int
	third int
}

fn (s SumSecond) matches()
fn (s SumSecond) doesnt_either()

type SomeSum = SumFirst | SumSecond

fn test_sumtype() {
	summed := SomeSum(SumFirst{1, 2})

	list := dir(summed)

	assert 'first' in list
	assert 'second' !in list
	assert 'third' !in list

	assert 'matches' in list
	assert 'doesnt' !in list
	assert 'doesnt_either' !in list
}

fn this_multireturns() (string, int) {
	return '', 0
}

fn test_multireturn() {
	assert dir(this_multireturns()) == []
}
