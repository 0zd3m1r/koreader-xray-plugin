return {
    -- System instruction
    system_instruction = "Você é um crítico literário especialista. Sua resposta deve ser APENAS em formato JSON válido. Não use Markdown, frases introdutórias ou explicações extras.",
    
    -- Main prompt (estrutura principal poderosa - Flash e Pro)
    main = [[Livro: "%s" - Autor: %s

Crie dados detalhados do X-Ray para este livro. Preencha COMPLETAMENTE o formato JSON abaixo.

REGRAS:
1. Não se desvie do formato JSON.
2. O campo "author_bio" é OBRIGATÓRIO; escreva 2-3 frases sobre o autor.
3. PERSONAGENS: Liste pelo menos 15-20 personagens (protagonistas e coadjuvantes).
4. FIGURAS HISTÓRICAS: Encontre figuras históricas REAIS mencionadas no livro ou que influenciam a época. Se não houver, não deixe vazio; adicione o rei/líder da época como uma "Period Figure".
5. DETALHES: Nunca deixe os campos "importance_in_book" e "context_in_book" vazios. Analise o contexto dentro do livro.

REQUIRED JSON FORMAT:
{
  "book_title": "Book Title",
  "author": "Author Name",
  "author_bio": "Detailed info about the author's life and literary personality (Mandatory)",
  "summary": "Comprehensive summary of the book (Spoiler-free overview)",
  "characters": [
    {
      "name": "Character Name",
      "role": "Protagonist / Supporting Character / Antagonist",
      "gender": "Male / Female / Ambiguous",
      "occupation": "Occupation or Status",
      "description": "Detailed analysis and personality traits of the character"
    }
  ],
  "historical_figures": [
    {
      "name": "Historical Figure Name",
      "role": "Role in Real History (e.g., Emperor, Philosopher)",
      "biography": "Short biography",
      "importance_in_book": "What is this person's importance in the book? Why are they mentioned?",
      "context_in_book": "How do characters mention this person? In what context do they appear?"
    }
  ],
  "locations": [
    {"name": "Location Name", "description": "Description of the location", "importance": "Significance in the story"}
  ],
  "themes": ["Theme 1", "Theme 2", "Theme 3", "Theme 4", "Theme 5"],
  "timeline": [
    {"event": "Event Title", "chapter": "Relevant Chapter/Section", "importance": "Significance of the event"}
  ]
}]]
}
