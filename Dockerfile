FROM registry.access.redhat.com/ubi8/ubi-minimal as builder
USER root

ENV CFLAGS="-DSQLITE_DEFAULT_CACHE_SIZE=-8000 \
-DSQLITE_ENABLE_FTS3 \
-DSQLITE_ENABLE_FTS3_PARENTHESIS \
-DSQLITE_ENABLE_FTS4 \
-DSQLITE_ENABLE_FTS5 \
-DSQLITE_ENABLE_JSON1 \
-DSQLITE_ENABLE_STAT4 \
-DSQLITE_ENABLE_UPDATE_DELETE_LIMIT \
-DSQLITE_SOUNDEX \
-DSQLITE_USE_URI \
-DSQLITE_HAS_CODEC \
-O2"


RUN microdnf install git tcl openssl openssl-devel make gcc python3 python3-pip python3-devel && \
    git clone https://github.com/sqlcipher/sqlcipher && \
    cd /sqlcipher && \
    ./configure --enable-tempstore=yes LDFLAGS="-lcrypto -lm" && \
    make && \
    make install &&\
    cd / && \
    git clone https://github.com/rigglemania/pysqlcipher3 && \
    cd /pysqlcipher3 && \
    python3 setup.py build && \
    python3 setup.py install

FROM registry.access.redhat.com/ubi8/ubi-minimal
ENV PYVER=3.6
ENV PYSQLCIPHERVER=1.0.3
ENV ARCH=x86_64
ENV LD_LIBRARY_PATH=/usr/local/lib

COPY --from=builder /usr/local/lib64/python3.6/site-packages/pysqlcipher3-1.0.3-py3.6-linux-x86_64.egg/pysqlcipher3 /usr/local/lib64/python3.6/site-packages/pysqlcipher3
COPY --from=builder /usr/local/lib/pkgconfig /usr/local/lib/pkgconfig
COPY --from=builder /usr/local/lib/libsqlcipher.so.0.8.6 /usr/local/lib/libsqlcipher.so.0.8.6
COPY --from=builder /usr/local/lib/libsqlcipher.la /usr/local/lib/libsqlcipher.la
COPY --from=builder /usr/local/lib/libsqlcipher.a /usr/local/lib/libsqlcipher.a
COPY --from=builder /usr/local/bin/sqlcipher /usr/local/bin/sqlcipher
RUN ln -s /usr/local/lib/libsqlcipher.so.0.8.6 /usr/local/lib/libsqlcipher.so.0  && \
    ln -s /usr/local/lib/libsqlcipher.so.0.8.6 /usr/local/lib/libsqlcipher.so  && \
    microdnf install python3 


