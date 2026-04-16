# Block Blast Survival (Godot 4.x)

Jogo arcade survival 2D para mobile (Android primeiro), inspirado em Bomberman:

- Sessões curtas e viciantes
- Movimento rápido com uma mão
- Blocos caindo continuamente
- Bombas com delay e explosão em área (arquitetura pronta para cruz estilo grid)
- Power-ups e progressão de dificuldade
- Retenção com score, recorde local, near miss feeling e game feel

## 1) Visão geral do produto

**Nome provisório:** Block Blast Survival  
**Gênero:** Arcade Survival  
**Plataforma alvo inicial:** Android (portrait)  
**Engine:** Godot 4.x (GDScript)

### Objetivo de design

- Aprender em < 5 segundos
- Difícil de dominar
- Loop de "só mais uma partida"
- UX mobile sem fricção

## 2) Estrutura do projeto

```
project.godot
scenes/
  Main.tscn
  Player.tscn
  Bomb.tscn
  Block.tscn
  Pickup.tscn
  ExplosionEffect.tscn
  UI.tscn
scripts/
  game/
    main.gd
    player.gd
    bomb.gd
    block.gd
    pickup.gd
    explosion_effect.gd
    block_spawner.gd
    ui.gd
  services/
    save_service.gd
    analytics_service.gd
    ads_service.gd
  audio/
    audio_manager.gd
  camera/
    camera_shaker.gd
docs/
  GAMEPLAY_TEST_CHECKLIST.md
  ANDROID_EXPORT.md
  EXPANSION_ROADMAP.md
```

## 3) Gameplay loop implementado

1. Partida inicia instantaneamente (`Main._start_new_run()`).
2. Jogador se move e desvia de blocos.
3. Jogador planta bomba (botão grande na UI / tecla espaço em debug).
4. Dificuldade cresce com o tempo (intervalo de spawn cai, velocidade sobe, tipos avançados mais frequentes).
5. Jogador morre por bloco ou explosão.
6. Tela de game over mostra score, best e opção de revive (rewarded simulado) ou reiniciar.

## 4) Sistemas implementados

### 4.1 Player

- `CharacterBody2D` com controle por teclado e joystick virtual
- Clamp em área jogável
- Morte, revive e escudo temporário
- Feedback visual de dano (flash)

### 4.2 Bombas

- Fuse timer (delay)
- Explosão por pontos, com arquitetura de cruz (centro + braços)
- Dano em blocos e no player
- Integração com shake + áudio + efeito visual

### 4.3 Blocos

Tipos:

- **Normal**
- **Pesado** (maior e mais rápido)
- **Explosivo** (reação em cadeia quando explodido)
- **Raro** (chance de dropar power-up)

### 4.4 Spawner e dificuldade progressiva

- Spawn contínuo com curva temporal
- Aumento de velocidade de queda
- Probabilidades dinâmicas por tipo
- Configurável em `block_spawner.gd`

### 4.5 Power-ups

- **Slow motion**
- **Escudo**
- **Bomba maior** (raio e alcance em cruz)
- **Limpeza de tela**

### 4.6 Retenção

- Score crescente por tempo
- Bonus por destruir blocos
- Near miss (+feedback + pontos extras)
- Best score local em JSON (`user://save_data.json`)

### 4.7 Game feel / Juice

- Camera shake procedural (`CameraShaker`)
- Micro slow motion em eventos intensos
- Explosão com partículas/flash
- SFX placeholders programáticos

### 4.8 Monetização preparada (arquitetura)

- `AdsService` com:
  - Rewarded para revive
  - Interstitial a cada N partidas
  - Flag de remover anúncios
- Sem SDK real, com pontos claros de integração

### 4.9 Analytics simulado

- `AnalyticsService` registra e imprime:
  - tempo por run
  - score médio
  - número de mortes

## 5) UX mobile aplicada

- Layout portrait
- Botão de bomba grande no canto inferior direito
- Joystick virtual no canto inferior esquerdo
- HUD limpa (score/best)
- Overlay de estado sem navegação complexa

## 6) Debug

- Toggle de debug (`F`)
- Exibição de colisões via `debug_collisions_hint`
- Label com informações de debug
- Logs de ads/analytics/debug no output

## 7) Como rodar

1. Abra no Godot 4.2+.
2. Execute `scenes/Main.tscn` (já configurada como `run/main_scene`).
3. Controles:
   - **Desktop debug:** WASD/setas, Espaço (bomba), R (restart), F (debug)
   - **Mobile:** joystick virtual + botão BOMBA

## 8) Arte placeholder e evolução

Arte atual é baseada em formas simples:

- Player: quadrado estilizado com olhos
- Blocos: cor por tipo
- Bomba: corpo + fuse pulsante
- Explosão: partículas + flash

Evoluções recomendadas para arte final:

- spritesheets com animações de idle/hit/death
- VFX com flipbook para explosão
- identidade visual por tema (neon, industrial, pixel)
- shader leve para impacto e brilho em eventos críticos

## 9) Testes e validação

Checklist manual completo em `docs/GAMEPLAY_TEST_CHECKLIST.md`.

## 10) Exportação Android

Guia completo em `docs/ANDROID_EXPORT.md`.

## 11) Próximos passos de produto

Roadmap sugerido (curto/médio prazo):

- Ranking assíncrono
- Skins
- Loja
- Eventos diários
- Preparação para publicação na Play Store
