# String constants
PROJECT_NAME ?= $(shell basename $(shell pwd))
DOCKER_NAME ?= $(PROJECT_NAME)-docker
VERSION ?= $(shell cat VERSION)
BUILD_NUMBER ?= $(shell git rev-list --reverse HEAD | wc -l)local

# Directory constants
CWD = $(shell pwd)
OPT = /opt/$(PROJECT_NAME)
TMP = /tmp/build
TMP_DEB_DIST = $(TMP)/deb_dist/$(PROJECT_NAME)-$(VERSION)

# Aliases
EXEC = docker exec $(DOCKER_NAME)


# Docker
container: clean_container
	# Build and start the container
	docker build -t $(DOCKER_NAME) docker
	docker run -dt --name $(DOCKER_NAME) \
		-v $(CWD):$(OPT) \
		-w $(OPT) \
		-e VERSION=$(VERSION) \
		-e FIND_PACKAGES=$(TMP) \
		-e PROJECT_NAME=$(PROJECT_NAME) \
		$(DOCKER_NAME)

clean_container:
	# Stop and remove the comtainer
	docker stop $(DOCKER_NAME) || true
	docker rm $(DOCKER_NAME) || true


# Protobuf
compile: clean_compile container
	# Make compiled directories
	# NOTE: explicitly use bash to support brace expansion
	$(EXEC) /bin/bash -c 'mkdir -p compiled/{python,java,go,ruby,cpp}'

	# Do compilation
	$(EXEC) find $(OPT)/definitions -name '*.proto' | \
	xargs $(EXEC) \
		protoc --proto_path=$(OPT)/definitions \
			--proto_path=/usr/bin/include \
			--python_out=$(OPT)/compiled/python \
			--java_out=$(OPT)/compiled/java \
			--go_out=$(OPT)/compiled/go \
			--ruby_out=$(OPT)/compiled/ruby \
			--cpp_out=$(OPT)/compiled/cpp

	# Add __init__.py files so they work as modules
	$(EXEC) find $(OPT)/compiled/python -type d | \
	xargs -t -I __dir__ $(EXEC) touch __dir__/__init__.py

	# Protobuf 3 still adds `_pb2.py` suffixes (???)
	$(EXEC) find $(OPT)/compiled/python -name "*_pb2.py" | \
	xargs -t $(EXEC) rename -v 's/_pb2.py/.py/'

clean_compile:
	# Cleanup compilation directories
	rm -rf compiled


# Python deb
python_deb: compile clean_python_deb
	# Move python files to tmp directory
	$(EXEC) mkdir -p $(TMP)
	$(EXEC) cp -R $(OPT)/compiled/python $(TMP)/$(PYTHON_PROJECT_NAME)
	$(EXEC) cp $(OPT)/setup.py $(TMP)

	# Run stdeb
	# Only generate source so we can hack up debian/rules
	$(EXEC) python $(TMP)/setup.py \
		--command-packages=stdeb.command \
		sdist_dsc \
		--debian-version $(BUILD_NUMBER)

	# Override dh_gencontrol since stdeb doesn't generate correct python version dependencies (???)
	$(EXEC) cp $(OPT)/debian/rules $(TMP_DEB_DIST)/debian/rules

	# Switch to tmp dir and actually build the deb
	$(EXEC) /bin/bash -c 'cd '$(TMP_DEB_DIST)' && dpkg-buildpackage -rfakeroot -uc -us'

	# Copy deb back to build directory
	$(EXEC) mkdir -p build
	$(EXEC) /bin/bash -c 'cp '$(TMP)'/deb_dist/*.deb build'
	$(MAKE) clean_python_deb

clean_python_deb:
	$(EXEC) rm -rf $(TMP)
