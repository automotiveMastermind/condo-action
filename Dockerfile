FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine3.14 as builder

RUN set -x \
    && apk add --no-cache bash git openssh

RUN git clone -b develop --single-branch https://github.com/automotiveMastermind/condo.git

WORKDIR /condo/src/AM.Condo
RUN dotnet publish --runtime alpine-x64 -c Release --output /artifacts/publish/cli --verbosity minimal

FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine3.14
ARG WORKSPACE=/github/workspace

COPY --from=builder /artifacts/publish/cli /usr/local/condo

RUN apk add --no-cache go --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN ln -s /usr/local/condo/condo /usr/local/bin \
    && ln -s /usr/local/go/bin/go /usr/local/bin 

WORKDIR $WORKSPACE
CMD [ "condo", "--", "/t:ci" ]