return {
    -- System instruction
    system_instruction = "Eres un crítico literario experto. Tu respuesta debe estar ÚNICAMENTE en formato JSON válido. No utilices Markdown, frases introductorias ni explicaciones adicionales.",
    
    -- Main prompt (Full book analysis)
    main = [[Libro: "%s" - Autor: %s
Crea datos detallados de Rayos X para este libro. Completa el formato JSON de abajo COMPLETAMENTE.
REGLAS:
1. No te desvíes del formato JSON.
2. El campo \"author_bio\" es OBLIGATORIO; escribe 2-3 frases sobre el autor.
3. PERSONAJES: Enumera al menos 15-20 personajes (protagonistas y secundarios).
4. PERSONAJES HISTÓRICOS: Encuentra personajes históricos REALES mencionados en el libro o que influyan en la época. Si no hay, no lo dejes vacío; añade el rey/líder de la época como \"Figura del período\"
5. DETAILS: Nunca dejes los campos \"importance_in_book\" y \"context_in_book\" vacíos. Analiza el contexto dentro del libro.
FORMATO JSON REQUERIDO:
{
  "book_title": "Título del libro",
  "author": "Nombre del autor",
  "author_bio": "Información detallada sobre la vida y personalidad literaria del autor (obligatorio)",
  "summary": "Resumen completo del libro (visión general sin spoilers)",
  "characters": [
    {
      "name": "Nombre del personaje",
      "role": "Protagonista / Personaje secundario / Antagonista",
      "gender": "Masculino / Femenino / Ambiguo",
      "occupation": "Ocupación o estatus",
      "description": "Análisis detallado y rasgos de personalidad del personaje"
    }
  ],
  "historical_figures": [
    {
      "name": "Nombre del personaje histórico",
      "role": "Rol en la historia real (ej. emperador, filósofo)",
      "biography": "Breve biografía",
      "importance_in_book": "¿Cuál es la importancia de esta persona en el libro? ¿Por qué se menciona?",
      "context_in_book": "¿Cómo mencionan los personajes a esta persona? ¿En qué contexto aparece?"
    }
  ],
  "locations": [
    {"name": "Nombre del lugar","description": "Descripción del lugar", "importance": "Relevancia en la historia"
  ],
  "themes": ["Tema 1", "Tema 2", "Tema 3", "Tema 4", "Tema 5"],
  "timeline": [
    {"event": "Título del evento", "chapter": "Capítulo/Sección relevante", "importance": "Relevancia del evento"}
  ]
}]],

    -- Spoiler-free prompt (Based on reading progress)
    spoiler_free = [[Libro: "%s" - Autor: %s
CRÍTICO: El lector ha leído %d%% de este libro. Crea datos de X-Ray SOLO para el contenido hasta este punto de lectura.
REGLAS DE PREVENCIÓN DE SPOILERS:
1. NO incluyas personajes que aparezcan DESPUÉS de este punto de lectura
2. NO menciones eventos de la trama que ocurran DESPUÉS de este punto
3. NO reveles desarrollos de personajes que sucedan más adelante
4. Los eventos de la cronología deben cubrir SOLO lo que el lector ya ha leído
5. Las descripciones de personajes deben reflejar su estado actual, no desarrollos posteriores
6. El resumen debe cubrir SOLO los eventos que el lector ya haya experimentado

REGLAS ADICIONALES:
1. La biografía del autor es obligatoria (esto nunca contiene spoilers)
2. Se pueden incluir personajes históricos si se mencionan en la parte ya leída
3. Los lugares deben ser solo aquellos visitados/mencionados hasta ahora
4. Los temas deben reflejar lo que es evidente en la historia hasta este punto

FORMATO JSON REQUERIDO:
{
  "book_title": "Título del libro",
  "author": "Nombre del autor",
  "author_bio": "Información detallada sobre la vida y personalidad literaria del autor (obligatorio)",
  "summary": "Resumen que cubre SOLO lo que el lector ha leído hasta ahora",
  "characters": [
    {
      "name": "Nombre del personaje (solo si ya fue introducido)",
      "role": "Protagonista / Personaje secundario / Antagonista",
      "gender": "Masculino / Femenino / Ambiguo",
      "occupation": "Ocupación o estatus",
      "description": "Estado del personaje en el punto actual de lectura - NO revelar desarrollos posteriores"
    }
  ],
  "historical_figures": [
    {
      "name": "Nombre de la persona histórica",
      "role": "Rol en la historia real",
      "biography": "Breve biografía",
      "importance_in_book": "Su relevancia hasta el punto actual de lectura",
      "context_in_book": "Cómo se menciona en la parte ya leída"
    }
  ],
  "locations": [
    {"name": "Nombre del lugar (solo si ya fue visitado/mencionado)", "description": "Descripción", "importance": "Relevancia hasta este punto"}
  ],
  "themes": ["Solo temas evidentes en la historia hasta ahora"],
  "timeline": [
    {"event": "Título del evento (SOLO eventos que ya ocurrieron)", "chapter": "Capítulo/Sección relevante", "importance": "Relevancia"}
  ]
}]],

    -- Fallback strings
    fallback = {
        unknown_book = "Libro desconocido",
        unknown_author = "Autor desconocido",
        unnamed_character = "Personaje sin nombre",
        not_specified = "No especificado",
        no_description = "Sin descripción",
        unnamed_person = "Persona sin nombre",
        no_biography = "Sin biografía"
    }
}