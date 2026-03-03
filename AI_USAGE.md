AI Usage Report, Spaceflight News App  
Tools Used  
Claude 3.5 Sonnet, Used for initial coding help and brainstorming.

How I Balanced the Work, The 50/50 Split  
I estimate that around 50% of the project was assisted by AI. I mainly used it to handle the routine tasks, such as writing basic API models and setting up folder structures, while I took care of the actual logic, state management choices, and platform-specific fixes.

1. Structure & Scaffolding  
   I started by asking Claude to suggest a folder layout for Clean Architecture with BLoC. It provided a good starting point, but I didn't accept it without changes.

What I changed, I pushed back on the database choice. The AI suggested Hive, but I chose to use sqflite instead. I wanted a relational structure to eventually add more complex filters or search features that SQL manages better.

2. BLoC State Management  
   The AI's first draft for the News BLoC used the usual "Sealed Class" approach (Loading, Loaded, Error).

Why I rejected it, I found it too rigid for pagination. If the user is at the bottom of the list and we fetch more items, a "Loading" state would hide the current list.

My decision, I opted for a Single State approach using copyWith. This lets the UI continue showing old news while a small spinner appears at the bottom for new data.

3. Fixing the Caching Logic, My Key Improvement  
   This was significant. The AI initially wrote code that cleared the entire local database before making the API call.

The Problem, if the internet cut out mid-way, the user would be left with a blank screen.

My Fix, I restructured the logic so that the old data is only cleared after a successful API response. This ensures that even if a refresh fails, the user still sees their previously cached news.

4. UI & Animations  
   I had the AI assist with the math for the staggered list animations, but I integrated the Hero transitions for the images myself. I also had to custom-code the "Read More" interaction because the AI didn't handle opening external links correctly for modern mobile OS versions.

5. Debugging & Platform Fixes  
   The AI was somewhat outdated on Android 11+ requirements. When I tried to open news articles, the app either crashed or did nothing.

The Fix, I discovered (through my own troubleshooting) that I needed to add <queries> tags to the AndroidManifest.xml for url_launcher to work. The AI missed this, so I had to manually update the manifest files.