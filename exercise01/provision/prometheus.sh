#!/usr/bin/env bash
set -e

source /vagrant/utils/defaults.sh
source /vagrant/utils/helpers.sh

sudo apt-get update
sudo apt-get install curl tar -y 
check_requirements curl tar



ARCHIVE="prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"

if ! check_cache "${ARCHIVE}"; then
  get_archive "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${ARCHIVE}"
fi

if ! id prometheus > /dev/null 2>&1 ; then
  useradd --system prometheus
fi

TMPD=$(mktemp -d)
tar zxf "${CACHE_PATH}/${ARCHIVE}" -C $TMPD --strip-components=1

install -m 0644 -D -t /usr/share/prometheus/consoles $TMPD/consoles/*
install -m 0644 -D -t /usr/share/prometheus/console_libraries $TMPD/console_libraries/*
install -m 0755 $TMPD/prometheus $TMPD/promtool /usr/bin/
install -d -o prometheus -g prometheus /var/lib/prometheus
install -m 0644 /vagrant/chapter03/configs/prometheus/prometheus.service /etc/systemd/system/
install -m 0644 -D /vagrant/chapter03/configs/prometheus/prometheus.yml /etc/prometheus/prometheus.yml
install -m 0644 -D /vagrant/chapter03/configs/prometheus/first_rules.yml /etc/prometheus/first_rules.yml

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
