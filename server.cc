#include "example_service.grpc.pb.h"

#include <grpcpp/grpcpp.h>
#include <grpcpp/resource_quota.h>

#include <string>
#include <memory>
#include <iostream>

#include <cstdint>


struct ServerConfig {
    std::string SomeConfigOption {};
};

class ServiceImpl: public StreamService::Service {
    ::grpc::Status StreamDecode(
        ::grpc::ServerContext* context,
        ::grpc::ServerReaderWriter< ::DecodeResult, ::DecodeRequest>* stream
    ) override
    {
        std::size_t received_bytes = 0;
        std::size_t processed_bytes = 0;
        constexpr std::size_t block_size = 16000;
        DecodeRequest req;
        DecodeResult result;
        while (stream->Read(&req)) {
            received_bytes += req.audio_data().size();
            for (; received_bytes - processed_bytes >= block_size; processed_bytes += block_size) {
                result.set_final(false);
                result.set_text_result(config_.SomeConfigOption);
                stream->Write(result);
            }
        }
        result.set_final(true);
        result.set_text_result(config_.SomeConfigOption);
        stream->Write(result);
        return ::grpc::Status::OK;
    }

public:
    ServiceImpl(ServerConfig& config)
    : config_(config)
    {}

private:
    ServerConfig& config_;
};


int main(int argc, char *argv[]) {
    if (argc != 2) {
        std::cerr << "usage: " << argv[0] << " <listen-addr>" << std::endl;
        return 1;
    }
    ServerConfig config;
    config.SomeConfigOption = "hello world";

    grpc::ResourceQuota quota;
    quota.Resize(100*1024*1024);

    ServiceImpl service(config);

    grpc::ServerBuilder builder;
    builder.SetResourceQuota(quota);
    builder.AddListeningPort(argv[1], grpc::InsecureServerCredentials());
    builder.RegisterService(&service);

    std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
    std::cerr << "listening on " << argv[1] << std::endl;
    server->Wait();
}