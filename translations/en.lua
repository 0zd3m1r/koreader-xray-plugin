return {
    -- System instruction
    system_instruction = "You are an expert literary critic. Your response must be ONLY in valid JSON format. Do not use Markdown, introductory sentences, or extra explanations.",
    
    -- Main prompt (Full book analysis)
    main = [[Book: "%s" - Author: %s
Create detailed X-Ray data for this book. Fill in the JSON format below COMPLETELY.
RULES:
1. Do not deviate from the JSON format.
2. The "author_bio" field is MANDATORY; write 2-3 sentences about the author.
3. CHARACTERS: List at least 15-20 characters (Protagonists and supporting characters).
4. HISTORICAL FIGURES: Find REAL historical figures mentioned in the book or influencing the era. If none, do not leave empty; add the king/leader of the era as a "Period Figure".
5. DETAILS: Never leave "importance_in_book" and "context_in_book" fields empty. Analyze the context within the book.
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
}]],

    -- Spoiler-free prompt (Based on reading progress)
    spoiler_free = [[Book: "%s" - Author: %s
CRITICAL: The reader has read %d%% of this book. Create X-Ray data ONLY for content up to this reading point.

SPOILER PREVENTION RULES:
1. DO NOT include any characters that appear AFTER this reading point
2. DO NOT mention any plot events that occur AFTER this point
3. DO NOT reveal any character developments that happen later in the book
4. Timeline events must ONLY cover what the reader has already read
5. Character descriptions should reflect their current state, not later developments
6. Summary must ONLY cover events the reader has already experienced

ADDITIONAL RULES:
1. Author bio is mandatory (this never contains spoilers)
2. Historical figures can be included if they're mentioned in the portion already read
3. Locations should only be those visited/mentioned so far
4. Themes should reflect what's apparent in the story up to this point

REQUIRED JSON FORMAT:
{
  "book_title": "Book Title",
  "author": "Author Name",
  "author_bio": "Detailed info about the author's life and literary personality (Mandatory)",
  "summary": "Summary covering ONLY what the reader has read so far",
  "characters": [
    {
      "name": "Character Name (only if already introduced)",
      "role": "Protagonist / Supporting Character / Antagonist",
      "gender": "Male / Female / Ambiguous",
      "occupation": "Occupation or Status",
      "description": "Character state at current reading point - DO NOT reveal later developments"
    }
  ],
  "historical_figures": [
    {
      "name": "Historical Figure Name",
      "role": "Role in Real History",
      "biography": "Short biography",
      "importance_in_book": "Their relevance up to current reading point",
      "context_in_book": "How they're mentioned in the portion already read"
    }
  ],
  "locations": [
    {"name": "Location Name (only if visited/mentioned so far)", "description": "Description", "importance": "Significance up to this point"}
  ],
  "themes": ["Only themes evident in the story so far"],
  "timeline": [
    {"event": "Event Title (ONLY events that have occurred)", "chapter": "Relevant Chapter/Section", "importance": "Significance"}
  ]
}]],

    -- Fallback strings
    fallback = {
        unknown_book = "Unknown Book",
        unknown_author = "Unknown Author",
        unnamed_character = "Unnamed Character",
        not_specified = "Not Specified",
        no_description = "No Description",
        unnamed_person = "Unnamed Person",
        no_biography = "No Biography Available"
    }
}

