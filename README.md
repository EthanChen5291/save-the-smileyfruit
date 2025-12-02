SmileyFruit Drop (Pyret) v1.0

================================ OVERVIEW ================================

SmileyFruit Drop is a small, self-contained game built in Pyret using the reactors library. It’s a fast-paced falling-object game: smiley fruit descend from the top of the screen, each marked with a direction. Your job is simple—press the matching key (arrow keys or WASD) as a face enters the tap zone. Hit the right key and the face disappears. Miss it, and it “splats” dramatically in the death zone.
The project explores reactive programming, functional state updates, and custom rendering using Pyret’s image library. Everything—movement, spawning, interaction, and drawing—is broken into pure helper functions backed by a thorough test suite.

================================ FEATURES ================================
- Dynamic falling objects with randomized color, direction, and fall depth
- Tap-zone timing mechanic akin to those of rhythm games
- Splat animation effect for fruit reaching the death zone
- Real-time input handling through on-key events
- Clean, functional design built around pure helpers
- Strong focus on correctness through extensive checks

============================ RUNNING THE GAME ============================
1. Open the file in the Pyret editor (pyret.org).
2. Ensure that the reactors, image, and lists libraries are available.
3. Click Run.
4. After all tests pass, type 'vr.interact()' without the single-quotes.
5. Use the arrow keys or WASD to remove (save) fruit as they enter the tap zone.

================================ GAMEPLAY ================================

-- Spawning --

Fruit spawn at randomized positions, colors, and directional arrows. The spawn rate and falling speed can be adjusted through top-level constants.

--- Zones ---
- Safe Zone: Fruit fall normally.
- Tap Zone: The window in which a press can remove the fruit. Bordered by two green lines.
- Death Zone: Fruit flatten and stop moving, marking a failed catch.

--- Input ---
A fruit is removed only if:
- It is inside the tap zone, and
- The pressed key matches the fruit’s direction.

======================== DESIGN AND CODE STRUCTURE ========================

The program is broken into clear subsystems:

--- Rendering ---

Custom functions draw smileyfruit, squashed fruit, and the full game scene. Image composition is handled through place-image layering.

--- Movement ---

Pure functions move fruit downward, respecting the death zone and applying fall depth to splatter height.

--- Spawning ---

Randomized color, x-position, direction, and fall depth are generated through controlled helper functions.

--- Interaction ---

Conversion from keyboard input to ArrowKey data types and fruit removal logic based on tap-zone position and direction matching.

--- Reactor Loop ---

The reactor ties everything together via on-tick (movement/spawn), on-key (removal), and to-draw (rendering) handlers.

--- Data Types ---

Custom types (Pt2, Face, ArrowKey) keep the game state structured and predictable.

--- Testing ---

The project includes a complete suite of checks validating:
- Movement behavior across all zones
- Splatter logic
- Input matching and removal conditions
- Random generation within bounds
- Image rendering for safe and death zones
- Reactor behavior over multiple ticks

These tests ensure that each subsystem behaves as intended and that gameplay remains consistent.

Project Notes...
SmileyFruit Drop is a compact but full-featured example of building interactive programs in Pyret. It demonstrates how reactors, pure functions, and image composition can come together to form a coherent, playful experience while still remaining rigorous and testable.
