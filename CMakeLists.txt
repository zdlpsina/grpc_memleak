cmake_minimum_required(VERSION 3.22)

set (CMAKE_CXX_STANDARD 11)
set (CMAKE_PREFIX_PATH /grpc/cmake/install)

project(repro_server VERSION 1.0 LANGUAGES CXX C)

set(protobuf_MODULE_COMPATIBLE TRUE)
find_package(protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)
find_package(Threads)

set(PROTO_FILES
    example_service.proto
)

# protobuf source files go into the lib just like any other CPP source file
add_library(my-service ${PROTO_FILES})
target_link_libraries(my-service
    PUBLIC
        protobuf::libprotobuf
        gRPC::grpc
        gRPC::grpc++
)

target_include_directories(my-service
    PUBLIC
        ${CMAKE_CURRENT_BINARY_DIR}
)

get_target_property(grpc_cpp_plugin_location gRPC::grpc_cpp_plugin LOCATION)

# compile the message types
protobuf_generate(TARGET my-service LANGUAGE cpp)

# compile the GRPC services
protobuf_generate(
    TARGET
        my-service
    LANGUAGE
        grpc
    GENERATE_EXTENSIONS
        .grpc.pb.h
        .grpc.pb.cc
    PLUGIN
        "protoc-gen-grpc=${grpc_cpp_plugin_location}"
)

add_executable(server server.cc)

target_link_libraries(server my-service)