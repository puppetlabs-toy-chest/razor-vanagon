project 'pe-razor-server' do |proj|
  platform = proj.get_platform

  proj.conflicts "razor-server"
  proj.replaces "razor-server"
  proj.provides "pe-razor-libs"

  proj.setting(:pe_package, true)
  proj.setting(:razor_user, 'pe-razor')
  proj.setting(:pe_version, ENV['PE_VER'] || '2019.3')
  platform.add_build_repository "http://enterprise.delivery.puppetlabs.net/#{proj.pe_version}/repos/#{platform.name}/#{platform.name}.repo"

  proj.instance_eval File.read('configs/projects/razor-server-shared.rb')

  proj.setting(:configdir, proj.install_root)

  proj.component "razor-server"
  proj.component "razor-torquebox"
end
