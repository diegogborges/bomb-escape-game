# Checklist de Testes Manuais (MVP)

## 1) Movimento

- [ ] Player move com WASD e setas.
- [ ] Player move com joystick virtual (toque/arrasto no pad).
- [ ] Player permanece dentro da area jogavel.
- [ ] Controle de uma mao e confortavel (dedo direito para bomba, esquerdo para movimento).

## 2) Spawn e dificuldade

- [ ] Blocos aparecem continuamente no topo.
- [ ] Velocidade e frequencia aumentam com o tempo.
- [ ] Tipos de bloco aparecem (Normal, Heavy, Explosive, Rare).
- [ ] Heavy cai mais rapido que Normal.

## 3) Bomba e explosao

- [ ] Botao de bomba cria bomba no player.
- [ ] Bomba explode apos delay.
- [ ] Explosao atinge em cruz (centro + bracos).
- [ ] Player morre se estiver na area de explosao sem escudo.
- [ ] Blocos sao destruidos pela explosao.

## 4) Blocos especiais

- [ ] Bloco explosivo causa reacao em cadeia ao ser destruido por explosao.
- [ ] Bloco raro pode dropar power-up ao explodir.

## 5) Power-ups

- [ ] Slow motion reduz tempo global por curto periodo.
- [ ] Escudo absorve um hit e expira.
- [ ] Bomba maior aumenta raio e tamanho da cruz temporariamente.
- [ ] Limpeza de tela remove blocos ativos.

## 6) Retencao e UX

- [ ] Score cresce continuamente com o tempo.
- [ ] Recorde persiste apos fechar e abrir o jogo.
- [ ] Near miss exibe feedback visual e bonus.
- [ ] Fluxo de reinicio pos-morte e rapido e claro.

## 7) Monetizacao (simulada)

- [ ] Revive so aparece quando permitido.
- [ ] Revive simulado completa e devolve player ao jogo.
- [ ] Interstitial simulado dispara a cada N runs configurado.
- [ ] Flag `ads_removed` bloqueia requests de ad.

## 8) Debug

- [ ] Tecla F ativa/desativa debug.
- [ ] Debug mostra colisoes (Godot collision hint).
- [ ] Label de debug exibe dados uteis.

## 9) Audio e game feel

- [ ] Som de explosao toca em bomba/reacao.
- [ ] Som de hit toca ao tomar dano.
- [ ] Som de game over toca ao morrer.
- [ ] Som de pickup toca ao coletar.
- [ ] Camera shake ocorre em explosoes e dano.

---

## Casos de erro comuns

1. **Player travado apos revive**
   - Verificar `is_running`, `player.revive()`, `spawner.start(false)` e input do joystick.
2. **Explosao sem dano**
   - Validar `_point_hits_target` e `bomb.configure`.
3. **Recorde nao salva**
   - Verificar permissao de escrita em `user://` e parsing JSON.
4. **UI some indevidamente**
   - Validar estados de `show_status`, `show_game_over`, `hide_game_over`.
5. **Queda de FPS em aparelhos fracos**
   - Reduzir particulas e taxa maxima de spawn.

---

## Estrategia de validacao de gameplay

1. Rodar 20 partidas curtas seguidas (30-90s).
2. Medir:
   - tempo ate primeira morte,
   - score medio,
   - frequencia de uso de bomba.
3. Ajustar:
   - `base_spawn_interval`,
   - `min_spawn_interval`,
   - `base_fall_speed`,
   - dano e duracao de power-ups.
4. Repetir ciclo ate atingir:
   - aprendizagem em menos de 5 segundos,
   - sensacao clara de progressao,
   - forte vontade de "so mais uma".
