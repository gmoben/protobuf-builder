import os

from setuptools import setup, find_packages

PROJECT_NAME = os.environ['PROJECT_NAME'].replace('-', '_')
VERSION = os.environ['VERSION']
FIND_PACKAGES = os.environ.get('FIND_PACKAGES', '.')

# Change directory into where we want to find packages
CWD = os.getcwd()
os.chdir(FIND_PACKAGES)

setup(name=PROJECT_NAME,
      packages=find_packages(FIND_PACKAGES),
      version=VERSION
)

# Change back to previous working directory afterwards
os.chdir(CWD)
