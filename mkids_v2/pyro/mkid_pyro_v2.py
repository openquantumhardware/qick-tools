import os
import psutil, socket
import Pyro4
import Pyro4.naming
from pathlib import Path


## Open up the Scan library
import sys
sys.path.append('../soft/')
try:
    import mkids
    import Scan
except:
    print("Error importing dependencies")
    pass

def start_nameserver(ns_host='0.0.0.0', ns_port=8888):
    """Starts a Pyro4 nameserver.

    Parameters
    ----------
    ns_host : str
        the nameserver hostname
    ns_port : int
        the port number for the nameserver to listen on

    Returns
    -------
    """
    Pyro4.config.SERIALIZERS_ACCEPTED = set(['pickle'])
    Pyro4.config.PICKLE_PROTOCOL_VERSION=4
    Pyro4.naming.startNSloop(host=ns_host, port=ns_port)

def start_server(ns_host, ns_port=8888, proxy_name='mkidrfsoc', **kwargs):
    """Initializes the Scan object and starts a Pyro4 proxy server.

    Parameters
    ----------
    ns_host : str
        hostname or IP address of the nameserver
        if the nameserver is running on the QICK board, "localhost" is fine
    ns_port : int
        the port number you used when starting the nameserver
    proxy_name : str
        name for the Scan proxy
        multiple boards can use the same nameserver, but must have different names
    kwargs : optional named arguments
        any other options will be passed to the Scan constructor;
        see Scan documentation for details

    Returns
    -------
    """
    Pyro4.config.REQUIRE_EXPOSE = False
    Pyro4.config.SERIALIZER = "pickle"
    Pyro4.config.SERIALIZERS_ACCEPTED=set(['pickle'])
    Pyro4.config.PICKLE_PROTOCOL_VERSION=4

    print("looking for nameserver . . .")
    ns = Pyro4.locateNS(host=ns_host, port=ns_port)
    print("found nameserver")

    # if we have multiple network interfaces, we want to register the daemon using the IP address that faces the nameserver
    host = Pyro4.socketutil.getInterfaceAddress(ns._pyroUri.host)
    # if the nameserver is running on the QICK, the above will usually return the loopback address - not useful
    if host=="127.0.0.1":
        # get the IPv4 address of the eth0 interface
        # unless you have an unusual network config (e.g. VPN), this is the interface clients will want to connect to
        (myaddr,) = [addr for addr in psutil.net_if_addrs()['eth0'] if addr.family==socket.AddressFamily.AF_INET]
        host = myaddr.address
    daemon = Pyro4.Daemon(host=host)

    ## This is where you have to instantiate the Soc object
    firmwareName = kwargs["firmwareName"]
    board = Scan.getBoard()
    full_path = os.path.realpath(__file__)
    path, filename = os.path.split(full_path)
    bitpath = str(Path(path).parent.joinpath(Path(board), firmwareName+'.bit'))
    soc = mkids.MkidsSoc(bitpath)
    print("initialized MkidsSoc")

    # register the Scan in the daemon (so the daemon exposes the Scan over Pyro4)
    # and in the nameserver (so the client can find the Scan)
    ns.register(proxy_name, daemon.register(soc))
    print("registered MkidsSoc")

    # register in the daemon all the objects we expose as properties of the Scan
    # we don't register them in the nameserver, since they are only meant to be accessed through the QickSoc proxy
    # https://pyro4.readthedocs.io/en/stable/servercode.html#autoproxying
    # https://github.com/irmen/Pyro4/blob/master/examples/autoproxy/server.py
    #for obj in soc.autoproxy:
    #    daemon.register(obj)
    #    print("registered member "+str(obj))
                    
    print("starting daemon")
    daemon.requestLoop() # this will run forever until interrupted

def make_proxy(ns_host, ns_port='8888', proxy_name='mkidrfsoc'):
    """Connects to a Scan proxy server.

    Parameters
    ----------
    ns_host : str
        hostname or IP address of the nameserver
        if the nameserver is running on the same PC you are running make_proxy() on, "localhost" is fine
    ns_port : int
        the port number you used when starting the nameserver
    proxy_name : str
        name for the QickSoc proxy you used when running start_server()

    Returns
    -------
    Proxy
        proxy to QickSoc - this is usually called "soc" in demos
    QickConfig
        config object - this is usually called "soccfg" in demos
    """
    Pyro4.config.SERIALIZER = "pickle"
    Pyro4.config.PICKLE_PROTOCOL_VERSION=4

    ns = Pyro4.locateNS(host=ns_host, port=ns_port)

    # print the nameserver entries: you should see the QickSoc proxy
    for k,v in ns.list().items():
        print(k,v)

    scan = Pyro4.Proxy(ns.lookup(proxy_name))
    # scancfg = QickConfig(scan.get_cfg())
    return scan # (scan, scancfg)