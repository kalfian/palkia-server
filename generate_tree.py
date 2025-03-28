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
    with open("README.md", "r") as f:
        content = f.read()

    start = "## 📁 Folder Structure"
    end = "\n##" if "\n##" in content.replace(start, "", 1) else "\n---"

    pre = content.split(start)[0].rstrip()
    post = content.split(end, 1)[-1].lstrip() if end in content else ""

    new_content = f"{pre}\n{tree_text}\n\n---\n{post}"
    with open("README.md", "w") as f:
        f.write(new_content)

tree = generate_tree()
replace_in_readme(tree)

