# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

{%- set config = prometheus.node_exporter.textfile_collectors.smartmon %}
{%- set dir = prometheus.service.node_exporter.args.get('collector.textfile.directory') %}
{%- set script = prometheus.dir.textfile_exporters ~ '/smartmon.sh' %}

prometheus-exporters-node-textfile_collectors-smartmon-pkg:
  pkg.installed:
    - name: {{ config.pkg }}

prometheus-exporters-node-textfile_collectors-smartmon-pkg-bash:
  pkg.installed:
    - name: {{ config.bash_pkg }}

prometheus-exporters-node-textfile_collectors-smartmon-script:
  file.managed:
    - name: {{ script }}
    - source: salt://prometheus/config/node_exporter/textfile_collectors/files/smartmon.sh.jinja
    - template: jinja
    - context:
        smartctl: {{ config.smartctl }}
    - mode: 755
    - require:
      - file: prometheus-node_exporter-textfile_collectors-dir

prometheus-exporters-node-textfile_collectors-smartmon-cronjob:
  cron.present:
    - identifier: prometheus-exporters-node-textfile_collectors-smartmon-cronjob
    - name: cd {{ dir}} && LANG=C {{ script }} > .smartmon.prom$$ && mv .smartmon.prom$$ smartmon.prom
    - minute: "{{ config.get('minute', '*') }}"
    - comment: Prometheus' node_exporter's smartmon textfile collector
    - require:
      - file: prometheus-exporters-node-textfile_collectors-smartmon-script
