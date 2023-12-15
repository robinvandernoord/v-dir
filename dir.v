module dir

import v.reflection

fn builtins_properties(kind reflection.VKind) []string {
	// todo: can this be done automatically? (also for some items in `properties_()`)
	return match kind {
		.string {
			['len', 'str']
		}
		else {
			[]string{}
		}
	}
}

fn find_matching_items(arr1 []string, arr2 []string) []string {
	mut mapping := map[string]bool{}
	mut result := []string{}

	// Create a map with elements from the first array
	for num in arr1 {
		mapping[num] = true
	}

	// Check for common elements in the second array
	for num in arr2 {
		if num in mapping {
			result << num
		}
	}

	return result
}

fn sumtype_properties(st reflection.TypeInfo) []string {
	return match st {
		reflection.SumType {
			mut combined_properties := []string{}
			mut initialized := false

			for variant in st.variants {
				subtype := reflection.get_type(variant) or { panic(err) }
				properties := properties_(subtype.sym)

				if initialized {
					combined_properties = find_matching_items(combined_properties, properties)
				} else {
					combined_properties = properties.clone()
					initialized = true
				}
			}

			combined_properties
		}
		else {
			panic('Invalid type ${st}')
		}
	}
}

fn sumtype_methods(st reflection.TypeInfo) []string {
	return match st {
		reflection.SumType {
			mut combined_methods := []string{}
			mut initialized := false

			for variant in st.variants {
				subtype := reflection.get_type(variant) or { panic(err) }
				methods := methods_(subtype.sym)

				if initialized {
					combined_methods = find_matching_items(combined_methods, methods)
				} else {
					combined_methods = methods.clone()
					initialized = true
				}
			}

			combined_methods
		}
		else {
			panic('Invalid type ${st}')
		}
	}
}

fn properties_(obj reflection.TypeSymbol) []string {
	return match obj.info {
		reflection.Alias {
			parent := reflection.get_type(obj.parent_idx) or { panic(err) }
			properties_(parent.sym)
		}
		reflection.Array {
			// https://modules.vlang.io/index.html#array
			['cap', 'data', 'element_size', 'flags', 'len', 'offset']
		}
		reflection.ArrayFixed {
			['len']
		}
		reflection.Enum, reflection.Function, reflection.MultiReturn {
			// no properties:
			[]string{}
		}
		reflection.Map {
			['len']
		}
		reflection.None {
			builtins_properties(obj.kind)
		}
		reflection.Struct, reflection.Interface {
			obj.info.fields.map(it.name)
		}
		reflection.SumType {
			sumtype_properties(obj.info)
		}
	}
}

/* Get a list of all public properties of an object.
* The items are sorted alphabetically.
*/
pub fn properties(object reflection.TypeSymbol) []string {
	info := reflection.type_of(object)
	return properties_(info.sym)
}

fn methods_(obj reflection.TypeSymbol) []string {
	return match obj.kind {
		.alias {
			parent := reflection.get_type(obj.parent_idx) or { panic(err) }
			methods_(parent.sym)
		}
		.sum_type {
			sumtype_methods(obj.info)
		}
		else {
			obj.methods.map(it.name)
		}
	}
}

/* Get a list of all public methods of an object.
* The items are sorted alphabetically.
*/
pub fn methods[T](object T) []string {
	info := reflection.type_of(object)
	return methods_(info.sym)
}

/* Get a list of all public methods and properties of an object, like Python's dir(obj).
* The items are sorted alphabetically.
* If you need a separate list of methods and/or properties, use dir.methods or dir.properties instead.
*/
pub fn dir[T](object T) []string {
	mut result := []string{}

	info := reflection.type_of(object)

	result << properties_(info.sym)
	result << methods_(info.sym)

	result.sort()

	return result
}
