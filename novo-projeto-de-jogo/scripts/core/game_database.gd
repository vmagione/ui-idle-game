extends RefCounted
class_name GameDatabase

const CAMPAIGN_COMPLETION_ORDER := 1.0e16
const STRUCTURE_UNLOCK_TOTAL_ORDER := 2.5e3
const PRESTIGE_UNLOCK_TOTAL_ORDER := 2.5e5
const ECHO_UNLOCK_TOTAL_ORDER := 2.0e11
const META_TREE_UNLOCK_CORES := 10.0
const OFFLINE_BASE_CAP := 2.0 * 3600.0
const OFFLINE_EXTENDED_CAP := 8.0 * 3600.0
const LOG_LIMIT := 60
const NOTIFICATION_LIMIT := 12
const TICK_RATE := 5.0
const UI_RATE := 10.0
const AUTOSAVE_DEFAULT := 20.0

static func generators() -> Array:
	return [
		{"id":"scribes","name":"Escribas","description":"Convertem anomalias em relatórios básicos de Ordem.","base_cost":12.0,"growth":1.16,"base_output":0.4},
		{"id":"protocols","name":"Protocolos","description":"Rotinas padronizadas que aceleram a produção contínua.","base_cost":85.0,"growth":1.18,"base_output":3.5},
		{"id":"archivists","name":"Arquivadores","description":"Consolidam fluxos dispersos em lotes estáveis.","base_cost":650.0,"growth":1.20,"base_output":24.0},
		{"id":"directives","name":"Diretivas","description":"Executam correções massivas em toda a cadeia produtiva.","base_cost":4200.0,"growth":1.22,"base_output":160.0},
		{"id":"councils","name":"Conselhos","description":"Sincronizam departamentos inteiros em escala estratégica.","base_cost":36000.0,"growth":1.235,"base_output":1200.0}
	]

static func structures() -> Array:
	return [
		{"id":"compression","name":"Compressão","description":"Multiplica toda a produção de Ordem.","base_cost":500.0,"growth":2.0},
		{"id":"synchronization","name":"Sincronização","description":"Fortalece os geradores mais fracos da cadeia.","base_cost":1200.0,"growth":2.25},
		{"id":"standardization","name":"Padronização","description":"Converte automação em potência de clique.","base_cost":2500.0,"growth":2.45},
		{"id":"scaling","name":"Escalonamento","description":"Transforma volume comprado em eficiência global.","base_cost":6500.0,"growth":2.7},
		{"id":"abstraction","name":"Abstração","description":"Armazena parte do progresso da run em bônus cumulativo.","base_cost":15000.0,"growth":2.9}
	]

