# rabbitmq-protobuf

> Demonstrating the use of Google's Protocol Buffers for serialization in order
to interchange data between Perl and Java via [RabbitMQ][rabbitmq] in RPC mode. This code is based on the excellent [RPC tutorial][rpc] by RabbitMQ.


## Motivation
Since one hardly finds any examples of using [RabbitMQ][rabbitmq] in connection with Google's Protocol Buffers ([Protobuf][protobuf]) for Perl, I decided to write a small example of using RabbitMQ in [RPC mode][rpc] to interchange data serialized with Protobuf between Perl and Java.

This tutorial is part of a ''greater'' series using other data-interchange
formats such as [Apache Avro][avro] and [Apache Thrift][thrift].


## Prerequisites

> Please skip this section, if you've already installed [Gradle][gradle], [RabbitMQ][rabbitmq], [Protobuf][protobuf], Perl including [AnyEvent][anyevent], [Net::RabbitFoot][rabbitfoot], [DBD::Mock][mock], and [Protobuf for Perl/XS][perlxs].

It should be noted, that the following instructions assume Mac OS X to be used as an operating system. The OS X version the installation is tested on is 10.9. Please adapt the commands to satisfy your needs, if needed.


### Gradle

Download [Gradle][gradle] via the following link

```bash
https://services.gradle.org/distributions/gradle-1.12-all.zip
```

unpack, and set the desired environment variable. Please replace {username} and {path-to-gradle}:

```bash
GRADLE_HOME=/Users/{username}/{path-to-gradle}/gradle-1.12
export GRADLE_HOME
export PATH=$PATH:$GRADLE_HOME/bin
```

### RabbitMQ

The easiest way to install RabbitMQ on Mac OS X is via __Homebrew__, the ''missing
package manager for OS X''. Open a terminal, and install [Homebrew][homebrew] as follows:

```bash
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
```

Next, install RabbitMQ (currently v3.2.4), and add the path to your $PATH variable:

```bash
brew update
brew install rabbitmq
export PATH=$PATH:/usr/local/sbin
```

Enable the management plugin (optional):

```bash
rabbitmq-plugins enable rabbitmq_management
```

Start the server:

```bash
rabbitmq-server
```

You can now browse to http://localhost:15762 in order to monitor your running RabbitMQ instance (if you previously installed the management plugin).


### Perl

I advice to install Perl via __perlbrew__. If you don't have a running installation of [perlbrew][perlbrew], then just execute the following line in your command line:

```bash
\curl -L http://install.perlbrew.pl | bash
```

Next, install a current version of Perl. It should be noted, that 5.16.0 has a bug when compiling the Protobuf definitions for Perl. Hence, you might want to use another version, e.g. 5.18.2:

```bash
perlbrew install perl-5.18.2
perlbrew switch perl-5.18.2
```

Now, we need to install some dependencies (use cpan or cpanminus):

```bash
cpanm install --notest AnyEvent
cpanm install --notest Net::RabbitFoot
cpanm install --notest DBD::Mock
```

Please note, that there are some errors while running the tests for each of the packages. Thus, we have to use the ''no test'' option.


### Google's Protocol Buffers

