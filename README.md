# PiuPiu MVP (Godot 4.6)

MVP 3D de puntería con torreta manual, proyectiles rectilíneos y blancos móviles aleatorios.

## Arquitectura
- `scenes/Main.tscn`: composición principal con subsistemas.
- `scripts/config/*`: recursos de configuración data-driven.
- `scripts/systems/*`: simulación, torreta, cámaras, proyectiles, blancos y métricas.
- `scripts/ui/*`: HUD y overlay debug.

## Controles
- Mouse X / Y: yaw / pitch de torreta.
- Click izquierdo: disparar.
- Click derecho: zoom de precisión (CombatView).
- Rueda mouse: zoom táctico (TacticalView).
- Tab: alternar CombatView/TacticalView.
- `R`: reiniciar escena.
- `F1`: mostrar/ocultar debug.
- `ESC`: salir.

## Ejecutar en Godot 4.6
1. Abrir Godot 4.6.
2. Importar carpeta del proyecto (`/workspace/Piu-Piu`).
3. Verificar que la escena principal sea `res://scenes/Main.tscn`.
4. Ejecutar (`F5`).

## Notas de extensión
- `ProjectileConfig.gravity` ya existe para habilitar balística en una iteración futura.
- Configuración desacoplada para soportar múltiples torretas, nuevos sensores y reglas competitivas.
- `MetricsRecorder` permite exportar métricas a JSON/CSV en tiempo de ejecución.
