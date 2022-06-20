<!-- Generate `description.html` from this by using `$ md2html -o description.html description.md`. -->

The Microcontroller is a semi-advanced programmable component with a persistent
256 bit EEPROM memory.

Warning: This device is largely considered deprecated and might contain bugs. It
is recommended to use a Luacontroller instead.

Detailed documentation can be found below:

* The Microcontroller's code is executed whenever any of the following events
  happens:
  * The Microcontroller is programmed. In this case the EEPROM and ports are all
    reset to `0` before.
  * An incoming signal changes its state.
  * An `after` event happens (see command `after` below).
* There are 4 I/O ports (ABCD) and 256 EEPROM bits (1 to 256).
* The code consists of a sequence of commands.
* Everything after `:` is a comment.
* Strings are enclosed in `"`s.
* Spaces and tabs outside of strings are ignored.
* Basic command syntax:
  ```
      command_name`(`param1`,` param2`,` ...`)`
  ```
* Commands:
  * `if(condition) commands [> else_commands];`:
    Evaluates the given condition and takes the corresponding branch.
    The else branch is optional (as indicated by the `[` and `]`). The `>` is part
    of the syntax and indicates the start of the else branch. The `;` marks the
    end of the if command.
  * `on(port1, port2, ...)`:
    Sets the given ports to `1`.
  * `off(port1, port2, ...)`:
    Sets the given ports to `0`.
  * `print("string" or codition, ...)`:
    Evaluates the conditions and prints the concatenation of all params to stdout
    (only useful in singleplayer).
  * `after(time, "more commands")`:
    Executes the commands in the string after the given time in seconds.
    There can only be one waiting `after` event at once.
    Warning: This is not reliable, ie. `minetest.after` is used.
  * `sbi(port_or_eeprom, condition)`:
    Evaluates the condition and sets the port or EEPROM bit to the resulting value.
    Note: EEPROM indices don't use `#` here, ie. it's `sbi(1, #2)`, not `sbi(#1, #2)`.
* Conditions (sorted by descending precedence; they are all evaluated from left
  to right):
  * `0`, `1`: constant
  * `A`, ..., `D`: value of a port. Takes writes that already happened during the
    current execution into account.
  * `#1`, ..., `#256`: value of an EEPROM bit. Takes writes that already happened
    during the current execution into account.
  * `!condition`: negation (can only be applied once, ie. not `!!1`)
  * `condition1 = condition2`: XNOR (equality)
  * `condition1 op condition2` where `op` is one of:
    * `&`: AND
    * `|`: OR
    * `~`: XOR (inequality)
  * Note: Explicit precedence using parentheses is not supported.
