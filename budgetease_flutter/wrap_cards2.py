import re
import os
import glob

def process_file(filepath):
    with open(filepath, 'r') as f:
        code = f.read()

    out = ""
    i = 0
    changed = False

    while i < len(code):
        # Chercher "Card("
        if code[i:].startswith("Card(") or code[i:].startswith("Card ("):
            prefix = code[:i]
            # Si déjà wrappé, ignorer (vérif simple des 150 derniers car)
            if "withSurfaceTheme(context, Builder(builder: (context) => " not in prefix[-150:]:
                # On parse les parenthèses
                start_paren = code.find('(', i)
                paren_count = 1
                curr = start_paren + 1
                while curr < len(code) and paren_count > 0:
                    if code[curr] == '(':
                        paren_count += 1
                    elif code[curr] == ')':
                        paren_count -= 1
                    curr += 1
                
                if paren_count == 0:
                    wrapped = "UIHelpers.withSurfaceTheme(context, Builder(builder: (context) => " + code[i:curr] + "))"
                    out += wrapped
                    i = curr
                    changed = True
                    continue
        out += code[i]
        i += 1
        
    if changed:
        if "ui_helpers.dart" not in out and "UIHelpers" in out:
            out = "import 'package:budgetease_flutter/core/utils/ui_helpers.dart';\n" + out
        with open(filepath, 'w') as f:
            f.write(out)
        print(f"Wrapped in {filepath}")
        return True
    return False

os.chdir('/home/kenzoobryan/eep/Budgetease/budgetease_flutter/lib')
files = glob.glob('**/*.dart', recursive=True)
count = 0
for f in files:
    if process_file(f):
        count += 1
print(f"Total wrapped: {count}")
