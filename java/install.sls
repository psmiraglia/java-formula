{% from 'java/map.jinja' import java_settings with context %}

{% set curl_opts = '-b oraclelicense=accept-securebackup-cookie -L -s' %}
{% set tar_file = '/tmp/java.tar.gz' %}

download_jdk_tarball:
  cmd.run:
    - name: curl {{ curl_opts }} -o "{{ tar_file }}" {{ java_settings.jdk.url }}

extract_jdk_tarball:
  archive.extracted:
    - name: /opt/
    - source: file://{{ tar_file }}
    - source_hash: {{ java_settings.jdk.hash }}
    - archive_format: tar
    - require:
      - cmd: download_jdk_tarball

symlink_to_java_home:
  file.symlink:
    - name: {{ java_settings.env.java_home }}
    - target: /opt/{{ java_settings.jdk.name }}
    - require:
      - archive: extract_jdk_tarball

set_java_home_env:
  file.managed:
    - name: /etc/profile.d/sun-java.sh
    - source: salt://java/files/sun-java.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        java_home: {{ java_settings.env.java_home }}

{{ tar_file }}:
  file.absent:
    - require:
      - archive: extract_jdk_tarball

