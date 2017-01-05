import dateutil.parser
from datetime import datetime
from pytz import timezone
import os

def polonex_convertdate(isodate):
    date = dateutil.parser.parse(isodate)
    return date.strftime("%d-%m-%Y %H:%M")
