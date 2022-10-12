# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# VMware ESXi 8.x

# Accept EULA silently
accepteula

# Install on the first available disk
install --firstdisk

# Set root password, either encrypted or unencrypted
rootpw ${admin_password}

# Keyboard
keyboard '${vm_guestos_keyboard}'

# Set network to DHCP
network --bootproto=dhcp --device=vmnic0

# Post-install reboot
reboot

# Firstboot section 1
%firstboot --interpreter=busybox

sleep 30

# Enter Maintenance mode
vim-cmd hostsvc/maintenance_mode_enter

# Enable & start remote ESXi Shell (SSH)
vim-cmd hostsvc/enable_ssh
vim-cmd hostsvc/start_ssh

# Enable & start ESXi Shell (TSM)
vim-cmd hostsvc/enable_esx_shell
vim-cmd hostsvc/start_esx_shell

# Suppress Shell Warning
esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i 1
esxcli system settings advanced set -o /UserVars/ESXiShellTimeOut -i 1

# Enable ESXi vmkernel ports to use MAC ID from vmnic
esxcli system settings advanced set -o /Net/FollowHardwareMac -i 1

# Firstboot Section 2
%firstboot --interpreter=busybox

# Disable IPv6
esxcli network ip set --ipv6-enabled=false

# Disable CEIP
esxcli system settings advanced set -o /UserVars/HostClientCEIPOptIn -i 2

# Exit Maintenance Mode
vim-cmd hostsvc/maintenance_mode_exit

# Reboot
sleep 30
reboot