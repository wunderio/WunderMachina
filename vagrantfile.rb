require 'yaml'
require File.dirname(__FILE__)+"/dependency_manager/dependency_manager.rb"

Encoding.default_external = 'UTF-8'

dir = File.dirname(__FILE__) + '/../'
# local variables
settings = YAML.load_file dir + 'conf/vagrant_local.yml'

INSTANCE_NAME     = settings['name']
INSTANCE_HOSTNAME = settings['hostname']
INSTANCE_MEM      = settings['mem']
INSTANCE_CPUS     = settings['cpus']
INSTANCE_IP       = settings['ip']
INSTANCE_BOX      = settings['box']
INSTANCE_ALIASES  = settings['aliases']
INSTANCE_VERSION  = settings['box_version']
SSH_FORWARD_AGENT  = settings['ssh_forward_agent']

# vagrant version
Vagrant.require_version ">= 1.9.2"

# Check depedencies during initial setup.
if Dir.glob("#{dir}.vagrant/machines/default/*").empty?

  # Optional depedency check.
  print "Allow vagrant to check for plugin depedencies? (y or n)"
  check_dep = STDIN.gets.chomp

  # Check depedency plugins and automatically install them if needed.
  if check_dep == "y"
    check_plugins ["vagrant-hostmanager", "vagrant-cachier", "vagrant-vbguest"]
  end
end

# And never anything below this line
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	########################################
	# Default configuration
	########################################

	# vagrant-hostmanager
	if Vagrant.has_plugin?("vagrant-hostmanager")
		config.hostmanager.enabled = true
		config.hostmanager.manage_host = true
		config.hostmanager.ignore_private_ip = false
		config.hostmanager.include_offline = true
    if INSTANCE_ALIASES.to_s != ''
      config.hostmanager.aliases = INSTANCE_ALIASES
    end
    config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
      if hostname = (vm.ssh_info && vm.ssh_info[:host])
        `vagrant ssh -c "hostname -I"`.split()[1]
      end
    end
  end

	config.vm.hostname = INSTANCE_HOSTNAME
	config.vm.box      = INSTANCE_BOX

	#Virtualbox has issues with the latest Centos7 box (1.1.4) so we forcing previous version.

	config.vm.provider :virtualbox do |vb|
	  # Set default box version
		if INSTANCE_VERSION.to_s != ''
			config.vm.box_version = INSTANCE_VERSION
		else
			config.vm.box_version = '1.2.0'
		end
	end
  
  if INSTANCE_IP.to_s != ''
	  config.vm.network :private_network, ip: INSTANCE_IP
  else  
	  config.vm.network :private_network, type: "dhcp"
  end

	# Sync folders
	if Gem.win_platform?
		config.vm.synced_folder ".", "/vagrant"
	else
		config.vm.synced_folder ".", "/vagrant", type: :nfs, nfs_udp: false
	end

	# Vagrant cachier
	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.scope = :box
		config.cache.enable :yum
		if Gem.win_platform?
			config.cache.synced_folder_opts = {
				mount_options: ['rw']
			}
		else
			config.cache.synced_folder_opts = {
				type: :nfs,
				nfs_udp: false,
				mount_options: ['rw', 'vers=3', 'tcp', 'nolock', 'actimeo=1']
			}
		end
	end

	# SSH configuration - requires config.ssh.forward_agent: true in vagrant_local.yml
	if SSH_FORWARD_AGENT
	  config.ssh.forward_agent = true
	end

	########################################
	# Configuration for virtualbox
	########################################

	#config.vm.provider "virtualbox" do |v, override|
	#	override.vm.box_url = "https://www.dropbox.com/s/mo7tjw15z5ep6p6/vb-centos-6.6-x86_64-v0.box?dl=1"
	#end

	config.vm.provider :virtualbox do |vb|
		vb.name = INSTANCE_NAME
		if Gem.win_platform?
			version = `"C:/Program Files/Oracle/VirtualBox/VBoxManage.exe" --version`
		else
			version = `VBoxManage --version`
		end
		if version[0] == "5"
			# Set up some VirtualBox 5 specific things
			vb.customize [
				"modifyvm", :id,
				"--memory", INSTANCE_MEM,
				"--cpus", INSTANCE_CPUS,
				"--ioapic", "on",
				"--rtcuseutc", "on",
				"--natdnshostresolver1", "on",
				"--paravirtprovider", "kvm"
			]
		else
			# Other virtualbox versions
			vb.customize [
				"modifyvm", :id,
				"--memory", INSTANCE_MEM,
				"--cpus", INSTANCE_CPUS,
				"--ioapic", "on",
				"--rtcuseutc", "on",
				"--natdnshostresolver1", "on"
			]
		end
	end

	########################################
	# Configuration for vmware_fusion
	########################################

	#config.vm.provider "vmware_fusion" do |v, override|
	#	override.vm.box_url = "https://www.dropbox.com/s/tcp23ka9hlhhsel/vm-centos-6.6-x86_64-v0.box?dl=1"
	#end

	config.vm.provider "vmware_fusion" do |vb|
		vb.name = INSTANCE_NAME
		vb.vmx["memsize"]  = INSTANCE_MEM
		vb.vmx["numvcpus"] = INSTANCE_CPUS
	end

	########################################
	# Provisioning
	########################################

  config.vm.provision "ansible_local" do |ansible|
    #ansible.verbose        = "v"
    ansible.install_mode   = "pip"
    ansible.version        = "2.6.5"
    ansible.extra_vars     = "/vagrant/conf/variables.yml"
    ansible.playbook       = "/vagrant/conf/vagrant.yml"
    ansible.limit          = "all"
  end

end
