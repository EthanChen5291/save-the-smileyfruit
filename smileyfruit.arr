include reactors
import lists as L
include image
# --- global variables 

WIDTH = 540

HEIGHT = 700

FALL-SPEED = 7

SPAWN-RATE = 2

FACE-COLORS = [list: "red", "violet", "orange", "dark blue", "purple", "green", "magenta", 
  "gold", "pink", "dark red", "indigo"]

ARROW-COLOR = "white"

FACE-RADIUS = 40

# --- background

#BG-IMG = image-url(```https://preview.redd.it/tips-for-drawing-background-like-these-v0-ulcyxst2au4d1.jpg?width=640&crop=smart&auto=webp&s=5344914af940c94896fd6ce118bb7c4ac133cf39```)

BG-IMG = rectangle(WIDTH, HEIGHT, "solid", "light blue")

BASE = place-image(scale(0.9, BG-IMG), WIDTH / 2, HEIGHT / 2,
  rectangle(WIDTH, HEIGHT, "solid", "white"))

START-LINE = rectangle(WIDTH, 2, "solid", "green")

END-LINE = rectangle(WIDTH, 2, "solid", "green")

BG = place-image(START-LINE, WIDTH / 2, HEIGHT * 2/3, 
  place-image(END-LINE, WIDTH / 2, HEIGHT * 5/6, BASE))

# --- zonal boundaries

DEATH-ZONE = rectangle(WIDTH, HEIGHT / 6, "outline", "brown")

TAP-ZONE-START = HEIGHT * 2/3

SAFE-ZONE-HEIGHT = TAP-ZONE-START

DEATH-ZONE-START = HEIGHT * 5/6

# --- drawing functions

fun make-smiley-face(color :: String, direction :: ArrowKey) -> Image:
  doc: "Creates a smiley face of color 'color' with an arrow of direction 'direction'"

  base = circle(FACE-RADIUS, "solid", color)

  arrow = triangle-sss(FACE-RADIUS * 9/8, FACE-RADIUS * 9/8, FACE-RADIUS * 3/4,
    "solid", ARROW-COLOR)

  directional-arrow = 
    cases (ArrowKey) direction:
      | up => rotate(180, arrow)
      | down => arrow
      | left => rotate(-90, arrow)
      | right => rotate(90, arrow)
    end

  centering-correction = FACE-RADIUS * (1/13) 
  # the default/rotated triangle is roughly (1/13) from the center

  base-with-arrow =
    cases (ArrowKey) direction:
      | up => 
        place-image(directional-arrow, FACE-RADIUS, FACE-RADIUS - centering-correction, base)
      | down => 
        place-image(directional-arrow, FACE-RADIUS, FACE-RADIUS + centering-correction, base)
      | left => 
        place-image(directional-arrow, FACE-RADIUS + centering-correction, FACE-RADIUS, base)
      | right => 
        place-image(directional-arrow, FACE-RADIUS - centering-correction, FACE-RADIUS, base)
    end

  eye = circle(FACE-RADIUS / 10, "solid", "black")
  eyes = place-image(eye, FACE-RADIUS * 0.7, FACE-RADIUS * 0.8,
    place-image(eye, FACE-RADIUS * 1.3, FACE-RADIUS * 0.8, base-with-arrow))
  mouth = ellipse(FACE-RADIUS * 0.6, FACE-RADIUS * 0.2, "solid", "black")

  place-image(mouth, FACE-RADIUS, FACE-RADIUS * 1.4, eyes)
end

