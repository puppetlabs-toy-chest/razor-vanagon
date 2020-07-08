project 'pe-razor-server' do |proj|
  platform = proj.get_platform

  proj.conflicts "razor-server"
  proj.replaces "razor-server"
  proj.provides "pe-razor-libs"

  proj.setting(:pe_package, true)
  proj.setting(:razor_user, 'pe-razor')
  proj.setting(:pe_version, ENV['PE_VER'] || '2018.1')

  artifactory_url = 'https://artifactory.delivery.puppetlabs.net/artifactory'

  if platform.is_rpm?
    platform.add_build_repository "#{artifactory_url}/rpm_enterprise__local/#{settings[:pe_version]}/repos/#{platform.name}/#{platform.name}.repo"
  end

  if platform.is_deb?
    platform.add_build_repository "#{artifactory_url}/debian_enterprise__local/#{settings[:pe_version]}/repos/#{platform.name}/#{platform.name}.list"
  end

  proj.instance_eval File.read('configs/projects/razor-server-shared.rb')

  proj.setting(:configdir, proj.install_root)

  proj.component "razor-server"
  proj.component "razor-torquebox"
end
