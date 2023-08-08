#!/usr/bin/env python3
"""This file starts a pyro nameserver and the proxying server."""
# from pathlib import Path
import subprocess
import time
from mkid_pyro import start_server

# HERE = Path(__file__).parent

############
# parameters
############

proxy_name ='mkidrfsoc'
ns_port = 8888
# set to 0.0.0.0 to allow access from outside systems
ns_host = '0.0.0.0' # 'localhost'

bitfile = 'mkids_2x2_kidsim_v2'

############

# start the nameserver process
ns_proc = subprocess.Popen(
    [f'PYRO_SERIALIZERS_ACCEPTED=pickle PYRO_PICKLE_PROTOCOL_VERSION=4 pyro4-ns -n {ns_host} -p {ns_port}'],
    shell=True
)

# wait for the nameserver to start up
time.sleep(5)

# start the qick proxy server
start_server(
    firmwareName=bitfile,
    proxy_name=proxy_name,
    ns_host='localhost',
    ns_port=ns_port
)