static func upgrades() -> Array:
	return [
		{"id":"click_training","name":"Treino de Entrada","desc":"Clique +100%.","category":"production","type":"run","cost_resource":"order","cost":40.0,"max_level":1},
		{"id":"scribe_manuals","name":"Manuais de Escrita","desc":"Escribas x2.","category":"production","type":"run","cost_resource":"order","cost":120.0,"max_level":1},
		{"id":"protocol_templates","name":"Modelos de Protocolo","desc":"Protocolos x2.","category":"production","type":"run","cost_resource":"order","cost":550.0,"max_level":1},
		{"id":"archive_indexing","name":"Indexação Densa","desc":"Arquivadores x2.","category":"production","type":"run","cost_resource":"order","cost":4500.0,"max_level":1},
		{"id":"directive_lattice","name":"Malha Diretiva","desc":"Diretivas x2.","category":"production","type":"run","cost_resource":"order","cost":28000.0,"max_level":1},
		{"id":"council_charter","name":"Carta do Conselho","desc":"Conselhos x2.","category":"production","type":"run","cost_resource":"order","cost":250000.0,"max_level":1},
		{"id":"bulk_procurement","name":"Compra em Lote","desc":"Libera compras mais eficientes e desconto leve.","category":"quality","type":"run","cost_resource":"order","cost":150.0,"max_level":1},
		{"id":"detailed_metrics","name":"Métricas Detalhadas","desc":"Desbloqueia estatísticas expandidas cedo.","category":"quality","type":"run","cost_resource":"order","cost":400.0,"max_level":1},
		{"id":"structure_permits","name":"Permissões Estruturais","desc":"Estruturas custam 12% menos.","category":"quality","type":"run","cost_resource":"structures","cost":3.0,"max_level":1},
		{"id":"automation_bus","name":"Barramento de Automação","desc":"Autobuyers ficam disponíveis após 1 recalibração.","category":"quality","type":"run","cost_resource":"structures","cost":5.0,"max_level":1},
		{"id":"order_feedback","name":"Retroalimentação","desc":"Clique escala com produção por segundo.","category":"synergy","type":"run","cost_resource":"order","cost":900.0,"max_level":5},
		{"id":"structure_resonance","name":"Ressonância Estrutural","desc":"Cada Estrutura aumenta produção global.","category":"synergy","type":"run","cost_resource":"structures","cost":2.0,"max_level":8},
		{"id":"cross_training","name":"Treinamento Cruzado","desc":"Cada Protocolos fortalece Escribas.","category":"synergy","type":"run","cost_resource":"order","cost":1800.0,"max_level":6},
		{"id":"deep_archives","name":"Arquivos Profundos","desc":"Arquivadores ganham bônus por Diretivas.","category":"synergy","type":"run","cost_resource":"order","cost":16000.0,"max_level":6},
		{"id":"council_echoes","name":"Ecos Deliberativos","desc":"Conselhos melhoram todos os anteriores.","category":"synergy","type":"run","cost_resource":"order","cost":220000.0,"max_level":6},
		{"id":"prestige_studies","name":"Estudos de Recalibração","desc":"Ganho de Núcleos +20% por nível.","category":"quality","type":"run","cost_resource":"structures","cost":8.0,"max_level":5},
		{"id":"offline_report","name":"Relatórios Assíncronos","desc":"Offline cap aumentado para 8 horas.","category":"quality","type":"run","cost_resource":"structures","cost":10.0,"max_level":1},
		{"id":"mission_division","name":"Divisão de Objetivos","desc":"Recompensas de objetivos +35%.","category":"quality","type":"run","cost_resource":"structures","cost":12.0,"max_level":3},
		{"id":"run_multiplier","name":"Doutrina de Escala","desc":"Produção global +30% por nível.","category":"production","type":"run","cost_resource":"structures","cost":4.0,"max_level":10},
		{"id":"click_overclock","name":"Overclock de Clique","desc":"Clique +70% por nível.","category":"production","type":"run","cost_resource":"order","cost":2500.0,"max_level":8},
		{"id":"auto_upgrade_unlock","name":"Rotina de Auditoria","desc":"Auto-upgrades disponíveis.","category":"quality","type":"run","cost_resource":"structures","cost":20.0,"max_level":1},
		{"id":"preservation_protocol","name":"Protocolo de Preservação","desc":"Mantém alguns upgrades-chave após recalibrar.","category":"quality","type":"meta","cost_resource":"cores","cost":12.0,"max_level":1},
		{"id":"echo_lens","name":"Lente de Eco","desc":"Ecos futuros +50% por nível.","category":"meta","type":"meta","cost_resource":"echoes","cost":2.0,"max_level":6},
		{"id":"infinite_campaign","name":"Protocolo Infinito","desc":"Marca a conclusão da campanha base.","category":"meta","type":"meta","cost_resource":"echoes","cost":10.0,"max_level":1},
		{"id":"structure_blueprints","name":"Plantas Estruturais","desc":"Estruturas +25% por nível.","category":"production","type":"run","cost_resource":"structures","cost":6.0,"max_level":6},
		{"id":"escalation_lab","name":"Laboratório de Escalada","desc":"Marcos ficam 20% mais fortes por nível.","category":"quality","type":"meta","cost_resource":"cores","cost":16.0,"max_level":5},
		{"id":"core_efficiency","name":"Eficiência de Núcleo","desc":"Produção inicial +25% por nível.","category":"meta","type":"meta","cost_resource":"cores","cost":2.0,"max_level":10},
		{"id":"starting_scribes","name":"Equipe Inicial","desc":"Começa com Escribas grátis.","category":"meta","type":"meta","cost_resource":"cores","cost":3.0,"max_level":8},
		{"id":"offline_archive","name":"Arquivo Offline","desc":"Produção offline +20% por nível.","category":"meta","type":"meta","cost_resource":"cores","cost":4.0,"max_level":8},
		{"id":"click_foundation","name":"Fundação de Clique","desc":"Clique inicial +30% por nível.","category":"meta","type":"meta","cost_resource":"cores","cost":2.0,"max_level":10},
		{"id":"core_yield","name":"Extração de Núcleos","desc":"Ganhos de Núcleos +15% por nível.","category":"meta","type":"meta","cost_resource":"cores","cost":5.0,"max_level":8},
		{"id":"autobuyer_permit","name":"Permissão de Autobuyer","desc":"Desbloqueia autobuyers sem depender de run.","category":"meta","type":"meta","cost_resource":"cores","cost":8.0,"max_level":1},
		{"id":"auto_upgrade_permit","name":"Permissão de Auto-upgrade","desc":"Desbloqueia auto-upgrades permanentes.","category":"meta","type":"meta","cost_resource":"cores","cost":14.0,"max_level":1},
		{"id":"starting_structures","name":"Infraestrutura Inicial","desc":"Começa com Estruturas.","category":"meta","type":"meta","cost_resource":"cores","cost":10.0,"max_level":5},
		{"id":"milestone_amplifier","name":"Amplificador de Marcos","desc":"Todos os marcos globais +15% por nível.","category":"meta","type":"meta","cost_resource":"cores","cost":18.0,"max_level":6},
		{"id":"echo_resonator","name":"Ressonador de Eco","desc":"Produção global +100% por nível de Eco.","category":"meta","type":"meta","cost_resource":"cores","cost":24.0,"max_level":4}
	]

