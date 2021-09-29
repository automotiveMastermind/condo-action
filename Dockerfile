FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine as builder

RUN set -x \
    && apk add --no-cache bash git openssh

RUN git clone -b develop --single-branch https://github.com/automotiveMastermind/condo.git

WORKDIR /condo/src/AM.Condo
RUN dotnet publish --runtime alpine-x64 -c Release --output /artifacts/publish/cli --verbosity minimal

FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine
ARG WORKSPACE=/github/workspace

COPY --from=builder /artifacts/publish/cli /usr/local/condo
COPY --from=golang:1.17-alpine /usr/local/go/ /usr/local/go/

RUN ln -s /usr/local/condo/condo /usr/local/bin

WORKDIR $WORKSPACE
CMD [ "condo", "--", "/t:ci" ]