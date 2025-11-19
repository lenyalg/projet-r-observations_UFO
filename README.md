# Projet R - Analyse des Observations d'OVNIs

Projet réalisé dans le cadre du cours de R-Data-Viz (DaMS3) à Polytech Montpellier.

## Membres du Groupe

* ALGUAZIL Lény
* HELLI Massyl
* MIEVRE Kevin
* SOULARD Lény

## Description

Cette application Shiny permet une analyse interactive du jeu de données Kaggle sur les observations d'OVNIs (UFO Sightings). Elle explore les tendances spatiales, temporelles et les caractéristiques des observations.

## Comment Lancer l'Application

Ce projet utilise `renv` pour la gestion des dépendances.

1.  **Cloner le dépôt :**
    ```bash
    git clone https://github.com/lenyalg/projet-r-observations_UFO
    cd projet-r-observations_UFO
    ```
2. **Préparez le dossier de données :**

   Créez un sous-dossier nommé `data` à l'intérieur du répertoire `projet-r-observations_UFO`.

3. **Ajoutez le jeu de données :**

      Téléchargez le fichier `complete.csv` depuis l'URL : URL
      Placez ce fichier téléchargé dans le nouveau dossier `data`, en vous assurant qu'il porte bien le nom `complete.csv`.

4.  **Installer les dépendances (avec `renv`) :**
    Ouvrez `projet-r.Rproj` dans RStudio. Le projet devrait automatiquement vous proposer d'installer les dépendances via `renv`.
    Sinon, lancez dans la console R :
    ```R
    renv::restore()
    ```

5.  **Lancer l'application :**
    Ouvrez le fichier `app.R` et cliquez sur "Run App" dans RStudio.