static func objectives() -> Array:
	return [
		{"id":"obj_order_100","name":"Primeiro Relatório","desc":"Produza 100 Ordem total.","target_type":"total_order","target":100.0,"reward":{"resource":"order","amount":35.0}},
		{"id":"obj_scribes_5","name":"Equipe Minúscula","desc":"Compre 5 Escribas.","target_type":"generator_owned","target":"scribes","value":5,"reward":{"multiplier":0.08}},
		{"id":"obj_order_1k","name":"Fluxo Estável","desc":"Produza 1.000 Ordem total.","target_type":"total_order","target":1000.0,"reward":{"resource":"order","amount":300.0}},
		{"id":"obj_protocols_3","name":"Primeiros Protocolos","desc":"Compre 3 Protocolos.","target_type":"generator_owned","target":"protocols","value":3,"reward":{"resource":"order","amount":600.0}},
		{"id":"obj_pps_25","name":"Operação Contínua","desc":"Alcance 25 Ordem/s.","target_type":"pps","target":25.0,"reward":{"multiplier":0.12}},
		{"id":"obj_structures_unlock","name":"Consolidação","desc":"Desbloqueie Estruturas.","target_type":"unlock","target":"structures","reward":{"resource":"structures","amount":1.0}},
		{"id":"obj_structures_5","name":"Plano Diretor","desc":"Tenha 5 Estruturas no total.","target_type":"structures_total","target":5,"reward":{"multiplier":0.15}},
		{"id":"obj_archivists_10","name":"Arquivo Vivo","desc":"Compre 10 Arquivadores.","target_type":"generator_owned","target":"archivists","value":10,"reward":{"resource":"order","amount":8000.0}},
		{"id":"obj_directives_5","name":"Cadeia de Comando","desc":"Compre 5 Diretivas.","target_type":"generator_owned","target":"directives","value":5,"reward":{"resource":"structures","amount":2.0}},
		{"id":"obj_total_100k","name":"Primeira Onda","desc":"Produza 100.000 Ordem total.","target_type":"total_order","target":100000.0,"reward":{"multiplier":0.2}},
		{"id":"obj_prestige_ready","name":"Limite da Run","desc":"Desbloqueie Recalibrar.","target_type":"unlock","target":"prestige","reward":{"resource":"order","amount":15000.0}},
		{"id":"obj_first_prestige","name":"Recalibração Inicial","desc":"Faça sua primeira recalibração.","target_type":"stat","target":"total_recalibrations","value":1,"reward":{"resource":"cores","amount":1.0}},
		{"id":"obj_cores_10","name":"Pesquisa Meta","desc":"Acumule 10 Núcleos totais.","target_type":"stat","target":"total_cores_earned","value":10,"reward":{"multiplier":0.25}},
		{"id":"obj_councils_5","name":"Conselho Formado","desc":"Compre 5 Conselhos.","target_type":"generator_owned","target":"councils","value":5,"reward":{"resource":"structures","amount":5.0}},
		{"id":"obj_pps_10k","name":"Máquina de Ordem","desc":"Alcance 10.000 Ordem/s.","target_type":"pps","target":10000.0,"reward":{"multiplier":0.35}},
		{"id":"obj_cores_50","name":"Laboratório Persistente","desc":"Acumule 50 Núcleos totais.","target_type":"stat","target":"total_cores_earned","value":50,"reward":{"resource":"cores","amount":3.0}},
		{"id":"obj_meta_unlock","name":"Árvore de Núcleos","desc":"Desbloqueie a aba Meta.","target_type":"unlock","target":"meta","reward":{"multiplier":0.4}},
		{"id":"obj_echo_unlock","name":"Primeiro Eco","desc":"Desbloqueie Ecos.","target_type":"unlock","target":"echoes","reward":{"resource":"echoes","amount":1.0}},
		{"id":"obj_echo_3","name":"Ressonância Longa","desc":"Acumule 3 Ecos.","target_type":"stat","target":"echoes","value":3,"reward":{"multiplier":0.55}},
		{"id":"obj_campaign","name":"Protocolo Infinito","desc":"Alcance o marco da campanha base.","target_type":"stat","target":"campaign_complete","value":1,"reward":{"resource":"echoes","amount":2.0}}
	]

