# 🧮 CalcSet — A Simple Set Calculator  

**Author:** Randrianaivo Kevin  
**Objective:** This project was created for educational purposes. You’re welcome to use or modify the code freely.  

---

## 📘 Overview
CalcSet is a **command-line calculator for mathematical sets**, built using **Flex** (the lexical analyzer generator) and **Bison** (the parser generator).  
It supports defining sets, performing set operations, comparing sets, and even simple conditional statements.

This project demonstrates how to build a small language and interpreter using classic compiler construction tools — perfect for students learning about **lexical analysis**, **parsing**, and **syntax-directed evaluation**.

---

## ⚙️ Tools Used

### **Bison**
- Used to define the **grammar** of the set language.
- Handles parsing, expression evaluation, and variable management.

### **Flex**
- Used to define the **lexical rules** (how text input is split into tokens).
- Recognizes numbers, identifiers, keywords (`let`, `if`, `DO`, `ELSE`), and operators (`+`, `-`, `^`, `x` or `*`).

---

## 💡 Features

- **Set definition**
  ```text
  let A = {1, 2, 3}
  let B = {2, 3, 4}
  ```
- **Basic operations**
  - Union → `A + B`
  - Difference → `A - B`
  - Intersection → `A ^ B`
  - Cartesian product → `A x B` (or `A * B`)
- **Set comparison**
  ```text
  A == B
  A != B
  ```
- **Conditional statements**
  ```text
  if (A != B) DO A + B ELSE A ^ B
  ```
- **Print sets automatically**
  Each operation prints the resulting set directly.

---

## 🧩 Example Session

```
CalcSet — set-only language
Type commands like:
  let A = {1,2}
  let B = {2,3}
  A + B
  A x B
  A == B
  if (A != B) DO A + B ELSE A ^ B

> let A = {1,2}
Defined A
> let B = {2,3}
Defined B
> A + B
{1, 2, 3}
> A x B
{(1, 2), (1, 3), (2, 2), (2, 3)}
> A == B
false
```

---

## 🛠️ Building the Project

### **Requirements**
- GCC (or MinGW on Windows)
- [Flex](https://github.com/westes/flex)
- [Bison](https://www.gnu.org/software/bison/)

### **Build Instructions**
From the terminal:

```bash
bison -d calcset.y
flex calcset.l
gcc -o calcset calcset.tab.c lex.yy.c -lfl
```

Then run:
```bash
./calcset
```

*(On Windows, use `calcset.exe` instead.)*

---

## 🧠 Learning Outcomes

Through this project, you’ll learn:
- How a lexer converts text into tokens (Flex)
- How a parser analyzes grammar structure (Bison)
- How semantic actions evaluate expressions
- How to manage variables and data structures (like sets) in a small interpreter

---

## 📜 License

This project is provided **for educational use**.  
You’re free to copy, modify, and share it with proper credit.
