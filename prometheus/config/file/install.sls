# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import prometheus with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set sls_config_users = tplroot ~ '.config.users' %}
{%- set sls_archive_install = tplroot ~ '.archive' %}
{%- set sls_package_install = tplroot ~ '.package' %}

include:
  - {{ sls_archive_install if prometheus.use_upstream_archive else sls_package_install }}
  - {{ sls_config_users }}

prometheus-config-file-etc-file-directory:
  file.directory:
    - name: {{ prometheus.dir.etc }}
    - user: root
    - group: {{ prometheus.rootgroup }}
    - mode: 755
    - makedirs: True
    - require:
      - sls: '{{ sls_archive_install if prometheus.use_upstream_archive else sls_package_install }}.*'

    {%- for name in prometheus.wanted %}
        {%- if name in prometheus.config or name in prometheus.service %}

prometheus-config-file-{{ name }}-file-managed:
  file.managed:
    - name: {{ prometheus.dir.etc }}/{{ name }}.yml
    - source: {{ files_switch(['config.yml.jinja'],
                              lookup='prometheus-config-file-{{ name }}-file-managed'
                 )
              }}
    - mode: 644
    - user: {{ name }}
    - group: {{ name }}
    - makedirs: True
    - template: jinja
    - context:
        config: {{ '' if name not in prometheus.config else prometheus.config[name]|json }}
    - require:
      - user: prometheus-config-user-install-{{ name }}-user-present
      - file: prometheus-config-file-etc-file-directory

        {%- endif %}
    {%- endfor %}
