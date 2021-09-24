FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine as builder

RUN set -x \
    && apk add --no-cache bash git openssh

RUN git clone -b develop --single-branch https://github.com/automotiveMastermind/condo.git

WORKDIR /condo/src/AM.Condo
RUN dotnet publish --runtime alpine-x64 -c Release --output /artifacts/publish/cli --verbosity minimal /p:GenerateAssemblyInfo=false /p:SourceLinkCreate=false /p:SourceLinkTest=false /p:PublishTrimmed=true

FROM alpine:3.13

# libs required by dotnet
RUN apk add --no-cache libstdc++ libintl icu

COPY --from=builder /artifacts/publish/cli /usr/local/condo
RUN ln -s /usr/local/condo/condo /usr/local/bin

ENTRYPOINT ["condo"]