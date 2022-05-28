# QuickPrint Changelog


## v1.0.2: 2022-05-28

* Added `advanceXCoarse()`, which provides basic "snap to grid"-like positioning of the cursor X position.
* Added `setXMin()`, which moves the cursor X only if the current X position is less than the requested position.
* Split the string-accepting logic of `advanceX()` into a separate function: `advanceXStr()`.
* Added some single-axis versions of cursor position methods:
  * `setPosition()`: `setXPosition()` and `setYPosition()`
  * `getPosition()`: `getXPosition()` and `getYPosition()`
  * `movePosition()`: `moveXPosition()` and `moveYPosition()`


## v1.0.1: 2022-05-16

* Started changelog.
* Changed alignment priority: 1) explicit `align` function arguments, if specified, 2) tab stop `align` fields, if present, 3) the `qp` table's default `align` setting.

