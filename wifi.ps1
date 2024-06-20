# Author : Xunilone

$retryCount = 0 # Initialiser le compteur de tentatives à 0
$wifiName = "SDIS73.local" # Nom du réseau Wi-Fi auquel se connecter

while($retryCount -lt 3) {
    Start-Sleep -Seconds 5
    # Vérifiez si nous sommes connectés à un réseau Wi-Fi
    $connected = Test-Connection -ComputerName $wifiName -Count 1 -Quiet 

    if($connected) {
        Write-Output "Connecté au Wi-Fi. Fin du script."
        exit
    } else {
        Write-Output "Non connecté au Wi-Fi. Tentative de reconnexion..." 
        $retryCount++ # Incrémenter le compteur de tentatives
        # Attendre un peu avant de réessayer
    }
}

# Si nous sommes ici, cela signifie que nous n'avons pas réussi à nous connecter après 3 tentatives
Write-Output "Non connecté au Wi-Fi après 3 tentatives. Redémarrage de l'ordinateur..."
Restart-Computer -Force
