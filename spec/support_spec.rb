require 'spec_helper'
require 'tempfile'

describe 'support' do

  let(:output) do
    StringIO.new('', 'w')
  end

  let(:repl) do
    PuppetRepl::Cli.new(:out_buffer => output)
  end

  let(:scope) do
    repl.scope
  end

  describe 'play' do
    let(:url) do
      'https://gist.github.com/logicminds/f9b1ac65a3a440d562b0'
    end
    let(:input) do
      "play #{url}"
    end

    let(:expected) do
      ''
    end

    it do
      repl.handle_input(input)
      expect(output.string).to match(/server_facts/)
      expect(output.string).to match(/test/)
      expect(output.string).to match(/Puppet::Type::File/)
    end
  end

  let(:puppet_version) do
    repl.mod_finder.match(repl.puppet_lib_dir)[1]
  end

  let(:manifest_file) do
    file = File.open('/tmp/repl_puppet_manifest.pp', 'w') do |f|
      f.write(manifest_code)
    end
    '/tmp/repl_puppet_manifest.pp'
  end

  let(:manifest_code) do
    <<-EOF
    file{'/tmp/test.txt': ensure => absent } \n
    notify{'hello_there':} \n
    service{'httpd': ensure => running}\n

    EOF
  end

  after(:each) do
    #manifest_file.close
  end

  context '#function_map' do

    it 'should list functions' do
      func = repl.function_map["#{puppet_version}::hiera"]
      expect(repl.function_map).to be_instance_of(Hash)
      expect(func).to eq({:name => 'hiera', :parent => puppet_version})
    end

  end

  it 'should return a puppet version' do
    expect(puppet_version).to match(/puppet-\d\.\d.\d/)
  end

  it 'should return lib dirs' do
    expect(repl.lib_dirs.count).to be >= 1
  end

  it 'should return module dirs' do
    expect(repl.modules_paths.count).to be >= 1
  end

  it 'should return a list of default facts' do
    expect(repl.default_facts.values).to be_instance_of(Hash)
    expect(repl.default_facts.values['fqdn']).to eq('foo.example.com')
  end

  it 'should return a list of facts' do
    expect(repl.node.facts.values).to be_instance_of(Hash)
    expect(repl.node.facts.values['fqdn']).to eq('foo.example.com')
  end

  describe 'convert  url' do

    describe 'unsupported' do
      let(:url) { 'https://bitbuck.com/master/lib/log_helper.rb'}
      let(:converted) { 'https://bitbuck.com/master/lib/log_helper.rb' }
      it do
        expect(repl.convert_to_text(url)).to eq(converted)
      end
    end
    describe 'gitlab' do
      describe 'blob' do
        let(:url) { 'https://gitlab.com/nwops/prepl-web/blob/master/lib/log_helper.rb'}
        let(:converted) { 'https://gitlab.com/nwops/prepl-web/raw/master/lib/log_helper.rb' }
        it do
          expect(repl.convert_to_text(url)).to eq(converted)
        end
      end

      describe 'raw' do
        let(:url) { 'https://gitlab.com/nwops/prepl-web/raw/master/lib/log_helper.rb'}
        let(:converted) { 'https://gitlab.com/nwops/prepl-web/raw/master/lib/log_helper.rb' }
        it do
          expect(repl.convert_to_text(url)).to eq(converted)
        end
      end

      describe 'snippet' do

        describe 'not raw' do
          let(:url) { 'https://gitlab.com/snippets/19471'}
          let(:converted) { 'https://gitlab.com/snippets/19471/raw'}
          it do
            expect(repl.convert_to_text(url)).to eq(converted)
          end
        end

        describe 'raw' do
          let(:url) { 'https://gitlab.com/snippets/19471/raw'}
          let(:converted) { 'https://gitlab.com/snippets/19471/raw'}
          it do
            expect(repl.convert_to_text(url)).to eq(converted)
          end
        end
      end
    end

    describe 'github' do
      describe 'raw' do
        let(:url) { 'https://gist.githubusercontent.com/logicminds/f9b1ac65a3a440d562b0/raw'}
        let(:converted) { 'https://gist.githubusercontent.com/logicminds/f9b1ac65a3a440d562b0/raw' }
        it do
          expect(repl.convert_to_text(url)).to eq(converted)
        end
      end

      describe 'raw gist' do
        let(:url) {'https://gist.githubusercontent.com/logicminds/f9b1ac65a3a440d562b0/raw/c8f6be52da5b2b0eeaabb9aa75832b75793d35d1/controls.pp'}
        let(:converted) {'https://gist.githubusercontent.com/logicminds/f9b1ac65a3a440d562b0/raw/c8f6be52da5b2b0eeaabb9aa75832b75793d35d1/controls.pp'}
        it do
          expect(repl.convert_to_text(url)).to eq(converted)
        end
      end
      describe 'raw non gist' do
        let(:url) { 'https://raw.githubusercontent.com/nwops/puppet-repl/master/lib/puppet-repl.rb'}
        let(:converted) { 'https://raw.githubusercontent.com/nwops/puppet-repl/master/lib/puppet-repl.rb' }
        it do
          expect(repl.convert_to_text(url)).to eq(converted)
        end

      end

      describe 'blob' do
        let(:url) { 'https://github.com/nwops/puppet-repl/blob/master/lib/puppet-repl.rb'}
        let(:converted) { 'https://github.com/nwops/puppet-repl/raw/master/lib/puppet-repl.rb' }
        it do
          expect(repl.convert_to_text(url)).to eq(converted)
        end
      end

      describe 'gist' do
        let(:url) { 'https://gist.github.com/logicminds/f9b1ac65a3a440d562b0'}
        let(:converted) { 'https://gist.github.com/logicminds/f9b1ac65a3a440d562b0.txt' }
        it do
          expect(repl.convert_to_text(url)).to eq(converted)
        end
      end
    end
  end

end
