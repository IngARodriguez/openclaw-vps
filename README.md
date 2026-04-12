# 🦞 OpenClaw VPS

> Tu agente de IA autónomo en la nube — gratis, listo en 30 segundos.

VPS basado en Ubuntu corriendo en Railway con OpenClaw y Claude Code preinstalados. Controla tu agente desde Telegram, programa desde el navegador y deploya proyectos a GitHub y Vercel sin tocar tu computador.

---

## ¿Qué es OpenClaw?

OpenClaw es un agente de IA autónomo de código abierto. Vive en tu servidor, está conectado a tus cuentas y puede ejecutar tareas solo — sin que estés presente. Lo controlas desde Telegram como si fuera un asistente personal.

**Qué puede hacer:**
- Responder preguntas y buscar en la web
- Crear y subir archivos a GitHub
- Ejecutar comandos en la terminal
- Deployar proyectos en Vercel
- Enviar notificaciones y reportes
- Programar tareas automáticas (cron jobs)

**Modelo:** Gemini 2.0 Flash via OpenRouter — gratuito, rápido, con 1M de contexto.

---

## ¿Qué es Claude Code?

Claude Code es el agente de programación de Anthropic. Corre directamente en la terminal del VPS con acceso completo al sistema de archivos, la terminal y las herramientas instaladas.

**Qué puede hacer:**
- Crear proyectos completos desde cero
- Leer, editar y refactorizar código
- Ejecutar comandos, tests y scripts
- Hacer commits y push a GitHub
- Deployar en Vercel con un solo comando
- Resolver bugs de forma autónoma

**Modelo:** Claude Sonnet 4.6 — requiere suscripción Anthropic Pro (sin costo extra).

---

## Herramientas incluidas

| Herramienta | Para qué sirve |
|---|---|
| **OpenClaw** | Agente autónomo controlable por Telegram |
| **Claude Code** | Programación avanzada desde la terminal web |
| **GitHub CLI** | Crear repos, hacer commits, gestionar código |
| **Vercel CLI** | Deployar páginas y apps instantáneamente |
| **ttyd + tmux** | Terminal web persistente desde cualquier navegador |
| **Workspace → GitHub** | Todo lo que crees se sincroniza automáticamente |

---

## Deploy en Railway

1. Ve a [railway.app](https://railway.app) → **New Project** → **Deploy a Docker Image**
2. Imagen: `ingarodriguez/openclaw-vps:latest`
3. En **Variables** agrega las variables de abajo
4. En **Settings → Networking** genera un dominio público
5. Listo — tu agente está corriendo

---

## Variables de entorno

### Requeridas

| Variable | Descripción | Cómo obtenerla |
|---|---|---|
| `OPENROUTER_API_KEY` | Key de OpenRouter (`sk-or-...`) | [openrouter.ai](https://openrouter.ai) → Keys |
| `TELEGRAM_BOT_TOKEN` | Token del bot de Telegram | [@BotFather](https://t.me/BotFather) → /newbot |
| `GITHUB_USER` | Tu usuario de GitHub | Tu perfil de GitHub |
| `GITHUB_TOKEN` | Token con scope `repo` y `workflow` | GitHub → Settings → Developer settings → Tokens |
| `GITHUB_REPO` | Repo que usarás como disco persistente | Crea un repo vacío, ej: `openclaw-workspace` |
| `GIT_USER` | Nombre para los commits | El que prefieras |
| `GIT_EMAIL` | Email para los commits | Tu email de GitHub |
| `TTYD_USER` | Usuario para la terminal web | El que prefieras |
| `TTYD_PASS` | Contraseña para la terminal web | La que prefieras |

### Opcionales

| Variable | Descripción | Cómo obtenerla |
|---|---|---|
| `VERCEL_TOKEN` | Vercel autenticado automáticamente al arrancar | [vercel.com](https://vercel.com) → Settings → Tokens |
| `ANTHROPIC_API_KEY` | Claude Code sin login interactivo | [console.anthropic.com](https://console.anthropic.com) |

---

## Cómo acceder

### Terminal web
```
https://TTYD_USER:TTYD_PASS@tu-url.up.railway.app
```

La terminal usa tmux — si cierras el navegador y vuelves a entrar, la sesión sigue exactamente donde la dejaste.

### Bot de Telegram
Busca tu bot y escríbele. La primera vez te pedirá un código de pairing — apruébalo desde la terminal:
```bash
openclaw pairing approve telegram XXXXXXXX
```

---

## Primer uso

### Paso 1 — Activar Claude Code
Abre la terminal web y ejecuta:
```bash
claude
```
Te dará un link de autenticación. Ábrelo en el navegador, inicia sesión con tu cuenta de Anthropic y listo. Guarda las credenciales para que sobrevivan reinicios:
```bash
cp -r ~/.claude ~/workspace/.claude-auth && save
```

### Paso 2 — Usar OpenClaw desde Telegram
Escríbele a tu bot en Telegram. Algunos ejemplos:
```
crea una landing page para mi startup y deployala en Vercel
busca las últimas noticias de IA y resúmelas
revisa mi repo de GitHub y encuentra bugs en el código
crea una API REST en Node.js y súbela a GitHub
```

### Paso 3 — Usar Claude Code desde la terminal
```bash
claude
> crea un proyecto Next.js, conéctalo a Supabase y deployalo en Vercel
```

---

## Comandos en la terminal

```bash
save      # guarda todos los cambios en GitHub
sync      # descarga cambios desde GitHub
claw      # reinicia el gateway de OpenClaw
logs      # ver logs en tiempo real de OpenClaw
gs        # git status del workspace
claude    # abrir Claude Code
ll        # listar archivos
```

---

## Arquitectura

```
Telegram
    ↓
OpenClaw (Gemini 2.0 Flash)
    ↓
/home/claw/workspace ←→ Claude Code (Sonnet 4.6)
    ↓
GitHub repo
    ↓
Vercel / Railway
```

Todo lo que OpenClaw o Claude Code creen va a `/home/claw/workspace`. Con `save` se sube a GitHub y desde ahí puedes deployar donde quieras.

---

## Stack y costos

| Servicio | Plan | Costo |
|---|---|---|
| Railway | Free (0.5 GB RAM / 1 vCPU) | $0 |
| OpenRouter | Free (50 req/día) | $0 |
| GitHub | Free | $0 |
| Vercel | Free (hobby) | $0 |
| Claude Code | Incluido en Pro | $0 extra |
| **Total** | | **$0/mes** |

---

## Notas importantes

- **OpenRouter free**: 50 requests/día. Con $10 de crédito sube a 1000/día permanentemente.
- **Sin disco persistente en Railway**: todo se guarda en GitHub via `save`. No se pierde nada al reiniciar.
- **iOS**: la terminal web no funciona bien en Safari/iOS. Usa Telegram como interfaz principal en móvil.
- **Claude Code**: requiere login manual la primera vez. Guarda las credenciales con el comando del Paso 1.
