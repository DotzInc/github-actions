FROM node:20-alpine

RUN apk --no-cache add bash git git-lfs curl jq && npm install -g semver

COPY action.sh /action.sh

ENTRYPOINT ["/action.sh"]
