#!/usr/bin/env python3
"""
Git Agent - автоматичне керування git з осмисленими commit повідомленнями.

Використання:
    python git_agent.py              # Перевірити статус і зробити commit якщо є зміни
    python git_agent.py --status     # Тільки показати статус
    python git_agent.py --push       # Commit + push
    python git_agent.py --auto       # Автоматичний режим (commit + push без підтвердження)
"""

import subprocess
import sys
import os

# Fix encoding for Windows console
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# Перейти в корінь проекту
PROJECT_ROOT = Path(__file__).parent.parent
os.chdir(PROJECT_ROOT)


def run_git(args: list[str], capture=True) -> tuple[int, str]:
    """Виконати git команду."""
    cmd = ['git'] + args
    if capture:
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode, result.stdout + result.stderr
    else:
        result = subprocess.run(cmd)
        return result.returncode, ""


def get_status() -> dict:
    """Отримати статус git репозиторію."""
    code, output = run_git(['status', '--porcelain'])
    
    changes = {
        'staged': [],      # Готові до commit
        'modified': [],    # Змінені, але не staged
        'untracked': [],   # Нові файли
        'deleted': [],     # Видалені
    }
    
    for line in output.strip().split('\n'):
        if not line:
            continue
        status = line[:2]
        filename = line[3:]
        
        # Перший символ - staged статус, другий - робоча директорія
        if status[0] in ('M', 'A', 'D', 'R'):
            changes['staged'].append(filename)
        if status[1] == 'M':
            changes['modified'].append(filename)
        elif status[1] == 'D':
            changes['deleted'].append(filename)
        elif status == '??':
            changes['untracked'].append(filename)
    
    return changes


def get_diff_stats() -> dict:
    """Отримати статистику змін."""
    code, output = run_git(['diff', '--stat', '--cached'])
    staged_stats = output
    
    code, output = run_git(['diff', '--stat'])
    unstaged_stats = output
    
    return {
        'staged': staged_stats,
        'unstaged': unstaged_stats
    }


def categorize_changes(files: list[str]) -> dict:
    """Категоризувати зміни за типом/папкою."""
    categories = defaultdict(list)
    
    for f in files:
        path = Path(f)
        parts = path.parts
        
        if 'lib' in parts:
            if 'features' in parts:
                idx = parts.index('features')
                if idx + 1 < len(parts):
                    categories[f'feature/{parts[idx+1]}'].append(f)
                else:
                    categories['features'].append(f)
            elif 'core' in parts:
                if 'models' in parts:
                    categories['models'].append(f)
                elif 'services' in parts:
                    categories['services'].append(f)
                elif 'constants' in parts:
                    categories['constants'].append(f)
                else:
                    categories['core'].append(f)
            else:
                categories['lib'].append(f)
        elif 'assets' in parts:
            categories['assets'].append(f)
        elif 'res' in parts:
            if 'tools' in parts:
                categories['tools'].append(f)
            elif 'reports' in parts:
                categories['docs'].append(f)
            else:
                categories['resources'].append(f)
        elif 'scripts' in parts:
            categories['scripts'].append(f)
        elif 'test' in parts:
            categories['tests'].append(f)
        elif path.suffix in ('.yaml', '.yml', '.json', '.xml'):
            categories['config'].append(f)
        elif path.name in ('.gitignore', 'README.md', 'CHANGELOG.md'):
            categories['meta'].append(f)
        else:
            categories['other'].append(f)
    
    return dict(categories)


def generate_commit_message(changes: dict) -> str:
    """Згенерувати осмислене commit повідомлення."""
    all_files = changes['staged'] + changes['modified'] + changes['untracked']
    deleted = changes['deleted']
    
    if not all_files and not deleted:
        return None
    
    categories = categorize_changes(all_files + deleted)
    
    # Визначити основну категорію
    main_category = max(categories.keys(), key=lambda k: len(categories[k])) if categories else 'misc'
    
    # Визначити тип зміни
    if deleted and not all_files:
        change_type = 'remove'
    elif changes['untracked'] and not changes['modified'] and not changes['staged']:
        change_type = 'add'
    elif len(categories) == 1 and 'config' in categories:
        change_type = 'config'
    elif 'tests' in categories:
        change_type = 'test'
    elif 'docs' in categories:
        change_type = 'docs'
    else:
        change_type = 'update'
    
    # Побудувати повідомлення
    prefixes = {
        'feature/menu': 'feat(menu)',
        'feature/game': 'feat(game)',
        'feature/level_select': 'feat(level-select)',
        'models': 'feat(models)',
        'services': 'feat(services)',
        'constants': 'refactor(constants)',
        'core': 'refactor(core)',
        'lib': 'feat',
        'assets': 'assets',
        'tools': 'tools',
        'docs': 'docs',
        'resources': 'chore(resources)',
        'scripts': 'chore(scripts)',
        'tests': 'test',
        'config': 'config',
        'meta': 'chore',
        'other': 'chore',
    }
    
    prefix = prefixes.get(main_category, 'chore')
    
    # Згенерувати опис
    total_files = len(all_files) + len(deleted)
    
    if total_files == 1:
        single_file = (all_files + deleted)[0]
        filename = Path(single_file).name
        if change_type == 'add':
            description = f"add {filename}"
        elif change_type == 'remove':
            description = f"remove {filename}"
        else:
            description = f"update {filename}"
    else:
        # Опис за категоріями
        parts = []
        for cat, files in sorted(categories.items(), key=lambda x: -len(x[1])):
            if len(files) == 1:
                parts.append(Path(files[0]).name)
            else:
                parts.append(f"{cat} ({len(files)} files)")
        
        if len(parts) > 3:
            description = f"{', '.join(parts[:2])} and {len(parts)-2} more areas"
        else:
            description = ', '.join(parts)
    
    return f"{prefix}: {description}"


