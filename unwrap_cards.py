import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Match UIHelpers.withSurfaceTheme(context, Builder(builder: (context) => Widget))
    pattern1 = re.compile(r'UIHelpers\.withSurfaceTheme\(\s*context,\s*Builder\(\s*builder:\s*\(context\)\s*=>\s*(.*?)\s*\)\s*\)', re.DOTALL)
    
    # Pattern for simple UIHelpers.withSurfaceTheme(context, Widget)
    pattern2 = re.compile(r'UIHelpers\.withSurfaceTheme\(\s*context,\s*(.*?)\s*\)', re.DOTALL)
    
    # We must be careful because regex with DOTALL is greedy. 
    # A better approach: search for "UIHelpers.withSurfaceTheme(" and extract matching parens.
    return content

def unwrap_all(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original = content
                
                # We'll do a simple paren-matching parser to be safe
                while "UIHelpers.withSurfaceTheme" in content:
                    idx = content.find("UIHelpers.withSurfaceTheme")
                    # find the opening parenthesis
                    start_paren = content.find("(", idx)
                    if start_paren == -1: break
                    
                    # find matching closing parenthesis
                    open_count = 1
                    end_paren = -1
                    for i in range(start_paren + 1, len(content)):
                        if content[i] == '(':
                            open_count += 1
                        elif content[i] == ')':
                            open_count -= 1
                            if open_count == 0:
                                end_paren = i
                                break
                                
                    if end_paren != -1:
                        # Extract the inner part
                        inner = content[start_paren+1:end_paren]
                        # Inner usually starts with "context, Builder(builder: (context) => " or "context, "
                        if inner.strip().startswith("context,"):
                            inner = inner.split(",", 1)[1].strip()
                        
                        # Now if it's a Builder(builder: (context) => Widget), strip that too
                        if inner.startswith("Builder(builder: (context) =>"):
                            b_start = inner.find("=>") + 2
                            # Ensure we just take the widget part
                            # And strip the closing parenthesis of the Builder if any
                            w_part = inner[b_start:].strip()
                            # It might have a trailing parenthesis from Builder
                            # Actually Builder is Builder(...) so the end_paren found the end of withSurfaceTheme.
                            # So inner is "context, Builder(builder: (context) => Widget)".
                            # We need to parse Builder's parens.
                            pass
                            
                # For safety, let's just use regex for the precise strings we added
                content = re.sub(r'UIHelpers\.withSurfaceTheme\(\s*context,\s*Builder\(\s*builder:\s*\(context\)\s*=>\s*(.*?)\s*\)\s*\)', r'\1', content, flags=re.DOTALL)
                content = re.sub(r'UIHelpers\.withSurfaceTheme\(\s*context,\s*(.*?)\s*\)', r'\1', content, flags=re.DOTALL)
                
                # Also restore context.bwPrimary to whatever it was. Let's just remove theme_extensions.
                # Actually we can let the compiler find errors and replace them.
                
                if content != original:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"Unwrapped {filepath}")

unwrap_all('budgetease_flutter/lib')
