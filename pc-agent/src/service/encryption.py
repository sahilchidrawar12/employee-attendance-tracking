from cryptography.fernet import Fernet


def generate_key() -> bytes:
    return Fernet.generate_key()


def load_key(key_path: str) -> bytes:
    with open(key_path, 'rb') as key_file:
        return key_file.read()


def encrypt_data(key: bytes, data: bytes) -> bytes:
    return Fernet(key).encrypt(data)


def decrypt_data(key: bytes, token: bytes) -> bytes:
    return Fernet(key).decrypt(token)
