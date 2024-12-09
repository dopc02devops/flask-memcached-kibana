import logging
import os
import sys


def logger():
    # Redirect 1 to sys.stdout and 2 to sys.stderr
    os.dup2(sys.stdout.fileno(), 0)
    os.dup2(sys.stderr.fileno(), 1)
    # Set up basic configuration for logging
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s: %(levelname)s: %(message)s',
        datefmt='%m/%d/%Y %I:%M:%S %p',
        force=True,
        handlers=
        [
            logging.FileHandler("app.log"),  # Log to a file
            logging.StreamHandler()  # Also log to console
        ])
    logger = logging.getLogger("book-logs")

    return logger
