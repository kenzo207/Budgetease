import os
import glob
import re

os.chdir('/home/kenzoobryan/eep/Budgetease/budgetease_flutter')

files = glob.glob('lib/**/*.dart', recursive=True)

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    orig = content
    
    # Remplacements exacts de la syntaxe
    content = content.replace('Theme.of(context).colorScheme.primary', 'context.bwPrimary')
    content = content.replace('Theme.of(context).colorScheme.onSurface', 'context.bwOnSurface')
    content = content.replace('Theme.of(context).colorScheme.surfaceContainerHighest', 'context.bwSurfaceContainerHighest')
    content = content.replace('Theme.of(context).colorScheme.surface', 'context.bwSurface')
    content = content.replace('Theme.of(context).textTheme', 'context.textTheme')
    content = content.replace('Theme.of(context).brightness', 'context.theme.brightness')
    
    if orig != content:
        import_stmt = "import 'package:budgetease_flutter/core/utils/theme_extensions.dart';"
        
        if import_stmt not in content and "theme_extensions.dart" not in content and 'lib/core/utils/theme_extensions.dart' not in f:
            # Check for multiple lines of import
            import_matches = list(re.finditer(r'^import .*?;$', content, re.MULTILINE))
            if import_matches:
                last_import = import_matches[-1]
                content = content[:last_import.end()] + '\n' + import_stmt + content[last_import.end():]
            else:
                content = import_stmt + '\n\n' + content
                
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)

print(f"\nRemplacement des syntaxes terminé.")
