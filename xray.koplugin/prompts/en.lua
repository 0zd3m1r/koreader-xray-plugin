return {
    -- System instruction
    system_instruction = "You are an expert literary critic. Your response must be ONLY in valid JSON format. Do not use Markdown, introductory sentences, or extra explanations.",
    
    -- Main prompt (Common powerful structure for Flash and Pro)
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
}]]
}