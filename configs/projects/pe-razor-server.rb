project 'pe-razor-server' do |proj|
  proj.conflicts "razor-server"
  proj.replaces "razor-server"
  proj.provides "pe-razor-libs"

  proj.setting(:pe_package, true)

  proj.instance_eval File.read('configs/projects/razor-server-shared.rb')
end
