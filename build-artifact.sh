#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -eu

print_available_builders() {
  find builder -name Dockerfile | sed "s/\/Dockerfile$//"
}

realpath() {
  echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

download_src_tar() {
    ls $(pwd)/aurora-${AURORA_VERSION}.tar.gz || curl -L -o $(pwd)/aurora-${AURORA_VERSION}.tar.gz  "https://github.com/apache/aurora/archive/${AURORA_VERSION}.tar.gz"
}

run_build() {
  BUILDER_DIR=$1
  AURORA_VERSION=$2
  
  echo "building $AURORA_VERSION"

  IMAGE_NAME="aurora-$(basename $BUILDER_DIR)"
  echo "Using docker image $IMAGE_NAME"
  docker build -t "$IMAGE_NAME" "$BUILDER_DIR"

  ARTIFACT_DIR="$(pwd)/dist/$BUILDER_DIR"
  mkdir -p $ARTIFACT_DIR
  download_src_tar
  docker run \
    --rm \
    -e AURORA_VERSION=$AURORA_VERSION \
    -v "$(pwd)/specs:/specs:ro" \
    -v "$(pwd)/aurora-${AURORA_VERSION}.tar.gz:/src.tar.gz:ro" \
    -v "$ARTIFACT_DIR:/dist" \
    -t "$IMAGE_NAME" /build.sh

  echo "Produced artifacts in $ARTIFACT_DIR:"
  ls $ARTIFACT_DIR
}

case $# in
  1)
    echo "building using all builders"
    for builder in $(print_available_builders); do
      run_build $builder $1 
      echo $builder
    done
    ;;

  2)
    echo "building specific"
    run_build "$@"
    ;;

  *)
    echo 'usage:'
    echo 'to build all artifacts:'
    echo "  $0 AURORA_VERSION"
    echo
    echo 'or to build a specific artifact:'
    echo "  $0 BUILDER AURORA_VERSION"
    echo
    echo 'Where BUILDER is a builder directory in:'
    print_available_builders
    exit 1
    ;;
esac
