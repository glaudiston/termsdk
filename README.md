# Bash ANSI Terminal Codes Library

A lightweight, modular Bash library providing a comprehensive set of ANSI escape sequences and helper functions to control terminal 
behavior, styling, and cursor positioning.

This library abstracts the complexity of raw ANSI escape codes into readable constants and reusable functions, making it easier to build 
Terminal User Interfaces (TUIs) and visually rich CLI tools using pure Bash.

## 🚀 Features

### 🎨 Colors & Styling
- **SGR Support**: Bold, Dim, Italic, Underline, Blink, Invert, and Strikethrough.
- **Color Depth**: 
  - Standard 16 colors (Foreground/Background, Standard/Bright).
  - 8-bit (256 colors) support.
  - 24-bit (TrueColor RGB) support.
- **Helper**: `term_color` function for dynamic color assignment.

### 🖱️ Cursor & Screen Control
- **Movement**: Move cursor up, down, left, right, or to a specific `row;col` coordinate.
- **Positioning**: Save and restore cursor positions.
- **Detection**: `term_cursor_pos` to query the current cursor position from the terminal.
- **Visibility**: Toggle cursor visibility on/off.
- **Screen Management**: Clear screen, handle line wrapping, and toggle the Alternative Screen Buffer (useful for full-screen apps).

### 🛠️ Advanced Controls
- **Scrolling**: Define top and bottom scroll margins.
- **OSC Commands**: Change the terminal window title via `term_title`.
- **Diagnostics**: `term_color_print_8bit_pallete` to visualize the 256-color palette.

## 📦 Installation

Clone the repository and source the script into your Bash project:

```bash
source path/to/ansi_term_codes.sh
```

*Note: This library depends on `pragma_once.sh` for include-guarding.*

## 🛠 Usage Examples

### Styling Text
```bash
source ./ansi_term_codes.sh

# Simple color constants
echo "${TERM_COLOR_RED}This is red text${TERM_COLOR_RESET}"

# Dynamic colors via function
term_color "magenta" "foreground" "bright"
echo " This is bright magenta"
TERM_COLOR_RESET
```

### Moving the Cursor
```bash
source ./ansi_term_codes.sh

term_move "down" 5
term_move 10 20 # Move to row 10, col 20
echo "Hello from a specific coordinate!"
```

### Setting the Window Title
```bash
source ./ansi_term_codes.sh
term_title "My Awesome Bash App"
```

## 📜 License

This project is licensed under **Creative Commons**. Please refer to the LICENSE file for more details.
