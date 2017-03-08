component "razor-server" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/razor-server.json')
  pkg.add_source "file://resources/files/razorserver.sh", sum: "f5987a68adf3844ca15ba53813ad6f63"

  pkg.build_requires "razor-torquebox"
  if platform.is_rpm?
    pkg.requires "shadow-utils"
    pkg.requires "libarchive-devel"
  elsif platform.is_deb?
    pkg.requires "libarchive-dev"
  end

  java_home = ""
  javacmd = ""
  case platform.name
  when /(el-(6|7)|fedora-(f22|f23))/
    pkg.build_requires 'java-1.8.0-openjdk-devel'
    pkg.requires 'java-1.8.0-openjdk'
  when /(debian-(7|8)|ubuntu-(12|14))/
    pkg.build_requires 'openjdk-7-jdk'
    pkg.requires 'openjdk-7-jre-headless'
    java_home = "JAVA_HOME='/usr/lib/jvm/java-7-openjdk-#{platform.architecture}'"
  when /(debian-9|ubuntu-(15|16))/
    pkg.build_requires 'openjdk-8-jdk'
    pkg.requires 'openjdk-8-jre-headless'
    java_home = "JAVA_HOME='/usr/lib/jvm/java-8-openjdk-#{platform.architecture}'"
  end
  jruby = "#{java_home} #{javacmd} #{settings[:torquebox_prefix]}/jruby/bin/jruby -S"

  pkg.directory File.join(settings[:install_root], "var", "razor")
  pkg.directory File.join(settings[:data_root], "repo")

  case platform.servicetype
  when "systemd"
    pkg.install_service "ext/razor-server.service"
    pkg.install_configfile "ext/razor-server.env", "#{settings[:prefix]}/razor-server.env"
    pkg.install_configfile "ext/razor-server-tmpfiles.conf", "/usr/lib/tmpfiles.d/razor-server.conf"
  when "sysv"
    pkg.install_service "ext/razor-server.init"
  else
    fail "need to know where to put service files"
  end
  pkg.install_configfile "ext/razor-server.sysconfig", "/etc/sysconfig/razor-server"
  pkg.install_configfile "config.yaml.sample", "#{settings[:sysconfdir]}/config.yaml"
  pkg.install_configfile "shiro.ini", "#{settings[:sysconfdir]}/shiro.ini"

  pkg.configure do
    [
      "rm Gemfile.lock",
      "#{jruby} bundle install --shebang #{settings[:torquebox_prefix]}/jruby/bin/jruby --clean --no-cache --path #{settings[:prefix]}/vendor/bundle --without 'development test doc'",
      "rm -rf .bundle/install.log",
      "rm -rf vendor/bundle/jruby/1.9/cache",
      "#{jruby} bundle config PATH #{settings[:prefix]}/vendor/bundle",
      "sed -i -- 's/version = \"DEVELOPMENT\"/version = \"#{@component.options[:ref]}\"/g' lib/razor/version.rb"
    ]
  end

  pkg.install do
    [
      "rm -rf spec",
      "rm -rf ext",
      "cp -pr .bundle * #{settings[:prefix]}",
      "rm -rf #{settings[:prefix]}/vendor/bundle/jruby/1.9/gems/thor-0.19.1/spec",
      "rm #{settings[:prefix]}/shiro.ini"
    ]
  end

  pkg.link "#{settings[:prefix]}/bin/razor-binary-wrapper", "#{settings[:agent_bindir]}/razor-admin"
  pkg.link "#{settings[:prefix]}/bin/razor-binary-wrapper", "#{settings[:server_bindir]}/razor-admin"

  pkg.install_file("../razorserver.sh", "/etc/profile.d/razorserver.sh")

  # On upgrade, check to see if these files exist and copy them out of the way to preserve their contents
  pkg.add_preinstall_action ['upgrade'],
    [
      "[[ -e /etc/razor/config.yaml ]] && mkdir -p /tmp/.razor-server.upgrade && cp /etc/razor/config.yaml /tmp/.razor-server.upgrade/config.yaml",
      "[[ -e /etc/razor/shiro.ini ]] && mkdir -p /tmp/.razor-server.upgrade && cp /etc/razor/shiro.ini /tmp/.razor-server.upgrade/shiro.ini",
    ]

  pkg.add_postinstall_action ['install', 'upgrade'],
    [
      "/bin/chown -R razor:razor #{settings[:install_root]}/var/razor || :",
      "/bin/chown -R razor:razor #{settings[:data_root]}/repo || :",
      "/bin/chown -R razor:razor #{settings[:logdir]} || :",
      "/bin/chown -R razor:razor #{settings[:rundir]} || :",
      "echo 'The razor-admin binary has been moved to /opt/puppetlabs/bin and is not currently on the path. To access it, log out and log back in or run `source /etc/profile.d/razorserver.sh`'"
    ]

  pkg.add_postinstall_action ['install'],
    [
      "source #{settings[:sysconfdir]}/razor-torquebox.sh",
      "#{settings[:torquebox_prefix]}/jruby/bin/torquebox deploy #{settings[:prefix]} --env=production"
    ]

  pkg.add_postinstall_action ['upgrade'],
    [
      "[[ -e /tmp/.razor-server.upgrade/config.yaml ]] && mv /tmp/.razor-server.upgrade/config.yaml #{settings[:sysconfdir]}/config.yaml",
      "[[ -e /tmp/.razor-server.upgrade/shiro.ini ]] && mv /tmp/.razor-server.upgrade/shiro.ini #{settings[:sysconfdir]}/shiro.ini",
      "[[ -e /tmp/.razor-server.upgrade ]] && rm -rf /tmp/.razor-server.upgrade",

      # we need making sure the old config files are removed from the file
      # system. If they were already there, they were moved to the new location
      # and should be removed completely from the old location. This happens
      # after we've ensured the old files are available in the new location
      "[[ -e /etc/razor/config.yaml ]] && rm /etc/razor/config.yaml",
      "[[ -e /etc/razor/shiro.ini ]] && rm /etc/razor/shiro.ini",

      # we have to chown the old repo-store location in case the user is still
      # using it. The debian packaging removes the razor user for some reason
      # and this directory loses it's permissions. Since we're not forcing the
      # user to migrate to the new repo store location, we need to make sure
      # the razor user still has access to this directory.
      "[[ -e /var/lib/razor/repo-store ]] && /bin/chown -R razor:razor /var/lib/razor/repo-store",
    ]

  pkg.add_preremove_action ['upgrade', 'removal'],
    [
    "source #{settings[:sysconfdir]}/razor-torquebox.sh ||:",
    "#{settings[:torquebox_prefix]}/jruby/bin/torquebox undeploy #{settings[:prefix]} ||:"
    ]
end
