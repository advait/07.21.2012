#!/usr/bin/python

import sys
import os
import argparse
import urllib
import urllib2
import httplib
import time, datetime

BASE_URL = "localhost:8000"
NEW_JOB_PATH =  "/jobs/new"
ACCESS_TOKEN = '2334787993255525024264726173982699884554'

def main():

  parser = argparse.ArgumentParser(description='Ask Compucius')
  parser.add_argument('code', metavar='CODE', type=str, nargs=1,
      help="The file containing the map and reduce functions.")
  parser.add_argument('files', metavar='DATA', type=str, nargs='+',
      help="The files that map reduce will process.")
  parser.add_argument('-s', '--shard-count', dest='shard_count', type=int,
      default=5,
      help="The number of shards to distribute map output to. Default: 5")
  parser.add_argument('-u', '--uid', dest='user_id', type=int,
      help="The user id you wish to submit as")

  
  args = parser.parse_args()

  code_file_name = args.code[0]
  data_file_names = args.files
  
  try:
    code = open(code_file_name).read()
  except:
    sys.stderr.write("Reading file failed: %s" % code_file_name)
    return 1

  data_type = "text"  
  if len(data_file_names) > 1:
    for file_name in data_file_names:
      if os.path.splitext(file_name)[1] == '.json':
        sys.stderr.write("Mutiple files not supported for json data.")
        return 1
  else: # len(data_file_names) == 1
    for file_name in data_file_names:
      if os.path.splitext(file_name)[1] == '.json':
        data_type = "json"


  data = ''
  for file_name in data_file_names:
    try:
      data += open(file_name).read() + ' '
    except:
      sys.stderr.write("Reading file failed: %s" % file_name)
      return 1

  d = datetime.datetime.now()
  time_stamp = time.mktime(d.timetuple())

  new_job = {
      'name': str(time_stamp),
      'data_type': data_type,
      'data': data,
      'code': code,
      'shard_count': str(args.shard_count),
  }
  if args.user_id:
    new_job['uid'] = args.user_id
  
  headers = {"Content-type": "application/x-www-form-urlencoded",
                  "Accept": "text/plain"}
  post_data = urllib.urlencode(new_job)
  conn = httplib.HTTPConnection(BASE_URL)
  conn.request("POST", NEW_JOB_PATH, post_data, headers)
  response = conn.getresponse()
  print response.status, response.reason
  

if __name__ == "__main__":
  sys.exit(main())
