#!/usr/bin/python

import psutil
import datetime
import json
import schedule
import time
import logging
import logging.config

try:
    config = json.loads(open("config.json").read())
except FileNotFoundError:
    print("Config file not found. Trying to generate default config")
    json.dump(
        {"common": {"interval": "5",
                    "output": "json"},
         "logsettings": {"filename": "monitor.log",
                         "level": "DEBUG",
                         "format": "%(asctime)s %(name)-10s %(levelname)-10s %(message)s"}},
        open("config.json", "a"), indent=4)
    config = json.loads(open("config.json").read())

period = config['common']['interval']
file_type = config['common']['output']
file_txt0 = "outputdata.txt"
file_json0 = "outputdata.json"

logging.basicConfig(filename=config['logsettings']['filename'],
                    level=config['logsettings']['level'],
                    format=config['logsettings']['format'])
logger = logging.getLogger(__name__)


def logger_decorator(function0):
    """
    The decorator prints number of calls of the decorated function, its *args and **kwargs
    """

    def wrapper(self, file_name):
        wrapper.counter += 1
        print("\nWRAPPER: Start logging of {} function".format(function0.__name__))
        result = function0(self, file_name)
        print("WRAPPER: {} has been called {} times with parameters {}\n".format(function0.__name__, wrapper.counter,
                                                                                 file_name))
        logging.info("Wrapper invoked")
        return result

    wrapper.counter = 0
    return wrapper


class ConvertToDict(object):
    counter0 = 1

    def converttodict(self, psutil_info):
        """Converts psutil format into dictionary"""
        value = list(psutil_info)
        key = psutil_info._fields
        dict0 = dict(zip(key, value))
        return dict0

    @classmethod
    def counter_increment(cls):
        """Method increments snapshot counter"""
        cls.counter0 += 1
        logging.info("Snapshot counter incremented to {}".format(cls.counter0))


class TxtData(ConvertToDict):
    @logger_decorator
    def txt_to_file(self, file_txt):
        # write info to outputdata.txt file
        timestamp = datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d %H:%M:%S')
        txt_file = open(file_txt, "a")
        txt_file.write("\n###Snapshot {0} : {1} ###\n".format(ConvertToDict.counter0, timestamp))
        txt_file.write("--- System-wide CPU utilization per cpu---\n{0}\n".format(psutil.cpu_times()))
        txt_file.write("--- System-wide Memory usage---\n{0}\n".format(psutil.virtual_memory()))
        txt_file.write("--- System-wide Swap memory statistics---\n{0}\n".format(psutil.swap_memory()))
        txt_file.write("--- System-wide Disk I/O statistics---\n{0}\n".format(psutil.disk_io_counters()))
        txt_file.write("--- System-wide Network I/O statistics---\n{0}\n".format(psutil.net_io_counters(pernic=True)))
        ConvertToDict.counter_increment()
        txt_file.close()
        print(timestamp)
        logging.info("{} file written successfully".format(file_txt))


class JsonData(ConvertToDict):
    @logger_decorator
    def json_to_file(self, file_json):
        # write info to outputdata.json file
        timestamp = datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d %H:%M:%S')
        json_file = open(file_json, "a")
        json_file.write('{{\n"Snapshot {0}": "{1}",'.format(ConvertToDict.counter0, timestamp))
        json_file.write('\n"System-wide CPU utilization per cpu":\n')
        json.dump(super().converttodict((psutil.cpu_times())), json_file, indent=4)
        json_file.write('\n, "System Memory usage":\n')
        json.dump(super().converttodict(psutil.virtual_memory()), json_file, indent=4)
        json_file.write('\n, "System-wide Swap memory statistics":\n')
        json.dump(super().converttodict(psutil.swap_memory()), json_file, indent=4)
        json_file.write('\n, "System-wide Disk I/O statistics":\n')
        json.dump(super().converttodict(psutil.disk_io_counters()), json_file, indent=4)
        json_file.write('\n , "System-wide Network I/O statistics":\n')
        json.dump(psutil.net_io_counters(pernic=True), json_file, indent=4)
        json_file.write('\n}\n\n')
        ConvertToDict.counter_increment()
        json_file.close()
        print(timestamp)
        logging.info("{} file written successfully".format(file_json))


try:
    json0 = JsonData()
    logging.info("Object {} was created successfully".format(json0))
except Exception as e:
    logging.exception("Can not create object, {}".format(e))

try:
    txt0 = TxtData()
    logging.info("Object {} was created successfully".format(txt0))
except Exception as e:
    logging.exception("Can not create object, {}".format(e))


def main():
    if file_type == "txt":
        txt0.txt_to_file(file_txt0)
    elif file_type == "json":
        json0.json_to_file(file_json0)
    else:
        logging.error("Unknown type of file in config")
        quit()


try:
    schedule.every(int(period)).seconds.do(main)
    logging.info("Scheduler started")
except Exception as e:
    logging.exception("Can not start scheduler, {}".format(e))

while True:
    schedule.run_pending()
    time.sleep(0)
