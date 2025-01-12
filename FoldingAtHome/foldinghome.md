Ubuntu 18.04 Server LTS Cheat-Sheet

#Get PPA repo
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update

#check recommended driver versions;
sudo apt install ubuntu-drivers-common
ubuntu-drivers devices
         OR: lshw -numeric -C display

#aptitude handles the nvidia-driver dependencies much smoother
sudo apt install aptitude

#install drivers
sudo aptitude install nvidia-driver-415

#install OpenCL
sudo apt install ocl-icd-opencl-dev

sudo reboot 

#verify Graphics cards are showing
nvidia-smi

#install FAH

wget no-check-certificate https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.5/fahclient_7.5.1_amd64.deb

sudo dpkg -i force-depends fahclient_7.5.1_amd64.deb

sudo /etc/init.d/FAHClient stop

#configure FAH
sudo nano /etc/fahclient/config.xml
```
<config>
  <!-- Remote Command Server -->
  <allow v='192.168.1.0/24'/>
  <password v='password'/>

  <!-- Client Control -->
  <checkpoint v='30'/>

  <!-- Folding Slot Configuration -->
  <cause v='ALZHEIMERS'/>

  <!-- Slot Control -->
  <power v='full'/>

  <!-- User Information -->
  <passkey v='passkey'/>
  <team v='224497'/>
  <user v='username_ALL_BTCwallet'/>

  <!-- Work Unit Control -->
  <next-unit-percentage v='100'/>

  <!-- Folding Slots -->
  <slot id='0' type='GPU'/>
  </slot>
  <slot id='1' type='GPU'/>
  </slot>
  <slot id='2' type='GPU'/>
  </slot>
  <slot id='3' type='GPU'/>
  </slot>
</config>
```
sudo /etc/init.d/FAHClient start
