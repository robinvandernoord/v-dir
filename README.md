# V Dir

This module provides functionalities similar to Python's `dir()` function for Vlang.

## Installation

Install the module using vpm:

```bash
v install robinvandernoord.dir
```

## Usage

### Importing the Module

```v
import robinvandernoord.dir
```

### `dir.dir()`

The primary method to inspect any object is `dir.dir()`. It returns a sorted list of all public methods and properties
of the provided object.

```v
dir.dir[T](object T) []string
```

### Example

```v
import robinvandernoord.dir
import time

struct Person {
	name string
	birth_year int
}

fn (p Person) age() int {
	current_year := time.now().year
	return current_year - p.birth_year
}

fn main() {
	person := Person{name: 'Alice', birth_year: 1993}

	// Get all public methods and properties of the person object
	dir_output := dir.dir(person) // []string

	println(dir_output) // ['age', 'birth_year', 'name']
}
```

## Contribution

Contributions via issues or pull requests are welcome.

## License

This project is licensed under the MIT License.
