# 📖 X-Ray Plugin for KOReader

Transform your reading experience with AI-powered book analysis, just like Amazon Kindle X-Ray!

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-KOReader-green.svg)
![License](https://img.shields.io/badge/license-MIT-yellow.svg)

---

## 🎯 What is X-Ray Plugin?

X-Ray Plugin brings Amazon Kindle's beloved X-Ray feature to KOReader. Using advanced AI technology (Google Gemini or ChatGPT), it automatically extracts and organizes:

- 👥 **Characters** - Names, descriptions, roles, occupations
- 📍 **Locations** - Important places and their significance
- ⏱️ **Timeline** - Key events in chronological order
- 📜 **Historical Figures** - Real people mentioned in the book
- 🎨 **Themes** - Main themes and ideas
- 📝 **Notes** - Your personal character notes

All data is **cached locally** for offline use and works **without internet** after the initial fetch!

---

## ✨ Key Features

### 🤖 AI Integration

- **Google Gemini 2.5 Flash** (FREE, recommended)
- **Google Gemini 2.5 Pro** (optional, more detailed)
- **ChatGPT (GPT-3.5 Turbo)** (paid, OpenAI)
- Smart JSON parsing with error recovery
- Language-aware prompts (Turkish/English)

### 👥 Character Management

- Automatic character extraction from book title
- Detailed profiles: name, description, role, gender, occupation
- **Character search** with fuzzy matching
- **Chapter analysis**: See which characters appear in current chapter
- **Personal notes**: Add your own notes for each character
- **📊 Smart Menu Counters**: See live counts (e.g., "Characters (12)")

### 📖 Advanced Analysis

- **Timeline**: Important events in chronological order
- **Historical Figures**: Real people mentioned (with biographies!)
- **Locations**: Important places and their significance
- **Themes**: Main themes extracted by AI
- **Spoiler-Free**: AI is trained to avoid spoilers
- **🔍 Enhanced Historical Analysis**: Detects direct and indirect historical references

### 💾 Cache System

- **Unlimited validity**: Cache never expires
- **Offline usage**: Internet only needed for initial fetch
- **Per-book storage**: Each book has its own cache
- **Auto-load**: Cache loads automatically when opening a book
- **🌍 Multi-Language Support**: Turkish and English interface + AI prompts

---

## 🚀 Quick Start

### 1. Installation

```bash
# Copy plugin to KOReader plugins directory
cp -r xray.koplugin ~/.config/koreader/plugins/

# Restart KOReader
```

### 2. Get a Free API Key

**Google Gemini (Recommended - FREE)**
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with Google account
3. Click "Create API Key"
4. Copy the key (starts with `AIza...`)

**Alternative: ChatGPT (Paid)**
1. Go to https://platform.openai.com/api-keys
2. Create API key (starts with `sk-...`)

### 3. Configure Plugin

1. Open any book in KOReader
2. Go to **Menu → X-Ray → AI Settings**
3. Select **Google Gemini API Key**
4. Paste your API key
5. Done! ✅

### 4. Fetch Your First Book

1. Go to **Menu → X-Ray → Fetch AI Data** (veya "AI ile Bilgi Çek")
2. Wait 10-15 seconds
3. Done! All data is now cached offline ✨

---

## 📱 Usage

### Quick Access

- **Alt + X**: Quick X-Ray menu
- **Menu → X-Ray**: Full menu with all features

### Main Features

#### 👥 Characters
```
Menu → X-Ray → Characters
```
- View all characters with descriptions
- Click any character for detailed info
- Search for specific characters

#### 📖 This Chapter
```
Menu → X-Ray → Characters in This Chapter
```
- See which characters appear in current chapter
- Shows occurrence frequency (e.g., "John (5x)")
- Quick access to character details

#### ⏱️ Timeline
```
Menu → X-Ray → Timeline
```
- Important events in order
- Chapter references
- Characters involved in each event

#### 📜 Historical Figures
```
Menu → X-Ray → Historical Figures
```
- Real people mentioned in the book
- Biographies and dates
- Context in the book

#### 📝 Character Notes
```
Menu → X-Ray → My Character Notes
```
- Add personal notes for each character
- Edit or delete existing notes
- Notes saved per book

### Advanced Features

#### 🌍 Change Language
```
Menu → X-Ray → Language / Dil
```
- Switch between languages
- Applies immediately (menu refreshes on next open)
- AI will fetch data in selected language

#### 🗑️ Clear Cache
```
Menu → X-Ray → Clear Cache
```
- Delete all cached data for current book
- Useful for re-fetching updated data
- Requires confirmation dialog

---

![photo_2025-10-30_13-38-30](https://github.com/user-attachments/assets/48e4b012-f0c1-43b0-9380-c5ca69c8cb6d)
![photo_2025-10-30_13-38-28](https://github.com/user-attachments/assets/60f292d4-acc3-42ef-8ae0-9a501719dd76)
![photo_2025-10-30_13-38-25](https://github.com/user-attachments/assets/2290087a-81e4-404b-bf6a-7fd8aa6f55bd)
![photo_2025-10-30_13-38-37](https://github.com/user-attachments/assets/0b451a75-966a-432d-93ff-83649f965c40)
![photo_2025-10-30_13-38-42](https://github.com/user-attachments/assets/8bf8a6cd-aa83-4f20-a096-924dd4ccd095)
![photo_2025-10-30_13-38-40](https://github.com/user-attachments/assets/c7924bf7-6775-46bb-ab04-c96cc1712b75)
![photo_2025-10-30_13-38-35](https://github.com/user-attachments/assets/345e805f-f34d-4051-8c0a-22c18a1f9825)
![photo_2025-10-30_13-38-33](https://github.com/user-attachments/assets/8c8aabd1-e8da-4690-a55d-d20fafc11484)


## 🛠️ Configuration

### config.lua (Optional)

Create `xray.koplugin/config.lua` for permanent settings:

```lua
return {
    -- API Keys
    gemini_api_key = "AIzaSy...",
    chatgpt_api_key = "sk-...",
    
    -- Default AI Provider
    default_provider = "gemini",  -- or "chatgpt"
    
    -- Gemini Model Selection
    gemini_model = "gemini-2.5-flash",  -- or "gemini-2.5-pro"
    
    -- Settings
    settings = {
        auto_load_cache = true,
        show_gender_icons = true,
    }
}
```

### File Locations

```
~/.config/koreader/
├── cache/xray/                 # Book data cache
│   └── book_hash_*.json
├── settings/xray/              # Plugin settings
│   ├── language.txt            # Selected language
│   └── notes/                  # Character notes
│       └── book_hash_*.json
└── plugins/xray.koplugin/      # Plugin files
    ├── main.lua
    ├── localization.lua
    ├── aihelper.lua
    ├── cachemanager.lua
    ├── chapteranalyzer.lua
    ├── characternotes.lua
    └── config.lua (optional)
```

---

## 💡 Tips & Tricks

### For Best Results

1. **Use original book titles**: "War and Peace" works better than "wp.epub"
2. **Include author name**: Helps AI identify the correct book
3. **Gemini Flash is great**: Free, fast, and accurate for most books
4. **Cache once, use forever**: No need to re-fetch unless you want updates

### Character Search Tips

- Search works with partial names: "john" finds "John Smith"
- Case-insensitive: "JOHN" = "john" = "John"
- First name search: "John" finds "John Smith"

### Historical Figures Detection

The plugin intelligently detects:
- **Direct references**: "Napoleon Bonaparte appears in Chapter 5"
- **Indirect references**: "The 1860s nihilist movement" → Adds key figures
- **Philosophical references**: Characters discussing "Hegel" → Adds Hegel
- **Period atmosphere**: Important figures of the book's era

Examples:
- **"Demons" (Dostoevsky)**: Finds Sergei Nechayev, Alexander Herzen, Vissarion Belinsky
- **"War and Peace"**: Finds Napoleon, Kutuzov, Alexander I
- **"1984"**: No historical figures (modern dystopia)

---

## 📚 Example Use Cases

### Classic Literature: "Crime and Punishment"

```
✓ Characters (15)
  - Raskolnikov (protagonist, student)
  - Sonya (poor girl, religious)
  - Porfiry (investigator)
  
✓ Timeline (8 events)
  - Chapter 1: Raskolnikov plans the crime
  - Chapter 2: The murder takes place
  - Chapter 5: First interrogation
  
✓ Historical Context
  - 1860s Russian nihilism movement
  - St. Petersburg urban poverty
```

### Historical Fiction: "War and Peace"

```
✓ Characters (100+) organized
✓ Historical Figures (20+)
  - Napoleon Bonaparte (1769-1821)
  - Mikhail Kutuzov (1745-1813)
  - Alexander I of Russia
  
✓ Locations (15+)
  - Moscow, Petersburg, Austerlitz
  
✓ Timeline
  - Battle of Austerlitz (1805)
  - French invasion of Russia (1812)
  - Battle of Borodino (1812)
```

### Modern Fiction: "The Great Gatsby"

```
✓ Characters (12)
  - Jay Gatsby (mysterious millionaire)
  - Nick Carraway (narrator)
  - Daisy Buchanan
  
✓ Themes
  - American Dream
  - Wealth and class
  - Love and obsession
  
✓ Locations
  - West Egg, East Egg, New York City
```

---

## 🌍 Supported Languages

### Interface Languages
- 🇹🇷 **Turkish** (Türkçe)
- 🇬🇧 **English**
- 🇵🇹 **Brazilian Português**

### AI Data Languages
AI automatically provides data in the selected interface language:
- Turkish interface → AI responses in Turkish
- English interface → AI responses in English
- Brazilian Português interface → AI responses in Português

### Adding New Languages

1. Edit `main.lua`
2. Add new language code (e.g., `de` for German)
3. Translate all strings in `de.po = { ... }`
4. Add prompt templates in `de.lua`
5. Done! 🎉

---

## 🔧 Technical Details

### Architecture

```
main.lua           → Plugin core, menu management
localization.lua   → Multi-language support
aihelper.lua       → AI integration (Gemini/ChatGPT)
cachemanager.lua   → Cache storage and retrieval
chapteranalyzer.lua → Chapter text analysis
characternotes.lua → Personal notes management
```

### AI Models

| Model | Cost | Speed | Quality | Token Limit |
|-------|------|-------|---------|-------------|
| Gemini 2.5 Flash | FREE | Fast | Good | 8K |
| Gemini 2.5 Pro | FREE | Medium | Excellent | 8K |
| GPT-3.5 Turbo | Paid | Fast | Good | 4K |

### Cache Format

```json
{
  "book_title": "Crime and Punishment",
  "author": "Fyodor Dostoevsky",
  "cached_at": 1735563600,
  "characters": [...],
  "locations": [...],
  "timeline": [...],
  "historical_figures": [...],
  "themes": [...],
  "summary": "..."
}
```

---

## ❓ FAQ

**Q: Is the API key safe?**
A: Yes, it's stored locally in KOReader. Never shared.

**Q: How much does it cost?**
A: Google Gemini has a generous free tier. Most users never pay.

**Q: Does it work offline?**
A: Yes! After initial fetch, everything is cached locally.

**Q: Can I use it on multiple devices?**
A: Yes, but cache is per-device. Fetch once per device.

**Q: Will it give spoilers?**
A: No! AI is explicitly instructed to avoid spoilers.

**Q: What if the book is not recognized?**
A: AI will try its best. You can also manually edit cache files.

**Q: Can I edit the data?**
A: Yes, cache files are JSON. Edit with any text editor.

**Q: Does it support graphic novels?**
A: Not yet. Text-based books only.

**Q: What about DRM-protected books?**
A: Plugin works with any book KOReader can open.

**Q: Can I contribute?**
A: Yes! See Contributing section below.

---

## 🐛 Troubleshooting

### "API key not set"
→ Go to Menu → X-Ray → AI Settings → Set API key

### "Failed to fetch AI data"
- Check internet connection
- Verify API key is correct (copy-paste from provider)
- Try clearing and re-entering API key
- Check API quota (Gemini free tier has limits)

### "No characters found in chapter"
- Make sure you're in a chapter (not title page)
- Try a different chapter
- Characters must be in main character list first

### Cache not loading
- Check file permissions in ~/.config/koreader/cache/xray/
- Try clearing cache and re-fetching

### Language not changing
- Language change requires menu reopen
- Check ~/.config/koreader/settings/xray/language.txt

---

## 🎯 Roadmap

### Planned Features
- [ ] More AI providers (Claude, local LLMs)
- [ ] Character relationship graph
- [ ] Custom AI prompts
- [ ] Quote extraction
- [ ] Series tracking (Book 1, 2, 3...)

### Under Consideration
- [ ] Character appearance highlighting in text
---

## 🤝 Contributing

Contributions are welcome! Here's how:

### Bug Reports
1. Open an issue on GitHub
2. Include KOReader version and e-Reader
3. Include error message (crash.log)
4. Describe steps to reproduce

### Feature Requests
1. Open an issue with "Feature Request" tag
2. Describe the feature
3. Explain use case

### Code Contributions
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit pull request

### Translations
1. Copy `localization.lua`
2. Add your language code
3. Translate all strings
4. Submit pull request

---

## 📜 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

- **KOReader Team** - For the amazing e-reader platform
- **Google Gemini Team** - For the free and powerful AI API
- **OpenAI** - For ChatGPT API
- **Beta Testers** - For valuable feedback
- **You** - For using X-Ray Plugin! 📖✨

---

## 📮 Support

- **GitHub Issues**: Report bugs and request features
---

## 🌟 Star History

If you find this plugin useful, please star the repository! ⭐

---

**Made with ❤️ for book lovers everywhere**

*Happy Reading! 📖✨*