We can install the Protobuf libraries with Homebrew, too. However, the version in their repository is outdated. Hence, you might want to install Protobuf directly via the sources. Since there were some issues while installing Protobuf for Mac OS X, you might want to execute the following build file (I found the snippet [here](https://gist.github.com/BennettSmith/7150245), and minified it to the essential part):

```bash
#!/bin/bash

echo Building Google Protobuf for Mac OS X / iOS.
echo Use 'tail -f build.log' to monitor progress.

(
PREFIX=`pwd`/protobuf
mkdir ${PREFIX}
mkdir ${PREFIX}/platform

CC=clang
CFLAGS="-DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions"
CXX=clang
CXXFLAGS="${CFLAGS} -std=c++11 -stdlib=libc++"
LDFLAGS="-stdlib=libc++"
LIBS="-lc++ -lc++abi"

####################################
# Cleanup any earlier build attempts
####################################

(
    cd /tmp
    if [ -d ${PREFIX} ]
    then
        rm -rf ${PREFIX}
    fi
    mkdir ${PREFIX}
    mkdir ${PREFIX}/platform
)

##########################################
# Fetch Google Protobuf 2.5.0 from source.
##########################################

(
    cd /tmp
    #curl http://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz --output /tmp/protobuf-2.5.0.tar.gz
    if [ -d /tmp/protobuf-2.5.0 ]
    then
        rm -rf /tmp/protobuf-2.5.0
    fi
    tar xvf /tmp/protobuf-2.5.0.tar.gz
)


#####################
# x86_64 for Mac OS X
#####################

(
    cd /tmp/protobuf-2.5.0
    make distclean
    ./configure --disable-shared "CC=${CC}" "CFLAGS=${CFLAGS} -arch x86_64" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch x86_64" "LDFLAGS=${LDFLAGS}" "LIBS=${LIBS}"
    make
    make test
    make install
)

) >build.log 2>&1
echo Done!
```

Thanks Bennett!


### Protobuf for Perl/XS

Next, we need to install the Perl extensions for Protobuf, so that we can later compile a Protobuf definition into a Perl library. Install the [Protobuf Perl/XS][perlxs] module as follows:

```bash
wget http://protobuf-perlxs.googlecode.com/files/protobuf-perlxs-1.1.tar.gz
tar zxf protobuf-perlxs-1.1.tar.gz
cd protobuf-perlxs-1.1
./configure --with-protobuf=/usr/local
make
sudo make install
```

You might then want to run one of the examples included in order to verify that the Protobuf compilation is successful.


## Installation

This section assumes that you've successfully installed RabbitMQ, Protobuf, Protobuf for Perl/XS, and that you are able to compile Protbuf definitions for Perl and Java.

First, clone the repository:

```bash
git clone git://github.com/hopped/rabbitmq-protobuf.git
```

Then, generate both the Protobuf binaries for Java and Perl via executing the following scripts found in the ''src/main/resources/[java|perl]/'':

```bash
# Current directory is the project root

# Java
cd src/main/resources/java
chmod +x gen-java.sh
./gen-java.sh

# Perl
cd ../perl
chmod +x gen-perl.sh
./gen-perl.sh
```

The Java task copies all generated Java classes directly to ''src/main/java'', and the Perl task copies the created library (blib directory) to ''src/main/perl''.

Finally, you can build the project using the Gradle build file:

```bash
# Current directory is the project root
gradle build
```

## Run the example

Since I don't have written a suitable Gradle task yet, you have to execute the following commands to run the default client/server scenario (ideally you can run each command in its own shell):

```bash
# Current directory is the project root

# (1) Start the RabbitMQ Server
rabbitmq-server
# (2) Start the server written in Perl
perl src/main/perl/RPCServer.pl
# (3) Run the client written in Java
gradle run
```


## Data

What data was actually interchanged? For this example, I wrote a small Protobuf definition file that might be used by a running website such as [Strava](http://www.strava.com) or [SmashRun](http://www.smashrun.com) in order to store runs for users. Let's have a look at the SimpleRunner.proto:

```protobuf
package SimpleRunner;

option java_package = "com.hopped.runner.protobuf";
option java_outer_classname = "SimpleRunnerProtos";
option optimize_for = LITE_RUNTIME;

message User {
    optional string alias = 1;
    optional int32 id = 2;
    optional int32 birthdate = 3;
    optional string totalDistanceMeters = 4;
    optional string eMail = 5;
    optional string firstName = 6;
    optional string gender = 7;
    optional int32 height = 8;
    optional string lastName = 9;
    optional int32 weight = 10;
}

message Run {
    optional string alias = 1;
    optional int32 id = 2;
    optional int32 averageHeartRateBpm = 3;
    optional double averagePace = 4;
    optional double averageSpeed = 5;
    optional int32 calories = 6;
    optional int32 date = 7;
    optional string description = 8;
    optional double distanceMeters = 9;
    optional double maximumSpeed = 10;
    optional int32 maximumHeartRateBpm = 11;
    optional int32 totalTimeSeconds = 12;
}

message RunList {
    repeated Run runs = 1;
}

message RunRequest {
    optional User user = 1;
    optional string distance = 2;
}
```

## Contributing
Find a bug? Have a feature request?
Please [create](https://github.com/hopped/website/issues) an issue.


## Authors

**Dennis Hoppe**

+ [github/hopped](https://github.com/hopped)


## Release History

| Date        | Version | Comment          |
| ----------- | ------- | ---------------- |
| 2014-05-13  | 0.1.0   | Initial release. |


## License
Copyright 2014 Dennis Hoppe.

[MIT License](LICENSE).


[anyevent]: http://search.cpan.org/dist/AnyEvent/
[avro]: http://avro.apache.org/
[gradle]: http://www.gradle.org/
[homebrew]: http://brew.sh/
[mock]: http://search.cpan.org/~dichi/DBD-Mock-1.45/lib/DBD/Mock.pm
[perlbrew]: http://perlbrew.pl/
[perlxs]: https://code.google.com/p/protobuf-perlxs/
[protobuf]: https://code.google.com/p/protobuf/
[rabbitmq]: http://www.rabbitmq.com
[rabbitfoot]: http://search.cpan.org/~ikuta/Net-RabbitFoot-1.03/lib/Net/RabbitFoot.pm
[rpc]: http://www.rabbitmq.com/tutorials/tutorial-six-java.html
[thrift]: http://thrift.apache.org/
