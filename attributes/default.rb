# encoding: UTF-8
#
# Cookbook Name:: openstack-image
# Attributes:: default
#
# Copyright 2012, Rackspace US, Inc.
# Copyright 2013, Craig Tracey <craigtracey@gmail.com>
# Copyright 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['image']['custom_template_banner'] = '
# This file is automatically generated by Chef
# Any changes will be overwritten
'

# SSL Options
# Enable SSL for glance api and registry bind endpoints.
default['openstack']['image']['ssl']['enabled'] = false
# Enable SSL for glance api bind endpoint.
default['openstack']['image']['ssl']['api']['enabled'] = node['openstack']['image']['ssl']['enabled']
# Enable SSL for glance registry bind endpoint.
default['openstack']['image']['ssl']['registry']['enabled'] = node['openstack']['image']['ssl']['enabled']
# Base directory for SSL certficate and key
default['openstack']['image']['ssl']['basedir'] = '/etc/glance/ssl'

default['openstack']['image']['verbose'] = 'False'

# This is the name of the Chef role that will install the Keystone Service API
default['openstack']['image']['identity_service_chef_role'] = 'os-identity'

# Gets set in the Image Endpoint when registering with Keystone
default['openstack']['image']['region'] = node['openstack']['region']

# The name of the Chef role that knows about the message queue server
# that Glance uses
default['openstack']['image']['rabbit_server_chef_role'] = 'os-ops-messaging'
default['openstack']['image']['service_project'] = 'service'
default['openstack']['image']['service_user'] = 'glance'
default['openstack']['image']['service_role'] = 'admin'

# Supported values for the 'container_format' image attribute
default['openstack']['image']['api']['container_formats'] = %w(ami ari aki bare ovf ova docker dockerref)

# Supported values for the 'disk_format' image attribute

# Whether to use any of the default caching pipelines from the paste configuration file
default['openstack']['image']['api']['caching'] = false
default['openstack']['image']['api']['cache_management'] = false

# Directory for the Image Cache
default['openstack']['image']['cache']['dir'] = '/var/lib/glance/image-cache/'
# Number of seconds until an incomplete image is considered stalled an

# Number of seconds to leave invalid images around before they are eligible to be reaped
default['openstack']['image']['cache']['grace_period'] = 3600

# Default Image Locations
default['openstack']['image']['upload_images'] = ['cirros']
default['openstack']['image']['upload_image']['xenial'] = 'http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img'
default['openstack']['image']['upload_image']['zesty'] = 'http://cloud-images.ubuntu.com/zesty/current/zesty-server-cloudimg-amd64-disk1.img'
default['openstack']['image']['upload_image']['cirros'] = 'http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img'
# more images available at https://github.com/rackerjoe/oz-image-build
default['openstack']['image']['upload_image']['centos'] = 'http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2'
# To override image type
# The following disk format types are supported: qcow vhd vmdk vdi iso raw
# Bare container format will be used.
default['openstack']['image']['upload_image_type']['cirros'] = 'qcow'
default['openstack']['image']['upload_image_id']['cirros'] = 'e1847f1a-01d2-4957-a067-b56085bf3781'
# logging attribute
default['openstack']['image']['syslog']['use'] = false
default['openstack']['image']['syslog']['facility'] = 'LOG_LOCAL2'
default['openstack']['image']['syslog']['config_facility'] = 'local2'

# vmware attributes
default['openstack']['image']['api']['vmware']['secret_name'] = 'openstack_vmware_secret_name'

# cron output redirection
default['openstack']['image']['cron']['redirection'] = '> /dev/null 2>&1'

# platform-specific settings
case platform_family
when 'rhel' # :pragma-foodcritic: ~FC024 - won't fix this
  default['openstack']['image']['user'] = 'glance'
  default['openstack']['image']['group'] = 'glance'
  default['openstack']['image']['platform'] = {
    'image_packages' => %w(openstack-glance cronie),
    'ceph_packages' => ['python-ceph'],
    'swift_packages' => ['openstack-swift'],
    'image_api_service' => 'openstack-glance-api',
    'image_registry_service' => 'openstack-glance-registry',
    'image_api_process_name' => 'glance-api',
    'package_overrides' => '',
  }
when 'suse'
  default['openstack']['image']['user'] = 'openstack-glance'
  default['openstack']['image']['group'] = 'openstack-glance'
  default['openstack']['image']['platform'] = {
    'image_packages' => ['openstack-glance'],
    'ceph_packages' => [],
    'swift_packages' => ['openstack-swift'],
    'image_api_service' => 'openstack-glance-api',
    'image_registry_service' => 'openstack-glance-registry',
    'image_api_process_name' => 'glance-api',
    'package_overrides' => '',
  }
when 'debian'
  default['openstack']['image']['user'] = 'glance'
  default['openstack']['image']['group'] = 'glance'
  default['openstack']['image']['platform'] = {
    'image_packages' => ['glance'],
    'ceph_packages' => ['python-ceph'],
    'swift_packages' => ['python-swift'],
    'image_api_service' => 'glance-api',
    'image_registry_service' => 'glance-registry',
    'image_registry_process_name' => 'glance-registry',
    'package_overrides' => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'",
  }
end

# ******************** OpenStack Image Endpoints ******************************

# The OpenStack Image (Glance) endpoints
%w(public internal admin).each do |ep_type|
  %w(image_api image_registry).each do |service|
    default['openstack']['endpoints'][ep_type][service]['scheme'] = 'http'
    default['openstack']['endpoints'][ep_type][service]['host'] = '127.0.0.1'
    default['openstack']['endpoints'][ep_type]['image_api']['path'] = ''
    default['openstack']['endpoints'][ep_type]['image_api']['port'] = 9292
    default['openstack']['endpoints'][ep_type]['image_registry']['path'] = '/v3'
    default['openstack']['endpoints'][ep_type]['image_registry']['port'] = 9191
  end
end
default['openstack']['bind_service']['all']['image_registry']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['image_registry']['port'] = 9191
default['openstack']['bind_service']['all']['image_api']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['image_api']['port'] = 9292
