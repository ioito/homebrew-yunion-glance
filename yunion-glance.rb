class YunionGlance < Formula
  desc "Yunion Cloud Image Service"
  homepage "https://github.com/yunionio/onecloud.git"
  url "https://github.com/yunionio/onecloud.git",
    :tag      => "release/2.10.0"
  version_scheme 1
  head "https://github.com/yunionio/onecloud.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    (buildpath/"src/yunion.io/x/onecloud").install buildpath.children
    cd buildpath/"src/yunion.io/x/onecloud" do
      system "make", "cmd/glance"
      bin.install "_output/bin/glance"
      prefix.install_metafiles
    end

    (buildpath/"glance.conf").write glance_conf
    etc.install "glance.conf"
  end

  def post_install
    (var/"log/glance").mkpath
  end

  def glance_conf; <<~EOS
  region = 'Yunion'
  address = '0.0.0.0'
  port = 8888
  auth_uri = 'https://127.0.0.0:35357/v3'
  admin_user = 'username'
  admin_password = 'password'
  admin_tenant_name = 'system'
  sql_connection = 'mysql+pymysql://yunioncloud:zfgkhjGZusg1InyS@10.168.222.209:3306/yunioncloud?charset=utf8'
  dns_server = '114.114.114.114'
  dns_domain = 'yunion.local'
  dns_resolvers = ['114.114.114.114']

  scheduler_port = 8897

  ignore_nonrunning_guests = True

  # convert_hypervisor_default_template = ''

  port_v2 = 8889

  log_level = 'debug'
  auto_sync_table = True

  enable_ssl = True
  ssl_certfile = '/opt/yunionsetup/config/keys/region/region-full.crt'
  ssl_keyfile = '/opt/yunionsetup/config/keys/region/region.key'
  ssl_ca_certs = '/opt/yunionsetup/config/keys/region/ca.crt'
  EOS
  end

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>RunAtLoad</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/glance</string>
        <string>--conf</string>
        <string>#{etc}/glance.conf</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/glance/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/glance/output.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "false"
  end
end
