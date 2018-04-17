component "razor-torquebox" do |pkg, settings, platform|
  pkg.version "3.2.0"
  pkg.md5sum "271f84fec822ed7222cb09adfa75b256"
  pkg.url "#{settings[:buildsources_url]}/torquebox-#{pkg.get_version}.tar.gz"
  pkg.add_source "file://resources/files/razor-torquebox.sh", sum: 'b0c34243002a691ee2179e749de59ae4'
  pkg.add_source "file://resources/files/standalone.xml", sum: '6b0a5e1a7fe63407de03a8ee1bba43f8'

  install_commands = [
    "mv * #{settings[:torquebox_prefix]}/",
    "rm -rf #{settings[:torquebox_prefix]}/jruby/lib/ruby/gems/shared/gems/builder-3.0.0/TAGS",
    "rm -rf #{settings[:torquebox_prefix]}/jruby/lib/ruby/gems/shared/gems/thor-0.19.1/spec",
    "sed -i 's,#!\/usr\/bin\/env\s*jruby,#!#{settings[:install_root]}/bin/jruby,g' #{settings[:torquebox_prefix]}/jruby/bin/*",
    %Q{sed -i '/^require .*rubygems.*$$/ a \ENV["JBOSS_HOME"] = "#{settings[:torquebox_prefix]}/jboss"' #{settings[:torquebox_prefix]}/jruby/bin/torquebox},
  ]
  if settings[:pe_package]
    # Add JAVACMD to jruby so it can find pe-java correctly
    install_commands.push("sed -i '/^cygwin=false$$/ a JAVACMD=#{settings[:server_bindir]}/java' #{settings[:torquebox_prefix]}/jruby/bin/jruby")
  end
  pkg.install do
    install_commands
  end

  pkg.install_configfile "../razor-torquebox.sh", "#{settings[:sysconfdir]}/razor-torquebox.sh"
  pkg.install_configfile "../standalone.xml", "#{settings[:torquebox_prefix]}/jboss/standalone/configuration/standalone.xml"

  pkg.link "#{settings[:torquebox_prefix]}/jruby/bin/jruby", "#{settings[:install_root]}/bin/jruby"
  pkg.link "#{settings[:torquebox_prefix]}/jruby/bin/torquebox", "#{settings[:install_root]}/sbin/torquebox"

  pkg.add_postinstall_action ['install', 'upgrade'],
    [
      "/bin/chown -R razor:razor #{settings[:torquebox_prefix]}",
    ]
end
