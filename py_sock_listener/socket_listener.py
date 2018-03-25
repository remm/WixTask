#!/usr/bin/python3
import socket

from morse_lib import encode_to_morse


class LogSocket:
    def __init__(self, socket):
        self.socket = socket

    def send(self, data):
        print("Sending {0} to {1}".format(data, self.socket.getpeername()[0]))
        self.socket.send(data)

    def close(self):
        self.socket.close()


def respond(client, response):
    client.send(bytes(response, 'utf8'))
    client.close()


if __name__ == "__main__":
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(('0.0.0.0', 11000))
    server.listen(1)
    try:
        while True:
            client, addr = server.accept()
            respond(LogSocket(client), encode_to_morse(addr[0]))
    finally:
        server.close()
