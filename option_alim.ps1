Write-Host "A partir de combien de temps voulez-vous que l'écran se mette en veille ?"
$tempsVeille = Read-Host "Entrez le temps en minutes"
powercfg /change monitor-timeout-ac $tempsVeille
Write-Host "Le temps de veille de l'écran a été modifié à $tempsVeille minutes."