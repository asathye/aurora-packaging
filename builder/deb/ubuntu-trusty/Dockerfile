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
FROM ubuntu:trusty

WORKDIR /aurora
ENV HOME /aurora
ENV DEBIAN_FRONTEND noninteractive
# TODO(wfarner): Provide external parameterization via env vars for versions.
ENV THRIFT_DEB thrift-compiler_0.9.1_amd64.deb

RUN apt-get update && apt-get -y install \
  bison \
  debhelper \
  devscripts \
  dpkg-dev \
  curl \
  git \
  libapr1-dev \
  libcurl4-openssl-dev \
  libsvn-dev \
  python-all-dev \
  software-properties-common

RUN add-apt-repository ppa:openjdk-r/ppa -y \
  && apt-get update \
  && apt-get install -y openjdk-8-jdk \
  && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

RUN curl -O http://people.apache.org/~jfarrell/thrift/0.9.1/contrib/deb/ubuntu/12.04/$THRIFT_DEB \
  && dpkg --install $THRIFT_DEB \
  && rm $THRIFT_DEB

# Install gradle.
RUN git clone --depth 1 https://github.com/benley/gradle-packaging \
  && cd gradle-packaging \
  && apt-get install -y ruby ruby-dev unzip wget \
  && gem install fpm && ./gradle-mkdeb.sh 2.5 \
  && dpkg -i gradle-2.5_2.5-2_all.deb \
  && cd .. && rm -rf gradle-packaging

ADD build.sh /build.sh
ADD pants.ini /pants.ini
