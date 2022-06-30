FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev \
    libjpeg-dev m4 yasm pkgconf
RUN git clone https://github.com/ultravideo/kvazaar.git
WORKDIR /kvazaar
RUN ./autogen.sh
RUN CC=afl-clang ./configure
RUN make
RUN make install
RUN mkdir /yuvCorpus
RUN wget https://chromium.googlesource.com/chromium/src/+/lkgr/media/test/data/bali_640x360_P420.yuv
RUN wget https://chromium.googlesource.com/chromium/src/+/lkgr/media/test/data/bear_192x320_270.nv12.yuv
RUN wget https://chromium.googlesource.com/chromium/src/+/lkgr/media/test/data/bear_320x192.i420.yuv
RUN mv *.yuv /yuvCorpus
RUN cp /usr/local/bin/epeg /epeg
ENV LD_LIBRARY_PATH=/usr/local/lib/

ENTRYPOINT ["afl-fuzz", "-i", "/yuvCorpus", "-o", "/yuvOut"]
CMD ["/usr/local/bin/kvazaar", "--input", "@@", "--output", "out.hevc"]
