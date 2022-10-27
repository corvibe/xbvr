FROM node:16 as build-env

### Install Go ###
ENV GO_VERSION=1.19.2 \
    GOPATH=$HOME/go-packages \
    GOROOT=$HOME/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH
RUN curl -fsSL https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar -xzv
RUN node -v
WORKDIR /app
ADD . /app
RUN cd /app && \
    yarn add @babel/core@^7.0.0 && \
    yarn add eslint-plugin-n@^15.0.0 && \
    yarn add eslint-plugin-vue@^8.7.1 && \
    yarn add eslint-plugin-n@^15.0.0 && \
    yarn install && \
    yarn build && \
    go generate && \
    go build -tags='json1' -ldflags '-w' -o xbvr main.go

FROM gcr.io/distroless/base
COPY --from=build-env /app/xbvr /

EXPOSE 9998-9999
VOLUME /root/.config/

ENTRYPOINT ["/xbvr"]
