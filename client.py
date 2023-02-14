import asyncio
import logging
import random
import string
import sys

import grpc
import uvloop

import example_service_pb2
import example_service_pb2_grpc


async def make_request(stub):
    rpc = stub.StreamDecode()
    await asyncio.gather(_send(rpc), _recv(rpc))


async def _send(rpc):
    length = random.randrange(1*16000, 30*16000, 2)
    sent = 0
    while sent < length:
        chunk_len = min(1600, length-sent)
        req = example_service_pb2.DecodeRequest(audio_data=bytes(chunk_len))
        await rpc.write(req)
        sent += chunk_len
        await asyncio.sleep(chunk_len / 16000)
    await rpc.done_writing()


async def _recv(rpc):
    async for msg in rpc:
        logging.debug(msg)


async def request_loop(stub, idx):
    i = 0
    while True:
        await asyncio.sleep(random.uniform(0.1, 2))
        await make_request(stub)
        logging.info('task %d request %d done', idx, i)
        i += 1


async def amain(server_addr, concurrency):
    async with grpc.aio.insecure_channel(server_addr) as channel:
        stub = example_service_pb2_grpc.StreamServiceStub(channel)
        await asyncio.gather(*[request_loop(stub, idx) for idx in range(concurrency)])


def main():
    uvloop.install()
    logging.basicConfig(level=logging.INFO)
    if len(sys.argv) != 3:
        print(f'usage: {sys.argv[0]} <server-address> <concurrency>')
        sys.exit(1)
    
    asyncio.run(amain(sys.argv[1], int(sys.argv[2])))


if __name__ == '__main__':
    main()