check "'make-smiley-face' draws a smiley-face with an arrow corresponding to 'direction'": 
  arrow = triangle-sss(FACE-RADIUS * 9/8, FACE-RADIUS * 9/8, FACE-RADIUS * 3/4,
    "solid", ARROW-COLOR)
  eye = circle(FACE-RADIUS / 10, "solid", "black")
  mouth = ellipse(FACE-RADIUS * 0.6, FACE-RADIUS * 0.2, "solid", "black")
  centering-correction = FACE-RADIUS * (1/13)

  red-base = circle(FACE-RADIUS, "solid", "red")
  red-base-with-arrow = place-image(
    rotate(180, arrow), FACE-RADIUS, FACE-RADIUS - centering-correction, red-base)
  red-eyes = place-image(eye, FACE-RADIUS * 0.7, FACE-RADIUS * 0.8,
    place-image(eye, FACE-RADIUS * 1.3, FACE-RADIUS * 0.8, red-base-with-arrow))

  make-smiley-face("red", up) is place-image(mouth, FACE-RADIUS, FACE-RADIUS * 1.4, red-eyes)
  make-smiley-face("yellow", up) is-not place-image(mouth, FACE-RADIUS, FACE-RADIUS * 1.4, red-eyes)
end

fun make-flat-face(color :: String) -> Image:
  doc: "Draws a flattened face of color 'color'."
  ellipse(FACE-RADIUS * 3, FACE-RADIUS * 0.80, "solid", color)
end

check "make-flat-face makes an ellipse of color 'color'":
  make-flat-face("red") is ellipse(FACE-RADIUS * 3, FACE-RADIUS * 0.80, "solid", "red")
  make-flat-face("aqua") is ellipse(FACE-RADIUS * 3, FACE-RADIUS * 0.80, "solid", "aqua")
end

# --- reactor functions

data Pt2:
  | pt2(x :: Number, y :: Number) 
end

data Face:
  | face(pt2 :: Pt2, color :: String, fall-depth :: Number, direction :: ArrowKey)
end

data ArrowKey:
  | up
  | left
  | right
  | down
end

fun maybe-add-faces(faces :: List<Face>) -> List<Face>:
  doc: ```Has a chance of adding random smiley-faces to 'faces'.
       This chance is directly proportional to the 'SPAWN-RATE' variable```
  probability = num-random(50 / SPAWN-RATE)

  if (probability == 1):
    link(
      face(pt2(random-x-val(), 0), random-color(), random-fall-depth(), random-direction()), faces)
  else:
    faces
  end
end

check "maybe-add-faces adds faces correctly with all valid list inputs":
  single-face = [list: face(pt2(0, 0), "red", 23, left)]
  multiple-faces = 
    [list: face(pt2(23, 2), "beige", 23, left), face(pt2(7, 35), "yellow", 23, left)]

  result-empty = maybe-add-faces(empty)
  result-single = maybe-add-faces(single-face)
  result-multiple = maybe-add-faces(multiple-faces)

  result-empty.length() >= 0 is true
  result-single.length() >= single-face.length() is true
  result-multiple.length() >= multiple-faces.length() is true
end

fun move-one(f :: Face) -> Face:
  doc: ```Moves the face downward by 'FALL-SPEED' in the safe zone
       and tap zone. Faces stop moving in the DEATH-ZONE```
  p = f.pt2 
  color = f.color

  if (p.y >= DEATH-ZONE-START):
    face(pt2(p.x, p.y), color, f.fall-depth, f.direction)
  else:
    face(pt2(p.x, p.y + FALL-SPEED), color, f.fall-depth, f.direction)
  end
end

check "move-one doesn't move faces in 'DEATH-ZONE'":
  y-val-in-death-zone = DEATH-ZONE-START
  y-val-in-death-zone2 = HEIGHT

  move-one(face(pt2(45, y-val-in-death-zone), "yellow", 27, left)) is 
  face(pt2(45, y-val-in-death-zone), "yellow", 27, left)
  move-one(face(pt2(45, y-val-in-death-zone2), "orange", 12, left)) is 
  face(pt2(45, y-val-in-death-zone2), "orange", 12, left)
end

