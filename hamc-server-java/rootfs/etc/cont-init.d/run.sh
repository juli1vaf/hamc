#!/usr/bin/env bashio

bashio::log.info "Starting..."

# Only start if explicitly enabled
if bashio::config.true 'PLAYIT_ENABLE'; then

    # Check if user provided a secret
    if ! bashio::config.has_value 'PLAYIT_SECRET'; then
        bashio::log.error "PLAYIT_ENABLE is true but no PLAYIT_SECRET was provided. Playit will NOT start."
    else

        bashio::log.info "Starting Playit.gg tunnel agent"

        mkdir -p /var/log /var/run
        playit_log="/var/log/playit.log"

        # Extract the secret from HA config
        provided_secret="$(bashio::config 'PLAYIT_SECRET')"
        bashio::log.info "Using provided Playit secret"

        #
        # ---- THIS IS THE VERIFIED WORKING COMMAND ----
        #
        /usr/local/bin/playit \
            --secret "${provided_secret}" \
            start >> "${playit_log}" 2>&1 &
        #
        # ------------------------------------------------
        #

        pid=$!
        echo "${pid}" > /var/run/playit.pid
        bashio::log.info "Playit.gg agent started with PID ${pid}"

    fi
fi

/start
