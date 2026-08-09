#!/usr/bin/env bash

# ===============================================================
# run-tests.sh
# Exécute les tests unitaires d'un projet (Angular/npm ou Gradle/Java)
# et génère un rapport JUnit XML dans test-results/<nom-du-projet>/
#
# Usage : ./run-tests.sh <chemin-vers-le-projet>
# Exemple : ./run-tests.sh Angular
# ===============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_PATH="$1"

# --- Vérification des arguments ---
if [ -z "$PROJECT_PATH" ]; then
  echo "Usage: $0 <chemin-vers-le-projet>" >&2
  exit 2
fi

if [ ! -d "$PROJECT_PATH" ]; then
  echo "Erreur: le dossier '$PROJECT_PATH' n'existe pas." >&2
  exit 2
fi

PROJECT_NAME="$(basename "$PROJECT_PATH")"
RESULTS_DIR="$SCRIPT_DIR/test-results/$PROJECT_NAME"

# --- Nettoyage des artefacts de tests précédents ---
echo "Nettoyage des anciens rapports pour '$PROJECT_NAME'..."
rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

cd "$PROJECT_PATH" || exit 2

TEST_EXIT_CODE=0

# --- Détection automatique du type de projet ---
if [ -f "package.json" ]; then
  echo "Type de projet détecté : Angular / npm (frontend)"

  if [ ! -d "node_modules" ]; then
    echo "Erreur: 'node_modules' introuvable. Lancez 'npm ci' avant d'exécuter ce script." >&2
    exit 1
  fi

  rm -rf reports

  npm test
  TEST_EXIT_CODE=$?

  if [ -d "reports" ]; then
    cp reports/*.xml "$RESULTS_DIR/" 2>/dev/null
  else
    echo "Attention: aucun rapport JUnit trouvé dans 'reports/'." >&2
  fi

elif [ -f "build.gradle" ]; then
  echo "Type de projet détecté : Gradle / Java (backend)"

  if [ ! -f "./gradlew" ]; then
    echo "Erreur: 'gradlew' introuvable dans ce projet." >&2
    exit 1
  fi
  chmod +x ./gradlew

  rm -rf build/test-results

  ./gradlew clean test
  TEST_EXIT_CODE=$?

  if [ -d "build/test-results/test" ]; then
    cp build/test-results/test/*.xml "$RESULTS_DIR/" 2>/dev/null
  else
    echo "Attention: aucun rapport JUnit trouvé dans 'build/test-results/test/'." >&2
  fi

else
  echo "Erreur: type de projet non reconnu (ni package.json ni build.gradle trouvé)." >&2
  exit 2
fi

echo "-----------------------------------------"
echo "Rapports copiés dans : $RESULTS_DIR"

if [ "$TEST_EXIT_CODE" -eq 0 ]; then
  echo "✅ Tests réussis"
else
  echo "❌ Tests en échec (code de sortie: $TEST_EXIT_CODE)"
fi

exit "$TEST_EXIT_CODE"