# Copyright 2016 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Define: lma_monitoring_analytics::influxdb_database

define telemetry::influxdb_database (
  $admin_user,
  $admin_password,
  $influxdb_url,
  $db_user,
  $db_password,
  $retention_period   = 30,
  $replication_factor = 3,
) {

  $db_name = $title
  $create_db_script = "/tmp/create_db_${db_name}"

    # retention period value is expressd in days
    if $retention_period == 0 {
      $real_retention_period = 'INF'
    } else {
      $real_retention_period = sprintf('%dd', $retention_period)
    }

  file { $create_db_script:
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    content => template('telemetry/create_db.sh.erb'),
  }

  exec { "run_${create_db_script}":
    command => $create_db_script,
    require => File[$create_db_script],
  }

  exec { "remove_${create_db_script}":
    command => "/bin/rm -f ${create_db_script}",
    require => Exec["run_${create_db_script}"],
  }
}
