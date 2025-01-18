import os
import logging

def setup_logger(name="app-logger", log_file="flask.log", level=logging.DEBUG):
    """
    Sets up a logger with the given name, log file, and log level.
    Ensures the log directory exists before creating the log file.
    
    :param name: Name of the logger
    :param log_file: File to write logs to (supports relative or absolute paths)
    :param level: Logging level (e.g., logging.DEBUG, logging.INFO)
    :return: Configured logger instance
    """
    # Ensure the directory for the log file exists
    log_dir = os.path.dirname(log_file)
    if log_dir and not os.path.exists(log_dir):
        os.makedirs(log_dir)

    # Create and configure the logger
    logger = logging.getLogger(name)
    logger.setLevel(level)

    if not logger.handlers:
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(level)
        file_formatter = logging.Formatter(
            '%(asctime)s: %(levelname)s: %(message)s', 
            datefmt='%m/%d/%Y %I:%M:%S %p'
        )
        file_handler.setFormatter(file_formatter)

        stream_handler = logging.StreamHandler()
        stream_handler.setLevel(level)
        stream_formatter = logging.Formatter('%(levelname)s: %(message)s')
        stream_handler.setFormatter(stream_formatter)

        logger.addHandler(file_handler)
        logger.addHandler(stream_handler)

    return logger
