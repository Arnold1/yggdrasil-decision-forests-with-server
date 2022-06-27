set -x
set -e

bazel build --config=linux_cpp17 --config=linux_avx2 --incompatible_require_linker_input_cc_api=false //:main

./bazel-bin/main