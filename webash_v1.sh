#!/bin/bash

# =================================================================
# TEXT COLORS
# =================================================================
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
BLUE='\033[34m'
NEUTRAL='\033[0m'

# =================================================================
# INITIAL VARIABLES
# =================================================================
current_dir=$(pwd)

# =================================================================
# SCRIPT
# =================================================================

echo -e "${BLUE}  _      __     _               _     ${NEUTRAL}"
echo -e "${BLUE} | | /| / /__  | |__  ___ _ ___| |__  ${NEUTRAL}"
echo -e "${YELLOW} | |/ |/ / _ \/ _  / / _ \` (_-< '_ \  ${NEUTRAL}"
echo -e "${YELLOW} |__/|__/\___/_.__/ /_/\_, /___/_.__/ ${NEUTRAL}"
echo -e "${GREEN}                       /___/          ${NEUTRAL} v1.0"
echo "---------------------------------------------"
echo ""

echo "Scan ..."
echo -e "Répertoire courant : ${BLUE}$current_dir${NEUTRAL}"
echo ""

read -r -p "Saisissez le nom de votre projet web : " project_name
if [ -z "$project_name" ]; then
    project_name="web_project"
fi
echo ""

echo "Démarrage de la génération du projet web ..."
echo ""
if [[ -e "$project_name" ]]; then
    echo -e "${RED}Un dossier existant porte déjà ce nom. Nettoyage...${NEUTRAL}"
    rm -rf "$project_name"
fi

echo -e "Création du projet web ${YELLOW}$project_name${NEUTRAL}..."
mkdir "$project_name"
echo -e "-> ${GREEN}FAIT${NEUTRAL}"
echo ""

echo -e "Création des dossiers ${YELLOW}src${NEUTRAL}, ${YELLOW}assets${NEUTRAL} et ${YELLOW}styles${NEUTRAL}..."
mkdir -p "$project_name"/src "$project_name"/assets "$project_name"/styles
echo -e "-> ${GREEN}FAIT${NEUTRAL}"
echo ""

echo -e "Création et préremplissage du fichier ${YELLOW}index.html${NEUTRAL}..."

cat << EOF > "$project_name"/index.html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$project_name</title>
    <link rel="stylesheet" href="styles/style.css">
</head>
<body>
    <h1>Projet : $project_name</h1>
    <p>Généré avec succès par Webash.</p>
    <script src="src/main.js"></script>
</body>
</html>
EOF

echo -e "-> ${GREEN}FAIT${NEUTRAL}"
echo ""

echo "-----------------------------------------------------------------------"
echo -e "Votre projet ${BLUE}$project_name${NEUTRAL} a été créé avec succès !"
echo "-----------------------------------------------------------------------"
echo ""

if command -v tree &> /dev/null; then
    tree "$project_name"
else
    ls -R "$project_name"
fi