check "move-one moves faces in the safe-zone down by FALL-SPEED":
  y-val-in-safe-zone = 0
  y-val-in-safe-zone2 = 25

  move-one(face(pt2(0, y-val-in-safe-zone), "red", 23, left)) is 
  face(pt2(0, y-val-in-safe-zone + FALL-SPEED), "red", 23, left)
  move-one(face(pt2(0, y-val-in-safe-zone2), "aqua", 18, left)) is 
  face(pt2(0, y-val-in-safe-zone2 + FALL-SPEED), "aqua", 18, left)
end

fun move(faces :: List<Face>) -> List<Face>:
  doc: ```Moves every face in 'faces' downward unless it's in the death zone.
       Has a chance of adding faces to the moved list.```
  maybe-add-faces(map(move-one, faces))
end

check "'move' maintains valid structure and behavior given different list types":
  y-val-in-death-zone = DEATH-ZONE-START
  y-val-in-safe-zone = 0
  single-face = [list: face(pt2(0, y-val-in-safe-zone), "red", 23, left)]
  multiple-faces = [list: face(pt2(23, y-val-in-safe-zone), "beige", 23, left), 
    face(pt2(7, y-val-in-death-zone), "yellow", 23, left)]

  empty-result = move(empty)
  single-face-result = move(single-face)
  multiple-faces-result = move(multiple-faces)

  # --- length checks
  empty-result.length() >= 0 is true
  single-face-result.length() >= single-face.length() is true
  multiple-faces-result.length() >= multiple-faces.length() is true

  # --- moves each face correctly
  single-face-result.member(
    face(pt2(0, y-val-in-safe-zone + FALL-SPEED), "red", 23, left)) is true
  multiple-faces-result.member(
    face(pt2(23, y-val-in-safe-zone + FALL-SPEED), "beige", 23, left)) is true
  multiple-faces-result.member(
    face(pt2(7, y-val-in-death-zone), "yellow", 23, left)) is true
end

fun show-one(img :: Image, f :: Face) -> Image:
  doc: ```Draws a smiley face from 'f' unless 'f''s position is
       in the death-zone, in which it draws a flattened face.```
  p = f.pt2
  color = f.color

  if (p.y >= DEATH-ZONE-START):
    flat = make-flat-face(color)
    place-image(flat, p.x, p.y + f.fall-depth, img)
  else:
    new-face = make-smiley-face(color, f.direction)
    place-image(new-face, p.x, p.y, img)
  end
end

check "'show-one' draws a flattened face if inside 'DEATH-ZONE'":
  death-face = face(pt2(0, DEATH-ZONE-START), "yellow", 18, up)

  yellow-flat-face = make-flat-face("yellow")
  show-one(BG, death-face) is 
  place-image(yellow-flat-face, 0, DEATH-ZONE-START + 18, BG)
end

check "'show-one' draws a normal face if outside 'DEATH-ZONE'":
  y-val-in-safe-zone = 0
  safe-face = face(pt2(0, y-val-in-safe-zone), "red", 23, left)

  normal-red-face = make-smiley-face("red", left)
  show-one(BG, safe-face) is 
  place-image(normal-red-face, 0, y-val-in-safe-zone, BG)
end

fun show(faces :: List<Face>) -> Image:
  doc: "Produces an image of all the faces in 'faces'"
  fold(show-one, BG, faces)
end

check "'show' draws correct image for multiple faces":
  safe-face = face(pt2(0, 0), "red", 23, left)
  death-face = face(pt2(10, DEATH-ZONE-START), "yellow", 18, up)

  normal-red-face = make-smiley-face("red", left)
  yellow-flat-face = make-flat-face("yellow")

  expected-image = place-image(yellow-flat-face, 10, DEATH-ZONE-START + 18, 
    place-image(normal-red-face, 0, 0, BG))

  show(empty) is BG
  show([list: safe-face]) is place-image(normal-red-face, 0, 0, BG)
  show([list: death-face]) is place-image(yellow-flat-face, 10, DEATH-ZONE-START + 18, BG)
  show([list: safe-face, death-face]) is expected-image
