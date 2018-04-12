from socket import socket, SO_REUSEADDR, SOL_SOCKET
from asyncio import Task, coroutine, get_event_loop
import json


class Peer(object):
    def __init__(self, server, sock, name):
        self.loop = server.loop
        self.name = name
        self._sock = sock
        self._server = server
        Task(self._peer_handler())

    def send(self, data):
        return self.loop.sock_sendall(self._sock, data.encode('utf8'))

    @coroutine
    def _peer_handler(self):
        try:
            yield from self._peer_loop()
        except IOError:
            pass
        finally:
            self._server.remove(self)

    @coroutine
    def _peer_loop(self):
        while True:
            buf = yield from self.loop.sock_recv(self._sock, 1024)
            buff_hash = json.loads(buf.decode('utf8'))
            if buf == b'':
                break
            elif buff_hash['to'] == 'server' and buff_hash['msg'] == 'shutdown':
                self._server.broadcast('%s: %s' % (self.name, buf.decode('utf8')))
                exit()
            elif buff_hash['to'] == 'all':
                self._server.broadcast('%s: %s' % (self.name, buf.decode('utf8')))
            else:
                print('from:',self.name,
                      'msg:', buff_hash['msg'],
                      'to:', buff_hash['to'])
                self._server.send_direct(buff_hash['msg'], buff_hash['to'])

class Server(object):
    def __init__(self, loop, port):
        self.name_count = 0
        self.loop = loop
        self._serv_sock = socket()
        self._serv_sock.setblocking(0)
        self._serv_sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
        self._serv_sock.bind(('',port))
        self._serv_sock.listen(5)
        self._peers = []
        Task(self._server())

    def remove(self, peer):
        self._peers.remove(peer)
        self.broadcast('Peer %s quit!\n' % (peer.name,))

    def broadcast(self, message):
        for peer in self._peers:
            peer.send(message)

    def send_direct(self, message, recipient):
        for peer in self._peers:
            if recipient in str(peer.name):
                peer.send(message)

    @coroutine
    def _server(self):
        while True:
            peer_sock, peer_name = yield from self.loop.sock_accept(self._serv_sock)
            self.name_count += 1
            peer_name = self.name_count
            peer_sock.setblocking(0)
            peer = Peer(self, peer_sock, peer_name)
            self._peers.append(peer)
            self.broadcast('Peer %s connected!\n' % (peer.name,))

def main():
    loop = get_event_loop()
    Server(loop, 1234)
    loop.run_forever()

if __name__ == '__main__':
    main()
