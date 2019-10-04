# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}

    {%- for name in prometheus.wanted %}
       {%- if name in prometheus.service %}

            {%- set service_name = prometheus.service.get(name, {}).get('name', False) %}
            {%- if not service_name %}
                {%- set service_name = name %}
            {%- endif %}

prometheus-service-clean-{{ name }}-service-dead:
  service.dead:
    - name: {{ name }}
    - enable: False
            {%- if grains.kernel|lower == 'linux' %}
    - onlyif: systemctl list-units | grep {{ service_name }} >/dev/null 2>&1
            {%- endif %}
  file.absent:
    - name: {{ prometheus.dir.service }}/{{ name }}.service
    - require:
      - service: prometheus-service-clean-{{ name }}-service-dead
  cmd.run:
    - onlyif: {{ grains.kernel|lower == 'linux' }}
    - name: systemctl daemon-reload
    - require:
      - file: prometheus-service-clean-{{ name }}-service-dead

        {%- endif %}
    {%- endfor %}

prometheus-config-file-var-file-absent:
  file.absent:
    - name: {{ prometheus.dir.var }}
