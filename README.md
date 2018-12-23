Author: Aysad Kozanoglu

## KVM Virtualisation production ready 
supported : Debian Jessie 8.x, ubuntu 16.04, 18.04 

tested on : online.net > pro-6-M dedicated

### see also my CLoud Virutalisation with KVM

https://github.com/AysadKozanoglu/webvirtmgr/wiki


# KVM_Virtualisation
KVM Virtualisation full headless install and guest vm management

## KVM install on ubuntu 16.04
```bash
apt-get install qemu-kvm libvirt-bin virt-manager  virtinst bridge-utils cpu-checker libguestfs-tools libosinfo-bin
```
## KVM install on ubuntu 18.04
```
apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools libosinfo-bin
```

## nameserver for dedicated (if not exists)
```
nameserver 8.8.8.8
nameserver 8.8.4.4
````
## Forwarding network 

#### KVM VNC remote viewer
https://www.realvnc.com/en/connect/download/viewer/linux/

```bash
iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 5900 -j DNAT --to 127.0.0.1:5900
sysctl -w net.ipv4.ip_forward=1
sysctl -p /etc/sysctl.conf 
```

### Forward Ports to guests with Iptables
https://aboullaite.me/kvm-qemo-forward-ports-with-iptables/

#### accepting nat forwarding on nic for vm ip 
do it for every libvirt bridge nat ip that need access incoming request from internet
```bash
iptables -I FORWARD -o virbr0 -d  192.168.122.49 -j ACCEPT
```
- onliner for all ip nat forwarding on nic for all vms
   - ```virsh net-dhcp-leases default | grep 192.168 | awk '{print $5}' | cut -d \/ -f1 | while read ips; do iptables -I FORWARD -o virbr0 -d  $ips -j ACCEPT; done; iptables-save | grep 192.168;```
#### forward specific port to vm
```bash
iptables -t nat -I PREROUTING -p tcp --dport 9867 -j DNAT --to 192.168.122.36:22
```

#### Forwaring all traffic for publich ip alias to vm 
```bash
iptables -t nat -A  PREROUTING -d 212.83.147.148 -j DNAT --to-destination 192.168.122.49
iptables -t nat -A POSTROUTING -s 192.168.122.49 -j SNAT --to-source 212.83.147.148
```
[Redirect all incoming traffic from a secondary public IP to an internal IP address using iptables - Server Fault](https://serverfault.com/questions/627608/redirect-all-incoming-traffic-from-a-secondary-public-ip-to-an-internal-ip-addre/627624)


## VM create 
```bash
Beispiel:
virt-install \
--virt-type=kvm \
--name debian8-11-1 \
--ram 2048 \
--vcpus=2 \
--os-type linux \
--os-variant generic \
--virt-type=kvm \
--hvm \
--cdrom=/var/lib/libvirt/boot/debian-8.11.0-amd64-netinst.iso \
--network=bridge=virbr0,model=virtio \
--graphics vnc \
--disk path=/var/lib/libvirt/images/debian-8-11-1amd64.qcow2,size=40,bus=virtio,format=qcow2
```

#### vm stop delete
```bash
virsh destroy win10-1 && virsh undefine win10-1
```

#### debian jessie :
```bash
virt-install --name debianJessie2 --ram=512 --vcpus=1 --cpu host --disk path=/var/lib/libvirt/images/debianVM2,size=8,bus=virtio,format=qcow2 --cdrom /var/lib/libvirt/boot/debian-8.11.0-amd64-netinst.iso --graphics vnc
```

#### debian jessie with vnc custom port:
```bash
vmname="vm1-debian8"; virt-install --name $vmname --ram=512 --vcpus=1 --cpu host --disk path=/var/lib/libvirt/images/${vmname}.qcow2,size=8,bus=virtio,format=qcow2 --cdrom /var/lib/libvirt/isos/debian-8.11.0-amd64-netinst.iso --graphics=vnc,port=5951,password=!PASSWORD! --network=bridge=virbr0,model=virtio
```
#### install linux without vnc on the console
location parameter is needed  for the console installation 
location links are image repo links from distro images
```
```

#### preseed install debian
```bash
OS="preesed-debian8";
virt-install --connect=qemu:///system --name=${OS} --ram=1024 --vcpus=2 --disk path=/var/lib/libvirt/images/$OS,size=8,bus=virtio,format=qcow2 --initrd-inject=preseed.cfg --location http://ftp.de.debian.org/debian/dists/jessie/main/installer-amd64 --os-type linux --os-variant debian8 --controller usb,model=none --graphics none --noautoconsole --network bridge=virbr0 --extra-args="auto=true hostname="${OS}" domain="vm1.yourserver.com" console=tty0 console=ttyS0,115200n8 serial"
```
#### os variant list --os-variant
```
apt install libosinfo-bin
osinfo-query os
```

####  win10 install:
```bash
virt-install --os-type=windows --os-variant=win8.1 --name win10-9 --ram=2048 --vcpus=1 --cpu host --disk path=/var/lib/libvirt/images/win10-9,size=40,bus=virtio,format=qcow2 --disk /var/lib/libvirt/boot/win1064bit.iso,device=cdrom --disk /var/lib/libvirt/boot/virtIO-drivers.iso,device=cdrom  --graphics=vnc,port=5952,password=!PASSWORD! --check all=off
```
<https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso>
  
[KVM Guest Drivers for Windows project files : KVM Guest Drivers for Windows](https://launchpad.net/kvm-guest-drivers-windows/+download)

## add new nat network

1. #### Create a new libvirt network (other than your default 198.162.x.x) file:
```bash
  $ vim  newnetwork.xml 
  <network>
    <name>newnetwork-1</name>
    <uuid>d0e9964a-f91a-40c0-b769-a609aee41bf2</uuid>
    <forward mode='nat'>
      <nat>
        <port start='1' end='65535'/>
      </nat>
    </forward>
    <bridge name='virbr1' stp='on' delay='0' />
    <mac address='52:54:00:60:f8:6e'/>
    <ip address='192.168.142.1' netmask='255.255.255.0'>
      <dhcp>
        <range start='192.168.142.2' end='192.168.142.254' />
      </dhcp>
    </ip>
  </network>
