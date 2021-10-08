#!/usr/bin/env python3

import sys
import argparse

def run_ssl(args):
    return

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Helper for sol-eng-docker')
    # parser.add_argument('command', type=str, nargs=1, help='command to execute', choices=['ssl','other'])

    subparsers = parser.add_subparsers(help='choose a command')

    parser_ssl = subparsers.add_parser('ssl', help='Generate ssl certificates')
    parser_ssl.add_argument('host', "-h", type=str, help='hostnames for the certificate')
    parser_ssl.add_argument('--url', "-u", type=str, help='url for the cfssl service')


    args = parser.parse_args()
    command_args = args.command
    if len(command_args) >0 and command_args[0] == 'ssl':
        print('hi')
