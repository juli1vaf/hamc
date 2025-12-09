#!/usr/bin/env bashio

bashio::log.info "Starting..."

if bashio::config.true 'PLAYIT_ENABLE'; then
    if ! bashio::config.has_value 'PLAYIT_SECRET'; then
        bashio::log.error "Playit.gg tunneling is enabled but no PLAYIT_SECRET was provided."
        bashio::log.error "The tunnel will NOT be started."
    else
        bashio::log.info "Starting Playit.gg tunnel agent"

        mkdir -p /var/log /var/run
        playit_log="/var/log/playit.log"

        # Secret from add-on config
        provided_secret="$(bashio::config 'PLAYIT_SECRET')"

        # Ask the Playit binary where it expects its secret file
        secret_path="$(
            /usr/local/bin/playit secret-path 2>/dev/null | head -n 1 | tr -d '\r'
        )"

        if [ -z "${secret_path}" ]; then
            bashio::log.warning "Could not determine Playit secret path, falling back to direct --secret usage."
            /usr/local/bin/playit \
                --secret "${provided_secret}" \
                start >> "${playit_log}" 2>&1 &
        else
            # Make sure directory exists
            mkdir -p "$(dirname "${secret_path}")"

            # Always sync the secret file with the configured secret
            printf '%s\n' "${provided_secret}" > "${secret_path}"
            bashio::log.info "Wrote Playit secret to ${secret_path}"

            # Start agent using the secret file
            /usr/local/bin/playit \
                --secret_path "${secret_path}" \
                --stdout \
                --log_path "${playit_log}" \
                start >> "${playit_log}" 2>&1 &
        fi

        pid=$!
        echo "${pid}" > /var/run/playit.pid
        bashio::log.info "Playit.gg agent started with PID ${pid}"
    fi
fi

/start
