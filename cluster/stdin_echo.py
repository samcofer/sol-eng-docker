#!/usr/bin/python3
import asyncio
import sys
import argparse

async def run(cmd):
    proc = await asyncio.create_subprocess_shell(
        cmd,
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE)

    for line in sys.stdin:
        print('writing stdin: ' + line)
        proc.stdin.write(line.encode('utf8'))
        await proc.stdin.drain()
    
        for i in range(1,10):
            print('checking stdout: ' + str(i))
            try:
                stdout = await asyncio.wait_for(proc.stdout.readline(), 0.1)
            except asyncio.TimeoutError:
                #stdout = 'hi'.encode('utf8')
                print('timeout!')
                continue
            print('done checking stdout: ' + str(i))
            if stdout:
                print(f'[stdout] {stdout.decode()}')


async def read_stdout(stdout):
    print('read_stdout')
    while True:
        buf = await stdout.readline()
        if not buf:
            break

        print(f'stdout: { buf }')


async def read_stderr(stderr):
    print('read_stderr')
    while True:
        buf = await stderr.readline()
        if not buf:
            break

        print(f'stderr: { buf }')


async def write_stdin_parent(stdin, what = sys.stdin):
    try:
        await asyncio.wait_for(write_stdin(stdin, what), 0.5)
    except asyncio.TimeoutError:
        print('Timeout!')

async def write_stdin(stdin, what = sys.stdin):
    print('write_stdin')
    print('waiting for input...')
    for line in what:
        buf = line.encode()
        print(f'stdin: { buf }')

        stdin.write(buf)
        await stdin.drain()
        print('waiting for input...')
        #await asyncio.sleep(0.01)
        await asyncio.sleep(0.1)
    print('done waiting...')


async def run_new(cmd):
    proc = await asyncio.create_subprocess_shell(
        cmd,
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE)

    await asyncio.gather(
        read_stderr(proc.stderr),
        read_stdout(proc.stdout),
        write_stdin(proc.stdin))

# THANK YOU https://stackoverflow.com/questions/55590343/asyncio-run-or-run-until-complete
def arun(aw):
    if sys.version_info >= (3, 7):
        return asyncio.run(aw)

    # Emulate asyncio.run() on older versions
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        return loop.run_until_complete(aw)
    finally:
        loop.close()
        asyncio.set_event_loop(None)

if __name__ == "__main__":
    args = sys.argv
    print(args)
    print("Removing first argument")
    del(args[0])

    command_to_run = ' '.join(args)
    print(command_to_run)

    arun(run_new(command_to_run))