end

fun arrow-converter(key :: String) -> Option<ArrowKey>:
  doc: ```Converts 'key' into a ArrowKey data type if applicable.
       Takes both 'WASD' and 'up/down/left/right' keysets, otherwise produces 'none'.```
  lowered-key = string-to-lower(key)
  ask: 
    | ((lowered-key == "up") or (lowered-key == "w")) then: some(up)
    | ((lowered-key == "down") or (lowered-key == "s")) then: some(down)
    | ((lowered-key == "left") or (lowered-key == "a")) then: some(left)
    | ((lowered-key == "right") or (lowered-key == "d")) then: some(right)
    | otherwise: none
  end
end

check "'arrow-converter' matches WASD and arrow keys to their corresponding ArrowKey":
  arrow-converter("up") is some(up)
  arrow-converter("w") is some(up)

  arrow-converter("left") is some(left)
  arrow-converter("a") is some(left)

  arrow-converter("down") is some(down)
  arrow-converter("s") is some(down)

  arrow-converter("right") is some(right)
  arrow-converter("d") is some(right)
end

check "'arrow-converter' returns 'none' if given non-WASD/arrow keys":
  arrow-converter("r") is none
  arrow-converter("enter") is none
  arrow-converter("2") is none
  arrow-converter("") is none
end

fun save-face(faces :: List<Face>, key :: String) -> List<Face>:
  doc: ```Removes one face when its corresponding arrow key 'key'
       is pressed in the tap zone in order of lowest to highest y-position.```
  arrow-key-opt = arrow-converter(key)
  rev-faces = L.reverse(faces) # oldest -> newest

  fun helper(rev :: List<Face>) -> List<Face>:
    cases (List) rev-faces:
      | empty => empty
      | link(f, r) => 
        p = f.pt2
        in-tap-zone = (p.y >= TAP-ZONE-START) and (p.y < DEATH-ZONE-START)

        arrow-matches = 
          cases (Option) arrow-key-opt:
            | some(v) => v == f.direction
            | none => false
          end

        if (in-tap-zone and arrow-matches):
          r
        else:
          link(f, save-face(r, key))
        end
    end
  end
  L.reverse(helper(rev-faces))
end

check "save-faces only removes faces if its arrow key is pressed while in the tap zone":
  y-val-in-tap-zone = TAP-ZONE-START
  y-val-in-safe-zone = 0
  safe-face = [list: face(pt2(0, y-val-in-safe-zone), "red", 23, left)]
  tap-face = [list: face(pt2(0, y-val-in-tap-zone), "red", 23, right)]
  multiple-faces = [list: face(pt2(23, y-val-in-safe-zone), "beige", 23, left), 
    face(pt2(7, y-val-in-tap-zone), "yellow", 23, up)]

  save-face(safe-face, "left") is safe-face
  save-face(tap-face, "left") is tap-face
  save-face(tap-face, "right") is empty
  save-face(multiple-faces, "left") is multiple-faces
  save-face(multiple-faces, "up") is [list: face(pt2(23, y-val-in-safe-zone), "beige", 23, left)]
  save-face(empty, "up") is empty
end

check "save-faces only removes one applicable face at a time":
  y-val-in-tap-zone = TAP-ZONE-START
  dupe-faces = [list: face(pt2(23, y-val-in-tap-zone), "beige", 23, left), 
    face(pt2(23, y-val-in-tap-zone), "beige", 23, left)]
  save-face(dupe-faces, "left") is [list: face(pt2(23, y-val-in-tap-zone), "beige", 23, left)]
end

fun random-color() -> String:
  doc: "Generates a random color from the 'FACE-COLORS' list"
  index = num-random(FACE-COLORS.length())
  L.get(FACE-COLORS, index)
end

check "random-color only picks colors from 'FACE-COLORS' list":
  for each(_ from range(0, 20)):
    color = random-color()
    FACE-COLORS.member(color) is true
  end
