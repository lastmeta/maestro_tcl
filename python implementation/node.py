from socket import *
from threading import Thread
import json


host = 'localhost'
port = 1234
s = socket(AF_INET, SOCK_STREAM)
s.connect((host, port))


t = Thread(target=listener)
t.start()


def accept_data(data):
    if data == 'shutdown':
        print('what the hell?')
        exit()


def listener():
    try:
        while True:
            data = s.recv(1024).decode('utf-8')
            print('incoming message:', data)
            accept_data(data)
    except ConnectionAbortedError:
        pass


def get_input():
    to = input('to: ')
    msg = input('msg: ')
    return to, msg



try:
    while True:
        to, msg = get_input()
        data = json.dumps({'to':to,'msg':msg})
        s.send(data.encode('utf-8'))
except EOFError:
    pass
finally:
    s.close()
