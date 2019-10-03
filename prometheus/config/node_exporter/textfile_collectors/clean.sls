# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

prometheus-node_exporter-textfile_collectors-dir:
  file.absent:
    - name: {{ prometheus.dir.textfile_exporters }}

prometheus-node_exporter-textfile-dir:
  file.absent:
    - name: {{ prometheus.service.node_exporter.args.get('collector.textfile.directory') }}

{%- for collector, config in prometheus.get('node_exporter', {}).get('textfile_collectors', {}).items() %}
include:
  - .{{ collector }}.clean
{%- endfor %}

