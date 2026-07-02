const fs = require('fs');
const path = require('path');

const directory = 'lib/features';

const replacements = [
    [/const Color\(0xFFFFE0B2\)/g, 'AppColors.warningContainer'],
    [/const Color\(0xFFECF5FE\)/g, 'AppColors.surfaceContainerLow'],
    [/Color\(0x0D002349\)/g, 'AppColors.primaryContainer.withValues(alpha: 0.05)'],
    
    [/Radius\.circular\(\s*4(?:\.0)?\s*\)/g, 'AppRadii.sm'],
    [/Radius\.circular\(\s*8(?:\.0)?\s*\)/g, 'AppRadii.defaultRadius'],
    [/Radius\.circular\(\s*12(?:\.0)?\s*\)/g, 'AppRadii.md'],
    [/Radius\.circular\(\s*16(?:\.0)?\s*\)/g, 'AppRadii.lg'],
    [/Radius\.circular\(\s*24(?:\.0)?\s*\)/g, 'AppRadii.xl'],
    
    [/BorderRadius\.circular\(\s*4(?:\.0)?\s*\)/g, 'AppRadii.borderSm'],
    [/BorderRadius\.circular\(\s*8(?:\.0)?\s*\)/g, 'AppRadii.borderDefault'],
    [/BorderRadius\.circular\(\s*12(?:\.0)?\s*\)/g, 'AppRadii.borderMd'],
    [/BorderRadius\.circular\(\s*16(?:\.0)?\s*\)/g, 'AppRadii.borderLg'],
    [/BorderRadius\.circular\(\s*24(?:\.0)?\s*\)/g, 'AppRadii.borderXl'],
    
    [/(?<!Pdf)Colors\.red/g, 'AppColors.error'],
    [/(?<!Pdf)Colors\.green/g, 'AppColors.success'],
    [/(?<!Pdf)Colors\.amber/g, 'AppColors.warning'],
    [/(?<!Pdf)Colors\.grey\.shade400/g, 'AppColors.outlineVariant'],
    [/(?<!Pdf)Colors\.grey\.shade600/g, 'AppColors.outline'],
    [/(?<!Pdf)Colors\.grey\.shade100/g, 'AppColors.surfaceContainerHigh'],
    [/(?<!Pdf)Colors\.black26/g, 'AppColors.onSurface.withValues(alpha: 0.26)'],
    [/(?<!Pdf)Colors\.black54/g, 'AppColors.onSurface.withValues(alpha: 0.54)'],
    [/(?<!Pdf)Colors\.black\s*\.withValues\(\s*alpha:\s*0\.4\s*\)/g, 'AppColors.onSurface.withValues(alpha: 0.4)'],
    [/(?<!Pdf)Colors\.black\s*\.withValues\(\s*alpha:\s*0\.15\s*\)/g, 'AppColors.onSurface.withValues(alpha: 0.15)']
];

function walkDir(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach((file) => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat && stat.isDirectory()) {
            results = results.concat(walkDir(fullPath));
        } else if (file.endsWith('.dart')) {
            results.push(fullPath);
        }
    });
    return results;
}

const files = walkDir(directory);
files.forEach(filepath => {
    let content = fs.readFileSync(filepath, 'utf8');
    let newContent = content;
    
    replacements.forEach(([regex, repl]) => {
        newContent = newContent.replace(regex, repl);
    });
    
    if (newContent !== content) {
        // Fix imports
        const normalizedPath = filepath.replace(/\\/g, '/');
        const depth = normalizedPath.split('/').length - 1;
        // lib/features/... -> depth is at least 2. (lib, features, file = depth 2)
        // lib/features/explore/file.dart -> depth 3.
        // We want to go back `depth - 1` times to reach `lib`.
        const prefix = depth > 1 ? '../'.repeat(depth - 1) : '';
        
        if (newContent.includes('AppRadii') && !newContent.includes('app_radii.dart')) {
            const importStmt = `import '${prefix}core/theme/app_radii.dart';\n`;
            newContent = newContent.replace(/(import .*;\n)/, `$1${importStmt}`);
        }
        if (newContent.includes('AppColors') && !newContent.includes('app_colors.dart')) {
            const importStmt = `import '${prefix}core/theme/app_colors.dart';\n`;
            newContent = newContent.replace(/(import .*;\n)/, `$1${importStmt}`);
        }
        
        fs.writeFileSync(filepath, newContent, 'utf8');
        console.log(`Updated ${filepath}`);
    }
});
