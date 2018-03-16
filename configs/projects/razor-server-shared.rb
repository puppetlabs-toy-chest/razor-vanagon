platform = proj.get_platform

proj.description <<-eos
Razor is an advanced provisioning application
Razor is an advanced provisioning application which can deploy both bare-metal
and virtual systems. It's aimed at solving the problem of how to bring new
metal into a state where your existing DevOps/configuration management
workflows can take it over.
Newly added machines in a Razor deployment will PXE-boot from a special Razor
Microkernel image, then check in, provide Razor with inventory information, and
wait for further instructions. Razor will consult user-created policy rules to
choose which preconfigured model to apply to a new node, which will begin to
follow the model's directions, giving feedback to Razor as it completes various
steps. Models can include steps for handoff to a DevOps system such as Puppet
or to any other system capable of controlling the node (such as a vCenter
server taking possession of ESX systems).
eos

proj.version_from_git
proj.license "See components"
proj.vendor "Puppet Labs <info@puppetlabs.com>"
proj.homepage "https://www.puppet.com"
proj.target_repo "puppet5"
proj.noarch

proj.conflicts "razor-torquebox"
proj.replaces "razor-torquebox"
proj.provides "razor-torquebox"

proj.conflicts "pe-razor-libs"
proj.replaces "pe-razor-libs"

# Directory Structure
proj.setting(:install_root, "/opt/puppetlabs/server/apps/razor-server")
proj.setting(:data_root, "/opt/puppetlabs/server/data/razor-server")
proj.setting(:prefix, File.join(proj.install_root, "share", "razor-server"))
proj.setting(:torquebox_prefix, File.join(proj.install_root, "share", "torquebox"))
proj.setting(:sysconfdir, "/etc/puppetlabs/razor-server")
proj.setting(:logdir, "/var/log/puppetlabs/razor-server")
proj.setting(:rundir, "/var/run/puppetlabs/razor-server")
proj.setting(:server_bindir, "/opt/puppetlabs/server/bin")
proj.setting(:agent_bindir, "/opt/puppetlabs/bin")

proj.setting(:artifactory_url, "https://artifactory.delivery.puppetlabs.net/artifactory")
proj.setting(:buildsources_url, "#{artifactory_url}/generic/buildsources")

proj.user("razor", group: "razor", shell: '/bin/bash', is_system: true, homedir: "#{proj.install_root}/var/razor")

proj.directory proj.prefix
proj.directory proj.torquebox_prefix
proj.directory proj.sysconfdir
proj.directory proj.logdir
proj.directory proj.rundir

# First our stuff
proj.component "razor-server"

# Then the dependencies
proj.component "razor-torquebox"
