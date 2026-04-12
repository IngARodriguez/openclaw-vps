# OpenClaw VPS — Deploy definitivo

VPS con OpenClaw + Claude Code + GitHub CLI + Vercel + Railway CLI.  
Al deployar en Railway todo queda configurado automáticamente.

## Variables de entorno en Railway

| Variable | Descripción | Requerida |
|---|---|---|
| `OPENROUTER_API_KEY` | Key de OpenRouter (`sk-or-...`) | ✅ |
| `TELEGRAM_BOT_TOKEN` | Token del bot de Telegram | ✅ |
| `GITHUB_USER` | Tu usuario de GitHub | ✅ |
| `GITHUB_TOKEN` | Token GitHub con scope `repo` | ✅ |
| `GITHUB_REPO` | Repo workspace (`openclaw-workspace`) | ✅ |
| `GIT_USER` | Nombre para commits | ✅ |
| `GIT_EMAIL` | Email para commits | ✅ |
| `TTYD_USER` | Usuario terminal web | ✅ |
| `TTYD_PASS` | Contraseña terminal web | ✅ |
| `VERCEL_TOKEN` | Token de Vercel | opcional |
| `ANTHROPIC_API_KEY` | Key de Anthropic para Claude Code | opcional |

## Acceso
https://TTYD_USER:TTYD_PASS@tu-url.railway.app

## Comandos en la terminal

```bash
save   # guarda en GitHub
sync   # descarga de GitHub
claw   # reinicia openclaw
logs   # ver logs
gs     # git status
```
