# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}
{%- from tplroot ~ "/map.jinja" import concat_args %}
{%- set sls_config_users = tplroot ~ '.config.users' %}
{%- set sls_archive_install = tplroot ~ '.archive' %}
{%- set sls_package_install = tplroot ~ '.package' %}

include:
  - {{ sls_archive_install if prometheus.use_upstream_archive else sls_package_install }}
  - {{ sls_config_users }}

    {%- if prometheus.dir.args %}
prometheus-config-file-args-file-directory:
  file.directory:
    - name: {{ prometheus.dir.args }}
    - user: prometheus
    - group: prometheus
    - mode: 755
    - makedirs: True
    - require:
      - sls: '{{ sls_archive_install if prometheus.use_upstream_archive else sls_package_install }}.*'
    {%- endif %}

    {%- for name in prometheus.wanted %}
        {%- if name in prometheus.config or name in prometheus.service %}
            {%- set args = {} %}
            {%- if 'args' in prometheus.service[name] %}
                {%- set args = prometheus.service[name]['args'] or {} %}
            {%- endif %}
            {%- if args and 'storage.tsdb.path' in args.keys() %}

prometheus-config-args-{{ name }}-data-dir:
  file.directory:
    - name: {{ args['storage.tsdb.path'] }}
    - owner: {{ name }}
    - group: {{ name }}
    - makedirs: True
    - watch_in:
      - service: prometheus-service-running-{{ name }}-service-running
                {%- if prometheus.dir.args %}
    - require:
      - file: prometheus-config-file-args-file-directory
                {%- endif %}

            {%- endif %}
            {%- if args and grains.os_family == 'FreeBSD' %}
                {%- if 'collector.textfile.directory' in args.keys() %}

prometheus-config-args-{{ name }}-collector-textfile-directory:
  sysrc.managed:
    - name: {{ name }}_textfile_dir
    - value: {{ args.pop('collector.textfile.directory') }}
    - watch_in:
      - service: prometheus-service-running-{{ name }}-service-running

                {%- endif %}
                {%- if 'storage.tsdb.path' in args.keys() %}

prometheus-config-args-{{ name }}-storage-tsdb-path:
  sysrc.managed:
    - name: {{ name }}_data_dir
    - value: {{ args.pop('storage.tsdb.path') }}
    - watch_in:
      - service: prometheus-service-running-{{ name }}-service-running

                {%- endif %}
                {%- if name in ['node_exporter'] and 'web.listen-address' in args.keys() %}

prometheus-config-args-{{ name }}-web-listen-address:
  sysrc.managed:
    - name: {{ name }}_listen_address
    - value: {{ args.pop('web.listen-address') }}
    - watch_in:
      - service: prometheus-service-running-{{ name }}-service-running

                {%- endif %}

prometheus-config-args-{{ name }}-config-file:
  sysrc.managed:
    - name: {{ name }}_config
    - value: {{ prometheus.dir.etc }}/{{ name }}.yml
    - watch_in:
      - service: prometheus-service-running-{{ name }}-service-running

prometheus-config-args-{{ name }}-all:
  sysrc.managed:
    - name: {{ name }}_args
    # service prometheus restart tended to hang on FreeBSD
    # https://github.com/saltstack/salt/issues/44848#issuecomment-487016414
    - value: "{{ concat_args(args) }} >/dev/null 2>&1"
    - watch_in:
      - service: prometheus-service-running-{{ name }}-service-running

            {%- elif grains.os_family != 'FreeBSD' %}

prometheus-config-args-{{ name }}-file-managed:
  file.managed:
    - name: {{ prometheus.dir.args }}/{{ name }}.sh
    - contents: |
        ARGS="{{ concat_args(args) }}"
    - watch_in:
      - service: prometheus-service-running-{{ name }}-service-running
                {%- if prometheus.dir.args %}
    - require:
      - file: prometheus-config-file-args-file-directory
                {%- endif %}

            {%- endif %}
        {%- endif %}
    {%- endfor %}
