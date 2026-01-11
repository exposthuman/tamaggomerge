# Asset Naming Conventions

## General
- Use lowercase kebab-case for asset names: `pet-happy`, `room-kitchen`.
- Prefix by domain: `pet-`, `room-`, `ui-`, `icon-`, `bg-`.
- Keep sprite sequences numbered: `pet-idle-01`, `pet-idle-02`.

## SpriteKit Atlases
- Store atlases in `Resources/Atlases` with suffix `.atlas`.
- Atlas names: `pet-idle.atlas`, `room-living.atlas`.

## Audio
- Keep audio in `Resources/Audio`.
- Prefix with context: `ui-tap.wav`, `pet-happy.mp3`.

## Localization
- Place localized strings in `Resources/Localization`.
- File name format: `Localizable.strings` per locale folder.
