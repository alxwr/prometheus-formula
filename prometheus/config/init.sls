# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

include:
  - .users
  - .args
  - .file
    {%- if 'node_exporter' in prometheus.wanted %}
  - .node_exporter.textfile_collectors
    {%- endif %}
