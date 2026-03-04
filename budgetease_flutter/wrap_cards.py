import re
import os

def balanced_paren_replace(code):
    out = ""
    i = 0
    changed = False
    while i < len(code):
        # Look for "Card("
        match = re.match(r"(?:return\s+)?Card\s*\(", code[i:])
        if match:
            # Check if it is already wrapped
            # simple check: if the previous non-whitespace characters are "=>" or "," it might be a child, but if it is preceded by "withSurfaceTheme(" it is wrapped
            prefix = code[:i]
            if "withSurfaceTheme(context, Builder(builder: (context) => " not in prefix[-100:]:
                # We need to find the matching parenthesis
                start_idx = i + match.end() - 1 # index of '('
                paren_count = 1
                curr = start_idx + 1
                while curr < len(code) and paren_count > 0:
                    if code[curr] == '(': paren_count += 1
                    elif code[curr] == ')': paren_count -= 1
                    curr += 1
                
                if paren_count == 0:
                    # We found the end of the Card.
                    # Replace Card(...) with UIHelpers.withSurfaceTheme(context, Builder(builder: (context) => Card(...)))
                    wrapped = "UIHelpers.withSurfaceTheme(context, Builder(builder: (context) => " + code[i:curr] + "))"
                    out += wrapped
                    i = curr
                    changed = True
                    continue
        out += code[i]
        i += 1
    return out, changed

import glob
os.chdir('/home/kenzoobryan/eep/Budgetease/budgetease_flutter/lib')
files = glob.glob('**/*.dart', recursive=True)
count = 0

for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    new_content, changed = balanced_paren_replace(content)
    
    if changed:
        # Check if UIHelpers is imported
        if "ui_helpers.dart" not in new_content and "UIHelpers" in new_content:
            new_content = "import 'package:budgetease_flutter/core/utils/ui_helpers.dart';\n" + new_content
            
        with open(f, 'w') as file:
            file.write(new_content)
        print(f"Wrapped Card in {f}")
        count += 1

print(f"Total wrapped: {count}")
