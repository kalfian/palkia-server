import os

# Define where to look
base_dirs = ["homarr", "portainer", "pihole", "uptime-kuma"]

def generate_tree():
    lines = ["## 📁 Folder Structure\n"]
    for d in sorted(base_dirs):
        lines.append(f"- `{d}/`")
        compose_path = os.path.join(d, "docker-compose.yml")
        if os.path.exists(compose_path):
            lines.append(f"  - `docker-compose.yml`")
    return "\n".join(lines)

def replace_in_readme(tree_text):
    with open("README.md", "r") as f:
        content = f.read()

    start = "## 📁 Folder Structure"
    end = "\n##" if "## " in content.replace(start, "", 1) else "\n---"

    pre = content.split(start)[0].rstrip()
    post = content.split(end, 1)[-1].lstrip() if end in content else ""

    new_content = f"{pre}\n{tree_text}\n\n---\n{post}"
    with open("README.md", "w") as f:
        f.write(new_content)

tree = generate_tree()
replace_in_readme(tree)

