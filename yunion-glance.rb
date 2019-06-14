class YunionGlance < Formula
  desc "Yunion Cloud Glance Registry server"
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
  port = 9292

  auth_uri = 'http://127.0.0.1:35357/v3'
  admin_user = 'sysadmin'
  admin_password = 'sysadmin'
  admin_project = 'system'

  sql_connection = 'mysql+pymysql://root:password@127.0.0.1:3306/glance?charset=utf8'

  filesystem_store_datadir = '/opt/cloud/workspace/data/glance/images'
  torrent_store_dir = '/opt/cloud/workspace/data/glance/torrents'

  auto_sync_table = true


  enable_ssl = false
  ssl_certfile = '/opt/yunionsetup/config/keys/glance/glance-full.crt'
  ssl_keyfile = '/opt/yunionsetup/config/keys/glance/glance.key'
  EOS
  end

  def caveats; <<~EOS
    Change #{etc}/glance.conf sql_connection options and create glance database
    brew services start yunion-glance
    source #{etc}/keystone/config/rc_admin
    climc service-create --enabled image glance
    climc endpoint-create --enabled glance Yunion public http://127.0.0.1:9292
    climc endpoint-create --enabled glance Yunion internal http://127.0.0.1:9292
    climc endpoint-create --enabled glance Yunion admin http://127.0.0.1:9292

    climc service-create torrent-tracker torrent-tracker
    climc endpoint-create torrent-tracker Yunion public https://tracker.yunion.cn
    climc endpoint-create torrent-tracker Yunion internal https://tracker.yunion.cn

    brew services restart yunion-yunionapi
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
        <string>--config</string>
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
