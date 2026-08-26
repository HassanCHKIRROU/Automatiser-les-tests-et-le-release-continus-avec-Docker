# Automatiser les tests et le release Docker:

L'objectif du projet est la conteneurisation, tests automatisés et pipeline CI/CD complet (GitHub Actions) pour deux applications independantes.
- Olympic Participation Tracker dans le dossier Angular/, implémenté avec Angular + Nginx pour le frontend.
- Workshop Organizer API dans le dossier Java/, implémenté avec Spring Boot + PostgreSQL pour le backend.

Chaque application est autonome: elle a son propre Dockerfile, docker-compose.yml et son propre README détaillé.


## Ce que fait le projet:
1- Conteneuriser chaque application dans un image Docker legère (build multi-stage).
2- Teste automatiquement les deux applications à chaque changement de code, grace à un script unique, qui s'adapte au type de projet.
3- Publie des images Docker vérsionnées sur GitHub Container Registry. (ghcr.io).
4- Génère automatiquement des releases GitHub (Changelog + numéro de version) à partir des messages de commit, sans intervention manuelle.

## Démarrage rapide:
Chaque application se lance indépendement avec Docker:

- le frontend est accessible sur http://localhost:2400
1- cd Angular
2- docker compose up -d

-le backend est accessible sur hhtp://localhost:8080
1- cd java
2- docker compose up -d

- Consulter le README de chaque dossier pour plus de détails (variable d'environnement, prérequis..).

## Exécuter les tests:

Un script unique détecte automatiquement le type de projet et lance les bons tests.
- tests Angular (Karma/ Jasmine)
./run-tests.sh Angular

- Tests Java (JUnit via Gradle)
./run-tests.sh Java

Les rapports sont générés au format JUnit XML dans le dossier test-results/<angular ou java>/

## Pipeline CI/CD:
Le fichier .github/workflows/ci.yml  définit trois job qui s'enchainent automatiquement à chaque push: 
 test ->  build  ->  release

 - le job 'test' est déclanché sur main, dev et pull request, permet d'exécuter les tests des deux applications et publie le rapport dans l'interface GitHub.

 - Le jeb 'build' est déclanché sur main et dev (après le succè des tests), permet de construire et pousser les image Docker vers ghcr.io

 - Le job 'release' est déclanché sur mein seulement (après le succè de build), permet de générer une version sémantique et un release GitHub via semantic-release

 ## Convention de commit:
 Le job release s'appuis sur la convention 'Conventional Commits' pour déterminer automatiquement le type de version à publier.
 Exemples:

 - "fix: corriger un bug "  ---> version patch (1.0.0 -> 1.0.1) 
 - "feat: Ajouter une fonctionnalitée"    ---> version minor (1.0.0 -> 1.1.0)
 - "feat!: ....  ou BREAKIN CHANGE:  dans le corps  ---> version major (1.0.0 -> 2.0.0)
 - chore, docs, ci..  ---> pas de nouvelle version

 A chaque release , le pipeline met aussi à jour automatiquement le numéro de version du "package.json" d'Angular et "build.gradle" de Java et tag l'image Docker déjà publiée avec ce meme numéro de version 

 ## Emplacement des livrables: 
   - Image Docker: onglet "Packages" du repo GitHub.
   - Release & Changelog:  onglet "Release" du repo GitHub.
   - historique des executions de pipeline: onglet "Actions" du repo GitHub. 

## La structure du projet:
 pour voir la l'architecture du prjet, cliquer sur le lien ci dessous:

 ![structure de projet](./docs/images/architecture%20p6.PNG)