```

2.  #### Define the above network:
```bash
  $ virsh net-define newnetwork.xml
```

3. #### Start the network and enable it for "autostart"
```bash
  $ virsh net-start newnetwork-1
  $ virsh net-autostart newnetwork-1
```

4. #### List your libvirt networks to see if it reflects:
```bash
  $ virsh net-list
  Name                 State      Autostart     Persistent
  ----------------------------------------------------------
  default              active     yes           yes
  newnetwork-1         active     yes           yes
```

5. #### Optionally, list your bridge devices:
```bash
  $ brctl show
  bridge name     bridge id               STP enabled     interfaces
  virbr0          8000.5254003339b3       yes             virbr0-nic
  virbr1          8000.52540060f86e       yes             virbr1-nic
```
[create-a-new-libvirt-bridge](https://kashyapc.fedorapeople.org/virt/create-a-new-libvirt-bridge.txt)

#### network destroy 
```bash
virsh net-list
virsh net-destroy default
virsh net-undefine default
service libvirtd restart
ifconfig
```
ftp://libvirt.org/libvirt/virshcmdref/html/sect-net-dumpxml.html


### get ip from guest vm
```
virsh net-dhcp-leases default | grep testvm | awk '{ print $5}'
```
```bash
virsh domiflist vm5-debian

Interface  Type       Source     Model       MAC
-------------------------------------------------------
vnet1      network    default    rtl8139     52:54:00:45:87:e6

```
#### get vm ip enstead of MAC list
```bash
arp -e

192.168.122.194          ether   52:54:00:45:87:e6

```
#### oneliner
```bash
 vmname="vm5-debian"; arp -e | grep $(virsh domiflist $vmname| grep vnet | awk '{print $5}') | awk '{print $1}'
```
#### oder anhand ip relase pool anzeigen
```
cat /var/lib/libvirt/dnsmasq/virbr0.status
```

#### Static ip for VM
```bash
virsh  net-edit default
  ...
  <dhcp>
  <range start='192.168.122.100' end='192.168.122.254'/>
  <host mac='52:54:00:6c:3c:01' name='vm1' ip='192.168.122.11'/>
  ...
