import os
import glob
import re

os.chdir('/home/kenzoobryan/eep/Budgetease/budgetease_flutter/lib')
files = glob.glob('**/*.dart', recursive=True)

count = 0

for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    # We want to replace "Card(" with "UIHelpers.withSurfaceTheme(context, Builder(builder: (context) => Card("
    # But only if it's not already wrapped.
    # To find the matching closing parenthesis of the Card, we can just replace "return Card(" with "return UIHelpers..." and find the trailing ";" to add "))"
    # Even simpler: we can just manually replace them in the 12 files if it's too risky.
    
    # Actually, we can just do a regex substitution:
    # Instead of wrapping Card, we can just change the card color to black/white and the text color to white/black globally in Theme?
    pass