def print_status(changes: dict, diff_stats: dict):
    """Вивести статус репозиторію."""
    print("\n" + "="*60)
    print("📊 GIT STATUS")
    print("="*60)
    
    has_changes = any(changes.values())
    
    if not has_changes:
        print("\n✅ Робоча директорія чиста - немає змін для commit")
        return False
    
    if changes['staged']:
        print(f"\n📦 Staged ({len(changes['staged'])} files):")
        for f in changes['staged'][:10]:
            print(f"   ✓ {f}")
        if len(changes['staged']) > 10:
            print(f"   ... і ще {len(changes['staged'])-10} файлів")
    
    if changes['modified']:
        print(f"\n📝 Modified ({len(changes['modified'])} files):")
        for f in changes['modified'][:10]:
            print(f"   ~ {f}")
        if len(changes['modified']) > 10:
            print(f"   ... і ще {len(changes['modified'])-10} файлів")
    
    if changes['untracked']:
        print(f"\n🆕 Untracked ({len(changes['untracked'])} files):")
        for f in changes['untracked'][:10]:
            print(f"   + {f}")
        if len(changes['untracked']) > 10:
            print(f"   ... і ще {len(changes['untracked'])-10} файлів")
    
    if changes['deleted']:
        print(f"\n🗑️ Deleted ({len(changes['deleted'])} files):")
        for f in changes['deleted'][:10]:
            print(f"   - {f}")
        if len(changes['deleted']) > 10:
            print(f"   ... і ще {len(changes['deleted'])-10} файлів")
    
    return True


def stage_all():
    """Додати всі зміни до stage."""
    run_git(['add', '-A'])


def commit(message: str) -> bool:
    """Зробити commit."""
    code, output = run_git(['commit', '-m', message])
    if code == 0:
        print(f"\n✅ Commit створено: {message}")
        return True
    else:
        print(f"\n❌ Помилка commit: {output}")
        return False


def push() -> bool:
    """Push до remote."""
    print("\n⬆️ Pushing to remote...")
    code, output = run_git(['push'])
    if code == 0:
        print("✅ Push успішний!")
        return True
    else:
        print(f"❌ Помилка push: {output}")
        # Спробувати з --set-upstream
        code, output = run_git(['push', '--set-upstream', 'origin', 'main'])
        if code == 0:
            print("✅ Push успішний (з set-upstream)!")
            return True
        return False


def get_unpushed_commits() -> list:
    """Отримати список непушнутих комітів."""
    code, output = run_git(['log', 'origin/main..HEAD', '--oneline'])
    if code == 0 and output.strip():
        return output.strip().split('\n')
    return []


def main():
    args = sys.argv[1:]
    
    status_only = '--status' in args
    do_push = '--push' in args
    auto_mode = '--auto' in args
    
    print("\n🤖 Git Agent v1.0")
    print(f"📁 Project: {PROJECT_ROOT}")
    print(f"🕐 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Перевірити чи це git репозиторій
    code, _ = run_git(['rev-parse', '--git-dir'])
    if code != 0:
        print("\n❌ Це не git репозиторій!")
        return 1
    
    # Отримати статус
    changes = get_status()
    diff_stats = get_diff_stats()
    
    has_changes = print_status(changes, diff_stats)
    
    # Перевірити непушнуті коміти
    unpushed = get_unpushed_commits()
    if unpushed:
        print(f"\n📤 Непушнуті коміти ({len(unpushed)}):")
        for c in unpushed[:5]:
            print(f"   • {c}")
        if len(unpushed) > 5:
            print(f"   ... і ще {len(unpushed)-5}")
    
    if status_only:
        return 0
    
    if not has_changes and not unpushed:
        print("\n✨ Все синхронізовано з remote!")
        return 0
    
    # Якщо є зміни - commit
    if has_changes:
        message = generate_commit_message(changes)
        if message:
            print(f"\n💬 Згенероване повідомлення: {message}")
            
            if not auto_mode:
                response = input("\n📝 Прийняти це повідомлення? [Y/n/edit]: ").strip().lower()
                if response == 'n':
                    print("Скасовано.")
                    return 0
                elif response == 'edit' or response == 'e':
                    message = input("Введіть своє повідомлення: ").strip()
                    if not message:
                        print("Скасовано.")
                        return 0
            
            # Stage all changes
            stage_all()
            
            # Commit
            if not commit(message):
                return 1
    
    # Push якщо потрібно
    if do_push or auto_mode:
        if not push():
            return 1
    elif unpushed or has_changes:
        if not auto_mode:
            response = input("\n⬆️ Зробити push? [Y/n]: ").strip().lower()
            if response != 'n':
                if not push():
                    return 1
    
    print("\n" + "="*60)
    print("✨ Готово!")
    print("="*60 + "\n")
    
    return 0


if __name__ == '__main__':
    sys.exit(main())

