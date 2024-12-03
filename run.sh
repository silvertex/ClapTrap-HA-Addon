#!/usr/bin/with-contenv bashio

# Définition des couleurs et styles
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Fonction pour les logs
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') ${BOLD}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') ${BOLD}$1${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') ${BOLD}$1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') ${BOLD}$1${NC}"
}

# Vérification de l'environnement
log_info "Vérification de l'environnement..."

# Vérifier le répertoire
if [ ! -d "/claptrap/data" ]; then
    log_error "Répertoire /claptrap/data non trouvé"
    exit 1
fi

# Vérifier Python
if ! command -v python3.10 &> /dev/null; then
    log_error "Python 3.10 n'est pas installé"
    exit 1
fi

# Vérifier la présence du fichier app.py
if [ ! -f "/claptrap/data/app.py" ]; then
    log_error "app.py non trouvé dans /claptrap/data"
    exit 1
fi

# Afficher la version de Python
PYTHON_VERSION=$(python3.10 --version)
log_info "Version Python: $PYTHON_VERSION"

# Vérifier les dépendances Python installées
log_info "Vérification des dépendances Python..."
python3.10 -m pip freeze

# Démarrage de l'application
cd /claptrap/data
log_info "Démarrage de ClapTrap..."
log_info "Répertoire courant: $(pwd)"

# Démarrer l'application avec plus de logs
log_info "Démarrage de l'application Python..."
python3.10 app.py 2>&1 | tee -a /claptrap/data/claptrap.log &
APP_PID=$!

# Attendre que l'application démarre (max 30 secondes)
COUNTER=0
while [ $COUNTER -lt 30 ]; do
    if kill -0 $APP_PID 2>/dev/null; then
        log_success "ClapTrap est en cours d'exécution (PID: $APP_PID)"
        break
    fi
    
    COUNTER=$((COUNTER + 1))
    log_info "En attente du démarrage... ($COUNTER/30)"
    sleep 1
done

if [ $COUNTER -eq 30 ]; then
    log_error "Timeout - L'application n'a pas démarré dans les 30 secondes"
    log_error "Dernières lignes du log:"
    tail -n 20 /claptrap/data/claptrap.log
    kill $APP_PID
    exit 1
fi

# Surveillance continue du processus
while true; do
    if ! kill -0 $APP_PID 2>/dev/null; then
        log_error "L'application s'est arrêtée"
        log_error "Dernières lignes du log:"
        tail -n 20 /claptrap/data/claptrap.log
        exit 1
    fi
    sleep 10
done
