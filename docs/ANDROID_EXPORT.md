# Exportação Android (Godot 4.x)

## 1) Pré-requisitos

- Android SDK + Build-Tools instalados.
- JDK 17 (recomendado para Godot 4.x).
- Template de exportação Android instalado no Godot.

## 2) Configurar paths no Godot

No Godot Editor:

1. `Editor > Editor Settings > Export > Android`
2. Preencher:
   - `adb`
   - `apksigner`
   - `debug_keystore`
   - `zipalign`
3. Salvar.

## 3) Instalar Export Template

1. `Editor > Manage Export Templates`
2. Instalar templates da mesma versão do editor.

## 4) Criar preset Android

1. `Project > Export`
2. Adicionar preset **Android**.
3. Configurar:
   - Package/Bundle identifier (ex: `com.studio.blockblastsurvival`)
   - Version code/name
   - Orientation (portrait, para one-hand play)
   - Permissions mínimas

## 5) Gerar APK (MVP)

1. No preset Android, escolher `Export Project`.
2. Gerar `block-blast-survival.apk`.
3. Instalar no device por USB:
   - `adb install -r block-blast-survival.apk`

## 6) Checklist rápido no device

- Controles confortáveis com uma mão.
- FPS estável.
- Texto legível em telas pequenas.
- Botão de bomba com toque consistente.
- Revive + restart funcionando.

## 7) Próximos passos para Play Store

- Gerar `.aab` para publicação.
- Configurar keystore de release.
- Ajustar ícones/splash finais.
- Integrar SDK real de ads e analytics.
