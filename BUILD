load("@rules_proto//proto:defs.bzl", "proto_library")
load("@io_bazel_rules_go//go:def.bzl", "go_library")
load("@io_bazel_rules_go//proto:def.bzl", "go_proto_library")

package(default_visibility = ["//visibility:public"])

load("@rules_python//python:defs.bzl", "py_binary")
load("@my_deps//:requirements.bzl", "requirement")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("@pybind11_bazel//:build_defs.bzl", "pybind_extension")

py_binary(
    name = "client",
    srcs = ["client.py"],
    main = "client.py",
    deps = [
        requirement("grpcio"),
        requirement("grpcio-tools"),
        requirement("numpy"),
        requirement("uvloop"),

    ],
)

proto_library(
    name = "example_service",
    srcs = ["example_service.proto"],
)