# avant execution :  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# executable virtual box
$vboxManagePath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

$vmName = Read-Host "Entrez le nom de la nouvelle machine virtuelle"
$templateName = Read-Host "Entrez le nom du template à cloner"chacha

$templateExists = & $vboxManagePath list vms | Select-String -Pattern $templateName
if (-not $templateExists) {
    Write-Host "Le template '$templateName' n'existe pas. Assurez-vous qu'il est correctement configuré."
    exit
}

#si VM existe déjà
$existingVM = & $vboxManagePath list vms | Select-String -Pattern "$vmName"
if ($existingVM) {
    Write-Host "Une VM avec le nom '$vmName' existe déjà. Veuillez choisir un autre nom."
    exit
}

# Cloner la VM
Write-Host "Clonage de la VM à partir du template '$templateName'..."
& $vboxManagePath clonevm $templateName --name $vmName --register --mode all
Write-Host "Démarrage de la VM '$vmName'..."
& $vboxManagePath startvm $vmName --type gui

Write-Host "La VM '$vmName' a été clonée et démarrée avec succès."
