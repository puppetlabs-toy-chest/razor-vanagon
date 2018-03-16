project 'razor-server' do |proj|
  proj.conflicts "pe-razor-server"
  proj.replaces "pe-razor-server"

  proj.setting(:pe_package, false)

  proj.instance_eval File.read('configs/projects/razor-server-shared.rb')
end
