# Bureau of Infinity

Idle incremental sci-fi administrativo feito para Godot 4.3+ usando apenas UI nativa do motor.

## Conceito

Você administra um departamento abstrato que transforma caos em `Ordem`. O loop mistura clique inicial, automação, upgrades, Estruturas, recalibração para ganhar `Núcleos` e progressão longa até `Ecos` e o marco `Protocolo Infinito`.

## Como executar

1. Abra a pasta `novo-projeto-de-jogo` no Godot 4.3 ou superior.
2. Rode a cena principal configurada em `project.godot`.
3. O jogo começa pelo menu principal.

## Estrutura

- `scenes/main`: bootstrap principal.
- `scenes/menus`: menu principal.
- `scenes/game`: tela principal do jogo.
- `scenes/ui`: componentes reutilizáveis de cards e log.
- `scenes/popups`: opções, recalibração e retorno offline.
- `scripts/managers`: estado central, save/load, config e formatação numérica.
- `scripts/core`: banco de dados de conteúdo e constantes.
- `scripts/ui`: scripts de telas, popups e helpers visuais.
- `scripts/utils`: helpers matemáticos.

## Conteúdo implementado

- 5 geradores base.
- 5 Estruturas.
- 35 upgrades cadastrados entre run e meta.
- 20 objetivos.
- 14 marcos.
- Recalibrar com Núcleos.
- camada de Ecos e campanha base com `Protocolo Infinito`.
- autobuyers, auto-upgrades e auto-recalibração.
- Diretivas de Foco para alterar o estilo da run.
- Conquistas Operacionais com bônus permanentes.
- Arquivo/Codex interno desbloqueável.
- painel de Destaques com notificações curtas.
- save/load em JSON.
- autosave.
- progresso offline com popup de retorno.
- menu principal, créditos, opções, ajuda e estatísticas.

## Onde ajustar balanceamento

- `scripts/core/game_database.gd`
  - custos base e crescimento de geradores
  - custos de Estruturas
  - upgrades, objetivos e marcos
  - limites de offline
  - thresholds de unlock
- `scripts/managers/game_manager.gd`
  - fórmulas de clique
  - multiplicadores globais
  - fórmula de Núcleos
  - geração de Estruturas e Ecos

## Como expandir

- Adicione novos geradores em `GameDatabase.generators()`.
- Adicione novas Estruturas em `GameDatabase.structures()`.
- Cadastre upgrades extras em `GameDatabase.upgrades()`.
- Acrescente objetivos e marcos nas listas correspondentes.
- Se precisar de novas camadas de recurso, use `state["resources"]` e siga o mesmo padrão de cálculo do `GameManager`.
- A UI principal popula listas dinamicamente a partir dos dados, então grande parte do conteúdo novo aparece sem mexer na cena.

## Save

- Save principal: `user://bureau_save.json`
- Configuração: `user://bureau_config.save`
- versão do save controlada em `scripts/managers/save_manager.gd`

## Observações

- O visual usa apenas `Control` nodes e `StyleBoxFlat`.
- Não há dependência de sprites, tilesets, modelos 3D ou arte externa.
- O projeto foi organizado para servir como base de expansão futura.
