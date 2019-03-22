FROM alpine:3.9.2 as icestorm
WORKDIR /root/
RUN apk add --no-cache bash git make build-base python3 libftdi1-dev
RUN git clone https://github.com/cliffordwolf/icestorm.git && \
    cd icestorm && \
    make -j`nproc` && \
    make install DESTDIR=/install

FROM alpine:3.9.2 as arachne-pnr
WORKDIR /root/
RUN apk add --no-cache bash git make build-base python3
COPY --from=icestorm /install /
RUN git clone https://github.com/YosysHQ/arachne-pnr.git && \
    cd arachne-pnr && \
    make -j`nproc` && \
    make install DESTDIR=/install

FROM alpine:3.9.2 as yosys
WORKDIR /root/
RUN apk add --no-cache bash git make build-base bison flex gawk readline-dev tcl-dev libffi-dev graphviz python3
RUN git clone https://github.com/YosysHQ/yosys.git && \
    cd yosys && \
    git checkout yosys-0.8 && \
    make config-gcc && \
    make -j`nproc` && \
    make install DESTDIR=/install

FROM alpine:3.9.2
WORKDIR /root/
RUN apk add --no-cache bash git make libgcc libstdc++ readline tcl libffi libftdi1
COPY --from=icestorm /install /
COPY --from=arachne-pnr /install /
COPY --from=yosys /install /
