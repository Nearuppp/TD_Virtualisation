# avant execution :  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# executable virtual box
$vboxManagePath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# Fonction ISO
function Create-VM-FromISO {
    $vmName = Read-Host "Entrez le nom de la nouvelle machine virtuelle"

    # Vérifier si la VM existe déjà
    $existingVM = & $vboxManagePath list vms | Select-String -Pattern "$vmName"
    if ($existingVM) {
        Write-Host "Une VM avec le nom '$vmName' existe déjà. Veuillez choisir un autre nom."
        exit
    }

    # Context VM
    $osType = "Ubuntu_64"  # OS
    $ramSize = 2048        # RAM
    $cpuCount = 2          # CPU
    $diskSize = 50000      # Taille du disque Mo
    $isoPath = ".\ubuntu-24.04-live-server-amd64.iso"  # ISO
    $vmPath = ".\$vmName"  # Dossier 

    if (Test-Path -Path ".\$vmName") {
        Write-Host "Le dossier '$vmName' existe déjà."
        exit
    }
    else {
        mkdir $vmName
    }

    Write-Host "Création de la VM '$vmName'..."
    & $vboxManagePath createvm --name $vmName --register
    & $vboxManagePath modifyvm $vmName --memory $ramSize --cpus $cpuCount --ostype $osType --nic1 nat
    & $vboxManagePath createhd --filename "$vmPath\$vmName.vdi" --size $diskSize --format VDI
    & $vboxManagePath storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
    & $vboxManagePath storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vmPath\$vmName.vdi"
    & $vboxManagePath storageattach $vmName --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium $isoPath

    Write-Host "VM '$vmName' créée avec succès!"

    Write-Host "Démarrage de la VM '$vmName'..."
    & $vboxManagePath startvm $vmName --type gui
}

# Fonction template
function Clone-VM-FromTemplate {
    $templateVMs = & $vboxManagePath list vms | ForEach-Object { ($_ -split '"')[1] }
    $templateName = $templateVMs | Out-GridView -Title "Sélectionnez un template à cloner" -PassThru

    if (-not $templateName) {
        Write-Host "Aucun template sélectionné. Fermeture du script."
        exit
    }

    $vmName = Read-Host "Entrez le nom de la nouvelle machine virtuelle"

    $existingVM = & $vboxManagePath list vms | Select-String -Pattern "$vmName"
    if ($existingVM) {
        Write-Host "Une VM avec le nom '$vmName' existe déjà. Veuillez choisir un autre nom."
        exit
    }

    Write-Host "Clonage de la VM à partir du template '$templateName'..."
    & $vboxManagePath clonevm $templateName --name $vmName --register --mode all

    Write-Host "Démarrage de la VM '$vmName'..."
    & $vboxManagePath startvm $vmName --type gui

    Write-Host "La VM '$vmName' a été clonée et démarrée avec succès."
}

$choices = @(
    "Creer une VM a partir d'un ISO",
    "Cloner ou importer une VM a partir d'un template"
)

# Utiliser Out-GridView pour l'interface graphique de sélection
$choice = $choices | Out-GridView -Title "Selectionnez une option" -PassThru

switch ($choice) {
    "Creer une VM a partir d'un ISO" {
        Create-VM-FromISO
        break
    }
    "Cloner ou importer une VM a partir d'un template" {
        Clone-VM-FromTemplate
        break
    }
    default {
        Write-Host "Aucune option valide selectionnee. Fe   rmeture du script."
        exit
    }
}