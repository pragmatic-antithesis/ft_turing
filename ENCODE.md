# Encoding Guide (Unary Addition Machine)

## 1. Raw input format

The machine is encoded as a single string with sections separated by semicolons:

A<alphabet>;S<states>;I<initial>;F<final>;T<transitions>;I<input>

Example:

A1+=;Ss,d,H;Is;FH;Ts|r1,ts,w1,aR|r+,ts,w1,aR|r=,ts,w.,aL|Td|r1,th,w.,aR|;I#1111+11=

---

## 2. Sections

### A — Alphabet

A followed by a concatenation of all valid symbols.

Example:
A1+=

Meaning:
The only valid tape symbols are:
1, +, =

---

### S — States

S followed by comma-separated state identifiers.

Example:
Ss,d,H

Meaning:

* s = scanning state
* d = cleanup/delete state
* H = halting state

---

### I — Initial state

I followed by the start state.

Example:
Is

Meaning:
Start execution in state s

---

### F — Final state(s)

F followed by halting state(s).

Example:
FH

Meaning:
H is a halting state

---

### T — Transition blocks

Transitions are grouped by state.

Format:

T<state>|<rules>|<state>|<rules>|...

Example:

Ts|r1,ts,w1,aR|r+,ts,w1,aR|r=,ts,w.,aL|Td|r1,th,w.,aR|

---

### B — Blank symbol

Blank symbol is:

.

This symbol represents empty tape cells and is NOT part of the input alphabet.

## 3. Transition rule format

Each rule has four fields:

rX, tY, wZ, aD

Meaning:

* rX = read symbol X
* tY = next state Y
* wZ = write symbol Z
* aD = move direction

Direction:

* aR = move right
* aL = move left

Example:

r1,ts,w1,aR

Meaning:
If reading 1:

* go to state s
* write 1
* move right

---

## 4. Input tape

Final section:

I#1111+11=

Meaning:
Initial tape content is:

#1111+11=

---

## 5. Derived alphabet (expanded model)

If fully expanded into atomic symbols, the machine alphabet is:

A, 1, +, =, S, s, d, H, I, F, T, r, t, w, a, R, L, |, ,

---

## 6. Execution model (informal)

1. Start in state s
2. Read tape symbol
3. Find matching rule in current state's transition block
4. Apply write, move, and state update
5. Repeat until reaching H

---

## 7. Important constraint

This encoding is NOT universal.

It is a compiled description of a specific unary addition machine.

Blank symbol . is reserved and excluded from the declared input alphabet but remains part of execution semantics.
