return {
    -- System instruction
    system_instruction = "Você é um especialista em crítica literária. Sua resposta deve ser APENAS em formato JSON válido. Não use Markdown, frases introdutórias ou explicações extras. Responda em Português do Brasil.",
    
    -- Main prompt (Full book analysis)
    main = [[Livro: "%s" - Autor: %s
Crie dados detalhados de Raio-X para este livro. Preencha o formato JSON abaixo COMPLETAMENTE.

REGRAS:
1. Não se desvie do formato JSON.
2. O campo "author_bio" é OBRIGATÓRIO; escreva 2-3 frases sobre o autor.
3. PERSONAGENS: Liste pelo menos 15-20 personagens (Protagonistas e personagens secundários).
4. FIGURAS HISTÓRICAS: Encontre figuras históricas REAIS mencionadas no livro ou que influenciaram a época. Se não houver, não deixe vazio; adicione o rei/líder da época como "Figura do Período".
5. DETALHES: Nunca deixe os campos "importance_in_book" e "context_in_book" vazios. Analise o contexto dentro do livro.

FORMATO JSON NECESSÁRIO:
{
  "book_title": "Título do Livro",
  "author": "Nome do Autor",
  "author_bio": "Informações detalhadas sobre a vida e personalidade literária do autor (Obrigatório)",
  "summary": "Resumo abrangente do livro (Visão geral sem spoilers)",
  "characters": [
    {
      "name": "Nome do Personagem",
      "role": "Protagonista / Personagem Secundário / Antagonista",
      "gender": "Masculino / Feminino / Ambíguo",
      "occupation": "Ocupação ou Status",
      "description": "Análise detalhada e traços de personalidade do personagem"
    }
  ],
  "historical_figures": [
    {
      "name": "Nome da Figura Histórica",
      "role": "Papel na História Real (ex: Imperador, Filósofo)",
      "biography": "Biografia curta",
      "importance_in_book": "Qual a importância dessa pessoa no livro? Por que ela é mencionada?",
      "context_in_book": "Como os personagens mencionam essa pessoa? Em que contexto ela aparece?"
    }
  ],
  "locations": [
    {"name": "Nome do Local", "description": "Descrição do local", "importance": "Significância na história"}
  ],
  "themes": ["Tema 1", "Tema 2", "Tema 3", "Tema 4", "Tema 5"],
  "timeline": [
    {"event": "Título do Evento", "chapter": "Capítulo/Seção Relevante", "importance": "Significância do evento"}
  ]
}]],

    -- Spoiler-free prompt (Based on reading progress)
    spoiler_free = [[Livro: "%s" - Autor: %s
CRÍTICO: O leitor leu %d%% deste livro. Crie dados de Raio-X APENAS para o conteúdo até este ponto de leitura.

REGRAS DE PREVENÇÃO DE SPOILER:
1. NÃO inclua personagens que aparecem DEPOIS deste ponto de leitura.
2. NÃO mencione eventos da trama que ocorrem DEPOIS deste ponto.
3. NÃO revele desenvolvimentos de personagens que acontecem mais tarde no livro.
4. Eventos da linha do tempo devem cobrir APENAS o que o leitor já leu.
5. Descrições de personagens devem refletir seu estado atual, não desenvolvimentos posteriores.
6. O resumo deve cobrir APENAS eventos que o leitor já experimentou.

REGRAS ADICIONAIS:
1. Biografia do autor é obrigatória (nunca contém spoilers).
2. Figuras históricas podem ser incluídas se forem mencionadas na parte já lida.
3. Locais devem ser apenas aqueles visitados/mencionados até agora.
4. Temas devem refletir o que é aparente na história até este ponto.

FORMATO JSON NECESSÁRIO:
{
  "book_title": "Título do Livro",
  "author": "Nome do Autor",
  "author_bio": "Informações detalhadas sobre a vida e personalidade literária do autor (Obrigatório)",
  "summary": "Resumo cobrindo APENAS o que o leitor leu até agora",
  "characters": [
    {
      "name": "Nome do Personagem (apenas se já introduzido)",
      "role": "Protagonista / Personagem Secundário / Antagonista",
      "gender": "Masculino / Feminino / Ambíguo",
      "occupation": "Ocupação ou Status",
      "description": "Estado do personagem no ponto atual de leitura - NÃO revele desenvolvimentos posteriores"
    }
  ],
  "historical_figures": [
    {
      "name": "Nome da Figura Histórica",
      "role": "Papel na História Real",
      "biography": "Biografia curta",
      "importance_in_book": "Sua relevância até o ponto atual de leitura",
      "context_in_book": "Como são mencionados na parte já lida"
    }
  ],
  "locations": [
    {"name": "Nome do Local (apenas se visitado/mencionado até agora)", "description": "Descrição", "importance": "Significância até este ponto"}
  ],
  "themes": ["Apenas temas evidentes na história até agora"],
  "timeline": [
    {"event": "Título do Evento (APENAS eventos que já ocorreram)", "chapter": "Capítulo/Seção Relevante", "importance": "Significância"}
  ]
}]],

    -- Fallback strings
    fallback = {
        unknown_book = "Livro Desconhecido",
        unknown_author = "Autor Desconhecido",
        unnamed_character = "Personagem Sem Nome",
        not_specified = "Não Especificado",
        no_description = "Sem Descrição",
        unnamed_person = "Pessoa Sem Nome",
        no_biography = "Biografia Não Disponível"
    }
}