static func milestones() -> Array:
	return [
		{"id":"m_scribes_10","name":"10 Escribas","desc":"Escribas x2.","kind":"generator","target":"scribes","value":10},
		{"id":"m_scribes_25","name":"25 Escribas","desc":"Escribas x2 novamente.","kind":"generator","target":"scribes","value":25},
		{"id":"m_protocols_10","name":"10 Protocolos","desc":"Protocolos fortalecem Escribas.","kind":"generator","target":"protocols","value":10},
		{"id":"m_protocols_25","name":"25 Protocolos","desc":"Protocolos x2.","kind":"generator","target":"protocols","value":25},
		{"id":"m_archivists_10","name":"10 Arquivadores","desc":"Arquivadores x2.","kind":"generator","target":"archivists","value":10},
		{"id":"m_directives_10","name":"10 Diretivas","desc":"Diretivas x2.","kind":"generator","target":"directives","value":10},
		{"id":"m_councils_10","name":"10 Conselhos","desc":"Todos os geradores anteriores x2.","kind":"generator","target":"councils","value":10},
		{"id":"m_first_prestige","name":"Primeira Recalibração","desc":"Autobuyers podem ser ativados.","kind":"stat","target":"total_recalibrations","value":1},
		{"id":"m_cores_10","name":"10 Núcleos","desc":"Árvore Meta liberada.","kind":"stat","target":"total_cores_earned","value":10},
		{"id":"m_cores_25","name":"25 Núcleos","desc":"Auto-upgrades mais fortes.","kind":"stat","target":"total_cores_earned","value":25},
		{"id":"m_order_1e8","name":"10^8 Ordem","desc":"Produção global massivamente ampliada.","kind":"total_order","target":"order","value":1.0e8},
		{"id":"m_echo_unlock","name":"Ecos Detectados","desc":"Sistema de Eco disponível.","kind":"stat","target":"echoes","value":1},
		{"id":"m_echo_5","name":"5 Ecos","desc":"Bônus meta adicional.","kind":"stat","target":"echoes","value":5},
		{"id":"m_campaign","name":"Campanha Base Concluída","desc":"Você estabilizou o Bureau of Infinity.","kind":"stat","target":"campaign_complete","value":1}
	]

static func focus_directives() -> Array:
	return [
		{"id":"balanced","name":"Equilíbrio Operacional","desc":"Sem penalidades. Crescimento consistente para a run.","unlock":"start"},
		{"id":"manual","name":"Entrada Manual","desc":"Clique +220%, produção automática -20%. Excelente para early game ativo.","unlock":"start"},
		{"id":"industrial","name":"Escala Industrial","desc":"Produção automática +45%, clique -35%. Melhor para runs mais idle.","unlock":"structures"},
		{"id":"prestige","name":"Pressão de Recalibração","desc":"Ganho de Núcleos +35%, produção atual -18%. Bom para fechar ciclos.","unlock":"prestige"},
		{"id":"resonant","name":"Ressonância de Eco","desc":"Estruturas e Ecos mais fortes, custos de geradores +6%.","unlock":"echoes"}
	]