end

fun random-fall-depth() -> Number:
  doc: "Produces a random variation to the height of each face's 'splatter'"
  base-fall-distance = (6 * FALL-SPEED)
  some-variation = num-random(image-height(DEATH-ZONE) / 3) - (image-height(DEATH-ZONE) / 6)

  base-fall-distance + some-variation
end

check "fall-depth is confined to 'DEATH-ZONE's zone":
  for each(_ from range(0, 20)):
    depth = random-fall-depth()
    (((DEATH-ZONE-START + depth) >= DEATH-ZONE-START) and 
      ((DEATH-ZONE-START + depth) <= HEIGHT)) is true
  end
end

fun random-x-val() -> Number: 
  doc: ```Generates a random x-value spanning BG width while keeping 
       the center of the face at least FACE-RADIUS away from edges```
  total-span = WIDTH - (2 * FACE-RADIUS)
  centered-span = num-random(total-span + 1) + FACE-RADIUS

  centered-span
end

check "'random-x-val' stays within bounds":
  min-val = FACE-RADIUS
  max-val = WIDTH - FACE-RADIUS

  for each(_ from range(0, 20)):
    val = random-x-val()
    (val >= min-val) and (val <= max-val) is true
  end
end

fun random-direction() -> ArrowKey:
  doc: "Generates a random arrow-key direction."
  lst = [list: up, down, left, right]
  L.get(lst, num-random(4))
end

check "random-direction only produces viable ArrowKey data types":
  valid-directions = [list: up, down, left, right]

  for each(_ from range(0, 20)):
    direction = random-direction()
    valid-directions.member(direction) is true
  end
end

vr = reactor:
  init: [list: face(
        pt2(random-x-val(), 0), random-color(), random-fall-depth(), random-direction())], 
  on-tick: move, 
  on-key: save-face,
  to-draw: show
end

check "checks in reactor 'vr' that faces accumulate over time":
  initial-state = empty

  state1 = move(initial-state)
  state2 = move(state1)
  state3 = move(state2)
  state4 = move(state3)
  state5 = move(state4)

  (state5.length() >= 0) is true # is this a valid test
end

check "checks in reactor 'vr' to verify a face moves and gets removed in tap zone":
  initial-state = [list: face(pt2(270, TAP-ZONE-START), "red", 35, up)]
  initial-face = initial-state.first

  moved-face1 = move-one(initial-face)
  moved-face2 = move-one(moved-face1)
  moved-face3 = move-one(moved-face2)

  # --- ensures face moves down
  moved-face3.pt2.y > initial-face.pt2.y is true

  # --- ensures face gets removed with key press
  after-key-press = save-face([list: moved-face3], "up")
  after-key-press.length() == 0 is true
end

check "checks in reactor 'vr' to verify that pressing wrong key doesn't remove face":
  tap-zone-face = [list: face(pt2(270, TAP-ZONE-START), "red", 35, up)]

  on-wrong-key = save-face(tap-zone-face, "down")
  on-wrong-key2 = save-face(on-wrong-key, "a")
  on-wrong-key2 is tap-zone-face

  on-right-key = save-face(tap-zone-face, "up")
  on-right-key is empty
end

check "checks in reactor 'vr' that faces stop moving after reaching death zone":
  almost-dead-face = [list: face(pt2(270, DEATH-ZONE-START - FALL-SPEED), "red", 35, up)]

  dead-zone-face = move-one(almost-dead-face.first)

  moved-dead-zone-face = move-one(dead-zone-face)

  dead-zone-face.pt2.y is moved-dead-zone-face.pt2.y
end

check "checks in reactor 'vr' that faces never move below the screen":
  test-face = face(pt2(270, HEIGHT - 1), "red", 35, up)
  moved = move-one(test-face)
  moved.pt2.y <= HEIGHT is true
end