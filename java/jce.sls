{% from 'java/map.jinja' import java_settings with context %}
{% set curl_opts = '-b oraclelicense=accept-securebackup-cookie -L -s' %}
{% set zip_file = '/tmp/jce.zip' %}

download_jce_zip:
  cmd.run:
    - name: curl {{ curl_opts }} -o "{{ zip_file }}" {{ java_settings.jce.url }}

extract_jce_zip:
  archive.extracted:
    - name: /tmp/
    - source: file://{{ zip_file }}
    - source_hash: {{ java_settings.jce.hash }}
    - archive_format: zip
    - require:
      - cmd: download_jce_zip

{{ java_settings.env.java_home }}/jre/lib/security/local_policy.jar:
  file.managed:
    - source: file:///tmp/{{ java_settings.jce.name }}/local_policy.jar
    - require:
      - archive: extract_jce_zip

{{ java_settings.env.java_home }}/jre/lib/security/US_export_policy.jar:
  file.managed:
    - source: file:///tmp/{{ java_settings.jce.name }}/US_export_policy.jar
    - require:
      - archive: extract_jce_zip

{{ zip_file }}:
  file.absent:
    - require:
      - archive: extract_jce_zip

/tmp/{{ java_settings.jce.name }}:
  file.absent:
    - require:
      - file: {{ java_settings.env.java_home }}/jre/lib/security/local_policy.jar
      - file: {{ java_settings.env.java_home }}/jre/lib/security/US_export_policy.jar

