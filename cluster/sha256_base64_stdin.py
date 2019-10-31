#!/Users/carendt/.pyenv/shims/python3
##!/usr/bin/python3
import sys
import hmac
import hashlib
import base64

print('hi');

#log_file = open("file.txt", "w+")
log_file = sys.stdout
#for line in sys.stdin:
#    print(line, file = log_file)
#    h = hmac.new('key'.encode('utf8'), line.encode('utf8'), hashlib.sha256).digest()
#    print(base64.encodebytes(h).decode('utf8'), end = "", file = log_file)
while True:
    line = input()
    print(line, file = log_file)
    h = hmac.new('key'.encode('utf8'), line.encode('utf8'), hashlib.sha256).digest()
    print(base64.encodebytes(h).decode('utf8'), end = "", file = log_file)
