# coding=utf-8
from datetime import datetime
import dateutil.parser
import json
import pytz

TZ = pytz.timezone('Europe/Kiev')

def string_to_float(string):
    return float(string)


def parse_date(date_str):
    date_str = datetime.strptime(date_str, "%d.%m.%Y %H:%M")
    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
                    date_str.microsecond)
    date = TZ.localize(date).isoformat()
    return date


def parse_item_date(date_str):
    date_str = datetime.strptime(date_str, "%d.%m.%Y")
    date = datetime(date_str.year, date_str.month, date_str.day)
    date = TZ.localize(date).isoformat()
    return date


def convert_date_to_string(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y %H:%M")
    return date


def convert_item_date_to_string(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y")
    return date

def download_file_from_url(url, path_to_save_file):
    f = open(path_to_save_file, 'wb')
    f.write(urllib.urlopen(url).read())
    f.close()
    return os.path.basename(f.name)

def Format(val):
    return '{:2f}'.format(val)