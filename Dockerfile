# Utilisation de l'image de base Debian pour Home Assistant
FROM homeassistant/amd64-base-debian:latest

# Définition du répertoire de travail
WORKDIR /claptrap

# Ajout d'un argument pour forcer la mise à jour

ARG CACHE_BUST=1

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    wget \
    libbz2-dev \
    portaudio19-dev \
    ffmpeg \
    libsm6 \
    libxext6 \
    libgl1 \
    python3-opencv \
    procps \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Installation de Python 3.10
RUN wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz \
    && tar -xf Python-3.10.13.tgz \
    && cd Python-3.10.13 \
    && ./configure --prefix=/usr/local --enable-optimizations --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib" \
    && make -j $(nproc) \
    && make altinstall \
    && cd .. \
    && rm -rf Python-3.10.13* \
    && python3.10 -m pip install --upgrade pip

# Installation directe des dépendances
RUN pip install --no-cache-dir \
    pytest==7.4.3 \
    pytest-mock==3.12.0 \
    numpy==1.26.3 \
    sounddevice==0.4.6 \
    mediapipe==0.10.8 \
    requests==2.31.0 \
    pyvban \
    scipy==1.11.4 \
    flask \
    flask_socketio \
    ffmpeg \
    psutil

# Copie des fichiers avec vérification
COPY data/ ./data/

# Copie et permissions du script
COPY run.sh .
RUN chmod a+x run.sh

# Exposer le port 6980
EXPOSE 6980

CMD [ "./run.sh" ]