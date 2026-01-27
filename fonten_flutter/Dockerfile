# fonten_flutter/Dockerfile

# ETAPA 1: Compilación (Usamos una imagen con Flutter preinstalado para ganar velocidad)
FROM debian:stable-slim AS build-env

# Instalación de dependencias básicas del sistema
RUN apt-get update && apt-get install -y curl git unzip

# Clonamos Flutter estable
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
# <!> Esto no se para que es 
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
# Compilamos el codigo web
RUN flutter build web --release


# Servidor Web liviano
FROM nginx:alpine



# CONFIGURACIÓN SPA: Evita errores 404 al recargar rutas de la app

# Configuración de Nginx optimizada para velocidad y SPA
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    # Habilitar compresión Gzip interna \
    gzip on; \
    gzip_types text/plain application/javascript application/x-javascript text/javascript text/xml text/css; \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
        # Evitar que el navegador cachee el index.html para ver actualizaciones diarias \
        add_header Cache-Control "no-store, no-cache, must-revalidate"; \
    } \
    \
    # Cachear assets estáticos (imágenes, fuentes) por 1 mes para que no pesen en la recarga \
    location ~* \.(?:ico|css|js|gif|jpe?g|png|woff2?|eot|otf|ttf|svg)$ { \
        expires 30d; \
        add_header Cache-Control "public"; \
    } \
}' > /etc/nginx/conf.d/default.conf


# <!> Esto parese que no va el de arriba parese funcionar bien 
# Comando anterior 
# RUN echo 'server { \
#     listen 80; \
#     server_name localhost; \
#     root /usr/share/nginx/html; \
#     index index.html; \
#     location / { \
#         try_files $uri $uri/ /index.html; \
#     } \
# }' > /etc/nginx/conf.d/default.conf



# Copiamos los archivos generados por Flutter a la carpeta de Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html


# --- LA SOLUCIÓN NUCLEAR ---
# Borramos el service worker para que el navegador no cachee versiones viejas
RUN echo "" > /usr/share/nginx/html/flutter_service_worker.js
# Comando anterior <!> Porque es diferente a el de arriba 
# RUN rm -f /usr/share/nginx/html/flutter_service_worker.js


# Exponemos el puerto 80 interno del contenedor
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]