</dhcp>
```
- reboot the VM or network from vm (ipdown eth0; ifup eth0)
  - if not works than 
    - virsh  net-destroy  $NETWORK_NAME  
    - virsh  net-start    $NETWORK_NAME  
- than restart vm dhcp client
   - if not works than
     - stop the libvirtd service
     - kill any dnsmasq processes that are still alive 
     - start the libvirtd service
- Important: if you change the of an existing static mac ip assign rule (<network>.xml) 
     - then you to redefine the bridge 
     - create accepting nat forwarding on nic for vm ips again
     - restart the vm(s)
     - ```virsh net-destroy default && virsh net-undefine default && virsh net-define /etc/libvirt/networks/default.xml && virsh net-start default && virsh net-autostart default; /etc/init.d/libvirt-bin restart; COMMAND=shutdown; virsh list | grep vm | awk '{print $2}' | while read vmname; do virsh $COMMAND $vmname; sleep 3; done; watch 'virsh list'; COMMAND=start; virsh list --all | grep vm | awk '{print $2}' | while read vmname; do virsh $COMMAND $vmname; sleep 3; done; watch 'virsh list' ```
  
#### Stop & start all vms oneliner
```bash
# shutdown
COMMAND=shutdown; virsh list | grep vm | awk '{print $2}' | while read vmname; do virsh $COMMAND $vmname; sleep 3; done; watch 'virsh list'

#start
COMMAND=start; virsh list --all | grep vm | awk '{print $2}' | while read vmname; do virsh $COMMAND $vmname; sleep 3; done; watch 'virsh list'
```

## reset forgotten root password for Linux KVM qcow2 image/vm
```bash
apt install libguestfs-tools
virsh shutdown < vmname >
virsh dumpxml debian9-vm1 | grep 'source file'
   ...
   <source file='/var/lib/libvirt/images/debian9-vm1.qcow2'/>
   ...

openssl passwd -1 newrootPassword

guestfish --rw -a /var/lib/libvirt/images/debian9-vm1.qcow2

><fs>
>launch
>list-filesystems
>mount /dev/sda1 /
>vi /etc/shadow
>flush
>quit
```

#### snapshot create & manage
```bash
virsh snapshot-create-as --domain vm-d8 --name vm-d8-snap --description "jessie base"

virsh snapshot-list vm-d8

virsh snapshot-revert webserver vm-d8-snap

virsh snapshot-delete --domain vm-d8 --snapshotname vm-d8-snap
```

#### RAM increasing
```bash
virsh shutdown <vm name>
virsh setmaxmem <vm name> 16G --config
virsh setmem <vm name> 16G --config
```

#### CPU increasing
```bash
virsh edit <vm name>
<vcpu placement='stait  virsh vcpuinfoc'>6</vcpu>
virsh vcpuinfo <vm name>
```
#### CPU increasing
```bash
virsh edit <vm name>
<vcpu placement='stait  virsh vcpuinfoc'>6</vcpu>
virsh vcpuinfo <vm name>
```

### vm disk increasing /resize
 #### on the kvm
```bash
# show current info of vm disk
virsh domblklist <vm name> --details
qemu-img resize /var/lib/libvirt/images/VM-Name +4G
fdisk -l /var/lib/libvirt/images/VM-Name
```
 #### on the vm
  ```
  # on the VM 
  roo@vm:/ fdisk -l /dev/vda

  Command (m for help): p
  Device     Boot    Start      End  Sectors Size Id Type
/dev/vda1  *        2048 33554432 33552385  16G 83 Linux

  Command (m for help): d
  [1,2.5]: 1
  #  swap auch löschen und danach mit p wieder erstellen, nachdem primary ext partition erstellt wurde(start und end sector per default übernehmen)
  Command (m for help): d 
  [1,2.5]: 2
  Command (m for help): n
  [primary ,extend]: p
  partition number: 1
  # WICHTIG: start sector von oben entnehmen !!
  Command (m for help): t
  # ext4
  type: 83
Command (m for help): n
  [primary ,extend]: p
  partition number: 2
# start und endsector per default übernehmen 
   Command (m for help): w
  roo@vm:/ resize2fs /dev/sda1 
  roo@vm:/ reboot 
  ```
```
