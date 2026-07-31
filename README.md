# Contribia Teleprompter — App Flutter (nativa Android)

App nativa de teleprompter para grabación de videos, hecha con Flutter.
Usa la cámara nativa de Android (`camera` package → Camera2 API), por lo
que la calidad de video es la real del teléfono, no la limitada de una PWA.

El ícono de la app usa tu logo real de Contribia (adaptive icon + ícono
estándar en todas las densidades).

## Funciones incluidas

- Lista de guiones guardados (SQLite) + crear / editar / eliminar
- Editor de guion con contador de palabras, tiempo estimado, resaltar
  palabra (`*palabra*`) e insertar pausa (`[pausa]`)
- **✨ Modo IA** (heurísticas locales, sin conexión): corregir ortografía,
  más natural, más profesional, más persuasivo, más corto/largo, y
  cambio de tono (Formal, Amigable, Didáctico, Vendedor, YouTube, TikTok,
  Instagram, Facebook)
- **Resaltado inteligente** en pantalla de grabación: números, porcentajes,
  fechas, valores monetarios y leyes/artículos se resaltan con color
  automáticamente mientras lees; activable/desactivable por tipo en Ajustes
- Pantalla de grabación: cámara de fondo + texto de teleprompter encima,
  scroll automático, control de velocidad, tamaño de letra, modo espejo,
  cronómetro, indicador REC, mantener pantalla encendida
- Guarda el video en una biblioteca dentro de la app (renombrar, compartir
  a tu galería/WhatsApp/Drive con el botón "Compartir", eliminar)
- **Pantalla de Configuración**: modo oscuro/claro, velocidad por defecto,
  y toggles de resaltado inteligente

*Pendiente para una siguiente iteración: plantillas tributarias
predefinidas de Contribia (RUC, IVA, retenciones, declaraciones), pantalla
de splash con el logo animado, sincronización en la nube.*

## Nota de la versión: se quitó el guardado automático a galería

La primera versión intentaba guardar el video automáticamente en la
galería del teléfono con el paquete `gal`, pero ese plugin usa una
configuración de Gradle antigua que falla al compilar con las versiones
recientes de Flutter/Android (error típico: *"Could not get unknown
property 'flutter'..."* en `:gal`). Para no depender de un plugin frágil,
ahora el video se guarda en la biblioteca interna de la app y el usuario
lo envía a su galería/WhatsApp/Drive con el botón **"Compartir"**
(usa `share_plus`, que sí es estable). Si más adelante quieres guardado
automático a galería, se puede retomar con un plugin distinto.

## Cómo obtener el APK (sin instalar nada en tu PC)

Vas a usar **GitHub Actions**, que compila el APK gratis en la nube. Son
tres pasos:

### 1. Sube este proyecto a GitHub

1. Crea una cuenta en [github.com](https://github.com) si no tienes.
2. Crea un repositorio nuevo (puede ser privado), por ejemplo
   `contribia-teleprompter-app`.
3. Sube **todo el contenido de esta carpeta** (`contribia_teleprompter_flutter/`)
   a la raíz de ese repositorio. Puedes hacerlo:
   - Arrastrando los archivos en la web de GitHub ("Add file" → "Upload files"), o
   - Con Git desde la terminal:
     ```
     git init
     git add .
     git commit -m "Contribia Teleprompter - primera versión"
     git branch -M main
     git remote add origin https://github.com/TU-USUARIO/contribia-teleprompter-app.git
     git push -u origin main
     ```

### 2. Deja que GitHub Actions compile el APK

En cuanto subas el código a la rama `main`, el workflow
`.github/workflows/build-apk.yml` se activa automáticamente. Si quieres
lanzarlo manualmente:

1. Entra a tu repositorio en GitHub.
2. Ve a la pestaña **Actions**.
3. Elige el workflow **"Build APK"** → botón **"Run workflow"**.

Tarda entre 4 y 8 minutos.

### 3. Descarga el APK

1. Cuando el workflow termine (ícono verde ✓), entra a esa ejecución.
2. Baja hasta la sección **Artifacts**.
3. Descarga **contribia-teleprompter-apk** (es un .zip que contiene el
   `app-release.apk`).
4. Pasa el APK a tu celular Android (por USB, Drive, WhatsApp, etc.) y
   ábrelo para instalarlo. Android pedirá permitir "instalar apps de
   fuentes desconocidas" la primera vez — es normal porque no viene de
   Play Store.

## Estructura del proyecto

```
lib/
  main.dart                  → punto de entrada
  theme.dart                 → colores/tema Contribia
  models/script_model.dart   → modelos ScriptModel y VideoModel
  services/
    database_service.dart    → SQLite (guiones y videos)
    settings_service.dart    → preferencias (velocidad, tamaño, tema)
  screens/
    home_screen.dart         → lista de guiones
    editor_screen.dart       → editor de guion
    record_screen.dart       → cámara + teleprompter + grabación
    video_library_screen.dart→ biblioteca de videos grabados
android_config/AndroidManifest.xml → permisos (cámara, mic, etc.)
android_config/res/                → ícono real de Contribia (launcher + adaptive icon)
assets/images/contribia_logo.png   → logo mostrado dentro de la app
.github/workflows/build-apk.yml    → build automático en la nube
```

## Nota sobre la carpeta `android/`

Esta carpeta **no viene incluida** en el proyecto (Flutter la genera
automáticamente). El workflow de GitHub Actions la crea solo la primera
vez que corre (`flutter create --platforms=android .`) y le aplica los
permisos de `android_config/AndroidManifest.xml`. No necesitas hacer
nada manual para esto.

## Siguiente paso sugerido

Una vez que confirmes que el APK instala, muestra el logo de Contribia
como ícono, y graba correctamente, dime y agregamos: plantillas
tributarias predefinidas (RUC, IVA, retenciones, declaraciones), pantalla
de bienvenida (splash) con el logo, y biblioteca de videos con
miniaturas.
