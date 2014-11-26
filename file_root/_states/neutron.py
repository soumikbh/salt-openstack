# -*- coding: utf-8 -*-
'''
Management of Neutron resources
===============================

:depends:   - neutronclient Python module
:configuration: See :py:mod:`salt.modules.neutron` for setup instructions.

.. code-block:: yaml

    neutron network present:
      neutron.network_present:
        - name: Netone
        - provider_physical_network: PHysnet1
        - provider_network_type: vlan
'''
import logging
from functools import wraps
LOG = logging.getLogger(__name__)


def __virtual__():
    '''
    Only load if glance module is present in __salt__
    '''
    return 'neutron' if 'neutron.list_networks' in __salt__ else False


def _test_call(method):
    (resource, functionality) = method.func_name.split('_')
    if functionality == 'present':
        functionality = 'updated'
    else:
        functionality = 'removed'

    @wraps(method)
    def check_for_testing(name, *args, **kwargs):
        if __opts__.get('test', None):
            return _no_change(name, resource, test=functionality)
        return method(name, *args, **kwargs)
    return check_for_testing


def _neutron_module_call(method, *args, **kwargs):
    return __salt__['neutron.{0}'.format(method)](*args, **kwargs)


@_test_call
def network_present(name=None,
                    provider_network_type=None,
                    provider_physical_network=None,
                    router_external=None,
                    admin_state_up=None,
                    shared=True,
                    **connection_args):
    '''
    Ensure that the neutron network is present with the specified properties.

    name
        The name of the network to manage
    '''
    existing_network = _neutron_module_call(
        'list_networks', name=name, **connection_args)
    network_arguments = _get_non_null_args(
        name=name,
        provider_network_type=provider_network_type,
        provider_physical_network=provider_physical_network,
        router_external=router_external,
        shared=shared)
    if not existing_network:
        network_arguments.update(connection_args)
        _neutron_module_call('create_network', **network_arguments)
        existing_network = _neutron_module_call(
            'list_networks', name=name, **connection_args)
        if existing_network:
            return _created(name, 'network', existing_network[name])
        return _update_failed(name, 'network')
    # map internal representation to display format
    existing_network = dict((key.replace(':', '_', 1), value)
                            for key, value in
                            existing_network[name].iteritems())
    # generate differential
    diff = dict((key, value) for key, value in network_arguments.iteritems()
                if existing_network.get(key, None) != value)
    if diff:
        # update the changes
        network_arguments = diff.copy()
        network_arguments.update(connection_args)
        try:
            LOG.debug('updating network {0} with changes {1}'.format(
                name, str(diff)))
            _neutron_module_call('update_network',
                                 existing_network['id'],
                                 **network_arguments)
            changes_dict = _created(name, 'network', diff)
            changes_dict['comment'] = '{1} {0} updated'.format(name, 'network')
            return changes_dict
        except:
            LOG.exception('Could not update network {0}'.format(name))
            return _update_failed(name, 'network')
    return _no_change(name, 'network')


@_test_call
def subnet_present(name=None,
                   network=None,
                   cidr=None,
                   ip_version=4,
                   enable_dhcp=True,
                   allocation_pools=None,
                   gateway_ip=None,
                   dns_nameservers=None,
                   host_routes=None,
                   **connection_args):
    '''
    Ensure that the neutron subnet is present with the specified properties.

    name
        The name of the subnet to manage
    '''
    existing_subnet = _neutron_module_call(
        'list_subnets', name=name, **connection_args)
    subnet_arguments = _get_non_null_args(
        name=name,
        network=network,
        cidr=cidr,
        ip_version=ip_version,
        enable_dhcp=enable_dhcp,
        allocation_pools=allocation_pools,
        gateway_ip=gateway_ip,
        dns_nameservers=dns_nameservers,
        host_routes=host_routes)
    # replace network with network_id
    if 'network' in subnet_arguments:
        network = subnet_arguments.pop('network', None)
        existing_network = _neutron_module_call(
            'list_networks', name=network, **connection_args)
        if existing_network:
            subnet_arguments['network_id'] = existing_network[network]['id']
    if not existing_subnet:
        subnet_arguments.update(connection_args)
        _neutron_module_call('create_subnet', **subnet_arguments)
        existing_subnet = _neutron_module_call(
            'list_subnets', name=name, **connection_args)
        if existing_subnet:
            return _created(name, 'subnet', existing_subnet[name])
        return _update_failed(name, 'subnet')
    # change from internal representation
    existing_subnet = existing_subnet[name]
    # create differential
    diff = dict((key, value) for key, value in subnet_arguments.iteritems()
                if existing_subnet.get('key', None) != value)
    if diff:
        # update the changes
        subnet_arguments = diff.copy()
        subnet_arguments.update(connection_args)
        try:
            LOG.debug('updating subnet {0} with changes {1}'.format(
                name, str(diff)))
            _neutron_module_call('update_subnet',
                                 existing_subnet['id'],
                                 **subnet_arguments)
            changes_dict = _created(name, 'subnet', diff)
            changes_dict['comment'] = '{1} {0} updated'.format(name, 'subnet')
            return changes_dict
        except:
            LOG.exception('Could not update subnet {0}'.format(name))
            return _update_failed(name, 'subnet')
    return _no_change(name, 'subnet')


def _created(name, resource, resource_definition):
    changes_dict = {'name': name,
                    'changes': resource_definition,
                    'result': True,
                    'comment': '{0} {1} created'.format(resource, name)}
    return changes_dict


def _no_change(name, resource, test=False):
    changes_dict = {'name': name,
                    'changes': {},
                    'result': True}
    if test:
        changes_dict['comment'] = \
            '{0} {1} will be {2}'.format(resource, name, test)
    else:
        changes_dict['comment'] = \
            '{0} {1} is in correct state'.format(resource, name)
    return changes_dict


def _update_failed(name, resource):
    changes_dict = {'name': name,
                    'changes': {},
                    'comment': '{0} {1} failed to update'.format(resource,
                                                                 name),
                    'result': False}
    return changes_dict


def _get_non_null_args(**kwargs):
    '''
    Return those kwargs which are not null
    '''
    return dict((key, value,) for key, value in kwargs.iteritems() if value)
