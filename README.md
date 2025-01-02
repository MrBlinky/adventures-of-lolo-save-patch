# adventures-of-lolo-save-patch
Save patch for Adventures of Lolo Gameboy rom

This patch saves the password of the last completed (or failed) stage to the (battery backed up) save ram. The next time you play you can choose the continue option and the password will be filled in already with the cursor pointing at last password character. Pressing the A button will complete the password and start the game from the selected stage. Entering other passwords is still  possible by deleting the filled in password by pressing the B button repeatedly. If the B button was pressed accidentally and erased a password character, you can press START + SELECT + B + A to reset out of the password screen.

### Supported game
| Title                                | SHA-1                                    |
| ------------------------------------ | ---------------------------------------- |
| Adventures of Lolo (U) (S)           | e09277358a7fd4f3a6206464dd9d39f3abe66a53 |

### Patching

An IPS patch file is included and can be applied using your favorite (online)
IPS patcher. If you want to to build the patch from source then RGBASM is
required. Put the files of this repo in a folder structure like this:

<pre>
.\rgbasm                                   Folder containing RGBASM executables.
.\patches\adventures-of-lolo-gb-save-patch Folder to put the files of this repo.
</pre>

Put the 'Adventures of Lolo (U) (S).gb' rom in the project folder and run patch-rom.bat
a copy of the rom is patched and saved with 'save patch' appended to the filename.
