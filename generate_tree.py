import os

def generate_tree():
    lines = []
    lines.append("## 📁 Folder Structure\n")
    lines.append("```")
    lines.append("palkia-stack/")

    for name in sorted(os.listdir(".")):
        path = os.path.join(".", name)
        if os.path.isdir(path) and not name.startswith(".") and name != ".github":
            lines.append(f"├── {name}/")
            compose_path = os.path.join(name, "docker-compose.yml")
            if os.path.exists(compose_path):
                lines.append(f"│   └── docker-compose.yml")
            lines.append("│")

    lines.append("├── generate_tree.py")
    lines.append("├── .gitignore")
    lines.append("└── README.md")
    lines.append("```")
    return "\n".join(lines)

def replace_in_readme(tree_text):
    start_tag = "<!-- FOLDER_TREE_START -->"
    end_tag = "<!-- FOLDER_TREE_END -->"

    with open("README.md", "r") as f:
        content = f.read()

    if start_tag not in content or end_tag not in content:
        print("Marker tags not found in README.md")
        return

    pre = content.split(start_tag)[0]
    post = content.split(end_tag)[-1]

    new_block = f"{start_tag}\n{tree_text}\n{end_tag}"
    new_content = pre + new_block + post

    with open("README.md", "w") as f:
        f.write(new_content)

tree = generate_tree()
replace_in_readme(tree)

