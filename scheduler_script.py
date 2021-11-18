#!/usr/bin/env python3

import os
import time

def run():
    while True:
        os.environ['TOKEN_UPDATED'] = str(12345)
        time.sleep(180)
        os.environ['TOKEN_NEW'] = str(time.time())


if __name__ == "__main__":
    run()
