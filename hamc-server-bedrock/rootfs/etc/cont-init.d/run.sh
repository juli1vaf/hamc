#!/usr/bin/env bashio

bashio::log.info "Starting..."

# Launch Playit.gg tunnel agent if a setup key is available. The Home Assistant
# supervisor injects the setup key as PLAYIT_SECRET. Without explicitly passing
# the secret, the agent falls back to setup mode and prints a claim URL instead
# of registering. Writing the secret to a config file and starting the agent
# with that config ensures it authenticates immediately.
if bashio::var.has_value "${PLAYIT_SECRET}"; then
    bashio::log.info "Configuring Playit.gg agent with provided setup key"

    mkdir -p /root/.playit /var/log /var/run
    playit_config="/root/.playit/playit.toml"
    playit_log="/var/log/playit.log"

    # Persist the secret so the agent starts in registered mode.
    printf 'secret = "%s"\n' "${PLAYIT_SECRET}" > "${playit_config}"

    /usr/local/bin/playit --config "${playit_config}" start >> "${playit_log}" 2>&1 &
    playit_pid=$!
    echo "${playit_pid}" > /var/run/playit.pid
    bashio::log.info "Playit.gg agent started with PID ${playit_pid}"
else
    bashio::log.info "PLAYIT_SECRET not provided; skipping Playit.gg agent startup"
fi

/opt/bedrock-entry.sh
