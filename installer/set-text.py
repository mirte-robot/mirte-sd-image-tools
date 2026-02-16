#!/usr/bin/python3



import asyncio
import sys
import time
import struct
from tmx_pico_aio import tmx_pico_aio


async def ssd1306(my_board):
    i2c_port = 0
    scl = 5
    sda = 4
    await my_board.set_pin_mode_i2c(i2c_port, sda, scl)
    await asyncio.sleep(0.1)
    funcs = await my_board.modules.add_tmx_ssd1306(i2c_port)
    print(funcs)
    await funcs["send_text"](
        "Starting"
    )
    last_txt = ''
    # read file /root/text.txt
    while True:
        try:
            await asyncio.sleep(1)
            with open('/root/text.txt', 'r') as file:
                txt = file.read()
            if txt != last_txt:
                print("send text to display: ", txt)
                out = await funcs["send_text"](txt)
                print(out)
                last_txt = txt
        except (KeyboardInterrupt, RuntimeError):
            await my_board.shutdown()
            sys.exit(0)
        except Exception as e:
            print(e)

# get the event loop
loop = asyncio.new_event_loop()

try:
    board = tmx_pico_aio.TmxPicoAio(loop=loop)
except KeyboardInterrupt as e:
    print(e)
    sys.exit()

try:
    # start the main function
    loop.run_until_complete(ssd1306(board))
except KeyboardInterrupt:
    loop.run_until_complete(board.shutdown())
    sys.exit(0)
except RuntimeError as e:
    print(e)
    sys.exit(0)