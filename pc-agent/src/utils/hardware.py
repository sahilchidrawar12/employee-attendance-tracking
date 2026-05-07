import platform
import uuid


def get_hardware_id():
    machine = platform.machine()
    node = platform.node()
    system = platform.system()
    release = platform.release()
    if node:
        return f"{system}-{node}-{release}".replace(' ', '_')
    return str(uuid.uuid4())
