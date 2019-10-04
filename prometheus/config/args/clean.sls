# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}
{%- set sls_service_clean = tplroot ~ '.service.clean' %}

include:
  - {{ sls_service_clean }}

    {%- for name in prometheus.wanted %}
        {%- if name in prometheus.service %}
            {%- set args = {} %}
            {%- if 'args' in prometheus.service[name] %}
                {%- set args = prometheus.service[name]['args'] or {} %}
            {%- endif %}
            {%- if args and 'storage.tsdb.path' in args.keys() %}

prometheus-config-args-{{ name }}-data-dir:
  file.absent:
    - name: {{ args['storage.tsdb.path'] }}
    - require:
      - sls: '{{ sls_service_clean }}.*'

                {%- if grains.os_family == 'FreeBSD' %}

prometheus-config-args-{{ name }}-{{ key }}:
  sysrc.absent:
    - name: {{ name }}_data_dir
    - require:
      - service: prometheus-service-clean-{{ name }}-service-dead

                {%- endif %}
            {%- endif %}
            {%- if args and grains.os_family == 'FreeBSD' %}

prometheus-config-args-{{ name }}-all:
  sysrc.absent:
    - names:
      - {{ name }}_args
      - {{ name }}_listen_address
      - {{ name }}_textfile_dir
    - require:
      - service: prometheus-service-clean-{{ name }}-service-dead

            {%- elif grains.os_family != 'FreeBSD' %}

                {%- set args_file = prometheus.pkg.get(name, {}).get('args_file', False) %}
                {%- if not args_file %}
                    {%- set args_file = prometheus.dir.args | path_join(name) %}
                    {%- if not grains.os_family in ['Debian'] %}
                        {%- set args_file = "{}.sh".format(args_file) %}
                    {%- endif %}
                {%- endif %}

prometheus-config-args-{{ name }}-file-absent:
  file.absent:
    - name: {{ args_file }}
    - require:
      - service: prometheus-service-clean-{{ name }}-service-dead
    - require_in:
      - file: prometheus-config-file-args-file-absent

            {%- endif %}
        {%- endif %}
    {%- endfor %}

prometheus-config-file-args-file-absent:
  file.absent:
    - name: {{ prometheus.dir.args }}