static func achievements() -> Array:
	return [
		{"id":"ach_first_click","name":"Primeiro Carimbo","desc":"Clique pela primeira vez.","kind":"stat","target":"total_clicks","value":1,"reward":{"type":"click_mult","value":0.05}},
		{"id":"ach_click_100","name":"Operador Incansável","desc":"Realize 100 cliques.","kind":"stat","target":"total_clicks","value":100,"reward":{"type":"click_mult","value":0.08}},
		{"id":"ach_order_1m","name":"Fluxo de Seis Dígitos","desc":"Produza 1M de Ordem total.","kind":"total_order","value":1.0e6,"reward":{"type":"global_mult","value":0.06}},
		{"id":"ach_order_1b","name":"Departamento Planetário","desc":"Produza 1B de Ordem total.","kind":"total_order","value":1.0e9,"reward":{"type":"global_mult","value":0.10}},
		{"id":"ach_scribes_50","name":"Sala de Escrita","desc":"Tenha 50 Escribas.","kind":"generator","target":"scribes","value":50,"reward":{"type":"generator_mult","target":"scribes","value":0.25}},
		{"id":"ach_protocols_25","name":"Malha de Protocolos","desc":"Tenha 25 Protocolos.","kind":"generator","target":"protocols","value":25,"reward":{"type":"generator_mult","target":"protocols","value":0.25}},
		{"id":"ach_structures_20","name":"Cidade de Painéis","desc":"Acumule 20 Estruturas no total.","kind":"structures_total","value":20,"reward":{"type":"structure_efficiency","value":0.10}},
		{"id":"ach_first_prestige","name":"Ciclo Reiniciado","desc":"Realize sua primeira recalibração.","kind":"stat","target":"total_recalibrations","value":1,"reward":{"type":"core_gain","value":0.10}},
		{"id":"ach_cores_100","name":"Reserva Permanente","desc":"Ganhe 100 Núcleos ao longo da campanha.","kind":"stat","target":"total_cores_earned","value":100,"reward":{"type":"core_gain","value":0.18}},
		{"id":"ach_echo_5","name":"Ruído de Fundo","desc":"Acumule 5 Ecos.","kind":"resource","target":"echoes","value":5,"reward":{"type":"echo_gain","value":0.20}},
		{"id":"ach_all_objectives_10","name":"Unidade de Execução","desc":"Conclua 10 objetivos.","kind":"objectives_completed","value":10,"reward":{"type":"global_mult","value":0.12}},
		{"id":"ach_campaign","name":"Bureau of Infinity","desc":"Conclua a campanha base.","kind":"stat","target":"campaign_complete","value":1,"reward":{"type":"global_mult","value":0.20}}
	]

static func codex_entries() -> Array:
	return [
		{"id":"codex_order","title":"Ordem","body":"A menor unidade operacional do Bureau. Tudo começa convertendo caos em Ordem estável.","unlock":"start"},
		{"id":"codex_structures","title":"Estruturas","body":"Camada de consolidação. Elas reorganizam a produção e funcionam como multiplicadores especializados.","unlock":"structures"},
		{"id":"codex_cores","title":"Núcleos","body":"Resultado de uma Recalibração. São o capital permanente da organização e sustentam a árvore meta.","unlock":"prestige"},
		{"id":"codex_echoes","title":"Ecos","body":"Vestígios de runs tão densas que continuam ressoando. São raros e moldam o endgame.","unlock":"echoes"},
		{"id":"codex_focus","title":"Diretivas de Foco","body":"Políticas ativas por run. Escolher a diretiva certa altera o ritmo entre clique, idle e resets.","unlock":"structures"},
		{"id":"codex_automation","title":"Automação","body":"Autobuyers, auto-upgrades e auto-recalibração transformam o Bureau em uma máquina autônoma.","unlock":"prestige"},
		{"id":"codex_campaign","title":"Protocolo Infinito","body":"O marco que sinaliza a conclusão da campanha base. O jogo continua, mas o departamento entra em uma nova era.","unlock":"campaign"}
	]
