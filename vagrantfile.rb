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
ANSIBLE_INVENTORY = "ansible/inventory"

# Write the inventory file for ansible
FileUtils.mkdir_p dir + ANSIBLE_INVENTORY
File.open(dir + ANSIBLE_INVENTORY + "/hosts", 'w') { |file| file.write("[vagrant]\n" + INSTANCE_IP) }
# Link the ansible playbook
unless File.exist?(dir + "ansible/playbook/vagrant.yml")
	FileUtils.ln_s "../../conf/vagrant.yml", dir + "ansible/playbook/vagrant.yml"
end

# Support project-specific ansible roles
# Loops through local_ansible_roles if it exists and symlinks from ansible/playbook to all folders there.
if File.exist?(dir + "local_ansible_roles")
	Dir.foreach('local_ansible_roles') do |item|
		next if item == '.' or item == '..'
		unless File.exist?(dir + "ansible/playbook/roles/" + item)
			FileUtils.ln_s "../../../local_ansible_roles/" + item, dir + "ansible/playbook/roles"
		end
	end
end

# And never anything below this line
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	########################################
	# Default configuration
	########################################

	config.vm.hostname = INSTANCE_HOSTNAME
	config.vm.box      = "geerlingguy/centos6"

	config.vm.network :private_network, ip: INSTANCE_IP
#	config.ssh.private_key_path = "~/.vagrant.d/insecure_private_key"

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

	########################################
	# Configuration for virtualbox
	########################################

	# config.vm.provider "virtualbox" do |v, override|
	#	override.vm.box_url = "https://www.dropbox.com/s/mo7tjw15z5ep6p6/vb-centos-6.6-x86_64-v0.box?dl=1"
	# end

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

	# config.vm.provider "vmware_fusion" do |v, override|
	#	override.vm.box_url = "https://www.dropbox.com/s/tcp23ka9hlhhsel/vm-centos-6.6-x86_64-v0.box?dl=1"
	# end

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
		ansible.inventory_path = ANSIBLE_INVENTORY
		ansible.extra_vars     = dir + "conf/variables.yml"
		ansible.playbook       = dir + "ansible/playbook/vagrant.yml"
		ansible.limit          = "all"
	end

	config.vm.provision :shell, :path => "ansible/shell/provision.sh"

end
