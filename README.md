# 🦞 OpenClaw VPS

> Tu agente de IA autónomo en la nube — gratis, listo en 30 segundos.

VPS minimalista basado en Ubuntu corriendo en Railway con **OpenClaw** preinstalado y configurado. Controla tu agente desde Telegram, programa con **Claude Code** desde el navegador, y deploya proyectos a GitHub y Vercel sin tocar tu computador.

---

## ¿Qué incluye?

| Herramienta | Para qué sirve |
|---|---|
| **OpenClaw** | Agente de IA autónomo controlable por Telegram |
| **Claude Code** | Programación avanzada desde la terminal web |
| **Gemini 2.0 Flash** | Modelo de IA gratuito via OpenRouter |
| **GitHub CLI** | Crear repos, hacer commits, gestionar código |
| **Vercel CLI** | Deployar páginas y apps instantáneamente |
| **ttyd** | Terminal web accesible desde cualquier navegador |
| **Workspace → GitHub** | Todo lo que crees se sincroniza automáticamente |

---

## Deploy en Railway

1. Haz fork de este repo
2. Ve a [railway.app](https://railway.app) → **New Project** → **Deploy a Docker Image**
3. Imagen: `ingarodriguez/openclaw-vps:latest`
4. En **Variables** agrega las variables de abajo
5. En **Settings → Networking** genera un dominio público
6. Listo — tu agente está corriendo

---

## Variables de entorno

### Requeridas

| Variable | Descripción | Cómo obtenerla |
|---|---|---|
| `OPENROUTER_API_KEY` | Key de OpenRouter (`sk-or-...`) | [openrouter.ai](https://openrouter.ai) → Keys |
| `TELEGRAM_BOT_TOKEN` | Token del bot de Telegram | [@BotFather](https://t.me/BotFather) → /newbot |
| `GITHUB_USER` | Tu usuario de GitHub | Tu perfil de GitHub |
| `GITHUB_TOKEN` | Token GitHub con scope `repo` y `workflow` | GitHub → Settings → Developer settings → Tokens |
| `GITHUB_REPO` | Repo que usarás como disco persistente | Crea un repo vacío ej: `openclaw-workspace` |
| `GIT_USER` | Nombre para los commits | El que prefieras |
| `GIT_EMAIL` | Email para los commits | Tu email de GitHub |
| `TTYD_USER` | Usuario para entrar a la terminal web | El que prefieras |
| `TTYD_PASS` | Contraseña para entrar a la terminal web | La que prefieras |

### Opcionales

| Variable | Descripción | Cómo obtenerla |
|---|---|---|
| `VERCEL_TOKEN` | Para que Vercel quede autenticado automáticamente | [vercel.com](https://vercel.com) → Settings → Tokens |
| `ANTHROPIC_API_KEY` | Para usar Claude Code con API key en vez de login | [console.anthropic.com](https://console.anthropic.com) |

---

## Cómo acceder

### Terminal web
Abre en el navegador:
```
https://TTYD_USER:TTYD_PASS@tu-url.up.railway.app
```

### Bot de Telegram
Busca tu bot en Telegram y escríbele. La primera vez te pedirá un código de pairing — apruébalo desde la terminal con:
```bash
openclaw pairing approve telegram XXXXXXXX
```

---

## Primer uso

### 1 — Activar Claude Code
Abre la terminal web y ejecuta:
```bash
claude
```
Te dará un link. Ábrelo en el navegador, inicia sesión con tu cuenta de Anthropic y listo — Claude Code queda autenticado con tu suscripción Pro.

### 2 — Hablar con tu agente
Abre Telegram, busca tu bot y escríbele en español o inglés. Ejemplos:

```
"crea una landing page para mi startup y deployala en Vercel"
"busca en la web las últimas noticias de IA y resúmelas"
"revisa mi repo de GitHub y encuentra bugs en el código"
"crea una API REST en Node.js y súbela a GitHub"
```

### 3 — Programar con Claude Code
Desde la terminal web ejecuta `claude` y dale instrucciones directas:
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
Telegram → OpenClaw (Gemini 2.0 Flash) → workspace
                                               ↓
Terminal web → Claude Code (Sonnet 4.6) → workspace
                                               ↓
                                          GitHub repo
                                               ↓
                                     Vercel / Railway
```

Todo lo que OpenClaw o Claude Code creen va a `/home/claw/workspace`. Con `save` se sube a GitHub y desde ahí puedes deployar donde quieras.

---

## Stack gratuito

| Servicio | Plan | Costo |
|---|---|---|
| Railway | Free (0.5 GB RAM) | $0 |
| OpenRouter | Free (50 req/día) | $0 |
| GitHub | Free | $0 |
| Vercel | Free (hobby) | $0 |
| Claude Code | Pro (ya tienes) | $0 extra |
| **Total** | | **$0/mes** |

---

## Limitaciones del plan gratuito

- **OpenRouter free**: 50 requests/día — suficiente para uso personal. Con $10 de crédito sube a 1000/día.
- **Railway**: El contenedor puede dormir si no hay actividad. El bot de Telegram lo mantiene activo.
- **Sin disco persistente**: Todo se guarda en GitHub via `save`. No se pierde nada.
