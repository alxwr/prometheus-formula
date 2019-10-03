# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

{%- set config = prometheus.node_exporter.textfile_collectors.ipmitool %}
{%- set dir = prometheus.service.node_exporter.args.get('collector.textfile.directory') %}
{%- set script = prometheus.dir.textfile_exporters ~ '/ipmitool' %}

prometheus-exporters-node-textfile_collectors-ipmitool-pkg:
  pkg.removed:
    - name: {{ config.pkg }}

prometheus-exporters-node-textfile_collectors-ipmitool-script:
  file.absent:
    - name: {{ script }}

prometheus-exporters-node-textfile_collectors-ipmitool-output:
  file.absent:
    - name: {{ dir }}/ipmitool.prom

prometheus-exporters-node-textfile_collectors-ipmitool-cronjob:
  cron.absent:
    - identifier: prometheus-exporters-node-textfile_collectors-ipmitool-cronjob
