# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_args = tplroot ~ '.config.args' %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

include:
  - {{ sls_config_args }}
  - {{ sls_config_file }}

    {%- if 'prometheus' in prometheus.wanted %}
prometheus-config-file-var-file-directory:
  file.directory:
    - name: {{ prometheus.dir.var }}
    - user: prometheus
    - group: prometheus
    - mode: 755
    - makedirs: True
    - require:
      - file: prometheus-config-file-etc-file-directory
    {%- endif %}

    {%- for name in prometheus.wanted %}
        {%- if name in prometheus.service %}
            {%- if grains.kernel|lower == 'linux' %}

prometheus-service-running-{{ name }}-service-unmasked:
  service.unmasked:
    - name: {{ name }}
                {%- if 'prometheus' in prometheus.wanted %}
    - require:
      - file: prometheus-config-file-var-file-directory
                {%- endif %}
    - onlyif:
       -  systemctl list-unit-files | grep {{ name }} >/dev/null 2>&1
            {%- endif %}

prometheus-service-running-{{ name }}-service-running:
  service.running:
    - name: {{ name }}
    - enable: True
            {%- if name in prometheus.config %}
    - watch:
      - file: prometheus-config-file-{{ name }}-file-managed
            {%- endif %}
            {%- if 'prometheus' in prometheus.wanted %}
    - require:
      - file: prometheus-config-file-var-file-directory
            {%- endif %}
            {%- if grains.kernel|lower == 'linux' %}
      - service: prometheus-service-running-{{ name }}-service-unmasked
    - onlyif: systemctl list-unit-files | grep {{ name }} >/dev/null 2>&1
            {%- endif %}

        {%- endif %}
    {%- endfor %}

