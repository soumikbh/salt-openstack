{% from "cluster/resources.jinja" import get_candidate with context %}

{% for network in salt['pillar.get']('neutron:networks', ()) %}
openstack-network-{{ network }}:
  neutron:
    - network_present
    - name: {{ network }}
    - connection_user: {{ pillar['neutron']['networks'][network].get('user', 'admin') }}
    - connection_tenant: {{ pillar['neutron']['networks'][network].get('tenant', 'admin') }}
    - connection_password: {{ salt['pillar.get']('keystone:tenants:%s:users:%s:password' % (pillar['neutron']['networks'][network].get('tenant', 'admin'), pillar['neutron']['networks'][network].get('user', 'admin')), 'ADMIN') }}
    - connection_auth_url: {{ salt['pillar.get']('keystone:services:keystone:endpoint:internalurl', 'http://{0}:5000/v2.0').format(get_candidate(salt['pillar.get']('keystone:services:keystone:endpoint:endpoint_host_sls', default='keystone'))) }}
{% for network_param in salt['pillar.get']('neutron:networks:%s' % network, ()) %}
{% if network_param not in ('subnets', 'user', 'tenant') %}
    - {{ network_param }}: {{ pillar['neutron']['networks'][network][network_param] }}
{% endif %}
{% endfor %}
{% for subnet in salt['pillar.get']('neutron:networks:%s:subnets' % network, ()) %}
openstack-subnet-{{ subnet }}:
  neutron:
    - subnet_present
    - name: {{ subnet }}
    - network: {{ network }}
    - connection_user: {{ pillar['neutron']['networks'][network].get('user', 'admin') }}
    - connection_tenant: {{ pillar['neutron']['networks'][network].get('tenant', 'admin') }}
    - connection_password: {{ salt['pillar.get']('keystone:tenants:%s:users:%s:password' % (pillar['neutron']['networks'][network].get('tenant', 'admin'), pillar['neutron']['networks'][network].get('user', 'admin')), 'ADMIN') }}
    - connection_auth_url: {{ salt['pillar.get']('keystone:services:keystone:endpoint:internalurl', 'http://{0}:5000/v2.0').format(get_candidate(salt['pillar.get']('keystone:services:keystone:endpoint:endpoint_host_sls', default='keystone'))) }}
{% for subnet_param in salt['pillar.get']('neutron:networks:%s:subnets:%s' % (network, subnet), ()) %}
    - {{ subnet_param }}: {{ pillar['neutron']['networks'][network]['subnets'][subnet][subnet_param] }}
{% endfor %}
    - require:
      - neutron: openstack-network-{{ network }}
{% endfor %}
{% endfor %}
