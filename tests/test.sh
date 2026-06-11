# shellcheck shell=sh

assert_true "_args 1"
assert_false "_args"

assert_equal "_argc 1 2 3 4" "4"
assert_not_equal "_argc 1 2 3 4" "5"

_error "This is test error message."
_warning "This is test warning message."
_info "This is test info message."
_success "This is test success message."

assert_true "_integer 1"
assert_true "_integer +1"
assert_true "_integer -1"
assert_false "_integer"
assert_false "_integer 1.0"
assert_false "_integer a"
assert_false "_integer -1.9"
assert_false "_integer '' '' '' ''"

assert_true "_float 1.0"
assert_true "_float +1.0"
assert_true "_float -1.0"
assert_false "_float 1.0.0"
assert_false "_float +1.0.0"
assert_false "_float -1.0.0"
assert_false "_float 1"
assert_false "_float a"
assert_false "_float a.a"
assert_false "_float -1.a"
assert_false "_float '' '' '' ''"

_str_pad_left "hello" 33 x
_nl

total=100 i=0
while [ "$i" -le "$total" ]; do
    _progress $i "$total" "100"
    i=$((i + 1))
    sleep 1
done
