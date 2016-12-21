import os
import shlex
import subprocess
import pytest

def execute(cmd, shell=False):
    """Use Popen to execute a command string or array of arguments """
    if isinstance(cmd, str) and not shell:
        cmd = shlex.split(cmd)
    process = subprocess.Popen(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE, shell=shell)

    out, err = process.communicate()
    returncode = process.returncode

    return (out, err, returncode)


def test_compile():
    dummy = """
syntax = 'proto3';

message Dummy {
  int32 who_cares = 1;
}
    """

    dummy_path = 'definitions/dummy.proto'

    try:
        with open(dummy_path, 'w+') as f:
            f.write(dummy)

        out, err, rc = execute('make compile')

        if rc:
            print out, err

        assert rc == 0

        for x in ['python', 'java', 'cpp', 'ruby', 'go']:
            compiled_dir = 'compiled/{}'.format(x)
            assert os.path.exists(compiled_dir)
            assert len(os.listdir(compiled_dir)) > 0

    finally:
        if os.path.exists(dummy_path):
            os.unlink(dummy_path)

        execute('make clean_compile')
