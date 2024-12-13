# avant execution :  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# executable virtual box
$vboxManagePath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

$vmName = Read-Host "Enter the name for the new virtual machine"

$existingVM = & $vboxManagePath list vms | Select-String -Pattern "$vmName"
if ($existingVM) {
    Write-Host "A VM with the name '$vmName' already exists. Please choose another name."
    exit
}

$osType = "Ubuntu_64" 

# Context VM
$ramSize = 2048   # RAM
$cpuCount = 2      # CPU
$diskSize = 50000  # hard disk (50 GB)
$isoPath = ".\ubuntu-24.04-live-server-amd64.iso"  # Path ISO file 
$vmPath = ".\$vmName"  # Folder to store the VM configuration and disks

if (Test-Path -Path ".\$vmName") {
    Write-Host "Le dossier '$vmName' already exists."
    exit
}
else{
    mkdir $vmName
}


Write-Host "Creating VM '$vmName'..."
& $vboxManagePath createvm --name $vmName --register
& $vboxManagePath modifyvm $vmName --memory $ramSize --cpus $cpuCount --ostype $osType --nic1 nat
& $vboxManagePath createhd --filename "$vmPath\$vmName.vdi" --size $diskSize --format VDI
& $vboxManagePath storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
& $vboxManagePath storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vmPath\$vmName.vdi"
& $vboxManagePath storageattach $vmName --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $isoPath

Write-Host "VM '$vmName' created successfully!"

Write-Host "Starting VM '$vmName'..."
& $vboxManagePath startvm $vmName --type gui
