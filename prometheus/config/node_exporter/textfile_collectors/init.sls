# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

prometheus-node_exporter-textfile_collectors-dir:
  file.directory:
    - name: {{ prometheus.dir.textfile_exporters }}
    - mode: 755
    - user: node_exporter
    - group: node_exporter
    - makedirs: True

prometheus-node_exporter-textfile-dir:
  file.directory:
    - name: {{ prometheus.service.node_exporter.args.get('collector.textfile.directory') }}
    - mode: 755
    - user: node_exporter
    - group: node_exporter
    - makedirs: True

{%- set obj = {'include_written': False} %}
{%- for collector, config in prometheus.get('node_exporter', {}).get('textfile_collectors', {}).items() %}
{%-     if config.get('enable', False) %}
{%-         if not obj.include_written %}
include:
{%              do obj.update({'include_written': True}) %}
{%-         endif %}
{%-         if config.get('remove', False) %}
  - .{{ collector }}.clean
{%          else %}
  - .{{ collector }}
{%          endif %}
{%      endif %}
{%- endfor %}
