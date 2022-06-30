ARG UBUNTU_VERSION=22.04

FROM ubuntu:${UBUNTU_VERSION} as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y \
        python3 python3-pip wget curl unzip git nano nvidia-cuda-dev golang libprotobuf-dev protobuf-compiler

# Set Home
WORKDIR /home/developer/yggdrasil-decision-forests
ENV HOME /home/developer/yggdrasil-decision-forests

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

# Build yggdrasil-decision-forests
RUN cd yggdrasil-decision-forests && bazel build //yggdrasil_decision_forests/cli:all --config=linux_cpp17 --config=linux_avx2
