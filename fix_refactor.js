const fs = require('fs');
const path = require('path');

const directory = 'lib/features';

const replacements = [
    [/BorderAppRadii\.sm/g, 'AppRadii.borderSm'],
    [/BorderAppRadii\.defaultRadius/g, 'AppRadii.borderDefault'],
    [/BorderAppRadii\.md/g, 'AppRadii.borderMd'],
    [/BorderAppRadii\.lg/g, 'AppRadii.borderLg'],
    [/BorderAppRadii\.xl/g, 'AppRadii.borderXl'],
    
    // Fix parameter types (e.g. topLeft: AppRadii.lg -> topLeft: Radius.circular(AppRadii.lg))
    [/(topLeft|topRight|bottomLeft|bottomRight):\s*AppRadii\.(sm|defaultRadius|md|lg|xl)/g, '$1: Radius.circular(AppRadii.$2)'],
    [/(topLeft|topRight|bottomLeft|bottomRight):\s*const AppRadii\.(sm|defaultRadius|md|lg|xl)/g, '$1: Radius.circular(AppRadii.$2)'],

    // Fix const method invocations (boxShadow)
    [/const\s+\[\s*BoxShadow\(\s*color:\s*AppColors\.primaryContainer\.withValues/g, '[ BoxShadow(color: AppColors.primaryContainer.withValues'],
    [/const\s+BoxShadow\(\s*color:\s*AppColors\.primaryContainer\.withValues/g, 'BoxShadow(color: AppColors.primaryContainer.withValues'],
    
    // Fix shade100 called on AppColors
    [/AppColors\.warning\.shade100/g, 'AppColors.warningContainer'],
    
    // Fix const Icons/Widgets with .withValues() method calls
    [/const\s+Icon\([^,]+,\s*color:\s*AppColors\.[a-zA-Z]+\.withValues\([^\)]+\)/g, (match) => match.replace('const ', '')],
    [/const\s+CircleAvatar\(\s*backgroundColor:\s*AppColors\.[a-zA-Z]+\.withValues/g, 'CircleAvatar(backgroundColor: AppColors.onSurface.withValues'],
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
    
    // Special fix for search_results_screen.dart & search_screen.dart for missing const removals
    // For `border: Border.all(...)` inside const BoxDecoration or similar where Radius is used
    newContent = newContent.replace(/const\s+BorderRadius\.only\(/g, 'BorderRadius.only(');
    newContent = newContent.replace(/const\s+BorderRadius\.all\(/g, 'BorderRadius.all(');
    
    // If we removed const from BorderRadius, we might have left a const on the parent BoxDecoration that now contains a non-const BorderRadius (because AppRadii isn't const? AppRadii variables are const, but Radius.circular(...) is not always const if we use const in the wrong place? Wait, AppRadii.borderLg is a const. So `const AppRadii.borderLg` is fine. But `Radius.circular(AppRadii.lg)` is const if we prefix it with const. The analyzer said:
    // A value of type 'double' can't be assigned to a parameter of type 'Radius' in a const constructor.
    // If we change it to Radius.circular(AppRadii.lg) it might still complain if we didn't add const to Radius.circular. Actually, Radius.circular is a const constructor. So `const Radius.circular(...)` is valid.
    
    // Also, search_results_screen.dart:371 "Use 'const' with the constructor to improve performance" on Icon(Icons.search_off...)
    newContent = newContent.replace(/Icon\(Icons\.search_off,\s*size:\s*64\.0,\s*color:\s*AppColors\.outlineVariant\)/g, 'const Icon(Icons.search_off, size: 64.0, color: AppColors.outlineVariant)');
    newContent = newContent.replace(/Icon\(Icons\.favorite_border,\s*color:\s*Colors\.white\)/g, 'const Icon(Icons.favorite_border, color: Colors.white)');

    if (newContent !== content) {
        fs.writeFileSync(filepath, newContent, 'utf8');
        console.log(`Updated ${filepath}`);
    }
});
