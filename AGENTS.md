# Testing
Instead of running one-off tests, add tests to $file_test.sh and run the file.

Write tests as if-statements:
```shell
source file_with_extract_version_number

should_extract_version_number() {
  input="domstolene/ip-matrikkel:pom.xml:         <maven.compiler.target>17</maven.compiler.target>"
  expected="17"
  result=$(extract_version_number)

  if [[ expected != result ]]; then
    failures+=("extract_version_number, expected '$expected', got '$result')
  fi
}

should_extract_version_numbers

for failure in failures; do
  echo "❌ $failure"
done

if [[ $failures ]]; then
  exit 1
fi
```

# Code order
ALLWAYS write code in the order it is read, main function first, then functions as they are used.

BAD:
```shell
b() {
  echo b
}
a() {
  echo a
}
main() {
  a
  b
}
```

GOOD:
```shell
main() {
  a
  b
}
a() {
  echo a
}
b() {
  echo b
}
```

# Abstraction level
Keep functions on the same abstraction level. Split into functions for good maintainability. A function should not exceed 10 lines. main function should not contain lot of details, prefer named functions, loops and if-statements explaining the program flow.

BAD:
```shell
main() {
  something=$(grep -E '(pattern)[a-z]+.?)' file.txt)
  if [[ -z something ]]; then
    echo "failure" >&2
  fi

  do_more
}
```

GOOD:
```shell
main() {
  if something=$(find_something); then
    do_more
  fi
}

find_something() {
  grep -E '(pattern)[a-z]+.?)' file.txt
}
```
