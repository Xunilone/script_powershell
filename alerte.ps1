# URL du flux RSS des vulnérabilités
$feedUrl = "http://atlasflux.suptribune.org/Outil_RSS_lecture.php?code_id=10583&charge=_us_&urllist=fra_informatique_securite"

# Chemin du fichier où les derniers titres sont stockés
$lastTitlesPath = "C:\Travail\scripts\nouvelle_vulnerabilité.txt" # Assurez-vous que le chemin est correct et que le fichier a l'extension .txt

# Récupère le flux RSS
$response = Invoke-WebRequest -Uri $feedUrl

# Vérifie si la réponse contient du contenu
if (-not $response) {
    Write-Host "Impossible de récupérer le flux RSS."
    exit
}

# Analyse le flux RSS pour extraire les titres des articles
# Assurez-vous que la regex extrait correctement les titres du contenu spécifique de votre flux RSS
$titles = $response.Content | Select-String -Pattern "<title>(.*?)</title>" -AllMatches | ForEach-Object { $_.Matches.Groups[1].Value }

# Lit les derniers titres connus à partir du fichier
$lastTitles = @()
if (Test-Path $lastTitlesPath) {
    $lastTitles = Get-Content $lastTitlesPath
}

# Compare les titres actuels avec les derniers titres connus
$isNewVulnerability = $false
$newTitles = @()
foreach ($title in $titles) {
    if ($title -notin $lastTitles) {
        $isNewVulnerability = $true
        $newTitles += $title
    }
}

if ($isNewVulnerability) {
    # Envoyer une alerte (exemple avec une notification sur le bureau)
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
    [System.Windows.Forms.MessageBox]::Show("Nouvelle(s) vulnérabilité(s) détectée(s): `n" + ($newTitles -join "`n"), "Alerte de Sécurité")

    # Met à jour le fichier avec les nouveaux titres
    $titles | Out-File $lastTitlesPath
} else {
    Write-Host "Aucune nouvelle vulnérabilité détectée."
}