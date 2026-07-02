import os
import re

directory = 'lib/features'

replacements = [
    (r'const Color\(0xFFFFE0B2\)', 'AppColors.warningContainer'),
    (r'const Color\(0xFFECF5FE\)', 'AppColors.surfaceContainerLow'),
    (r'Color\(0x0D002349\)', 'AppColors.primaryContainer.withValues(alpha: 0.05)'),
    
    (r'Radius\.circular\(\s*4(?:\.0)?\s*\)', 'AppRadii.sm'),
    (r'Radius\.circular\(\s*8(?:\.0)?\s*\)', 'AppRadii.defaultRadius'),
    (r'Radius\.circular\(\s*12(?:\.0)?\s*\)', 'AppRadii.md'),
    (r'Radius\.circular\(\s*16(?:\.0)?\s*\)', 'AppRadii.lg'),
    (r'Radius\.circular\(\s*24(?:\.0)?\s*\)', 'AppRadii.xl'),
    
    (r'BorderRadius\.circular\(\s*4(?:\.0)?\s*\)', 'AppRadii.borderSm'),
    (r'BorderRadius\.circular\(\s*8(?:\.0)?\s*\)', 'AppRadii.borderDefault'),
    (r'BorderRadius\.circular\(\s*12(?:\.0)?\s*\)', 'AppRadii.borderMd'),
    (r'BorderRadius\.circular\(\s*16(?:\.0)?\s*\)', 'AppRadii.borderLg'),
    (r'BorderRadius\.circular\(\s*24(?:\.0)?\s*\)', 'AppRadii.borderXl'),
    
    (r'(?<!Pdf)Colors\.red', 'AppColors.error'),
    (r'(?<!Pdf)Colors\.green', 'AppColors.success'),
    (r'(?<!Pdf)Colors\.amber', 'AppColors.warning'),
    (r'(?<!Pdf)Colors\.grey\.shade400', 'AppColors.outlineVariant'),
    (r'(?<!Pdf)Colors\.grey\.shade600', 'AppColors.outline'),
    (r'(?<!Pdf)Colors\.grey\.shade100', 'AppColors.surfaceContainerHigh'),
    (r'(?<!Pdf)Colors\.black26', 'AppColors.onSurface.withValues(alpha: 0.26)'),
    (r'(?<!Pdf)Colors\.black54', 'AppColors.onSurface.withValues(alpha: 0.54)'),
    (r'(?<!Pdf)Colors\.black\s*\.withValues\(\s*alpha:\s*0\.4\s*\)', 'AppColors.onSurface.withValues(alpha: 0.4)'),
    (r'(?<!Pdf)Colors\.black\s*\.withValues\(\s*alpha:\s*0\.15\s*\)', 'AppColors.onSurface.withValues(alpha: 0.15)'),
]

for root_dir, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root_dir, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = content
            for pattern, repl in replacements:
                new_content = re.sub(pattern, repl, new_content)
                
            if new_content != content:
                # Calculate relative depth to lib/core
                depth = filepath.replace('\\', '/').count('/') - 1
                prefix = '../' * (depth - 1) if depth > 1 else ''
                
                if 'AppRadii' in new_content and 'app_radii.dart' not in new_content:
                    import_stmt = f"import '{prefix}core/theme/app_radii.dart';\n"
                    new_content = re.sub(r'(import .*;\n)', r'\1' + import_stmt, new_content, count=1)
                if 'AppColors' in new_content and 'app_colors.dart' not in new_content:
                    import_stmt = f"import '{prefix}core/theme/app_colors.dart';\n"
                    new_content = re.sub(r'(import .*;\n)', r'\1' + import_stmt, new_content, count=1)
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
