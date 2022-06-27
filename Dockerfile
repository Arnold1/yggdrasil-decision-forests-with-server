ARG UBUNTU_VERSION=22.04

FROM ubuntu:${UBUNTU_VERSION} as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y \
        python3 python3-pip wget curl unzip git nano nvidia-cuda-dev golang libprotobuf-dev protobuf-compiler

# Set Home
WORKDIR /home/developer
ENV HOME /home/developer

# Install Bazel
ENV BAZEL_VERSION 5.1.1
RUN wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
RUN chmod +x bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh
RUN ./bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh --user
RUN cp -r $HOME/bin/bazel* /usr/bin/

# Install conan
RUN pip3 install conan

# Install tensorflow_decision_forests
RUN pip3 install -vv tensorflow_decision_forests

# Git clone yggdrasil-decision-forests
# hash: https://github.com/google/yggdrasil-decision-forests/commit/7be00e9b97eb6ada165823762a0df8a6e3d352af
#RUN git clone --branch main --depth=1 https://github.com/google/yggdrasil-decision-forests
ADD . $HOME

# dumb hack around a silly bug in TensorFlow: https://github.com/tensorflow/tensorflow/issues/56540
# begin dumb-hack
# get the files associated with the tensorflow target, but do not build yet
RUN env -C yggdrasil-decision-forests/ bazel fetch @org_tensorflow//tensorflow; exit 0
RUN sed -i -e 's/LLVM_SHA256 = "5a19ab6de4b0089fff456c0bc406b37ba5f95c76026e6bec294ec28dc28e4cb9"/LLVM_SHA256 = "10937113be5c7c551cffd7accf426e35b9071cac3251cb2b711076bdda0e98ea"/g' $(find /home/developer/.cache/bazel -path "*/org_tensorflow/third_party/llvm/workspace.bzl")
RUN sed -i -e 's/{commit}.tar.gz/{commit}.zip/g' $(find /home/developer/.cache/bazel -path "*/org_tensorflow/third_party/llvm/workspace.bzl")
# end dumb-hack

# Build yggdrasil-decision-forests
RUN cd yggdrasil-decision-forests && bazel build //yggdrasil_decision_forests/cli:all --config=linux_cpp17 --config=linux_avx2
