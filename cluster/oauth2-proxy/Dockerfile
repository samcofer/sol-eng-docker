FROM golang:latest as builder
WORKDIR /go
RUN go get -ldflags "-linkmode external -extldflags -static" -a github.com/bitly/oauth2_proxy


FROM a5huynh/oauth2_proxy:latest
COPY --from=builder /go/bin/oauth2_proxy ./bin/

# Install CA certificates
#RUN apk add --no-cache --virtual=build-dependencies ca-certificates

# Expose the ports we need and setup the ENTRYPOINT w/ the default argument
# to be pass in.
#EXPOSE 8080 4180
#ENTRYPOINT [ "./bin/oauth2_proxy" ]
#CMD [ "--upstream=http://0.0.0.0:8080/", "--http-address=0.0.0.0:4180" ]
