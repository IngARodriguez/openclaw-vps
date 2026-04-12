# OpenClaw VPS — Fase 1

VPS minimalista en Alpine Linux con terminal web.  
El workspace se sincroniza con GitHub como disco persistente.

## Deploy en Railway

1. Sube este repo a GitHub
2. Ve a [railway.app](https://railway.app) → New Project → Deploy from GitHub
3. Selecciona este repo
4. En **Variables**, configura las siguientes:

## Variables de entorno

| Variable | Descripción | Ejemplo |
|---|---|---|
| `GITHUB_USER` | Tu usuario de GitHub | `tuusuario` |
| `GITHUB_TOKEN` | Token con permisos `repo` | `ghp_xxxx` |
| `GITHUB_REPO` | Repo que usarás como disco | `openclaw-workspace` |
| `GIT_USER` | Nombre para commits | `Tu Nombre` |
| `GIT_EMAIL` | Email para commits | `tu@email.com` |
| `TTYD_USER` | Usuario para la terminal web | `admin` |
| `TTYD_PASS` | Contraseña para la terminal web | `tupassword` |

> **GITHUB_TOKEN**: ve a github.com → Settings → Developer settings → Personal access tokens → Tokens (classic) → New token → marca el scope `repo`

## Cómo crear el token de GitHub

1. GitHub → Settings → Developer settings
2. Personal access tokens → Tokens (classic)
3. Generate new token (classic)
4. Scope: marcar **repo** (completo)
5. Copiar el token → pegarlo en Railway como `GITHUB_TOKEN`

## Comandos dentro de la terminal

```bash
save      # guarda todos los cambios en GitHub
sync      # descarga cambios desde GitHub  
gs        # git status
workspace # ir a /root/workspace
```

## Disco persistente

Todo lo que guardes en `/root/workspace` y ejecutes `save`  
quedará en tu repo de GitHub y sobrevivirá reinicios.

## Fase 2 (próximo paso)

Dentro de la terminal, instalaremos OpenClaw manualmente,  
documentaremos todo, y crearemos el Dockerfile definitivo  
que lo instala automáticamente.
