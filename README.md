# aurora-sdk-nix

Standalone Nix flake для Aurora SDK BT на NixOS.

## Возможности

- Пакет `aurora-sdk` с автоматической установкой IDE через Docker при первом запуске.
- FHS-окружение со всеми зависимостями Qt Creator, GStreamer, QEMU и Docker.
- Home-manager модуль с опцией `programs.aurora-sdk.enable`.
- Overlay для подключения к `nixpkgs`.

## Использование

### Запуск из flake

```sh
nix run ~/git/nighteugene/aurora-sdk-nix
```

### Добавление в свою конфигурацию

```nix
{
  inputs.aurora-sdk.url = "github:nighteugene/aurora-sdk-nix";

  outputs = { self, nixpkgs, aurora-sdk, ... }: {
    # Через overlay
    nixpkgs.overlays = [ aurora-sdk.overlays.default ];

    # Или через home-manager
    home-manager.users.username = {
      imports = [ aurora-sdk.homeModules.default ];
      programs.aurora-sdk.enable = true;
    };
  };
}
```

## Требования

- NixOS x86_64-linux
- Включённый Docker (для первичной установки Aurora SDK)

## Лицензия

MIT — см. [LICENSE](./LICENSE).
