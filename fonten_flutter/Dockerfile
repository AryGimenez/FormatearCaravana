# fonten_flutter/Dockerfile

# ETAPA 1: Compilación (Usamos una imagen con Flutter preinstalado para ganar velocidad)
FROM debian:stable-slim AS build-env

# Instalación de dependencias básicas del sistema
RUN apt-get update && apt-get install -y curl git unzip

# Clonamos Flutter estable
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configurar Flutter para wcd eb
RUN flutter config --enable-web
# Pre-descarga de binarios de Flutter
RUN flutter doctor 


# Nos movemos a la carpeta de trabajo
WORKDIR /app

# Copiamos solo los archivos de dependencias
COPY pubspec.yaml pubspec.lock ./

# Obtenemos paquetes y buildeamos para web
RUN flutter pub get


# Copiamos el resto del codiog 
COPY . . 
RUN flutter build web --release

# ETAPA 2: Servidor Web liviano
FROM nginx:alpine



# CONFIGURACIÓN SPA: Evita errores 404 al recargar rutas de la app
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf



# Copiamos los archivos generados por Flutter a la carpeta de Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Exponemos el puerto 80 interno del contenedor
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]