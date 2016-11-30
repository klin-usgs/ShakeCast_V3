# ShakeCast Docker App Example

FROM perl:latest

RUN apt-get update

VOLUME /usr/local/shakecast

RUN cpanm strict FindBin File::Basename File::Path \
    IO::File Getopt::Long Carp LWP::UserAgent JSON \
    Time::Local Storable Data::Dumper

#ENTRYPOINT /usr/local/bin/perl

CMD ["/usr/local/shakecast/sc/bin/gs_json.pl"]

