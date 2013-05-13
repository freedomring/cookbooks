maintainer       "SendMe, Inc."
maintainer_email "gtrummell@sendme.com"
license          "All rights reserved"
description      "Installs/Configures SendMeMobile Content Services"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.9"

depends "apache2"
depends "ntp"
depends "nfs"
depends "vsftpd"

%w{ debian ubuntu centos redhat fedora }.each do |os|
  supports os
end