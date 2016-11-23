require 'yaml'

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
SSH_FORWARD_AGENT  = settings['config.ssh.forward_agent']

# Link the ansible playbook
unless File.exist?(dir + "ansible/playbook/vagrant.yml")
	FileUtils.ln_s "../../conf/vagrant.yml", dir + "ansible/playbook/vagrant.yml"
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
  end

	config.vm.hostname = INSTANCE_HOSTNAME
	config.vm.box      = INSTANCE_BOX

	#Virtualbox has issues with the latest Centos7 box (1.1.4) so we forcing previous version.

	config.vm.provider :virtualbox do |vb|
	  # Set default box version
		if INSTANCE_VERSION.to_s != ''
			config.vm.box_version = INSTANCE_VERSION
		else
			config.vm.box_version = '1.1.3'
		end
	end

	config.vm.network :private_network, ip: INSTANCE_IP

	# Sync folders
	config.vm.synced_folder ".", "/vagrant", type: :nfs

	# Vagrant cachier
	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.scope = :box
		config.cache.enable :yum
		config.cache.synced_folder_opts = {
			type: :nfs,
			mount_options: ['rw', 'vers=3', 'tcp', 'nolock', 'actimeo=1']
		}
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
		version = `VBoxManage --version`
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

	config.vm.provision "ansible" do |ansible|
		#ansible.verbose        = "v"
    ansible.extra_vars     = dir + "conf/variables.yml"
		ansible.playbook       = dir + "ansible/playbook/vagrant.yml"
		ansible.limit          = "all"
	end

end
