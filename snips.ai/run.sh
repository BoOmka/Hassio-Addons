#!/usr/bin/env bashio
set -e +u

bashio::log.info "Setup Settings"

broker_host=$(bashio::config 'mqtt.host')
broker_port=$(bashio::config 'mqtt.port')
broker_user=$(bashio::config 'mqtt.user')
broker_pass=$(bashio::config 'mqtt.password')

sed -i "/^# mqtt =/s/^# //" /etc/snips.toml
sed -i "/^mqtt =/s/=.*/= \"${broker_host}:${broker_port}\"/" /etc/snips.toml
sed -i "/^# mqtt_username =/s/^# //" /etc/snips.toml
sed -i "/^mqtt_username =/s/=.*/= \"${broker_user}\"/" /etc/snips.toml
sed -i "/^# mqtt_password =/s/^# //" /etc/snips.toml
sed -i "/^mqtt_password =/s/=.*/= \"${broker_pass}\"/" /etc/snips.toml

sed -i "/^# bind =/s/^# //" /etc/snips.toml
sed -i "/^bind =/s/=.*/= \"base@mqtt\"/" /etc/snips.toml
sed -i "/^# disable_capture =/s/^# //" /etc/snips.toml
sed -i "/^disable_capture =/s/=.*/= true/" /etc/snips.toml


bashio::log.info "Setup Assistant"
assistant_path="/share/$(bashio::config 'assistant')"
bashio::fs.file_exists "$assistant_path" || (bashio::log.error "Assistant zip not found! Expected location: '$assistant_path'"; exit 1)

bashio::log.info "| Unzip Assistant..."
unzip -q "$assistant_path" -d /usr/share/snips
bashio::log.info "| Generate Skill templates..."
snips-template render

pushd /var/lib/snips/skills > /dev/null

for url in $(awk '$1=="url:" {print $2}' /usr/share/snips/assistant/Snipsfile.yaml); do
  bashio::log.info "| Clone $url..."
  git clone "$url"
done

bashio::log.info "| Load Skill configs..."
mkdir -p /share/snips-skills
rsync -au --include="*/" --include="*.ini" --exclude="*" '/share/snips-skills/' '/var/lib/snips/skills'

bashio::log.info "| Build Skills..."
find . -maxdepth 1 -type d -print0 | while IFS= read -r -d '' dir; do
    pushd "$dir" > /dev/null
    cut_dir=${dir:2} 
    if [ -f setup.sh ]; then
        bashio::log.info "  | Run setup.sh for '$cut_dir'"
        python3 -m venv venv
        source venv/bin/activate
        pip3 install --upgrade pip setuptools wheel
        bash ./setup.sh
    fi
    popd > /dev/null
done

bashio::log.info "| Save Skill config..."
rsync -aum --include="*/" --include="*.ini" --exclude="*" '/var/lib/snips/skills/' '/share/snips-skills'
chown -R _snips-skills:_snips-skills /var/lib/snips/skills
popd > /dev/null

bashio::log.info "Start snips-asr"
snips-asr > /dev/null || bashio::log.error "Snips-ASR service failed!" &
bashio::log.info "Start snips-audio-server"
snips-audio-server > /dev/null || bashio::log.error "Snips-Audio-Server service failed!" &
bashio::log.info "Start snips-dialogue"
snips-dialogue > /dev/null || bashio::log.error "Snips-Dialogue service failed!" &
bashio::log.info "Start snips-nlu"
snips-nlu > /dev/null || bashio::log.error "Snips-NLU service failed!" &
bashio::log.info "Start snips-skill-server"
snips-skill-server > /dev/null || bashio::log.error "Snips-Skill-Server service failed!" &

bashio::log.info "Start snips-watch"
snips-watch -vv --no_color && kill $(jobs -p)
