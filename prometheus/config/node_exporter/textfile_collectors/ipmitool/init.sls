# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

{%- set config = prometheus.node_exporter.textfile_collectors.ipmitool %}
{%- set dir = prometheus.service.node_exporter.args.get('collector.textfile.directory') %}
{%- set script = prometheus.dir.textfile_exporters ~ '/ipmitool' %}

prometheus-exporters-node-textfile_collectors-ipmitool-pkg:
  pkg.installed:
    - name: {{ config.pkg }}

prometheus-exporters-node-textfile_collectors-ipmitool-script:
  file.managed:
    - name: {{ script }}
    - source: salt://prometheus/config/node_exporter/textfile_collectors/files/ipmitool
    - mode: 755
    - require:
      - file: prometheus-node_exporter-textfile_collectors-dir

{%-   set cmd_prefix = 'awk -f ' if grains.os_family in ['FreeBSD'] else '' %}

prometheus-exporters-node-textfile_collectors-ipmitool-cronjob:
  cron.present:
    - identifier: prometheus-exporters-node-textfile_collectors-ipmitool-cronjob
    - name: cd {{ dir }} && LANG=C ipmitool sensor | {{ cmd_prefix }}{{ script }} > .ipmitool.prom$$; mv .ipmitool.prom$$ ipmitool.prom
    - minute: "{{ config.get('minute', '*') }}"
    - comment: Prometheus' node_exporter's ipmitool textfile collector
    - require:
      - file: prometheus-exporters-node-textfile_collectors-ipmitool-script
