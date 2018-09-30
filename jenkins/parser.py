#!/usr/bin/env python
import json
import sys

obj=json.load(sys.stdin)
if sys.argv[1] == "status":
    try:
        print(obj['status'] + ' ' + obj['statusReason'])
    except:
        print(obj['status'])
else:
    master = [x['metadata'][0]['publicIp'] for x in obj['instanceGroups'] if x['group'] == 'master'][0]
    gateway = [x['metadata'][0]['publicIp'] for x in obj['instanceGroups'] if x['group'] == 'gateway'][0]
    nifi = [x['metadata'][0]['publicIp'] for x in obj['instanceGroups'] if x['group'] == 'nifi'][0]
    kafka = [x['metadata'][0]['publicIp'] for x in obj['instanceGroups'] if x['group'] == 'kafka'][0]
    print('Hive JDBC Host is %s' % (master))
    print('Superset URL is http://%s:9088' % (gateway))
    print('Zeppelin URL is http://%s:9997' % (gateway))
    print('Edge Node Host is %s' % (gateway))
    print('Nifi Server is https://%s:9091/nifi' % (nifi))
    print('Kakfa Broker is PLATINTEXTSASL://%s:6667' % (kafka))
