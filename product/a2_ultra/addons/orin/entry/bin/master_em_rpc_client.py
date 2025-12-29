import xmlrpc.client
import socket
from time import time
from enum import Enum, auto
from typing import Tuple, Any
from http.client import HTTPConnection

class RpcStatus(Enum):
    """XML-RPC 调用返回状态枚举"""
    SUCCESS = auto()          # 调用成功
    TIMEOUT = auto()          # 请求超时
    CONNECTION_ERROR = auto()  # 连接失败
    FAULT = auto()           # 服务端返回错误（如方法不存在）
    UNKNOWN_ERROR = auto()   # 其他未知错误

    def __str__(self):
        return self.name  # 方便打印

# 自定义带超时的HTTP连接类
class TimeoutHTTPConnection(HTTPConnection):
    def __init__(self, host, timeout=5):  # 默认5秒超时
        super().__init__(host)
        self.timeout = timeout

    def connect(self):
        # 重写connect方法以应用超时
        import socket
        self.sock = socket.create_connection(
            (self.host, self.port),
            self.timeout  # 连接阶段超时
        )
        if self._tunnel_host:
            self._tunnel()

# 自定义传输类
class TimeoutTransport(xmlrpc.client.Transport):
    def __init__(self, timeout=5):
        self.timeout = timeout
        super().__init__()

    def make_connection(self, host):
        # 返回自定义的连接对象
        conn = TimeoutHTTPConnection(host, timeout=self.timeout)
        return conn


def call_xmlrpc_with_enum(
    host: str,
    port: int,
    method: str,
    *args,
    ) -> Tuple[RpcStatus, Any]:

    server_url = f"http://{host}:{port}"
    try:
        with xmlrpc.client.ServerProxy(server_url,
                                    transport=TimeoutTransport(timeout=5)) as proxy:
            if not hasattr(proxy, method):
                return RpcStatus.FAULT, f"Method '{method}' not found"

            start_time = time()
            result = getattr(proxy, method)(*args)
            return RpcStatus.SUCCESS, result

    except socket.timeout:
        diff = time() - start_time
        return RpcStatus.TIMEOUT, f"rpc timeout...cost:{diff:.3f}"
    except ConnectionError:
        return RpcStatus.CONNECTION_ERROR, "Connection failed"
    except xmlrpc.client.Fault as e:
        return RpcStatus.FAULT, f"Server fault: {e.faultString}"
    except Exception as e:
        return RpcStatus.UNKNOWN_ERROR, f"Unexpected error: {str(e)}"
