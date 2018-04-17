project 'razor-server' do |proj|
  proj.conflicts "pe-razor-server"
  proj.replaces "pe-razor-server"

  proj.setting(:pe_package, false)
  proj.setting(:razor_user, 'razor')

  proj.instance_eval File.read('configs/projects/razor-server-shared.rb')

  proj.setting(:configdir, proj.sysconfdir)

  proj.component "razor-server"
  proj.component "razor-torquebox"
end
