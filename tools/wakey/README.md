# Wakey

Petit utilitaire local pour garder une activité via micro-mouvements souris.

## Location

Dans le backpack :

```txt
tools/wakey/
  wakey.swift
  wakey
```

## Build

```sh
swiftc wakey.swift -o wakey
```

## Fish function

La fonction portable est dans :

```txt
dotfiles/fish/functions/wakey.fish
```

Elle utilise `BACKPACK_ROOT`.

## Usage

```sh
wakey start
wakey start --interval 30s --pixels 2
```

- `--interval` par défaut : `30s`
- `--pixels` par défaut : `2`
- stop : `Ctrl+C`

## macOS permissions

Donner l'accès **Accessibilité** au terminal utilisé :

Réglages Système → Confidentialité et sécurité → Accessibilité.
