# protobuf-builder [![Build Status](https://travis-ci.org/gmoben/protobuf-builder.svg?branch=master)](https://travis-ci.org/gmoben/protobuf-builder)

Base project for building Protobuf definitions.

Provided Languages
---
- Python
- Java
- Go
- Ruby
- C++

Setup
---
Set up compilation of `.proto` defintions automatically on commit by installing a pre-commit hook with:
```
./setup_hooks.sh
```

Compiling definitions
---
If you want to test compilation in between commits, run
```
make compile
```
This will spin up a docker container with `protoc` installed and will compile them to the `compiled` directory.


Create a `.deb` for compiled python definitions using
```
make python_deb
```

Tests
---
Run tests to ensure compilation works as intended
```
make test
```