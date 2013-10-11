class Ruby200 < FPM::Cookery::Recipe
  description 'The Ruby virtual machine'

  name 'ruby2.0'
  version '2.0.0.247'
  revision 0
  homepage 'http://www.ruby-lang.org/'
  source 'http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p247.tar.bz2'
  sha256 '08e3d4b85b8a1118a8e81261f59dd8b4ddcfd70b6ae554e0ec5ceb99c3185e8a'

  section 'interpreters'

  build_depends 'autoconf', 'libreadline6-dev', 'bison', 'zlib1g-dev',
                'libssl-dev', 'libyaml-dev'

  depends 'libffi6', 'libncurses5', 'libreadline6', 'libssl1.0.0',
          'libtinfo5', 'libyaml-0-2', 'zlib1g'

  def build
    configure :prefix => prefix,
      'disable-install-doc' => true,
      'program-suffix' => '2.0'
    make
  end

  def install
    make :install, 'DESTDIR' => destdir

    with_trueprefix do
      File.open(builddir('post-install'), 'w', 0755) do |f|
        f.write <<-__POSTINST
#!/bin/sh
set -e

BIN_PATH="#{prefix("bin")}"

for bin in gem ruby; do
  update-alternatives --install /usr/bin/$bin $bin $BIN_PATH/$bin 20000
done

exit 0
        __POSTINST
        self.class.post_install File.expand_path(f.path)
      end

      File.open(builddir('pre-uninstall'), 'w', 0755) do |f|
        f.write <<-__PRERM
#!/bin/sh
set -e

BIN_PATH="#{prefix("bin")}"

if [ "$1" != "upgrade" ]; then
  for bin in gem ruby; do
    update-alternatives --remove $bin $BIN_PATH/$bin
  done
fi

exit 0
        __PRERM
        self.class.pre_uninstall File.expand_path(f.path)
      end
    end

  end
end
