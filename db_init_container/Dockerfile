FROM alpine:3.19
RUN apk add --no-cache postgresql-client bash

LABEL authors="kiro"

COPY identity-provider.sql identity-provider.sql
COPY messagelog-metadata.sql messagelog-metadata.sql
COPY op-monitor.sql op-monitor.sql
COPY serverconf.sql serverconf.sql
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]