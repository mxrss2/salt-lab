dis-salt-minion:
  service.disabled: 
    - name: salt-minion
   
deploy the minion configuration:
 file.managed:
 {% if grains['os'] == 'Windows' %}
  - name: c:/salt/conf/minion
{% else %}
  - name: /etc/salt/minion
{% endif %}
  - source: salt://files/minion.jinja
  - template: jinja
  - context:
         ssp_master: {{ salt['environ.get']('SALT_MASTER') }}
         host_name: {{ salt['environ.get']('HOST_NAME') }}
         server_role: {{ salt['environ.get']('SERVER_ROLE')  }}

start-salt-minion:
  service.enabled: 
    - name: salt-minion
  
