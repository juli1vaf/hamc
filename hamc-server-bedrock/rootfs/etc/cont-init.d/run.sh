#!/usr/bin/env bashio

bashio::log.info "Starting..."

# Launch Playit.gg tunnel agent if a setup key is available. The Home Assistant
# supervisor injects the setup key as PLAYIT_SECRET. Passing it directly with
# --secret keeps the agent out of setup mode so it registers immediately.
if bashio::var.has_value "${PLAYIT_SECRET}"; then
    bashio::log.info "Configuring Playit.gg agent with provided setup key"

    mkdir -p /var/log /var/run
    playit_log="/var/log/playit.log"

    #
    # ---- THIS IS THE VERIFIED WORKING COMMAND ----
    # Using --secret is required; the agent ignores the value if it is only
    # written to a config file and falls back to setup mode, printing a claim
    # link. Passing it explicitly ensures registration on startup.
    /usr/local/bin/playit \
        --secret "${PLAYIT_SECRET}" \
        start >> "${playit_log}" 2>&1 &
    # ------------------------------------------------

    playit_pid=$!
    echo "${playit_pid}" > /var/run/playit.pid
    bashio::log.info "Playit.gg agent started with PID ${playit_pid}" and secret from PLAYIT_SECRET
else
    bashio::log.info "PLAYIT_SECRET not provided; skipping Playit.gg agent startup"
fi

/opt/bedrock-entry.sh
