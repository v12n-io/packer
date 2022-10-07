# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# VMware ESXi 7.x

# Accept EULA silently
accepteula

# Install on the first available disk
install --firstdisk

# Set root password, either encrypted or unencrypted
rootpw ${admin_password}

# Keyboard
keyboardType '${vm_guestos_keyboard}'

# Set network to DHCP
network --bootproto=dhcp --device=vmnic0

# Post-install reboot
reboot

# First boot section
%firstboot --interpreter=busybox
sleep 20
esxcli network vswitch standard uplink add --uplink-name vmnic1 --vswitch-name vSwitch0
esxcli system maintenanceMode set -e true
# Suppress shell warning
esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i 1
# Disable IPv6
esxcli network ip set --ipv6-enabled=false
# Disable CEIP
esxcli system settings advanced set -o /UserVars/HostClientCEIPOptIn -i 2
# Enable ESXi vmkernel ports to use MAC ID from vmnic
esxcli system settings advanced set -o /Net/FollowHardwareMac -i 1
# Enable remote ESXi Shell (SSH)
vim-cmd hostsvc/enable_ssh
vim-cmd hostsvc/start_ssh