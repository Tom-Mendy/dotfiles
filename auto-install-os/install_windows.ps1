<#
.SYNOPSIS
    Installe un poste Windows orienté DevOps avec winget.

.DESCRIPTION
    Ce script est conçu pour être exécuté directement depuis GitHub :

        irm https://raw.githubusercontent.com/Tom-Mendy/dotfiles/main/auto-install-os/install_windows.ps1 | iex

    Il ne clone pas le dépôt et n'installe aucun jeu.
#>

$ErrorActionPreference = "Continue"

function Write-Title([string] $Text) {
    Clear-Host
    Write-Host ""
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "  $('-' * $Text.Length)" -ForegroundColor DarkCyan
    Write-Host ""
}

function Ask-YesNo([string] $Question, [bool] $Default = $true) {
    $suffix = if ($Default) { "[O/n]" } else { "[o/N]" }
    $answer = Read-Host "$Question $suffix"
    if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
    return $answer -match '^(o|oui|y|yes)$'
}

function Install-Packages([string] $GroupName, [string[]] $Packages) {
    Write-Host "`n[$GroupName]" -ForegroundColor Yellow

    foreach ($package in $Packages) {
        Write-Host "  -> $package" -ForegroundColor Gray
        & winget install --id $package --exact --source winget `
            --accept-source-agreements --accept-package-agreements `
            --disable-interactivity

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Installation échouée ou ignorée pour $package (code $LASTEXITCODE)."
        }
    }
}

function Install-Codex {
    Write-Host "`n[IA et assistants]" -ForegroundColor Yellow

    Write-Host "  -> Installeur officiel Codex" -ForegroundColor Gray
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://chatgpt.com/codex/install.ps1 | iex"
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Installation de Codex échouée (code $LASTEXITCODE)."
        return
    }

    Write-Host "Codex est installé." -ForegroundColor Green
    if (Ask-YesNo "Lancer la connexion Codex maintenant ?" $true) {
        & codex --login
    }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget est introuvable. Installe ou mets à jour App Installer depuis le Microsoft Store, puis relance ce script." -ForegroundColor Red
    exit 1
}

$catalog = [ordered]@{
    "Outils de base" = @(
        "Microsoft.WindowsTerminal",
        "Microsoft.PowerShell",
        "Git.Git",
        "GitHub.cli",
        "Microsoft.VisualStudioCode",
        "7zip.7zip",
        "JanDeDobbeleer.OhMyPosh"
    )
    "CLI et formats" = @(
        "BurntSushi.ripgrep.MSVC",
        "sharkdp.fd",
        "junegunn.fzf",
        "sharkdp.bat",
        "jqlang.jq",
        "mikefarah.yq"
    )
    "Conteneurs" = @(
        "Docker.DockerDesktop",
        "Microsoft.WSL"
    )
    "Kubernetes" = @(
        "Kubernetes.kubectl",
        "Helm.Helm",
        "derailed.k9s"
    )
    "Infrastructure as code" = @(
        "Hashicorp.Terraform",
        "OpenTofu.OpenTofu"
    )
    "Cloud" = @(
        "Amazon.AWSCLI",
        "Microsoft.AzureCLI",
        "Google.CloudSDK"
    )
    "Langages et outils de build" = @(
        "Python.Python.3.12",
        "OpenJS.NodeJS.LTS",
        "GoLang.Go",
        "Rustlang.Rustup"
    )
    "Java et JVM" = @(
        "EclipseAdoptium.Temurin.21.JDK",
        "Apache.Maven",
        "Gradle.Gradle",
        "EclipseFoundation.EclipseIDE"
    )
    "Éditeurs" = @(
        "ZedIndustries.Zed"
    )
    "IA et assistants" = @()
}

Write-Title "Installation Windows DevOps"
Write-Host "Ce script installe uniquement des outils de travail. Aucun jeu, lanceur ou logiciel de loisir n'est inclus."
Write-Host "Les paquets déjà présents seront ignorés par winget."
Write-Host ""
Write-Host "  1. Base uniquement"
Write-Host "  2. Base + conteneurs"
Write-Host "  3. Poste DevOps complet"
Write-Host "  4. Choisir les groupes"
Write-Host "  Q. Quitter"
Write-Host ""

$selection = (Read-Host "Choisis un profil").Trim().ToUpperInvariant()
$groups = [System.Collections.Generic.List[string]]::new()

switch ($selection) {
    "1" { $groups.Add("Outils de base") }
    "2" {
        $groups.Add("Outils de base")
        $groups.Add("Conteneurs")
    }
    "3" {
        foreach ($name in $catalog.Keys) { $groups.Add($name) }
    }
    "4" {
        foreach ($name in $catalog.Keys) {
            if (Ask-YesNo "Installer le groupe '$name' ?" $true) { $groups.Add($name) }
        }
    }
    default {
        Write-Host "Installation annulée." -ForegroundColor Yellow
        exit 0
    }
}

if ($groups.Count -eq 0) {
    Write-Host "Aucun groupe sélectionné." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Profil sélectionné : $($groups -join ', ')" -ForegroundColor Green
if (-not (Ask-YesNo "Commencer l'installation ?" $true)) {
    Write-Host "Installation annulée." -ForegroundColor Yellow
    exit 0
}

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Warning "PowerShell n'est pas lancé en administrateur. Certains paquets pourront demander une confirmation UAC ou échouer."
}

foreach ($group in $groups) {
    Install-Packages $group $catalog[$group]
    if ($group -eq "IA et assistants") {
        Install-Codex
    }
}

Write-Host ""
Write-Host "Installation terminée." -ForegroundColor Green
Write-Host "Pense à redémarrer Windows, surtout si WSL ou Docker Desktop a été installé."
Write-Host ""
if (Ask-YesNo "Mettre à jour les paquets déjà installés maintenant ?" $false) {
    & winget upgrade --all --source winget --accept-source-agreements --accept-package-agreements --disable-interactivity
}
Read-Host "Appuie sur Entrée pour fermer"
