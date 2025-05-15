FROM alpine:3.19
RUN apk add --no-cache postgresql-client

LABEL authors="kiro"

COPY identity-provider.sql identity-provider.sql
COPY messagelog-metadata.sql messagelog-metadata.sql
COPY op-monitor.sql op-monitor.sql
COPY serverconf.sql serverconf.sql

ENTRYPOINT ["top", "-b"]