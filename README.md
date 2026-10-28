# OpenDrive desktop (Windows)

> **Status:** Aceito (2026-10-26). Primeira compilação ok ([execução #5](https://github.com/darlanpicetti/OpenDrive-Desktop/actions/runs/40337927116)). Decisão: ADR-0079 do OpenSysID.

OpenDrive é o cliente de sincronização de arquivos da estação OpenSysID. É o [cliente desktop do Nextcloud](https://github.com/nextcloud/desktop) compilado com marca própria. Este repositório guarda **só** a camada de marca, os retoques de UI ([ADR-0085](../../docs/02-decisions/ADR-0085-opendrive-no-ui-in-build.md): sem assistente de login) e a compilação. O motor de sincronização é o do Nextcloud, na tag indicada em `UPSTREAM`.

Licença: GPL-2.0-or-later, a mesma do cliente original (`COPYING`). Nextcloud é marca da Nextcloud GmbH. OpenDrive não é produto da Nextcloud GmbH nem é endossado por ela.

## O que muda em relação ao Nextcloud

| Item | Valor |
|---|---|
| Nome, executável | `OpenDrive`, `opendrive.exe` |
| Fabricante | OpenSys |
| Servidor | fixo em `https://files.opensysid.com` |
| Contas | uma só; arquivos virtuais (Cloud Files) obrigatórios |
| Atualizador | desligado (a versão vem do hub do OpenSysID) |
| Importar conta de um Nextcloud instalado | desligado |
| Login na estação | nenhum: a conta nasce no logon Windows. A compilação não abre assistente nem Settings ([ADR-0085](../../docs/02-decisions/ADR-0085-opendrive-no-ui-in-build.md)); o agente fecha o processo sem conta ([ADR-0083](../../docs/02-decisions/ADR-0083-opendrive-no-login-ui.md)) |
| Certificado TLS inválido | recusado, sem opção de aceitar |
| GUIDs do Explorer e do MSI | próprios: OpenDrive e Nextcloud podem coexistir na estação |
| Ícones, logo, bitmaps do instalador | `branding/` |

Arquivos:

- `branding/` é copiado por cima do código do Nextcloud, no mesmo caminho relativo (`NEXTCLOUD.cmake` é o arquivo de marca que o `CMakeLists.txt` do Nextcloud já inclui).
- `scripts/apply-branding.ps1 -Source <checkout>` copia `branding/`, troca os GUIDs do Nextcloud pelos do OpenDrive em toda a árvore e ajusta o `craftmaster.ini` (sem testes, pacote portátil). Falha se algo esperado não estiver lá: subir a versão do Nextcloud exige revisar, não remendar calado.
- `scripts/apply-branding.ps1 -Blueprints <dir>` ajusta o blueprint do Craft (nome do pacote e o filtro que só mantém `nextcloud*.exe`).
- `scripts/make-msi.ps1` gera o MSI com WiX 3 a partir da árvore que o Craft juntou.
- `.github/workflows/build-windows.yml` faz tudo isso no GitHub Actions (`windows-2022`), com o mesmo Craft que o Nextcloud usa.

## Compilar

Actions → **Build OpenDrive (Windows)** → *Run workflow*. A primeira execução compila as dependências do Craft (horas) e guarda em cache; as seguintes reaproveitam.

Artefato `opendrive-windows`:

- `OpenDrive-<versão>-x64.msi` e `.sha256`
- `opendrive-desktop-source.zip`: o código-fonte correspondente completo (Nextcloud já com a marca aplicada, mais este repositório)
- `OPENDRIVE-SOURCE.txt`: commits exatos do Nextcloud, deste repositório, do Craft e dos blueprints

Uma tag `v*` publica os mesmos arquivos numa release.

## Subir a versão do Nextcloud

1. Trocar `ref=` em `UPSTREAM`.
2. Rodar o workflow. Se `apply-branding.ps1` falhar, ver o que mudou no Nextcloud antes de ajustar.
3. No OpenSysID, refazer o lab do formato da conta (ADR-0077) com o novo cliente antes de publicar no hub.
